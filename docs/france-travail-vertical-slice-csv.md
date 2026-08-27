# G8N-027 — France Travail vertical slice to CSV

Status: implemented as export policy, inactive workflow skeleton and local validation procedure; not executed.

## Purpose

This vertical slice proves the local chain from France Travail collection to a simple company-level CSV. In the cloud authoring environment, no workflow, API call, Docker command, Data Table read/write or CSV generation was executed.

## Scope

The slice aggregates canonical `job_offers` rows by declared company name and city. It deliberately stops before SIRENE, Pappers, LLM classification, CRM or scoring.

## CSV contract

The export policy is `config/export.vertical-slice.csv.json`.

The CSV is flat and encoded as UTF-8 with BOM so Excel opens French accents without manual correction. Fields are quoted and line endings are CRLF.

Columns:

| Column | Meaning |
| --- | --- |
| `run_id` | Local vertical-slice export run identifier |
| `generated_at` | UTC generation timestamp |
| `declared_company_name` | Company name declared on the job offer |
| `city` | Declared city or normalized city from the offer |
| `offer_count` | Distinct non-duplicate canonical offers in the aggregate |
| `titles` | Distinct offer titles joined by `; ` |
| `first_published_at` | Earliest publication date in the aggregate |
| `last_published_at` | Latest publication date in the aggregate |
| `source_offer_keys` | Offer keys kept as traceability evidence |

## Replay expectation

For the same canonical input rows, business columns must remain stable across replay. Only `run_id`, `generated_at` and the output file name are volatile.

Duplicate and rejected offers are excluded. `needs_review` rows remain visible in the POC CSV so local review can measure quality gaps before enrichment.

## Workflow skeleton

`workflows/wf-30-export-company-csv.json` is inactive. It contains:

1. A manual trigger.
2. A mock input node that represents the result of a local Data Table read.
3. An aggregation code node for company/city grouping.
4. A CSV rendering code node that quotes every field and emits CRLF rows.
5. A report node listing volumes, rejected rows, duplicates and replay notes.

The workflow does not read Data Tables or write the `exports/` directory until the user wires the local n8n file and Data Table nodes.

## Local validation commands not executed in cloud

```shell
docker compose up -d
```

Then in local n8n:

1. Import `workflows/wf-30-export-company-csv.json`.
2. Replace the mock input node with a Data Table read from `job_offers`.
3. Keep filters from `config/export.vertical-slice.csv.json`.
4. Add a local file write node targeting `exports/france-travail/`.
5. Run a bounded France Travail batch through WF-10, WF-11, WF-20 and WF-21.
6. Run WF-30 and open the CSV in Excel or LibreOffice.
7. Replay the same run and compare business rows, excluding `run_id`, `generated_at` and file name.
8. Add one synthetic or real authorized new offer and verify the expected aggregate change.

Record locally:

- source run identifier;
- input row count;
- exported aggregate row count;
- duplicate count;
- rejected count;
- duration;
- observed gaps before enrichment.

No validation command was executed in the cloud authoring environment.
