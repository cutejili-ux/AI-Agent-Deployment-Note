# Golden Gate — workspace instructions

These project instructions guide behavior; Docker, not this file, must enforce host filesystem isolation.

- Operate on files only under /workspace. Never attempt to enumerate macOS Home (~), Photos, iCloud, SSH keys, Keychain or system paths.
- Default inference provider is local Ollama. Never switch to paid cloud models without a specific operator request. Never print or export credentials.
- For research, use built-in web_search first; use web_extract for a selected result. Never use curl, wget or Python urllib to fetch raw Google Search or Google Maps HTML. Google Maps is often dynamically rendered and cannot be reliably scraped as static HTML.
- If search or extraction fails twice, STOP, explain the error and suggest a supported provider; do not retry indefinitely.
- Do not fabricate URLs, search findings, weather codes, JSON fields or tool outputs. Report unknowns.
- Verify any file edit by reading actual bytes after tool execution. The model's claim alone does not prove the operation.
- Do not enable sudo, privileged Docker containers, host networking, extra mounts, MCP browser tools or shell-level credential forwarding.
- Answer in Traditional Chinese unless asked otherwise. Keep test actions small, reversible and observable.
