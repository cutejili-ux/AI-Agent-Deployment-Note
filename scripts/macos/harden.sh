#!/usr/bin/env bash
# Manual operator script: --check (default), --apply, or --rollback.
# Applies Docker tool sandbox and native web-search routing; NOT a full-Hermes container.
set -Eeuo pipefail
umask 077
MODE=--check
if [ "$#" -gt 0 ]; then MODE=$1; fi
ROOT=$(cd "$(dirname "$0")/../.." && pwd -P)
WORKSPACE="$HOME/hermes_workspace"
CFG="$HOME/.hermes/config.yaml"
BACKUPS="$HOME/.hermes/backups"
LATEST="$BACKUPS/hardening-last-backup.path"
NEW_BACKUP=
SUCCESS=0
fail() { echo "ERROR: $*" >&2; exit 1; }
on_exit() {
  rc=$?
  if [ "$MODE" = --apply ] && [ "$SUCCESS" -eq 0 ] && [ -n "$NEW_BACKUP" ] && [ -f "$NEW_BACKUP" ]; then
    echo "Configuration failed: restoring original Hermes config.yaml" >&2
    cp -p "$NEW_BACKUP" "$CFG" || true
    chmod 600 "$CFG" || true
  fi
  exit "$rc"
}
trap on_exit EXIT
case "$MODE" in
--check)
  echo "Workspace: $WORKSPACE"
  [ ! -L "$WORKSPACE" ] || fail "Workspace must not be a symlink"
  [ ! -e "$WORKSPACE" ] || ls -ld "$WORKSPACE"
  [ -f "$CFG" ] && echo 'Existing Hermes config found; content hidden' || echo 'No Hermes config found'
  command -v hermes >/dev/null 2>&1 && hermes --version || true
  command -v docker >/dev/null 2>&1 && docker version --format '{{.Client.Version}}' || true
  command -v ollama >/dev/null 2>&1 && ollama --version || true
  df -h /
  echo 'Read-only check complete. No changes.'
  ;;
--rollback)
  command -v hermes >/dev/null 2>&1 || fail 'Hermes not found'
  [ -f "$LATEST" ] || fail 'No private last-backup pointer'
  BACKUP=$(cat "$LATEST")
  case "$BACKUP" in "$BACKUPS"/hardening.*) ;; *) fail 'Backup pointer outside approved directory';; esac
  [ -f "$BACKUP" ] || fail 'Backup file missing'
  cp -p "$BACKUP" "$CFG"
  chmod 600 "$CFG"
  hermes config check
  echo 'Original Hermes config restored. Reopen Hermes; keys, models and workspace preserved.'
  ;;
--apply)
  command -v hermes >/dev/null 2>&1 || fail 'Hermes not found'
  command -v docker >/dev/null 2>&1 || fail 'Install and start Docker Desktop first'
  docker info >/dev/null 2>&1 || fail 'Docker engine not running'
  [ -f "$CFG" ] || fail 'Hermes config.yaml missing'
  [ ! -L "$WORKSPACE" ] || fail 'Workspace is a symlink'
  [ ! -e "$WORKSPACE" ] || [ -d "$WORKSPACE" ] || fail 'Workspace is not a directory'
  mkdir -p "$WORKSPACE" "$BACKUPS"
  chmod 700 "$WORKSPACE"
  if [ ! -e "$WORKSPACE/AGENTS.md" ]; then
    cp "$ROOT/policy/AGENTS.md" "$WORKSPACE/AGENTS.md"
    chmod 600 "$WORKSPACE/AGENTS.md"
  else
    echo 'Existing workspace AGENTS.md preserved; review its contents.'
  fi
  NEW_BACKUP=$(mktemp "$BACKUPS/hardening.$(date +%Y%m%d-%H%M%S).XXXXXX")
  cp -p "$CFG" "$NEW_BACKUP"
  chmod 600 "$NEW_BACKUP"
  hermes config set terminal.backend docker
  hermes config set terminal.docker_image python:3.12-slim
  hermes config set terminal.docker_mount_cwd_to_workspace false
  hermes config set terminal.docker_volumes "[\"$WORKSPACE:/workspace:rw\"]"
  hermes config set terminal.docker_forward_env '[]'
  hermes config set terminal.docker_env '{}'
  hermes config set terminal.docker_network false
  hermes config set terminal.container_cpu 2
  hermes config set terminal.container_memory 1536
  hermes config set terminal.container_persistent false
  hermes config set terminal.docker_persist_across_processes false
  hermes config set terminal.cwd /workspace
  hermes config set approvals.mode manual
  # Preserve existing approvals.deny policies; avoid replacing an operator's blocklist.
  # Docker network=none, not glob matching, controls terminal/container egress.
  hermes config set web.search_backend ddgs
  hermes config set web.extract_backend tavily
  hermes config check
  printf '%s\n' "$NEW_BACKUP" > "$LATEST"
  chmod 600 "$LATEST"
  SUCCESS=1
  echo 'Configuration saved. Restart Hermes and inspect effective Docker mounts.'
  echo 'Ensure ddgs optional dependency is installed using hermes tools; never silently fallback to local execution.'
  ;;
*) fail 'Usage: harden.sh [--check|--apply|--rollback]' ;;
esac
