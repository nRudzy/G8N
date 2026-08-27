# G8N-040 — Tension job taxonomy and training needs

Status: implemented as versioned importable taxonomy, inactive workflow skeleton and synthetic cases; not executed.

## Purpose

The taxonomy maps structured job codes and normalized titles to stable job families, reference tension flags and potential training needs. It separates external/reference tension from demand observed later by G8N.

## Rules

- Prefer structured job codes when available.
- Keep `taxonomy_version`, `valid_from` and `valid_to`.
- One job offer can map to multiple training needs without duplicating the offer.
- Ambiguous generic titles are marked `needs_review`.
- Updating the taxonomy must not require changing workflows.

## Workflow skeleton

`workflows/wf-40-import-job-taxonomy.json` is inactive. It prepares family, keyword and training-need upserts from `config/job-taxonomy.json`.

## Local validation commands not executed in cloud

```shell
docker compose up -d
```

Then in local n8n:

1. Import WF-40 taxonomy import.
2. Load `config/job-taxonomy.json`.
3. Wire Data Table upserts.
4. Replay `fixtures/expected/job-taxonomy-cases.json`.
5. Confirm exact code, keyword, ambiguity, multiple needs and out-of-scope behavior.

No command, workflow import, Data Table operation, test, lint, build or Docker run was executed in the cloud authoring environment.
