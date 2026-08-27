# G8N-037 — Legal and financial health normalization

Status: implemented as a cautious health model, inactive workflow skeleton and synthetic cases; not executed.

## Decision

V1 must run for free whenever possible. Pappers and LLM are not required for this model. If Pappers is disabled, unavailable, paid or missing credentials, health normalization still produces SIRENE-based measures and keeps optional financial measures as `unknown`.

## No false zeroes

Missing revenue, result, financial accounts or risk events are stored as `null` with an explicit status. They are never converted to zero and never used as an unsupported solvency conclusion.

## Statuses

| Status | Meaning |
| --- | --- |
| `known` | Value is available and recent enough |
| `unknown` | Value is absent or provider disabled |
| `not_applicable` | Measure does not apply |
| `stale` | Value exists but is too old; confidence is reduced |
| `conflict` | Providers disagree; conflict remains visible |

## Penalty rules

Strong penalties require explicit evidence such as inactive company or known legal risk event. Unknown financial data only reduces confidence; it is not a negative business fact.

## Workflow skeleton

`workflows/wf-41-normalize-company-health.json` is inactive. It merges SIRENE identity state and optional Pappers whitelisted data, emits normalized health measures, and separates risk signals from final score.

No Pappers, LLM, API call or Data Table operation is executed by the export.

## Local validation commands not executed in cloud

```shell
docker compose up -d
```

Then in local n8n:

1. Import WF-41.
2. Feed `fixtures/expected/company-health-normalization-cases.json`.
3. Wire Data Table upserts to `company_health_measures`.
4. Confirm missing financials stay `null/unknown`.
5. Confirm stale and conflict are visible and exportable.

No command, workflow import, API call, Data Table operation, test, lint, build or Docker run was executed in the cloud authoring environment.
