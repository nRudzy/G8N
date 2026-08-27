# G8N-044 — Derived recruitment signals

Status: implemented as versioned formulas, inactive workflow skeleton and synthetic numerical cases; not executed.

## Purpose

Derived signals distinguish raw volume from acceleration, job-family diversity, multi-site campaigns and recurrent republication.

## Formulas

| Signal | Formula |
| --- | --- |
| Acceleration | `active_24h / max(active_7d / 7, 1)`, capped to 5 |
| Diversity | `job_family_count_30d / max(active_30d, 1)` |
| Multi-site | `site_count_30d` only when SIRET/localisations are proven |
| Recurrence | `republication_30d / max(active_30d + republication_30d, 1)` |

Cold start never produces infinity or automatic maximum score. It gets its own label and capped confidence.

## Campaign labels

- `campaign`: acceleration high and recurrence low;
- `continuous_need`: recurrence high and acceleration stable;
- `multi_site`: at least two proven establishments;
- `focused`: low family diversity;
- `cold_start`: insufficient baseline.

## Persistence

Signals are stored in `company_derived_signals` separately from final lead score.

## Workflow skeleton

`workflows/wf-61-company-derived-signals.json` is inactive. It expects G8N-043 company signals and returns derived-signal upsert plans.

## Local validation commands not executed in cloud

```shell
docker compose up -d
```

Then in local n8n:

1. Import WF-61.
2. Feed `fixtures/expected/company-derived-signal-cases.json`.
3. Verify cold start, caps, republication, multi-site and same-family variants.

No command, workflow import, calculation execution, Data Table operation, test, lint, build or Docker run was executed in the cloud authoring environment.
