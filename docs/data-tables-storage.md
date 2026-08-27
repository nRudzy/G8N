# G8N-012 — Local business storage with SQLite and Data Tables

Status: implemented as a Data Tables specification and local procedure, not executed against a live n8n instance.

## Storage boundary

G8N uses n8n embedded SQLite as part of the local n8n runtime. Business workflows must not read or mutate `database.sqlite` directly.

Structured business records go through n8n Data Table nodes. Large source payloads stay as local JSON files and are referenced by path and hash.

## Data Tables

The authoritative table specification is `config/data-tables.json`.

Required tables:

- `ingestion_runs`
- `raw_job_offers`
- `job_offers`
- `companies`
- `company_matches`
- `company_enrichments`
- `job_classifications`
- `company_signals`
- `lead_scores`
- `export_batches`
- `error_events`

Relations are logical and use stable keys such as `run_id`, `raw_offer_key`, `offer_key`, `company_key`, `signal_key` and `score_key`. Data Tables are not treated as a relational schema with foreign keys.

## Upsert strategy

Each table has a documented `upsert_key` in `config/data-tables.json`.

| Table | Upsert key |
| --- | --- |
| `ingestion_runs` | `run_id` |
| `raw_job_offers` | `raw_offer_key` |
| `job_offers` | `offer_key` |
| `companies` | `company_key` |
| `company_matches` | `match_key` |
| `company_enrichments` | `enrichment_key` |
| `job_classifications` | `classification_key` |
| `company_signals` | `signal_key` |
| `lead_scores` | `score_key` |
| `export_batches` | `export_batch_id` |
| `error_events` | `error_key` |

For France Travail offers, `raw_offer_key` should be `source:source_offer_id` when the source identifier is usable. If no source identifier is usable, use a deterministic fingerprint built from normalized declared company, normalized title, normalized city and publication date.

## Raw payload layout

Raw payloads use this layout:

```text
data/raw/{source}/{yyyy-mm-dd}/{run_id}/{source_offer_id_or_fingerprint}.json
```

The Data Table row stores only:

- `raw_path`
- `payload_hash`
- `collected_at`
- `run_id`
- source identifiers useful for replay

## Initialization procedure

Manual local procedure, to run later in the user’s n8n instance:

1. Start n8n locally with the existing Docker Compose stack.
2. Open Data Tables in n8n.
3. Create every table listed in `config/data-tables.json`.
4. Add the columns exactly as specified.
5. For every workflow that writes a table, configure the Data Table node with Upsert on the documented key.
6. Create `data/raw` if it does not already exist.
7. Run the fixture workflow from G8N-015 once it exists.

This procedure is intended to be replayable: if a table already exists, verify its columns instead of deleting it.

## Reset procedure

Reset must be limited to G8N business data. Do not edit n8n internal SQLite tables.

Manual local reset options:

1. Preferred: use n8n Data Tables UI or Data Table nodes to delete rows from the G8N tables only.
2. Delete only raw payload files under `data/raw`.
3. Keep workflows, credentials, owner account and n8n configuration intact.

Do not run `docker compose down --volumes` for routine business-data reset because it removes all n8n state, including credentials.

## Volume, retention and migration threshold

Default retention for local POC:

- raw payload JSON: 30 days for routine replay, longer only when manually archived;
- `error_events`: keep until the related run is reviewed;
- `ingestion_runs` and derived business tables: keep while calibrating the POC.

Re-evaluate PostgreSQL only if one of these conditions becomes true:

- Data Tables cannot express the needed operations safely;
- local SQLite becomes slow or fragile for the observed volume;
- multiple concurrent users/workers are required;
- deployment outside the local machine becomes a real requirement;
- analytical queries become too complex for n8n/Data Tables.

## Manual validation to run later

These commands and actions are for local validation and were not executed here:

```bash
python -m json.tool config/data-tables.json >/dev/null
```

Manual checks:

1. Initialize the tables in a fresh local n8n.
2. Upsert the same fixture twice and confirm a single business row.
3. Update an existing offer using the same `offer_key`.
4. Restart n8n with the same Docker volume and confirm the Data Tables persist.
5. Write a raw JSON payload, store its path/hash in `raw_job_offers`, then replay from the path.
6. Reset G8N business rows and raw files without deleting workflows or credentials.

## Known limits

- The tables were not created in a live n8n instance during this cloud implementation.
- No Docker, n8n, test, lint, build, CI or API call was executed.
- Physical verification is intentionally deferred to the user’s local environment.
