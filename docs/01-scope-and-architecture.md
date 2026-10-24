# 01 — POC scope, architecture and success criteria

**Recorded:** 2026-10-24. **Target:** Golden Gate, user-described Mac mini M6 base model, 16 GB unified memory, 256 GB internal SSD. **Status:** requirements defined, hardware not inspected.

## Main question

Can a small Mac host a usable Hermes agent with an Ollama local model, optionally invoke Gemini with clear approval and auditable provider selection, and be restored/removed without leaving unmanaged services or secrets?

This is a **learning / compatibility / operability POC**, not a benchmark claiming cloud-model equivalence.

## Decisions

| ID | Decision | Why |
| --- | --- | --- |
| D01 | Start with CLI-only Hermes source installer on macOS | Easy to observe, version and uninstall; Desktop optional later |
| D02 | Use Apple Command Line Tools Git first; Homebrew optional | Fewest dependencies on a fresh Mac |
| D03 | Use official Ollama macOS app OR official installer, not two competing service installations | Avoid duplicate servers and unclear ownership |
| D04 | Start with qwen3.5:4b (~3.3–4.0 GB download depending on tag/variant) | Plausible weight size on a 16 GB machine; still must measure runtime memory |
| D05 | Try 65,536-token context through a derived Ollama Modelfile | Hermes documentation specifies at least 64K; large KV cache may create memory pressure |
| D06 | Local-only default; Gemini API requires an explicit operator action initially | Prevent accidental spend/data egress |
| D07 | Do not configure fallback until controlled test, and never treat provider error fallback as a quality judge | Native fallback is error-driven, not reasoning-quality-driven |
| D08 | No messaging gateway, browser tools, or computer-use driver in initial install | Reduce attack surface, disk consumption, and variables |
| D09 | Secret values are local only; GitHub stores only sanitized evidence | Repository is public |
| D10 | Keep hardware-specific steps isolated; future automation must be idempotent, have checks, and support dry-run/remove | Portability across macOS/Linux/Windows |

## Preconditions / environment checks

- macOS version and arm64 architecture confirmed by commands; required OS version supported by official installers.
- Named local admin available for Command Line Tools/install; **do not run Hermes installation as root**.
- Enough free SSD space for runtimes, model, logs and swap. An *initial planning target* is at least 35–40 GB free (not a vendor minimum); record actual free space and stop if insufficient.
- Internet to trusted vendor domains; optionally Gemini API key and billing/quota access.
- Isolate testing in a disposable directory under the user's home; no access to employer data or private home documents.

## Working topology

1. Terminal connects to Hermes CLI.
2. Hermes uses a custom/OpenAI-compatible provider at http://127.0.0.1:11434/v1.
3. Ollama serves qwen3.5-4b-64k. All local requests should remain local.
4. Gemini is a separately configured **native** provider. A manual model switch or an intentionally enabled fallback may make outbound requests.
5. Collect evidence from Hermes local logs, the Ollama server, model state, and provider/billing dashboard.

Do not expose Ollama on 0.0.0.0 or port-forward it. Leave cloud API credentials out of shell history, public documents and test output.

## Exit / acceptance gates

- G0 Baseline: architecture, OS, RAM, free space and Git recorded; no prerequisite error.
- G1 Ollama: process/API responds; selected model loads at >=64K configured context without unacceptable swap/OOM.
- G2 Hermes local: starts, uses expected localhost endpoint, answers two prompts, and completes one harmless permitted tool action inside scratch directory.
- G3 Provider safety: routine prompt creates no Gemini usage; manual Gemini invocation is visible in agent logs/session evidence and provider dashboard.
- G4 Failure experiment: an optional deliberate fallback (if enabled) triggers only under documented error conditions, with observable provider selection and cost.
- G5 Reproducibility: uninstall dry-run reviewed, retained data choice tested, re-install documented; no unintended removal of shared dependencies.
- G6 Repository: exact versions, timings, results, blockers and sanitized errors are committed.

If G1 cannot be achieved within physical memory, label local full-agent compatibility **BLOCKED** rather than silently reducing the context below Hermes' minimum or claiming success.

## Later enhancement only

Prepare platform-specific bootstrap/check/remove wrappers (macOS zsh; Linux shell; Windows PowerShell) from verified commands, pin model tags/installer versions, use feature flags for gateways/browsers/cloud, and add dry-run and re-entry tests. Do not advertise universal one-click automation until it has been tested on each OS.
