# G8N-035 — Ambiguous match review and override import

Status: implemented as CSV contract, inactive export/import workflow skeleton and synthetic cases; not executed.

## Purpose

G8N V1 has no web review UI. Ambiguous company matches are exported to a CSV that can be edited locally, then imported with controlled validation.

## Review CSV

The review CSV uses stable IDs: `review_key`, `offer_key` and candidate SIRET/SIREN. A spreadsheet row number is never an identifier.

Allowed decisions:

- `accept`: select the top ranked candidate;
- `select_siret`: select one exported candidate SIRET;
- `reject`: keep the offer unresolved;
- `ignore`: leave the ambiguity unchanged.

Selecting a SIRET absent from candidates is rejected unless an explicit override note is provided.

## Import behavior

Malformed rows are rejected independently and do not block valid rows. Imports are idempotent by decision key and keep previous decisions in `company_match_review_history`.

Human decisions override automatic rules but remain revocable. Downstream company signals, lead scores and exports are marked for targeted recalculation.

## Workflow skeleton

`workflows/wf-35-review-company-matches.json` is inactive. It prepares export rows from `company_match_reviews`, validates imported decisions and returns accepted/rejected reports. It does not read/write files or Data Tables in the cloud.

## Local validation commands not executed in cloud

```shell
docker compose up -d
```

Then in local n8n:

1. Import WF-35.
2. Export ambiguous rows to `exports/review/`.
3. Fill decisions in the CSV.
4. Reimport the file.
5. Confirm accepted/rejected counts, idempotent reimport and targeted invalidation.

No command, workflow import, CSV generation/import, Data Table operation, test, lint, build or Docker run was executed in the cloud authoring environment.
