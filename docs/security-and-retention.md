# Security, credentials and retention

## Non-negotiable rules

- Keep every secret in an n8n credential or the untracked local `.env` file.
- Never place tokens, passwords, cookies, private keys or `Authorization` headers in workflow parameters, Code nodes, fixtures, logs or Git.
- Do not export decrypted credentials. The n8n CLI option that emits credentials in plain text is prohibited for normal G8N operations.
- Keep `N8N_ENCRYPTION_KEY` long, unique and stable. Back it up outside Git together with the encrypted n8n volume.
- Treat raw payloads, exports, execution data and screenshots as potentially sensitive even when they contain company data only.

## Credential naming convention

Use lower-case kebab-case:

```text
<provider>-<purpose>-<environment>
```

The POC environment name is `local`. Examples describe names only, never values:

- `france-travail-oauth-local`
- `insee-sirene-api-local`
- `pappers-api-local`
- `llm-classification-api-local`

Nodes must reference the credential object. Rotating a credential must not require editing node parameters.

## Execution retention

The Compose defaults implement this policy:

| Setting | Default | Rationale |
| --- | --- | --- |
| Successful production executions | not saved | Avoid retaining large payloads that add no diagnostic value |
| Failed executions | saved | Permit local diagnosis and controlled replay |
| Manual executions | saved | Permit development inspection until local validation is complete |
| Maximum execution age | 168 hours | Remove retained execution data after seven days |
| Maximum retained executions | 10,000 | Bound SQLite growth if error volume spikes |
| Log level | `info` | Avoid verbose request/response dumps |

The values are configurable in the local `.env`, but increasing retention requires an explicit reason and a disk-space review. Error data can still contain sensitive headers or payloads; workflows must never add these values to thrown errors or logs.

Before moving to unattended operation, consider setting `EXECUTIONS_DATA_SAVE_MANUAL_EXECUTIONS=false` after local debugging is complete.

## Raw payload and export lifecycle

Initial policy values are 30 days for `data/raw` and `exports`. They are documented as `G8N_RAW_RETENTION_DAYS` and `G8N_EXPORT_RETENTION_DAYS`; n8n does not apply these project-specific variables automatically. Until a dedicated lifecycle workflow exists, purge is a deliberate local maintenance operation.

Review the resolved paths before running either command.

PowerShell examples:

```powershell
Get-ChildItem .\data\raw -File -Recurse |
  Where-Object LastWriteTime -LT (Get-Date).AddDays(-[int]$env:G8N_RAW_RETENTION_DAYS) |
  Remove-Item

Get-ChildItem .\exports -File -Recurse |
  Where-Object LastWriteTime -LT (Get-Date).AddDays(-[int]$env:G8N_EXPORT_RETENTION_DAYS) |
  Remove-Item
```

Bash examples:

```bash
find ./data/raw -type f ! -name .gitkeep -mtime "+${G8N_RAW_RETENTION_DAYS:-30}" -print -delete
find ./exports -type f ! -name .gitkeep -mtime "+${G8N_EXPORT_RETENTION_DAYS:-30}" -print -delete
```

## Workflow sharing checklist

Before committing or sharing an exported workflow:

- [ ] Export the workflow only; do not export credentials.
- [ ] Confirm credential references contain only expected credential names and IDs.
- [ ] Search the JSON for `Authorization`, `Bearer`, `token`, `apiKey`, `password`, `cookie`, `client_secret` and private-key markers.
- [ ] Inspect HTTP Request headers, query parameters and Code nodes manually.
- [ ] Replace real request/response bodies with synthetic fixtures.
- [ ] Remove execution data, pinned production data, personal data and local absolute paths.
- [ ] Confirm `git diff --cached` contains no raw payload, export or `.env` content.
- [ ] Keep error messages to provider, status code, correlation ID and a sanitized reason; never serialize full request headers.

## Local validation — not executed remotely

1. Start n8n with the original encryption key and create a disposable credential using a synthetic value.
2. Reference it from a temporary HTTP Request node, export the workflow JSON and perform the sharing checklist.
3. Rotate the disposable credential in the n8n UI and confirm the node does not need editing.
4. Trigger a synthetic HTTP error without a real external service and inspect the saved execution and console logs for sensitive fields.
5. Restart with the same encryption key and confirm the disposable credential remains readable.
6. In an isolated disposable volume only, start with a different key and record the behavior without altering the main local volume.
7. Confirm old execution records are pruned according to the configured age/count after sufficient local runtime.

No item above has been executed in the cloud authoring environment.
