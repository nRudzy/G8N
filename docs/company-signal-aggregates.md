# G8N-043 — Company recruitment signal aggregates

Status: implemented as versioned aggregate contract, inactive workflow skeleton and synthetic cases; not executed.

## Purpose

Mass hiring is measured at SIREN/company level over time. Individual offers remain available as drill-down evidence.

## Windows

WF-60 computes `24h`, `7d` and `30d` windows with UTC boundaries. Presentation can use Europe/Paris, but calculation remains UTC.

Window rule: start inclusive, end exclusive.

## Counting

- Exclude duplicate and rejected offers.
- Include republications as republication evidence, not duplicate source rows.
- Count an offer once even if it maps to several training needs.
- Count distinct families and establishments separately.

## Persistence

`company_signals` is upserted by company/window/reference time/version. The same replay updates the same signal key instead of creating duplicates.

`company_signal_contributors` stores drill-down offer keys for explainability.

## Workflow skeleton

`workflows/wf-60-company-signal-aggregates.json` is inactive. It expects filtered offer/classification rows and emits signal/contributor upsert plans. It does not read/write Data Tables in the cloud.

## Local validation commands not executed in cloud

```shell
docker compose up -d
```

Then in local n8n:

1. Import WF-60.
2. Feed `fixtures/expected/company-signal-aggregate-cases.json`.
3. Wire Data Table reads/upserts.
4. Verify boundary, republication, multi-establishment and multi-family cases.

No command, workflow import, aggregation execution, Data Table operation, test, lint, build or Docker run was executed in the cloud authoring environment.
