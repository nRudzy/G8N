# G8N-023 — Idempotent raw ingestion persistence

Status: implemented as configuration and inactive n8n workflow skeletons; not executed.

## Purpose

France Travail runs must be auditable and replayable without relying on n8n execution history. Structured metadata is stored in Data Tables. Full source payloads stay as local JSON files under `data/raw/`, which is ignored by Git.

## Data Tables

`config/data-tables.json` now includes the persistence fields needed for:

- run status `partial`;
- source window and config version;
- serialized checkpoint and counter metadata;
- raw page path, page range and page index;
- `first_seen_at`, `last_seen_at` and `payload_status`.

Payloads are not copied into Data Tables.

## Idempotence keys

The raw offer upsert key is:

```text
raw_offer_key = source + ":" + source_offer_id
```

Status is computed from the previous row:

| Previous row | Hash comparison | Result |
| --- | --- | --- |
| missing | n/a | `new` |
| exists | same `payload_hash` | `unchanged` |
| exists | different `payload_hash` | `updated` |

`first_seen_at` is preserved from the previous row when present. `last_seen_at`, `payload_hash`, `raw_path`, `raw_page_path`, `source_page_range`, `page_index` and `run_id` reflect the latest persisted observation.

## Page persistence order

`config/raw-ingestion-persistence.json` defines the page commit order:

1. write the raw page JSON file locally;
2. compute SHA-256 hashes for page and offer payloads;
3. upsert `raw_job_offers` metadata rows;
4. update `ingestion_runs` counters and checkpoint;
5. mark the page persisted.

The checkpoint is not advanced before file write, hash computation and raw offer metadata upserts have all succeeded.

## Workflow skeletons

`workflows/wf-11-persist-raw-offers.json` is inactive and contains the control logic for:

- creating a run envelope;
- preparing a page persistence plan;
- classifying each offer as `new`, `unchanged` or `updated`;
- proposing Data Table upserts;
- refusing checkpoint advancement until persistence is marked successful.

`workflows/wf-12-read-ingestion-run.json` is inactive and documents the read path for a run, its raw offer rows and raw page files.

The skeletons intentionally do not execute Data Table writes, file writes or API calls in the cloud.

## Local validation commands not executed in cloud

The user can validate later with:

```shell
docker compose up -d
```

Then in n8n:

1. Import WF-11 and WF-12.
2. Wire WF-11 to Data Table upsert nodes and local file write nodes.
3. Replay the same synthetic page twice and confirm no additional business row is created.
4. Replay the same `source_offer_id` with a changed payload and confirm `payload_status = updated`.
5. Interrupt after a page and resume from `checkpoint_json.next_range`.
6. Alter a raw page file and verify hash mismatch blocks downstream normalization.

No command, workflow import, validation, file write, Data Table write or API call was executed in the cloud authoring environment.
