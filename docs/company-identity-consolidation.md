# G8N-034 — Company, establishment and identity history consolidation

Status: implemented as identity model contract, inactive workflow skeleton and synthetic cases; not executed.

## Purpose

Signals aggregate at SIREN level, while offers keep the SIRET establishment that was proven at collection/matching time. Historical identity evidence must not be overwritten by later SIRENE changes.

## Model

| Entity | Key | Rule |
| --- | --- | --- |
| Company | `siren:{siren}` | One row per SIREN; never merge two SIREN by name |
| Establishment | `siret:{siret}` | One row per SIRET, linked to its SIREN |
| Alias | `{company_key}:{normalized_alias}` | Legal names, trade names and declared source names |
| Snapshot | `{provider}:{entity_type}:{entity_key}:{payload_hash}` | Immutable enrichment state |

## Aggregation

Offer-level evidence keeps both:

- `establishment_key` for the source establishment;
- `company_key` for SIREN-level signal aggregation.

The 24 h, 7 d, 30 d and 90 d signal windows aggregate by `company_key`.

## History

An address, status or payload change creates a new snapshot. Replaying an identical payload hash must not create a duplicate state. Closed establishments remain queryable and visible.

## Workflow skeleton

`workflows/wf-34-consolidate-company-identity.json` is inactive. It prepares company, establishment, alias and snapshot upserts from matched offers and SIRENE envelopes. It does not write Data Tables.

## Local validation commands not executed in cloud

```shell
docker compose up -d
```

Then in local n8n:

1. Import WF-34 after WF-31/WF-32/WF-33.
2. Feed `fixtures/expected/company-identity-consolidation-cases.json`.
3. Wire upserts for companies, establishments, aliases and snapshots.
4. Replay the same snapshot and confirm idempotence.
5. Query 24 h/7 d/30 d aggregations by `company_key`.

No command, workflow import, API lookup, query, Data Table operation, test, lint, build or Docker run was executed in the cloud authoring environment.
