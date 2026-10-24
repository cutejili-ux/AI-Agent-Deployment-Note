# 02 — Golden Gate macOS installation runbook

**Status: NOT EXECUTED.** Run commands in Terminal on Golden Gate, not in the ChatGPT cloud. Record output (sanitized) in 06-execution-log.md. Commands are a proposed sequence checked against vendor docs 2026-10-24, not proof of success.

## A. Baseline / Git prerequisites

    date
    hostname
    uname -m                  # expect arm64
    sw_vers
    sysctl -n hw.memsize      # expect ~16 GB in bytes
    df -h /
    xcode-select -p || true
    git --version || true
    command -v brew || true

If Git is absent or Apple command-line tools are missing, execute:

    xcode-select --install

Complete the macOS GUI installation/permissions, open a new Terminal and recheck:

    xcode-select -p
    git --version

This satisfies Hermes' Git prerequisite. Homebrew is **optional**, not mandatory for this POC. If an additional Git version is needed, first install Homebrew following https://brew.sh/ (review the install script), then run brew install git and record PATH/version. Never silently override an existing corporate/personal Git configuration.

Clone the documentation project:

    mkdir -p "$HOME/Projects"
    cd "$HOME/Projects"
    git clone https://github.com/cutejili-ux/AI-Agent-Deployment-Note.git
    cd AI-Agent-Deployment-Note
    git status --short

Public clone needs no GitHub token; future push needs normal approved GitHub authentication. Do NOT place a token in clone URL or commands. Confirm physical free space before continuing (planning target ~35–40 GB for this POC, not a formal requirement).

## B. Install Ollama on Apple Silicon

**Recommended for the interactive Mac POC:** download the official macOS app from https://ollama.com/download/mac, open the DMG, drag to Applications, launch Ollama, and let it register the command-line executable when prompted. Official macOS requirement: macOS 14+ (verify the current requirement at execution).

**Alternative, not in addition to app install:** use Ollama's official command-line installer at https://ollama.com/install.sh after inspecting the script; or on an automated headless Mac, document and select a Homebrew-managed install/service. Choose **one install/service owner**.

    command -v ollama
    ollama --version
    curl -fsS http://127.0.0.1:11434/api/tags
    ollama list

If the HTTP request fails, launch the Ollama app (for an app install), then retry. For a CLI-only install, use its supported service management or ollama serve in a dedicated foreground terminal; do not run a second instance if the port is already occupied.

Pull one local model only:

    ollama pull qwen3.5:4b
    ollama list
    ollama show qwen3.5:4b

**Why qwen3.5:4b?** Small model weight footprint and advertised long model context; tool-call reliability and *runtime* memory consumption remain unknown on this exact machine. Do **not** start with qwen3.5:9b, 27b or an unqualified latest tag: 9B plus 64K KV cache can put significant pressure on 16 GB and larger models exceed the POC's intended footprint.

## C. Configure 64K context

Hermes Quickstart currently requires **at least 64,000 context tokens**. The model's advertised maximum (up to 256K on the Ollama library page) is not the actual Ollama serving context. Create a reproducible derived tag using the checked-in Modelfile:

    cd "$HOME/Projects/AI-Agent-Deployment-Note"
    ollama create qwen3.5-4b-64k -f config/Modelfile.qwen3.5-4b-64k
    ollama show --modelfile qwen3.5-4b-64k
    ollama run qwen3.5-4b-64k "Reply with just: LOCAL_OK"
    ollama ps

Expect the derived Modelfile to contain PARAMETER num_ctx 65536. Monitor **Activity Monitor > Memory / Memory Pressure / Swap Used**, available disk, latency and responsiveness, and record them. A long configured context consumes memory as KV cache grows; being able to download the model does not guarantee usable 64K operation. Stop and document G1 as BLOCKED if memory pressure becomes unsafe/unacceptable. Do not claim Hermes works if model-only tests pass.

For an independent API smoke test:

    curl -fsS http://127.0.0.1:11434/api/tags
    curl -fsS http://127.0.0.1:11434/v1/models

Never publish raw endpoint logs without redacting user prompts/private content.

## D. Install Hermes CLI, minimal profile

Official source installer: https://hermes-agent.nousresearch.com/install.sh. Download, inspect, then execute as **normal user** (no sudo):

    curl -fsSL https://hermes-agent.nousresearch.com/install.sh -o /tmp/hermes-install.sh
    less /tmp/hermes-install.sh
    bash /tmp/hermes-install.sh --skip-setup --skip-browser --skip-computer-use
    export PATH="$HOME/.local/bin:$PATH"
    command -v hermes
    hermes --help
    hermes doctor

The optional skip flags are documented for the source installer; inspect its current --help before use if it has changed. Hermes installer itself prepares its pinned Python, Node, ripgrep, ffmpeg and other dependencies; avoid separately installing global Python/Node unless the recorded error specifically requires it. Minimal flags skip browser and computer-use payloads to reduce SSD use. Do **not** configure Telegram, Discord, launchd gateway or cron.

Run the interactive configuration from Terminal:

    hermes model

Choose **Custom endpoint**:
- Base URL: http://127.0.0.1:11434/v1
- Key: leave blank for local Ollama
- Model: qwen3.5-4b-64k
- Context: use 65536 if prompted; otherwise verify the auto-detected 65536 against the derived Modelfile
- Keep this custom Ollama provider as the **default**

On versions whose setup wizard is required, use hermes setup and choose manual/full or Blank Slate configuration instead of automatically subscribing to Nous Portal. Keep file operations/terminal only when needed for sandbox tests; disable optional toolsets through hermes tools.

Inspect configuration **without printing secrets**:

    hermes doctor
    hermes config check
    hermes logs list
    hermes logs agent -n 50

Hermes non-secret configuration is normally ~/.hermes/config.yaml and secrets are normally in ~/.hermes/.env. Do not check these files into Git.

## E. Local-only smoke tests

    hermes chat --oneshot --max-turns 3 -q "Reply exactly: HERMES_LOCAL_OK"
    hermes logs agent -n 80
    ollama ps

Then run controlled tests from 04-validation.md. Expect the configured provider to be local/custom, with Ollama actively loaded and no Gemini usage.

**Optional shortcut, not the canonical reproducible install:** Ollama also documents ollama launch hermes, which installs/configures Hermes automatically. Use it only as a separate comparison; it can change the install state and model choice, so do not mix it into the controlled sequence without recording the changes.

## F. Record version and installation provenance

Save sanitized command outputs: macOS build, git/ollama/hermes version, git commit/tag or install channel when available, model tag/digest, free SSD, memory pressure, steps attempted, duration and errors. See 06-execution-log.md.

## G. Next steps

1. Finish all local smoke tests before adding credentials.
2. Follow 03-gemini-escalation.md for explicit cloud-only trials.
3. Run 04-validation.md and 05-troubleshooting-rollback.md.
4. Commit only sanitized, reviewed findings to GitHub.
