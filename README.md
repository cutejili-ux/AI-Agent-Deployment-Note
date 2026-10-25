# AI Agent Deployment Notes

> POC 001 — Hermes Agent + Ollama + optional Gemini on **Golden Gate** (Mac mini M6 base, Apple Silicon, 16 GB unified memory, 256 GB SSD).

**Status (2026-10-25): USER-REINSTALLED; VALIDATION NOT PASSED.** Following the earlier complete removal, the operator independently installed Hermes Desktop with native llama.cpp and tested Telegram. The latest run reuses all T00–T15 criteria, preserves Ollama-specific blockers, skips T13/T14 at the operator's instruction, and attempts T11 once in an isolated profile. See [16-case results and health check（繁體中文）](docs/14-validation-healthcheck-20261025-zh-TW.md) and [sanitized evidence](evidence/public/validation-2026-10-25-native.json). No production configuration/credential changes or application reinstall were made by this validation run; earlier removal and deployment receipts are historical.

## Objectives

1. Install and run Hermes Agent locally on Golden Gate, including prerequisite Git/Apple command-line tools.
2. Install Ollama and select a realistic small local LLM for 16 GB unified memory.
3. Keep local inference the default; permit deliberate, observable Gemini calls only when needed.
4. Make future deployment, diagnosis, upgrade and removal repeatable on clean hardware.
5. Record commands, observed results, errors, fixes and versions here **after** real execution.

**Not in scope for the first POC:** production/24×7 service, remote shell access, Telegram/Discord gateway, browser automation, MCP plugins, autonomous file changes, a large 30B–70B model, or guaranteed automatic complexity-based routing.

## Proposed flow

    User / Terminal
          |
      Hermes Agent CLI
          |
     [local by default] ------ [explicit opt-in/controlled fallback] ---> Google Gemini API
          |
     Ollama on 127.0.0.1:11434
          |
     qwen3.5-4b-64k (trial model)

Important: fallback on transport/rate-limit/API failure is NOT equivalent to automatically identifying weak reasoning. For the first POC, **no automatic Gemini fallback** and **no hidden cloud calls**.

## Documentation index

| File | Purpose |
| --- | --- |
| [01-scope-and-architecture.md](docs/01-scope-and-architecture.md) | Boundaries, success criteria, assumptions and decisions |
| [02-macos-deployment.md](docs/02-macos-deployment.md) | Git/CLT, Ollama, model, Hermes, basic smoke test |
| [03-gemini-escalation.md](docs/03-gemini-escalation.md) | Credentials, manual escalation, observable fallback test |
| [04-validation.md](docs/04-validation.md) | Repeatable test matrix and evidence requirements |
| [05-troubleshooting-rollback.md](docs/05-troubleshooting-rollback.md) | Diagnostics, recovery, uninstall/rollback |
| [06-execution-log.md](docs/06-execution-log.md) | Execution and error register — awaiting test data |
| [07-codex-execution-brief.md](docs/07-codex-execution-brief.md) | Instructions for the Codex operator on Golden Gate |
| [Modelfile](config/Modelfile.qwen3.5-4b-64k) | 64K-context local trial model configuration |

## Quick-start order

Read 01 → execute 02 on the Mac → run 04 local tests → configure and deliberately test 03 → update 06 → exercise 05 uninstall → reinstall to prove repeatability.

Never commit API keys, auth files, private sessions, logs, personal documents or machine-derived secrets. This repository is **public**; the committed ignore rules help, but do not replace reviewing each git diff.

## Official references (checked 2026-10-24)

- Hermes: https://hermes-agent.nousresearch.com/docs/getting-started/installation
- Hermes Quickstart: https://hermes-agent.nousresearch.com/docs/getting-started/quickstart
- Hermes Ollama: https://hermes-agent.nousresearch.com/docs/guides/local-ollama-setup
- Hermes Gemini: https://hermes-agent.nousresearch.com/docs/guides/google-gemini
- Hermes Fallback: https://hermes-agent.nousresearch.com/docs/user-guide/features/fallback-providers
- Hermes CLI: https://hermes-agent.nousresearch.com/docs/reference/cli-commands
- Hermes Uninstall: https://hermes-agent.nousresearch.com/docs/getting-started/updating
- Ollama Hermes integration: https://github.com/ollama/ollama/blob/main/docs/integrations/hermes.mdx
- Ollama download: https://ollama.com/download/mac
- Ollama Qwen3.5: https://ollama.com/library/qwen3.5

Installation interfaces and model catalogs evolve; recheck official docs and record the exact versions before executing.


## Phase 4 — sandbox, web search and model tuning (HISTORICAL PLAN, NOT DEPLOYED)

Requested 2026-10-24. These are version-aware documents and operator-run scripts. They do NOT imply that Golden Gate settings, Ollama models or Docker were changed.

- [繁中安全設計與部署步驟](docs/11-hardening-plan-zh-TW.md)
- [繁中驗收／回復矩陣](docs/12-hardening-validation-zh-TW.md)
- [Reversible Docker backend / search config](scripts/macos/harden.sh): --check / --apply / --rollback
- [Optional local model trial](scripts/macos/model-trials.sh): --plan / --build-4b / --build-7b
- [Workspace agent instructions](policy/AGENTS.md)
- [4B temperature=0.2 Modelfile](config/Modelfile.qwen3.5-4b-t02)
- [Experimental 7B temperature=0.2 Modelfile](config/Modelfile.qwen2.5-7b-experimental)
- [Empty cloud/Search key placeholders](config/cloud-keys.env.example)

Priority: keep Ollama on macOS for Apple GPU, send Hermes terminal/file/code operations to Docker with only ~/hermes_workspace mounted. Built-in web_search handles search; do not scrape Google Maps via curl/urllib. Qwen2.5 7B/14B catalog context is listed at 32K vs Hermes >=64K, so 7B is a *trial*, not an automatic default switch. Existing Gemini 503 and long-context instability remain unresolved.
