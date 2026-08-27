# G8N-042 — Optional bounded LLM classification

Status: implemented as disabled-by-default contract, JSON schema and inactive workflow skeleton; not executed.

## Decision

V1 must not spend money. LLM classification is disabled by default and not required for the pipeline. The idea remains available for later if the user explicitly enables a local provider/key and budget.

## Gate

An LLM call is eligible only when the deterministic baseline is `ambiguous` or `unclassified`, enough description text exists, the taxonomy is loaded and budget remains.

With the default config, budget limits are zero, so every case falls back to deterministic behavior.

## Output

The only accepted output is strict JSON matching `schema/job-llm-classification-output.schema.json`. Invented family IDs or free text are rejected.

## Workflow skeleton

`workflows/wf-51-optional-llm-classification.json` is inactive and contains no provider-specific call. It evaluates the gate, validates a supplied provider output envelope and prepares cache/upsert plans.

No LLM, API, paid service, Data Table operation or test is executed by this export.

## Local validation commands not executed in cloud

```shell
docker compose up -d
```

Then in local n8n only if the user later enables an LLM:

1. Import WF-51.
2. Keep `LLM_ENABLED=false` and confirm pipeline fallback.
3. Optionally configure a local/provider credential later.
4. Replay `fixtures/expected/job-llm-classification-cases.json`.
5. Confirm invalid JSON, timeout, 429, invented family and budget exceeded all fall back.

No command, workflow import, LLM/API call, Data Table operation, test, lint, build or Docker run was executed in the cloud authoring environment.
