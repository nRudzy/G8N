# G8N-015 — Fixtures, mock mode and local reset

Status: implemented as synthetic fixtures, inactive workflow skeletons and guarded local procedures, not executed.

## Purpose

G8N development must be possible without repeatedly calling external APIs. This package provides deterministic synthetic data and local-only reset conventions so future workflows can be developed offline.

## Files

- `config/mock-mode.json`: mock activation, dataset routing, seed namespace and reset guard.
- `fixtures/france-travail/`: nominal, incomplete, duplicate, republished and performance-template offer payloads.
- `fixtures/sirene/`: exact, ambiguous and no-result company identity payloads.
- `fixtures/pappers/`: nominal enrichment, quota error and missing-financials payloads.
- `fixtures/expected/seed-counts.json`: expected deterministic counters per dataset.
- `workflows/wf-01-seed-fixtures.json`: inactive seed workflow skeleton.
- `workflows/wf-02-reset-local-fixtures.json`: inactive guarded reset workflow skeleton.
- `scripts/g8n-reset-local-fixtures.sh`: local dry-run reset helper.

## Confidentiality

All fixtures are synthetic. They deliberately avoid:

- real Notion content;
- real company exports;
- candidate data;
- credentials, tokens, cookies or authorization headers;
- complete private source payloads.

The provider payloads are only provider-like until G8N-003 supplies validated API examples and contractual constraints.

## Mock mode

Mock mode is enabled only by local configuration:

```shell
G8N_MOCK_MODE=true
G8N_MOCK_DATASET=smoke
```

Supported datasets:

| Dataset | Purpose |
| --- | --- |
| `smoke` | Small deterministic offline checks. |
| `edge` | Missing fields, duplicates, republished offers, ambiguous SIRENE and Pappers quota errors. |
| `performance` | Template for local generation of larger batches; generated data must not be committed. |

## Seed workflow

`WF-01 — Seed deterministic fixtures` is intentionally inactive. After importing locally, add Data Table nodes to upsert rows with:

- `fixture_namespace = g8n-fixture`;
- stable IDs derived from fixture IDs;
- `source_run_id = seed_g8n_fixtures_v1`;
- deterministic timestamps from fixture files.

Seed must be idempotent: running it twice should leave the same final row counts.

## Reset workflow

`WF-02 — Reset local G8N fixtures` refuses to proceed unless both local guards are present:

```shell
G8N_ENVIRONMENT=local
G8N_RESET_CONFIRMATION=RESET_G8N_LOCAL_ONLY
```

Reset scope is limited to:

- Data Table rows where `fixture_namespace = g8n-fixture`;
- files under `data/raw/g8n-fixtures/`;
- files under `exports/g8n-fixtures/`.

It must not touch workflows, credentials, n8n's internal SQLite configuration, unrelated Data Table rows, other Docker volumes or non-G8N directories.

## Local validation commands not executed in cloud

The user can validate later with:

```shell
docker compose up -d
```

Then in n8n:

1. Import `workflows/wf-01-seed-fixtures.json`.
2. Import `workflows/wf-02-reset-local-fixtures.json`.
3. Add local Data Table nodes based on `config/data-tables.json`.
4. Enable mock mode with `G8N_MOCK_MODE=true`.
5. Run seed twice and compare row counts with `fixtures/expected/seed-counts.json`.
6. Try reset without the two guard variables and confirm it refuses.
7. Set the two guard variables locally and verify only `g8n-fixture` rows/files are targeted.

The shell helper is dry-run only:

```shell
G8N_ENVIRONMENT=local G8N_RESET_CONFIRMATION=RESET_G8N_LOCAL_ONLY bash scripts/g8n-reset-local-fixtures.sh
```

No command above was executed in the cloud authoring environment.
