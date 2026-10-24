#!/usr/bin/env bash
# Creates trial model tags, but NEVER switches Hermes default or deletes existing models.
set -Eeuo pipefail
ROOT=$(cd "$(dirname "$0")/../.." && pwd -P)
MODE=--plan
if [ "$#" -gt 0 ]; then MODE=$1; fi
command -v ollama >/dev/null 2>&1 || { echo 'Ollama missing' >&2; exit 1; }
case "$MODE" in
--plan)
  echo 'First trial: same 4B weights and temperature 0.2; leave original model intact.'
  echo 'Next optional trial: qwen2.5 7B, catalog lists 32K context vs Hermes >=64K requirement.'
  echo 'Do not download 14B on 16GB Mac. Monitor Activity Monitor memory pressure/swapping.'
  ollama list
  ;;
--build-4b)
  ollama create qwen3.5-4b-t02 -f "$ROOT/config/Modelfile.qwen3.5-4b-t02"
  ollama show --modelfile qwen3.5-4b-t02
  echo 'Trial built; existing Hermes default unchanged.'
  ;;
--build-7b)
  echo 'EXPERIMENT: 7B + 64K setting is beyond catalog listing; not proven stable.'
  ollama pull qwen2.5:7b
  ollama show qwen2.5:7b
  ollama create qwen2.5-7b-poc -f "$ROOT/config/Modelfile.qwen2.5-7b-experimental"
  ollama show --modelfile qwen2.5-7b-poc
  echo 'Trial built; existing Hermes default unchanged. Stop if memory pressure rises.'
  ;;
*) echo 'Usage: model-trials.sh [--plan|--build-4b|--build-7b]' >&2; exit 2 ;;
esac
