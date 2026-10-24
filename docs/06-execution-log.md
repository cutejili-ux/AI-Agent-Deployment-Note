# 06 — Actual deployment execution log

**State: LOCAL PHASE LIMITED PASS — executed 2026-10-24, Australia/Brisbane.**

Hermes + Ollama are installed and local chat works. File tools executed, but the 4B model failed exact-format and correction tests. Full POC acceptance is not achieved: Successful Gemini inference is blocked by Google HTTP 503; long-context stress, actual uninstall/reinstall, and upstream dependency remediation remain untested or unresolved. The operator accepted the local phase with these recorded limitations and authorized GitHub publication and the next manual Gemini stage. This acceptance does not change the measured test results.

## Environment and provenance

| Field | Observed value |
| --- | --- |
| Execution window | Approximately 20:12–20:26 +10:00, 2026-10-24 |
| Hardware | Mac mini, Apple M6, 16 GiB RAM, arm64; identifying fields omitted |
| macOS | 27.0.1, build 26A434 |
| Disk available | 92 GiB before; 84 GiB after installation/tests |
| Git / developer tools | 2.54.0 (Apple Git-157); existing Xcode developer tools |
| Notes source commit | 2f9f57459e7f56b3722c41e7dc806bba68567822 |
| Ollama | 0.40.10, official macOS app; user-owned CLI symlink |
| Hermes | v0.22.5, stable, commit bf0203a794a07aac3ff764972ab9087baa4e4f4e |
| Runtime | Managed Python 3.14.9, OpenAI SDK 2.24.0, uv 0.13.5 |
| Base model digest | qwen3.5:4b — 7f3251fa6878a78a606bcb3c074283306e5ad2ea411a7774a9dd98a4bc7f2d13 |
| Derived model digest | qwen3.5-4b-64k:latest — 87155d193d0f4125cb81653a5da4c40945740e57715e88b62025a422dbb4790c |
| Model format / size | safetensors, nvfp4, MLX runner; approximately 4.0 GB shared weights |
| Inference endpoint | http://127.0.0.1:11434/v1 |
| Context | 65536 in Modelfile, Hermes config, and `ollama ps` |
| Gemini / fallback | Phase 1: no key. Phase 2: local key mode 0600, live catalog HTTP 200, two Flash trials HTTP 503; fallback list remains empty |

## Results

| ID | Result | Evidence / limit |
| --- | --- | --- |
| T00/T01, G0 | PASS | Hardware/OS/disk verified; Git and existing Xcode tools work |
| T02 | PASS | CLI 0.40.10; loopback `/api/tags` HTTP 200; Apple M6 Metal detected |
| T03 | PASS | Base/derived tags exist; derived Modelfile declares num_ctx 65536 |
| T04, G1 | LIMITED PASS | Short prompt runs with actual 65536 context and 100% GPU; full-window stress and GUI memory-pressure observations not performed |
| T05 | LIMITED PASS | Installation, launcher, config check pass; doctor exits 1 due to npm dependency vulnerability findings |
| T06 | PASS | HERMES_LOCAL_OK in 6s; 17 + 25 → 42 in 3s; matching loopback `/v1/chat/completions` HTTP 200 |
| T07, G2 | LIMITED / strict test FAIL | File created and read, independently verified; missing requested newline; correction attempt used an invalid path and claimed success despite failure |
| T08 | PARTIAL | Explicit local route and corresponding Ollama requests observed; no Gemini key/fallback configured; no packet-level audit or Google dashboard check |
| T09, G3 | BLOCKED | Native Gemini routing observed; 3.7 and 3.8 Flash inference returned HTTP 503; no successful reply or billing corroboration |
| T10 | PARTIAL | Missing key correctly rejects execution, but CLI shows generic failure; backend logs identify missing credentials; original key restored |
| T11, G4 | NOT STARTED | Optional fallback disabled |
| T12 | PASS | Stopped/restarted only POC Ollama; Hermes returned RECOVERY_OK in 5s using the same local default |
| T13 | PARTIAL | `hermes uninstall --dry-run` exit 0; no destructive uninstall performed |
| T14, G5 | NOT STARTED | Actual removal/reinstallation not authorized/performed |
| T15, G6 | PASS for local evidence publication | Sanitized local-phase docs published in 9ba199fa804e5823560c402e49f0c06db39837ce; subsequent phase evidence follows in Git history |

## Installation commands and incidents

1. Inspected `uname -m`, `sw_vers`, `sysctl -n hw.memsize hw.model`, non-identifying `system_profiler SPHardwareDataType` fields, `df -h /`, `xcode-select -p`, and `git --version`. No prerequisites reinstalled.
2. Cloned the user's notes repository. Sandbox DNS resolution failed (exit 128); authorized normal network execution succeeded (exit 0). Hardware sysctl likewise required leaving the restricted sandbox.
3. Downloaded and inspected official scripts:
   - `https://ollama.com/install.sh`, SHA-256 `25f64b810b947145095956533e1bdf56eacea2673c55a7e586be4515fc882c9f`.
   - `https://hermes-agent.nousresearch.com/install.sh`, SHA-256 `abf338605dae6dd28d101673ac6aed7995c955745db46d47676bc591a7957209`.
4. Ran `OLLAMA_NO_START=1 sh /tmp/ollama-install.sh`. App installation succeeded; system CLI symlink creation exited 1 because sudo required an interactive password. Created only the user-owned `~/.local/bin/ollama` symlink to `/Applications/Ollama.app/Contents/Resources/ollama`; no sudo password supplied.
5. Started `OLLAMA_HOST=127.0.0.1:11434 OLLAMA_NO_CLOUD=1 ~/.local/bin/ollama serve`. Verified loopback listener and endpoint. No launchd service or login item added by this workflow.
6. `ollama pull qwen3.5:4b` and `ollama create qwen3.5-4b-64k -f config/Modelfile.qwen3.5-4b-64k` both succeeded (exit 0); no other models downloaded.
7. Official Hermes minimal install: `bash /tmp/hermes-install.sh --skip-setup --skip-browser --skip-computer-use`. The initial blobless historical clone was slow and was intentionally terminated. Downloaded the same official stable release with `git clone --depth 1 --branch v0.22.5 https://github.com/NousResearch/hermes-agent.git ~/.hermes/hermes-agent`, then reran the same official installer successfully (exit 0). Incomplete initial staging checkout was left untouched; no user data deleted.
8. Installer prepared its managed runtimes/dependencies, CLI, TUI/web build products and shell PATH entries in `.zshrc`/`.zprofile`. Browser and computer-use payloads were skipped; desktop app and messaging integration setup were not requested.
9. Preserved the generated config locally as `config.yaml.pre-local-poc`, then set local custom provider, context_length/ollama_num_ctx 65536, scratch terminal cwd, CLI terminal/file toolsets, max_turns 5, empty fallback list, external login adoption off, auxiliary titles/compression off for short POC tests, built-in memories off, passive update checks off and telemetry off. `hermes curator pause` succeeded. Credentials remain outside Git; no keys were supplied.
10. `hermes --help`, `hermes --version`, and `hermes config check` work. `hermes doctor` exits 1: root npm and web workspace each report 1 high finding; TUI workspace reports 1 high and 1 moderate. Counts can overlap across workspaces. Doctor calls for an upstream lockfile fix; no ad-hoc lockfile changes were made. Missing optional browser/container/cloud integrations are expected for this profile. Doctor also performed public connectivity probes, including OpenRouter; these are distinct from model inference and mean this was not a zero-outbound-network audit.
11. CLI tests automatically started a temporary internal gateway (`gateway run --quiet --idle-exit`) on a random loopback port. This was CLI transport, with no messaging gateway credentials or launchd service. After tests, `hermes gateway stop` succeeded and status confirmed it was not running. A future CLI invocation may start this internal transport again.

## Actual test observations

### Model-only smoke

`/api/generate` with the derived tag, `think: false`, and a harmless LOCAL_OK prompt returned `LOCAL_OK`, HTTP 200, total_duration 4.735s, load_duration 2.409s, prompt processing 1.733s, generation 0.110s (2 tokens). `ollama ps` reported actual context 65536, 100% GPU, MLX, around 4.1 GB resident at first observation. This is not a 64K-token input stress test.

### Hermes chat and tool test

- `hermes chat --oneshot --max-turns 3 --run-budget 120 --reasoning none -q 'Reply exactly: HERMES_LOCAL_OK'`: exit 0, correct answer, 6s, no tool calls.
- Same command form for `17 + 25`: exit 0, `42`, 3s, no tool calls.
- File test used `--toolsets file`, max_turns 5 and a 120s budget. Requested one file containing `HERMES_TOOL_OK` plus newline, followed by a read. Tool trace showed write/read; independent Python inspection found exactly `b'HERMES_TOOL_OK'` (14 bytes), without the requested newline. Command exited 0, duration 6s; strict content assertion failed. Exit 0 is therefore not proof of task correctness.
- One correction attempt (max_turns 3) used a malformed relative path, exhausted the iteration budget and claimed the newline was present. Hermes' mutation verifier explicitly reported the failed edit. Independent inspection confirmed the file was unchanged. Duration 8s, process exit 0, task FAIL.
- Removed only this POC-created test file after inspection. Scratch folder retained.
- Restarted the POC Ollama process with identical loopback/cloud-off settings; Hermes returned `RECOVERY_OK` in 5s, exit 0. Local model/context unchanged.

### Resource observations

- Swap before installation: 0.25 MiB used.
- After first model load during installation: 687.31 MiB swap used; system-wide free memory 32%.
- After tool tests: 977.75 MiB swap used; free memory 32%; `ollama ps` about 5.1 GB GPU memory.
- After recovery: 1234.44 MiB swap used; free memory 37%; model about 4.2 GB, context 65536, 100% GPU.
- Server-reported inference peaks included 3.85 GiB for initial short model test and 5.41 GiB for first Hermes prompt. System figures include other applications and concurrent installation work; no causal attribution or long-context stability claim is made.
- No observed OOM/process kill during short tests. Activity Monitor Memory Pressure and sustained long-context behavior still need operator evaluation.

## Removal preview and final state

`hermes uninstall --dry-run` succeeded and explicitly reported no changes. Preview covered gateway processes/services, Hermes PATH entries/wrappers, managed node/npm/npx links, desktop artifacts and the source checkout, while retaining `~/.hermes` config/data. Nothing was uninstalled.

Ollama is left running as a foreground POC session process on loopback; it is not configured to start at login. Model memory unloads after its normal idle timeout. Hermes config and launcher remain available; internal CLI gateway was stopped. Raw installer/server/chat/diagnostic logs remain outside this public repository in local temporary storage and may be cleared by macOS.

## Next checkpoints

- Use local chat for the initial POC. Treat file edits as unverified until independently checked; exact-byte and path handling failed with this 4B model.
- Observe sustained 64K context memory pressure before accepting G1 fully.
- Review upstream dependency fixes before broader exposure or production use.
- Operator approved the local phase and manual Gemini stage. Key setup/catalog succeeded; successful Gemini inference needs a later explicit retest after vendor 503s clear. Keep fallback off.
- Actual uninstall/reinstall remain separate, pending steps. Sanitized evidence publication is authorized.


## Phase 2 — approved manual Gemini tests (2026-10-24)

### Authorization and secret handling

- Operator accepted the local phase and explicitly authorized GitHub publication plus the next stage. The measured local limitations were retained, not relabeled PASS.
- Local-phase publication succeeded: commit `9ba199fa804e5823560c402e49f0c06db39837ce` on origin/main.
- Operator entered the Google AI Studio key using a native macOS hidden-answer dialog. A helper captured it privately and atomically saved only the local `~/.hermes/.env` with mode 0600. No key was placed in chat, shell arguments, repository content, or public evidence.
- Set the native `GEMINI_BASE_URL=https://generativelanguage.googleapis.com/v1beta`; the main model/default stayed custom Ollama.

### Catalog and explicit cloud trials

- 20:34:45 +10:00 / 10:34:45 UTC: authenticated native `GET /v1beta/models?pageSize=1000`, key supplied through an HTTP header, returned HTTP 200.
- Intersected Google's live generateContent models with the installed Hermes selector list. Available entries included `gemini-3.7-flash` and `gemini-3.8-flash`; model IDs were observed, not guessed.
- First explicit invocation requested `gemini-3.7-flash`, native Google base URL, harmless prompt `Answer with exactly GEMINI_OK. Do not use tools.`, max_turns 1 and run_budget 90. Logs confirmed `provider=gemini`, the native Google host and exact model. Google returned HTTP 503 UNAVAILABLE/high demand; Hermes' default internal recovery logic continued beyond the desired wall-clock budget. The outer harness timed out after 120s and the sole test gateway was deliberately stopped with `hermes gateway stop --yes` to terminate its active recovery. No successful response was observed.
- To bound further POC retries, preserved the previous config locally as `config.yaml.pre-gemini-poc`, set `agent.api_max_retries: 1`, `agent.auto_recovery_cycles: 0`, and Gemini request/stale timeouts to 20/25 seconds. Main model/default and empty fallback list were retained. These caps remain in the POC profile.
- 20:37:53 +10:00 / 10:37:53 UTC: made one explicit second-model trial with catalog-verified `gemini-3.8-flash`, same endpoint and synthetic prompt. This was an intentional manual switch, not automatic fallback. Command exited 1 after 30.37s; Google again returned HTTP 503 high demand. No GEMINI_OK reply. No additional model trials were made.
- The second invocation did not alter config (verified by before/after SHA-256 equality; digest itself not published).
- The session store recorded model `gemini-3.8-flash`, zero successful api_call_count/token counts, empty per-model usage and null billing fields. Logs establish attempted provider routing; these counters do NOT establish zero Google billing. Google dashboard usage/quota/cost verification remains pending.

### Missing-key experiment (T10 PARTIAL)

- Stopped the prior temporary gateway so credentials could not be inherited from that process.
- Temporarily removed only Gemini/Google key entries from the local dotenv file and subprocess environment; made one explicit Gemini invocation; restored the original dotenv bytes atomically in a finally block and removed the private temporary backup. Restoration and mode 0600 were verified.
- The command exited 1 in about 1s, before model inference, with no alternate-provider response. Backend log: `ProviderNotConfiguredError: Provider 'gemini' ... no API key was found`. CLI only showed a generic model-request failure, so the clear user-facing-error acceptance condition did not fully pass.

### Post-cloud local recovery

- Stopped the keyless-test gateway, then ran an ordinary Hermes one-shot without provider/model overrides.
- Returned `LOCAL_STILL_OK`, exit 0, duration 7s, no tool calls. Session metadata recorded `model=qwen3.5-4b-64k`, `billing_provider=custom`, `billing_base_url=http://127.0.0.1:11434/v1`, one call, 4863 input tokens and 4 output tokens.
- Verified local default/context settings retained, fallback list empty, Gemini key present locally and dotenv mode 0600. No Telegram/Discord integration, launchd gateway, automatic provider fallback or billing-plan changes were configured.

### Phase 2 result

**SETUP COMPLETE; SUCCESSFUL CLOUD INFERENCE BLOCKED BY HTTP 503.** Native provider setup and attempted routing are observed. Gemini response correctness, successful token/cost attribution and Google dashboard corroboration are not proven. Local operation remains available. Do not enable fallback or claim full G3 PASS on this evidence. Retest the explicit synthetic Gemini call after the vendor becomes available; do not schedule or retry indefinitely. Raw diagnostic/credential artifacts stay outside this public repository.
