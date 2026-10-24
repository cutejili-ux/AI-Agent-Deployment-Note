# 07 — Codex execution brief (for a future run on Golden Gate)

Copy the instructions below into a Codex session that has authorized access to Golden Gate. **Do not assume the current ChatGPT session can run commands on the Mac.**

## Operator instructions

You are implementing POC 001 in cutejili-ux/AI-Agent-Deployment-Note on a Mac named Golden Gate (user-stated Mac mini M6, 16 GB unified memory, 256 GB SSD). Read README.md and docs/01 through docs/06 before taking action. Work sequentially with checkpoints; user wants to learn how each component installs, starts, fails and is removed, NOT an uncontrolled autonomous deployment.

1. First inventory architecture, macOS, Git, Apple Command Line Tools, disk, RAM, installed Ollama/Hermes, conflicting services; capture a redacted baseline. Do not reinstall tools that already work.
2. Follow docs/02 for prerequisites and Git clone, with the official vendors' CURRENT instructions. Use minimal CLI installation and optional feature skips. Avoid sudo for Hermes and never expose service ports beyond loopback.
3. Install/select only qwen3.5:4b for the first try and create qwen3.5-4b-64k with the committed Modelfile. Confirm Hermes >=64K context requirement and monitor memory pressure/swapping on the 16 GB Mac. STOP at a blocker rather than secretly changing architecture.
4. Configure Hermes local custom provider. Execute safe local-only tests, explicitly verify any claimed tool action against the filesystem under $HOME/Projects/hermes-poc-scratch.
5. Do NOT add Gemini until local test approval. When approval is given, ask operator to enter key through a secure local UI/prompt, not through Codex chat or a shell command that would be logged. Run a controlled manual Gemini call; capture provable routing. Keep auto fallback off unless explicitly approved for separate failure experiment.
6. Record each real command, version, result, exit code, troubleshooting, timings, memory and any provider switch in docs/06; preserve private raw logs outside this public repo.
7. Use docs/05 for reviewed dry-run uninstall and (if approved) actual uninstall/reinstall. Do not delete shared Homebrew, Xcode CLT, existing model caches or user data.
8. Before any git push, inspect staged content for secrets/private artifacts and show a concise summary of modifications. Commit/push only sanitized documentation and portable artifacts. If user approval is required for destruction, spending or data egress, stop at that gate.

Acceptance is defined by docs/01 and docs/04. Report accurate PASS / FAIL / BLOCKED findings, not optimistic conclusions.

## Suggested future automation outputs

Once the manual workflow passes on Golden Gate, design (do not prematurely execute) platform-detection and safe-install scripts under scripts/macos, scripts/linux and scripts/windows, plus a manifest and uninstall dry-run. Build an idempotent detection/restart/repair path before packaging a 'one-click' installer. Keep key material outside Git.
