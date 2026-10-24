# 05 — Troubleshooting, update and reversible removal

**Not an execution log.** These are diagnostic paths to use when errors actually occur.

## Diagnosis map

| Symptom | Verify / response |
| --- | --- |
| git: command not found | xcode-select --install; reopen Terminal; git --version |
| hermes: command not found | Confirm source installer finished; export PATH="$HOME/.local/bin:$PATH"; command -v hermes; check ~/.hermes/logs/install.log if present |
| Hermes doctor/config error | hermes doctor; hermes config check; inspect config values without secrets; do not delete data directory to fix a code install |
| Ollama connection refused | Check app running; curl http://127.0.0.1:11434/api/tags; check duplicate service instances/port conflicts |
| local model unknown | ollama list; ollama show --modelfile qwen3.5-4b-64k; verify model name matches custom provider config |
| Hermes says minimum context not met | Verify 65536 configured in derived Modelfile and detected provider context; do not claim 2K/8K is sufficient |
| Sluggish Mac / heavy swap / process killed | Inspect Activity Monitor Memory Pressure, swap, free disk; stop local model; record; do not push to 9B/27B |
| Model returns raw tool JSON or refuses tools | Verify tool-call compatible model + endpoint and Hermes tools; record failure, do not infer filesystem changes from prose |
| API key missing or Gemini 401/403/429 | Check provider key setup without printing it; model availability; Google's API project billing/quota; avoid repeated expensive retries |
| Unexpected Gemini calls | Disable fallback, restore local provider, inspect auxiliary settings and model switches; inspect logs and Google billing |
| Failed installer / SSD exhaustion | Inspect official install log, disk free space, stable release/installer version; stop before destructive cleanup |

Useful commands:

    hermes doctor
    hermes config check
    hermes logs list
    hermes logs agent -n 100
    hermes logs errors -n 100
    ollama list
    ollama ps
    curl -fsS http://127.0.0.1:11434/api/tags
    df -h /

Before sharing logs, remove API tokens, URLs containing credentials, private prompts, file paths that identify people, and secret-bearing environment variables. Record exact errors and the **change that resolved them**.

## Update / version pinning

For a managed Hermes source installation: hermes update (after reviewing release notes and making a backup). Updates can change provider configuration, tool behavior, and supported flags. Save versions before and after, and rerun the local-only smoke tests. Never update in the middle of a failing compatibility investigation without snapshotting the current state.

For Ollama, update through the SAME install owner originally used (app, installer or Homebrew), never two methods concurrently. Model tags can move: record model digest and avoid assuming a tag is immutable.

## Hermes rollback / uninstall

First stop active chats and any gateway; for this POC the gateway should not have been enabled.

    hermes gateway status
    hermes gateway stop
    hermes uninstall --dry-run

Read the dry-run path list carefully. If data should be retained, use the normal hermes uninstall workflow and verify what it preserved. The --full option can delete user data; --data targets data but not package-owned code. Never run destructive modes without confirmed backup and explicit choice.

    hermes uninstall

Official reference: https://hermes-agent.nousresearch.com/docs/getting-started/updating

If installing Hermes Desktop instead of source code, removal differs: quit the app and move its bundle to Trash, then review separately whether user data should remain.

## Ollama model and application removal

First remove only the two POC-created model names (review ollama list before doing so):

    ollama rm qwen3.5-4b-64k
    ollama rm qwen3.5:4b
    ollama list

Ollama may share blobs across tags: do not assume removing one tag frees its full displayed size. If installed from the macOS app, quit it and uninstall through the app-owner route; if installed via Homebrew, stop and uninstall that formula via Homebrew. **Do not** delete ~/.ollama, ~/.hermes, shared Homebrew, Apple CLT, or other unrelated models unless the owner specifically approves data loss.

Check before/after:

    command -v hermes || true
    ollama list
    df -h /

## Fast redeploy design (not yet implemented)

The first deployment is manual and documented. Future wrapper must support:

- detect/verify OS + architecture + free space and required tools;
- idempotent install of Git, single Ollama owner, specified model/tag and Hermes;
- feature flags LOCAL_ONLY (default), ALLOW_GEMINI, ENABLE_FALLBACK (off);
- dry-run/check/backup/repair/update/uninstall modes;
- strict minimal permissions, local bind, no embedded secrets;
- macOS/Linux/Windows adapters tested independently;
- version manifest, transcript redaction, error/exit-code reporting and clean retry.

Do not claim quick deployment/removal on any platform until fresh-machine reinstall and uninstall tests pass.
