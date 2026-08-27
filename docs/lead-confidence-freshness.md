# G8N-046 — Lead confidence and freshness

Status: implemented as a versioned formula, inactive workflow skeleton and six synthetic profiles; not executed.

## Principle

Business score and confidence stay separate. A company can have a high recruitment score and low confidence if identity, freshness or source quality is weak.

## Subscores

| Subscore | Weight | Meaning |
| --- | ---: | --- |
| Identity | 35 | SIREN/SIRET match confidence and ambiguity |
| Source quality | 20 | raw payload, canonical completeness and deduplication quality |
| Freshness | 20 | recency of offers, SIRENE and health data |
| Classification | 15 | deterministic job classification confidence; LLM remains optional/disabled |
| Enrichment | 10 | SIRENE/Pappers/health availability and conflicts |

The export priority threshold is configurable with `minimum_priority_export_confidence` and defaults to 65.

## V1 free/local policy

Pappers absence does not zero confidence when SIRENE identity is reliable. LLM absence does not zero classification confidence because deterministic classification is the V1 primary path.

## Persistence

`lead_scores` keeps `score` beside `confidence` and `freshness`. G8N-046 adds exportable `confidence_breakdown_json` and `confidence_reasons_json`.

## Workflow skeleton

`workflows/wf-71-calculate-lead-confidence.json` is inactive and contains a pure deterministic calculator. It updates confidence fields after WF-70 scoring rows exist locally.

## Local validation commands not executed in cloud

```shell
docker compose up -d
```

Then in local n8n:

1. Import WF-71.
2. Feed `fixtures/expected/lead-confidence-cases.json`.
3. Compare exact fresh match, fuzzy ambiguous match, stale SIRENE, Pappers absent, health conflict and LLM-disabled cases.
4. Confirm score and confidence are displayed/exported side by side.

No command, workflow import, test, lint, build, Docker run or Data Table write was executed in the cloud authoring environment.
