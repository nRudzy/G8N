# G8N-013 — WF-00 Healthcheck and developer smoke test

Status: implemented as an importable workflow skeleton and runbook, not executed.

## Files

- `workflows/wf-00-healthcheck.json`: n8n manual workflow export.
- `config/healthcheck.json`: expected components, technical keys and result schema.

## Purpose

WF-00 checks whether the local G8N runtime is ready before debugging business workflows.

It must never expose secret values and must not write business data. Its only persistent technical write is the stable key `healthcheck:wf-00` in the technical table selected in `config/healthcheck.json`.

## Components

| Component | Expected result |
| --- | --- |
| `n8n_runtime` | The workflow can execute and produce `run_id` + UTC timestamp |
| `data_tables` | A technical Upsert can write/read one stable row without duplication |
| `raw_directory` | `/files/raw` is mounted and writable |
| `exports_directory` | `/files/exports` is mounted and writable |
| `france_travail_credentials` | Credential presence/auth status is reported without printing tokens |
| `sirene_credentials` | Optional credential presence/auth status is reported without printing tokens |
| `pappers_credentials` | Optional credential presence/auth status is reported without printing tokens |

## Local completion steps

The exported workflow is intentionally conservative. After importing it locally:

1. Create the Data Tables from `config/data-tables.json`.
2. Add a Data Table Upsert node after `Build run context` to upsert `healthcheck:wf-00` into `error_events`.
3. Add Data Table readback or a second upsert-safe check to prove the row is not duplicated.
4. Add file write/read checks for `/files/raw/.healthcheck.json` and `/files/exports/.healthcheck.json`.
5. Add optional non-destructive credential checks only after credentials exist in n8n.
6. Keep each sub-test isolated so one failure still returns all component statuses.

## Result contract

Every run should return:

```json
{
  "run_id": "healthcheck_20260827T120000Z",
  "checked_at": "2026-08-27T10:00:00Z",
  "overall_status": "ok",
  "components": [
    {"component": "n8n_runtime", "status": "ok", "latency_ms": 10, "message": "Workflow executed.", "action": null}
  ]
}
```

## Developer smoke test command

The local smoke test is manual until n8n exposes a local webhook or CLI import path for this project.

Commands for the user to run later, not executed here:

```bash
docker compose up -d
```

Then import `workflows/wf-00-healthcheck.json` in n8n and run it manually.

## Failure messages

Use actionable messages:

- Missing Data Table: create or repair the table from `config/data-tables.json`.
- Folder not mounted: verify Docker Compose volume mapping for `/files/raw` or `/files/exports`.
- Credential absent: create the credential in n8n; never paste the secret into logs or chat.
- Auth refused: verify credential value locally in n8n.
- Quota reached: stop API sub-tests and retry after the quota window.
- Timeout: keep partial results and flag only the component that timed out.

## Known limits

- The workflow was not imported or run in a live n8n instance during this implementation.
- Data Table and filesystem nodes are documented as local completion steps because their exact n8n Data Table IDs are created inside the user’s local instance.
- No test, lint, build, Docker, CI or API call was executed.
