# G8N-024 — France Travail raw offer normalization

Status: implemented as configuration, expected fixtures and inactive workflow skeleton; not executed.

## Purpose

France Travail raw offer metadata is mapped into `job_offers` before matching, deduplication and scoring. The normalizer must keep source links, avoid fabricated data and isolate invalid rows without failing a whole batch.

## Mapping

`config/job-offer-normalization.json` defines the source-to-canonical mapping and stable reason codes.

| Canonical field | France Travail candidates | Rule |
| --- | --- | --- |
| `offer_key` | `source + ":" + source_offer_id` | deterministic upsert key |
| `source_offer_id` | `id`, `source_offer_id` | required |
| `title` | `intitule`, `title` | required, trimmed |
| `normalized_title` | `title` | lowercased, collapsed spaces |
| `description_excerpt` | `description` | trimmed excerpt; may be missing |
| `contract_type` | `typeContrat` | mapped from known codes, otherwise review |
| `declared_company_name` | `entreprise.nom` | optional but missing means review |
| `city` / `postal_code` | `lieuTravail.*` | parsed without guessing |
| `published_at` | `dateCreation` | UTC ISO if valid |
| `raw_offer_key` | raw metadata | preserves raw-to-canonical link |

## Status rules

- `valid`: no issue found.
- `needs_review`: partially usable record with a stable reason such as missing company, empty description, invalid date, unknown contract or ambiguous location.
- `rejected`: unusable record, currently missing source id or title.

Rejected records stay traceable through `raw_offer_key` and reason codes.

## Workflow skeleton

`workflows/wf-20-normalize-job-offers.json` is inactive. It models:

1. receiving raw offer metadata from `raw_job_offers`;
2. reading or carrying the raw payload excerpt;
3. mapping fields deterministically;
4. computing quality metrics and reason codes;
5. preparing `job_offers` upsert rows.

It performs no Data Table writes and no file reads in the cloud authoring environment.

## Local validation commands not executed in cloud

The user can validate later with:

```shell
docker compose up -d
```

Then in n8n:

1. Import `workflows/wf-20-normalize-job-offers.json`.
2. Wire Data Table reads from `raw_job_offers` and local raw JSON file reads.
3. Run the nominal and edge fixtures.
4. Compare produced rows with `fixtures/expected/normalized-job-offers.json`.
5. Confirm missing title rejects, missing company/date/location become `needs_review`, and complete offers become `valid`.

No command, workflow import, validation, Data Table read/write, file read or API call was executed in the cloud authoring environment.
