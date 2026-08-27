# G8N-021 — WF-10 France Travail manual run

Status: implemented as configuration and inactive dry-run workflow, not executed.

## Purpose

WF-10 builds a controlled France Travail search request from a versioned configuration. It produces a clear pre-run summary before any real collection branch can be enabled locally.

The default scope is France entière, following the current user decision for G8N-001.

## Configuration

`config/france-travail.search.json` defines:

- `config_version`: persisted in future `ingestion_run` records;
- France-wide default zone;
- explicit UTC publication window;
- default keywords, ROME codes and contract types;
- conservative batch size;
- allowed and forbidden overrides.

Free-form URL strings are forbidden. Workflows must map known config fields into encoded query parameters.

## Dry-run behavior

The exported workflow is intentionally inactive and dry-run first:

1. Build default France-wide configuration.
2. Validate date window and batch size.
3. Produce `france_travail_query`.
4. Return a summary with window, filters, max results and `config_version`.
5. Refuse real-run execution in the exported skeleton until WF-20 is locally validated.

## Local validation commands not executed in cloud

The user can validate later with:

```shell
docker compose up -d
```

Then in n8n:

1. Import `workflows/wf-10-france-travail-manual-run.json`.
2. Run with the default dry-run configuration.
3. Override region or métier and verify only the expected query parameter changes.
4. Try inverted dates and a batch above the hard limit; verify the workflow refuses before any HTTP call.
5. Review the summary before enabling any real collection branch.

No command, import, validation or API call was executed in the cloud authoring environment.
