# G8N-031 — SIRENE lookup, cache and normalized response

Status: implemented as configuration, inactive workflow skeleton and synthetic cases; real SIRENE call not executed.

## Purpose

SIRENE is the authoritative source used to verify French company and establishment identity. This ticket defines the local lookup contract used by later matching workflows.

## Credential contract

Create the SIRENE credential only in the local n8n instance. Do not commit API tokens or OAuth material.

The workflow expects a local credential named `SIRENE API — local`. The exact auth mode and quota limits must be filled after the user validates G8N-003.

## Lookup order

1. Query explicit SIRET first.
2. Query explicit SIREN second.
3. Use bounded text search only when no legal identifier is available.

Text search must be capped to 10 candidates and must return `multiple_results` when ambiguity remains.

## Cache policy

`config/sirene.lookup.json` defines a 30-day TTL in the `sirene_cache` Data Table.

Cache keys use:

```text
lookup_mode + ":" + normalized_query
```

An expired cache entry can be served as `stale` if the provider returns quota, timeout or transient errors. A provider error must never be interpreted as a missing company.

## Normalized output

The workflow output separates:

- `single_result`;
- `zero_result`;
- `multiple_results`;
- `stale`;
- `provider_error`;
- `invalid_input`.

Only fields needed for matching and ICP are retained: identity, address, NAF, employee band when available and administrative state.

## Metrics

Each response carries:

- `cache_status`;
- `api_call_count`;
- `latency_ms`;
- `result_count`;
- `error_code`.

These counters are designed for later observability and quota review.

## Workflow skeleton

`workflows/wf-31-sirene-lookup.json` is inactive and does not include a connected HTTP node. It prepares the request contract, simulates cache/provider classification and returns a normalized envelope. The local implementation can wire Data Table reads/writes and the HTTP Request node after credentials exist.

## Local validation commands not executed in cloud

```shell
docker compose up -d
```

Then in local n8n:

1. Create the `SIRENE API — local` credential.
2. Import `workflows/wf-31-sirene-lookup.json`.
3. Wire Data Table read/write nodes for `sirene_cache`.
4. Wire the HTTP Request node to SIRENE using `config/sirene.lookup.json`.
5. Run the synthetic scenarios from `fixtures/sirene/sirene-cache-cases.json`.
6. Confirm cache hit, miss, expired stale, zero result, multiple result, 401, 429 and timeout are distinct.

No command, workflow import, API request, credential read, Data Table operation, test, lint, build or Docker run was executed in the cloud authoring environment.
