# G8N-025 — Job offer deduplication and republications

Status: implemented as configuration, expected fixtures and inactive workflow skeleton; not executed.

## Purpose

Recruitment signals must not be inflated by exact replays, updates or republications. G8N keeps useful history while assigning each observation to a canonical offer decision.

## Rules

`config/job-offer-deduplication.json` defines:

- primary uniqueness by `source + ":" + source_offer_id`;
- a fallback fingerprint using title, declared company, location, contract and publication date;
- separate `new`, `updated`, `duplicate` and `republication` decisions;
- counters that explain each decision;
- aggregate policy excluding exact duplicates while retaining proof rows.

Never merge offers on title alone. Same title in a different company or city remains distinct.

## Stored links

`job_offers` is extended with:

- `canonical_offer_key`;
- `republication_group_key`;
- `duplicate_of_offer_key`;
- `dedupe_status`;
- `dedupe_reasons_json`;
- `dedupe_confidence`;
- `first_seen_at` / `last_seen_at`.

These fields preserve the replay/update/republication trail without deleting rows.

## Workflow skeleton

`workflows/wf-21-deduplicate-job-offers.json` is inactive. It prepares decisions from normalized rows and previous canonical candidates. It does not read or write Data Tables in the cloud.

## Local validation commands not executed in cloud

The user can validate later with:

```shell
docker compose up -d
```

Then in n8n:

1. Import `workflows/wf-21-deduplicate-job-offers.json`.
2. Wire previous `job_offers` lookups by source key and fallback fingerprint.
3. Run exact replay, changed payload, republication and same-title-distinct-company fixtures.
4. Compare with `fixtures/expected/deduplication-cases.json`.
5. Confirm duplicate rows are excluded from future aggregates but remain auditable.

No command, workflow import, validation, Data Table read/write or API call was executed in the cloud authoring environment.
