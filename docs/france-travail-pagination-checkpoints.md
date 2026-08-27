# G8N-022 — France Travail pagination, retries and checkpoints

Status: implemented as configuration, synthetic fixtures and inactive workflow skeleton; not executed.

## Purpose

WF-10 must collect France Travail pages in bounded batches without duplicating data after a temporary failure. This ticket defines the local execution policy and an importable n8n skeleton that can later be wired to the real HTTP and persistence nodes.

## Policy

`config/france-travail.pagination.json` defines:

- range-based pagination with a finite page and call budget;
- retryable and non-retryable HTTP statuses;
- Retry-After handling for 429 responses;
- bounded exponential backoff with jitter;
- loop guards for repeated ranges;
- counters for calls, pages, offers, retries, errors and duration;
- checkpoint advancement only after raw batch persistence succeeds.

401 and 403 are terminal action-required states because they usually mean credential, scope or contract issues. 429 is handled by Retry-After when present, then cut to a partial run if the run budget is exhausted. 5xx and timeout statuses are retryable until the page budget is exhausted.

## Checkpoint rule

The checkpoint key is:

```text
source + config_version + publication_window + query_hash
```

The checkpoint advances from `last_persisted_range` to `next_range` only after the corresponding raw page and its offer rows have been persisted successfully by the G8N-023 persistence layer. A failed HTTP call, failed validation or failed persistence step leaves `next_range` unchanged so a later run can retry the same page.

## Workflow skeleton

`workflows/wf-10-pagination-checkpoint-skeleton.json` is inactive and mock-oriented. It does not call France Travail and does not persist data. It models:

1. run envelope initialization;
2. pagination policy attachment;
3. retry/error classification;
4. next checkpoint proposal;
5. final counters and local action hints.

The real HTTP request and Data Table writes must be enabled locally after G8N-020 and G8N-023 are validated.

## Synthetic fixtures

`fixtures/france-travail/pagination-scenarios.json` covers:

- three nominal pages;
- one temporary 500 on page 2 followed by success;
- 429 with Retry-After;
- repeated range loop guard.

These fixtures contain synthetic ids only and no real France Travail payloads.

## Local validation commands not executed in cloud

The user can validate later with:

```shell
docker compose up -d
```

Then in n8n:

1. Import WF-10 manual run and the pagination checkpoint skeleton.
2. Use the synthetic pagination scenarios as manual input.
3. Confirm the same page is not marked checkpointed before persistence succeeds.
4. Confirm 429 respects Retry-After or returns partial when budget is exhausted.
5. Confirm max calls and repeated ranges cut the run cleanly.
6. Wire real HTTP and Data Table nodes only after local credential and G8N-023 validation.

No command, workflow import, validation, API call or persistence operation was executed in the cloud authoring environment.
