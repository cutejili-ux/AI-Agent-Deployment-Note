# 04 — POC test matrix and acceptance evidence

**Latest execution:** [2026-10-25 manually reinstalled native-backend validation + health check](14-validation-healthcheck-20261025-zh-TW.md). The original matrix below is unchanged; backend differences, user-skipped T13/T14, and failed/blocked cases are recorded explicitly.

**Rule:** A documented command is not evidence of execution. Mark each case PENDING / PASS / FAIL / BLOCKED, with sanitized artifacts. Never paste full Hermes config, API keys, auth/session database or sensitive messages.

| ID | What to test | How | Pass condition |
| --- | --- | --- | --- |
| T00 | Hardware and OS baseline | uname -m, sw_vers, sysctl hw.memsize, df -h / | arm64, RAM/SSD recorded, supported OS |
| T01 | Prerequisites | git --version, xcode-select -p | Git usable without unresolved prompt |
| T02 | Ollama install | ollama --version, /api/tags | CLI + loopback endpoint respond |
| T03 | Model availability | ollama list, ollama show --modelfile qwen3.5-4b-64k | Derived 4B tag exists and declares 65536 context |
| T04 | Memory and execution | ollama run (safe simple prompt); Activity Monitor; ollama ps | Loads, responds and Mac remains responsive with acceptable swap |
| T05 | Hermes install | hermes --help, hermes doctor, hermes config check | Commands succeed; no blocking config warnings |
| T06 | Hermes local chat | hermes chat --oneshot -q "Return LOCAL_OK" | Valid answer; local endpoint confirmed |
| T07 | Local tool-call behavior | Controlled create/read/remove of a text file **only** under $HOME/Projects/hermes-poc-scratch | Tool calls execute correctly in allowed folder; no other files changed |
| T08 | No accidental cloud usage | Run local prompts; check Hermes logs + Gemini dashboard | Local provider used; no related cloud calls (subject to dashboard delay) |
| T09 | Gemini on-demand | Explicit --provider gemini one-shot with a known model | Recorded actual Gemini provider, successful API response and correlated usage |
| T10 | Gemini blocked path | Remove key temporarily in secure local process; attempt explicit call | Fails clearly, no silent secret or provider substitution |
| T11 | Optional error fallback | With approval, enable fallback; interrupt local provider; restore it | Switch only on expected error; route/time/usage recorded |
| T12 | Recovery | Restart Ollama; rerun local chat | Local default restored and works |
| T13 | Uninstall and data preservation | hermes uninstall --dry-run followed by reviewed uninstall | Correct paths, appropriate data retained or removed |
| T14 | Reinstallation | Repeat documented steps after uninstall | Rebuild completes without manual guesswork |
| T15 | Git sanitization | git status and git diff --cached; secret scanning/review | No tokens, private logs, personal files, or machine-derived sensitive data |

## Measurements to capture

- Total install time; startup and first-token time; answer completion time (at least 3 local prompts).
- Mac memory pressure and swap-used before load, during first request and after unload; CPU/GPU utilization if observable.
- SSD free space before install, after model download and after uninstall.
- Model digest/tag, context setting, Ollama/Hermes/Git/macOS versions.
- Model/tool correctness for each safe prompt; error codes and sanitized traceback.
- Gemini call timestamp, model, reason, token counts if available, quota/cost evidence.
- Whether Hermes stores the actual provider attribution in a reliable inspectable log/session view.

## Tool-call test guardrails

Create $HOME/Projects/hermes-poc-scratch. Ask Hermes to create a non-sensitive text file there, read it back, and report content. Require confirmation before any tool could change files outside that directory, install software, read secrets or access network. A model response claiming to have written a file is insufficient: verify on disk separately.

## Decision thresholds

- **PASS**: T00–T09, T12, T13, T15 meet conditions; no unintended cloud usage or unsafe file access. T11 is optional.
- **LIMITED PASS**: basic local chat works, but tool use or 64K memory stability does not; precisely state limitations. Do not label full agentic success.
- **BLOCKED/FAIL**: local model cannot meet Hermes context requirement or reliably run on 16 GB; capture evidence and propose a smaller-compatible model / alternate backend / deliberate cloud-only evaluation instead of inventing a pass.

After executing, update 06-execution-log.md with real outcomes and link to the commit containing reviewed evidence.
