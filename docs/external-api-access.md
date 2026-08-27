# G8N-003 — External API access matrix

Status: implemented as a zero-secret V1 access matrix, disabled paid providers and local verification workflow skeleton; not executed.

## V1 decision

G8N V1 keeps the project local and free as far as possible:

| Provider | V1 status | Credential expected | Cost policy |
| --- | --- | --- | --- |
| France Travail | Enabled only after the user adds the local n8n credential | `G8N_FRANCE_TRAVAIL_OAUTH` | Free or existing account only |
| SIRENE / INSEE | Enabled only after the user adds the local n8n credential | `G8N_SIRENE_API` | Free or existing account only |
| Pappers | Disabled by default for V1 if paid | `G8N_PAPPERS_API_OPTIONAL` | Budget zero, max calls zero |
| LLM | Disabled for now, optional contract kept for later | `G8N_LLM_OPTIONAL` | Budget zero, max calls zero |

No secret belongs in Notion, Git, exported workflows, fixtures or support logs.

## Delivered contract

- `config/external-api-access.json` stores the provider matrix, credential names, V1 decisions and call caps.
- `workflows/wf-03-verify-external-access.json` is inactive and only checks the configuration contract. It does not contain credentials.
- `fixtures/expected/external-api-access-matrix.json` documents expected behavior when secrets are absent.

## Runtime behavior

When a credential is missing, workflows must fail closed with an explicit local-action message instead of silently calling a paid or unauthenticated endpoint.

Pappers and LLM remain represented in config so later tickets can reference their disabled state without hardcoding paid assumptions.

## Local validation commands not executed in cloud

```shell
docker compose up -d
```

Then in local n8n:

1. Create credentials named `G8N_FRANCE_TRAVAIL_OAUTH` and `G8N_SIRENE_API` if you want real calls.
2. Import `workflows/wf-03-verify-external-access.json`.
3. Confirm that Pappers and LLM show `disabled_for_v1`.
4. Confirm that no credential value is printed in node output.
5. Optionally run one minimal authenticated provider call locally after credentials exist.

No command, API call, workflow import, test, lint, build or Docker run was executed in the cloud authoring environment.
