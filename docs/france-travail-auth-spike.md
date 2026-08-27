# G8N-020 — France Travail auth spike

Status: implemented as an inactive local workflow skeleton and configuration contract, not executed.

## Purpose

WF-20 prepares the smallest local France Travail authentication spike without exposing secrets and without requiring the cloud authoring environment to call the API.

The real authenticated call remains a local validation step after G8N-003 confirms access, quotas, endpoint URLs and contract constraints.

## Credential

Create the n8n credential locally with this name:

```text
G8N — France Travail — Offres — Local
```

Secrets must live only in n8n's credential store. They must not be copied to Git, Notion, workflow exports, fixtures, logs or chat.

## Required local variables

| Variable | Purpose |
| --- | --- |
| `G8N_FRANCE_TRAVAIL_BASE_URL` | Official API base URL confirmed in G8N-003. |
| `G8N_FRANCE_TRAVAIL_TOKEN_URL` | Official token URL if required by the selected n8n credential configuration. |
| `G8N_FRANCE_TRAVAIL_OFFERS_SEARCH_PATH` | Official minimal offers search path confirmed in G8N-003. |
| `G8N_MOCK_MODE` | `true` uses local fixtures and avoids the HTTP request branch. |

No default production endpoint is hard-coded because the official contract still has to be confirmed.

## Minimal query

The first local real call should stay conservative:

```json
{
  "motsCles": "formation",
  "range": "0-9",
  "sort": "date"
}
```

If G8N-003 returns stricter limits, use the stricter values.

## Fixture handling

Before the first real call, use:

- mock fixture: `fixtures/france-travail/offres-smoke.json`;
- real cleaned target: `fixtures/france-travail/offres-auth-spike.cleaned.json`;
- template: `fixtures/france-travail/offres-auth-spike-template.json`.

When producing the real cleaned fixture locally:

1. Remove `Authorization`, `Cookie`, `Set-Cookie` and token-like headers.
2. Keep pagination/quota headers only when non-sensitive.
3. Keep only the minimum response fields required to compare with `schema/canonical-data-contract.json`.
4. Do not commit complete raw business exports.

## Error baseline

`config/france-travail-error-codes.json` maps the initial expected categories:

| HTTP status | Category | Retry |
| --- | --- | --- |
| 400 | validation | no |
| 401 | credential | no |
| 403 | authorization | no |
| 404 | configuration | no |
| 408 | timeout | once |
| 429 | rate_limit | once, respecting `Retry-After` |
| 5xx | upstream | once |

The exact provider-specific code list must be updated after G8N-003 and the first local run.

## Local validation commands not executed in cloud

The user can validate later with:

```shell
docker compose up -d
```

Then in n8n:

1. Create the credential `G8N — France Travail — Offres — Local`.
2. Set the required `G8N_FRANCE_TRAVAIL_*` variables from the official contract.
3. Import `workflows/wf-20-france-travail-auth-spike.json`.
4. Run first with `G8N_MOCK_MODE=true`.
5. Run with the real credential only after G8N-003 is complete.
6. Save a sanitized fixture to `fixtures/france-travail/offres-auth-spike.cleaned.json`.
7. Confirm the exported workflow JSON contains no secret values.

No step above was executed in the cloud authoring environment.
