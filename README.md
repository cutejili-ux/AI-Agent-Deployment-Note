# AI Agent Deployment Notes

> POC 001 — Hermes Agent + Ollama + optional Gemini on **Golden Gate** (Mac mini M6 base, Apple Silicon, 16 GB unified memory, 256 GB SSD).

**Status (2026-10-24): LIMITED PASS.** Hermes v0.22.5 + Ollama 0.40.10 + Qwen3.5 4B run locally on the inspected M6 / 16 GB Mac. Short local chat, constrained file operations, and retained-data uninstall/reinstall passed. Long-input testing stopped at macOS memory-pressure warnings; full 64K input stability is BLOCKED. Hermes Gemini calls still fail with 503/timeouts, although a minimal native Google request returned HTTP 200; root cause remains unresolved. npm audit findings remain. See [actual evidence](docs/06-execution-log.md), [local guide (繁體中文)](docs/08-local-start-zh-TW.md), and [third-stage validation/reinstallation results (繁體中文)](docs/10-validation-reinstall-zh-TW.md). The operator accepted the initial local phase and authorized publication and further deployment stages; historical failures remain recorded.

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
