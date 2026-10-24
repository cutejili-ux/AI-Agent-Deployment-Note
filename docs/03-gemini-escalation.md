# 03 — Gemini: explicit escalation, optional fallback and attribution

**Default mode: local-only.** Having a Google/Gemini subscription is NOT the same as being entitled to Gemini API calls inside Hermes. Hermes native Gemini provider uses an API key and API quota/billing.

Official guide: https://hermes-agent.nousresearch.com/docs/guides/google-gemini

## Stage 0 — no Gemini credentials

First verify that Hermes + Ollama pass the local test set and no cloud requests occur. Do not enable fallback providers. Privacy rule: never silently transmit local files, confidential material, personal conversations or source code to cloud inference.

## Stage 1 — configure Gemini but keep local as default

1. Create a Google AI Studio API key at https://aistudio.google.com/apikey in an account/project approved for POC use.
2. Set project billing/quota limits and monitor spending via Google's billing/API usage tools. For this POC, use low limits and no sensitive user data.
3. Configure the key **interactively** in hermes model (More providers → Google AI Studio) or in ~/.hermes/.env with restrictive file permissions. Do not put the key in a shell command, a repository file, screenshot, or exported logs. If creating the file manually: chmod 600 ~/.hermes/.env.
4. Select a Gemini model actually returned by Hermes' current selector. Record its exact ID in the execution log, not a guessed version string.
5. Since hermes model changes the saved default, return to hermes model and select the *local custom Ollama model* as the default again. Verify with hermes doctor/config and a local-only query.
6. Native Gemini endpoint: https://generativelanguage.googleapis.com/v1beta. Prefer it to Google's OpenAI-compatibility path for Hermes tool loops.

## Stage 2 — explicit / auditable manual cloud call

After setting up credentials, use a one-shot invocation with the EXACT Gemini model ID obtained in the selector:

    hermes chat --oneshot --provider gemini --model <SELECTED_GEMINI_MODEL_ID> -q "Answer with exactly GEMINI_OK"
    hermes logs agent -n 100

The angle-bracket token above is a placeholder — replace it. Do not paste the placeholder literally. Confirm the chosen provider/model from logs and session metadata, and corroborate with Google API usage/billing, allowing for reporting delays. Check again that an ordinary local prompt uses Ollama. If provider attribution is unavailable in logs, mark observability BLOCKED and do not assert the route.

Within an existing Hermes interactive session, /model displays/switches between already configured models. A temporary session-only switch can be used for a deliberate Gemini question; avoid --global when not intended. Use /model again to switch back. Provider setup (keys) must be done outside chat via hermes model.

## When is Gemini warranted?

| Situation | Action | Automation? |
| --- | --- | --- |
| Short Q&A, harmless file summarization, simple tool tasks | Try local model first | Local only |
| Weak/contradictory answer, task beyond 4B reasoning, repeated malformed tool actions | **Ask operator for explicit escalation**; use separate Gemini one-shot after approval | Not a native automatic quality rule |
| Local model API transport error / overload / timeout / provider rate limit | Capture error; optionally test error-driven fallback once approved | Supported by Hermes fallback manager |
| Confidential/employer/private data, secrets, credentials | Do not send to cloud unless independently authorized and compliant | Never auto-route |
| Cost/quota cap reached or Gemini unavailable | Stay local or stop with a clear error | Do not retry indefinitely |

Prompts such as "use Gemini only if needed" do not enforce routing/cost. The default Hermes fallback feature is triggered by *provider/API errors*, not a reliable measure of the quality of local reasoning. A policy-based complexity router, budget guard, or approval gate would require a separately designed wrapper/integration and testing.

## Optional Stage 3 — explicit error-driven fallback POC

Only after Stage 2 passes and the operator approves possible cloud calls:

    hermes fallback
    hermes fallback list

Add one Gemini provider/model **interactively** via the manager; verify config.yaml shows exactly one approved fallback entry, with no stray legacy fallback_model or additional cloud route. Fallback documentation: https://hermes-agent.nousresearch.com/docs/user-guide/features/fallback-providers

Confirm failure-driven behavior safely, e.g. take the Ollama server temporarily offline after saving service state, run an innocuous test message, observe logs and Gemini usage, then restore Ollama. Record whether Hermes actually switched, why, when, error class, model, and resulting usage. Do not assume it will switch on slow or low-quality answers.

At end of the experiment, **remove the fallback** using hermes fallback manager and verify local-only default; having a configured API key alone does not mean automatic routing is desired.

## Minimum cloud-call audit record

- ISO-8601 local and UTC time; prompt test ID, **non-sensitive** summary only.
- Initial provider/model and actual provider/model used.
- Invocation reason: manual approval or fallback error; record error category.
- API response status, latency and request/usage IDs where safely available.
- Input/output token counts if supported, Google dashboard usage/billing comparison.
- Outcome, failure and privacy review.
- No API keys, raw personal prompts, private payloads, or credentials.

**Cloud usage may also arise from auxiliary model features** (e.g. compression/vision) if explicitly configured to a cloud provider. For Phase 1 leave these disabled or local and inspect configuration before claiming local-only operation.
