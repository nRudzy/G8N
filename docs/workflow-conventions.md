# G8N workflow conventions

This charter applies to every importable n8n workflow in the G8N repository. It keeps workflow chaining, troubleshooting and manual review predictable without adding a heavy governance layer.

## Naming

| Element | Convention | Example |
| --- | --- | --- |
| Workflow | `WF-XX — Intent in sentence case` | `WF-00 — Healthcheck` |
| Business workflow file | `workflows/wf-XX-short-name.json` | `workflows/wf-20-france-travail-search.json` |
| Example workflow file | `workflows/examples/wf-example-short-name.json` | `workflows/examples/wf-example-conventions.json` |
| Trigger node | `Trigger — Intent` | `Trigger — Manual convention sample` |
| Input normalization node | `Normalize — Input envelope` | `Normalize — Input envelope` |
| Decision branch | `If — Business intention` | `If — Payload is usable` |
| Success output node | `Return — Success envelope` | `Return — Success envelope` |
| Error output node | `Return — Error envelope` | `Return — Error envelope` |
| Credential name | `G8N — Provider — Scope — Environment` | `G8N — France Travail — Offres — Local` |
| Environment variable | `G8N_<DOMAIN>_<NAME>` | `G8N_FRANCE_TRAVAIL_CLIENT_ID` |
| Execution label | `WF-XX:${run_id}:${short_status}` | `WF-00:run_20260827_120000:success` |

Node names must describe intent, not node type alone. `If — Payload is usable` is acceptable; `IF1`, `Code 3` and `HTTP Request` are not.

## Standard envelope

Every workflow receives and emits one envelope. The same `run_id` and `correlation_id` move across workflow boundaries, so two workflows can chain without ad hoc mapping.

Required top-level fields:

| Field | Required | Rule |
| --- | --- | --- |
| `run_id` | Yes | Stable identifier for the current end-to-end run. It is created once at the entry workflow and propagated unchanged. |
| `correlation_id` | Yes | Stable identifier for cross-workflow tracing. Use the upstream value when present; otherwise default to `run_id`. |
| `schema_version` | Yes | Contract version. The POC baseline is `g8n.workflow-envelope.v1`. |
| `source` | Yes | Object describing the producer workflow, node and input origin. |
| `timestamps` | Yes | UTC ISO-8601 timestamps for `received_at`, `started_at`, `finished_at` when known. |
| `payload` | Yes | Business data for this step only. Do not place secrets in it. |
| `metadata` | Yes | Operational metadata, retry counters, fixture flags and non-sensitive context. |

### Complete input example

```json
{
  "run_id": "run_2026-08-27T12-00-00Z_001",
  "correlation_id": "corr_2026-08-27_france_scope_demo",
  "schema_version": "g8n.workflow-envelope.v1",
  "source": {
    "workflow_id": "WF-00",
    "workflow_name": "WF-00 — Healthcheck",
    "node_name": "Return — Success envelope",
    "origin": "manual_fixture"
  },
  "timestamps": {
    "received_at": "2026-08-27T12:00:00.000Z",
    "started_at": "2026-08-27T12:00:01.000Z",
    "finished_at": null
  },
  "payload": {
    "company": {
      "siren": "000000000",
      "name": "Synthetic France Example SAS",
      "department": "75",
      "region": "Île-de-France"
    },
    "signals": [
      {
        "type": "mass_hiring",
        "label": "Multiple active offers across operational roles",
        "confidence": 0.72
      }
    ]
  },
  "metadata": {
    "environment": "local",
    "fixture": true,
    "retry_count": 0,
    "upstream_workflow": "WF-00",
    "notes": "Synthetic data only; no Notion or business export."
  }
}
```

### Success output contract

```json
{
  "run_id": "run_2026-08-27T12-00-00Z_001",
  "correlation_id": "corr_2026-08-27_france_scope_demo",
  "schema_version": "g8n.workflow-envelope.v1",
  "status": "success",
  "source": {
    "workflow_id": "WF-EXAMPLE",
    "workflow_name": "WF-EXAMPLE — Convention handoff",
    "node_name": "Return — Success envelope"
  },
  "timestamps": {
    "received_at": "2026-08-27T12:00:00.000Z",
    "started_at": "2026-08-27T12:00:01.000Z",
    "finished_at": "2026-08-27T12:00:02.000Z"
  },
  "payload": {
    "accepted": true,
    "next_workflow": "WF-XX — Downstream workflow",
    "handoff": {
      "company_siren": "000000000",
      "signal_count": 1
    }
  },
  "metadata": {
    "environment": "local",
    "fixture": true,
    "retry_count": 0
  },
  "errors": []
}
```

### Error output contract

```json
{
  "run_id": "run_2026-08-27T12-00-00Z_001",
  "correlation_id": "corr_2026-08-27_france_scope_demo",
  "schema_version": "g8n.workflow-envelope.v1",
  "status": "error",
  "source": {
    "workflow_id": "WF-EXAMPLE",
    "workflow_name": "WF-EXAMPLE — Convention handoff",
    "node_name": "Return — Error envelope"
  },
  "timestamps": {
    "received_at": "2026-08-27T12:00:00.000Z",
    "started_at": "2026-08-27T12:00:01.000Z",
    "finished_at": "2026-08-27T12:00:02.000Z"
  },
  "payload": {
    "recoverable": true,
    "resume_from": "Normalize — Input envelope"
  },
  "metadata": {
    "environment": "local",
    "fixture": true,
    "retry_count": 0
  },
  "errors": [
    {
      "code": "G8N_VALIDATION_MISSING_FIELD",
      "message": "Required field payload.company.siren is missing.",
      "category": "validation",
      "recoverable": true,
      "masked": true,
      "context": {
        "workflow_id": "WF-EXAMPLE",
        "node_name": "If — Payload is usable",
        "missing_field": "payload.company.siren"
      }
    }
  ]
}
```

Error context must include only the minimum data needed to resume or debug. It must never include credentials, source tokens, raw authorization headers, private Notion page content, real candidate records or complete business payload exports.

## Workflow chaining rule

When a workflow calls another workflow, the downstream input must copy these fields unchanged:

- `run_id`
- `correlation_id`
- `schema_version`
- `metadata.retry_count`, incremented only when an actual retry is attempted

The downstream workflow may replace `source` with its own workflow and node details, and may enrich `payload` with its own result. This makes a `WF-20 → WF-21` handoff traceable without local node-by-node mappings.

## Activation and versioning

- Keep imported workflows inactive until local manual validation is complete.
- Activate only from the local n8n UI after credentials, timeouts and error branches have been reviewed.
- Export workflow JSON after each meaningful local change and commit the export in the matching ticket.
- Use the workflow name for the human version, for example `WF-20 — France Travail search v1`.
- Keep `schema_version` stable until a breaking envelope change is required. Breaking changes require a new version such as `g8n.workflow-envelope.v2` and a migration note.
- Reusable sub-workflows must document their accepted envelope fields, produced payload fields and possible error codes in the same ticket documentation.

## Code node rule

Code nodes are allowed for small transformations only:

- normalizing field names;
- creating or passing the envelope;
- masking known sensitive keys;
- selecting a branch value.

They must not contain bulky, untested business logic. Heavier classification, scoring, export formatting or API-specific parsing belongs in documented scripts, config files or small reusable functions that the user can validate locally.

## Timeouts and retries

- Every HTTP/API node must define an explicit timeout in its node settings or documented local setup notes.
- Retries must be intentional and bounded.
- A timeout branch must return an error envelope with category `timeout`.
- Credentials and token refresh failures must return category `credential` without exposing the token or secret value.

## n8n review checklist

Use this checklist before moving a workflow ticket to Review:

- [ ] Workflow name follows `WF-XX — Intent`.
- [ ] File path follows `workflows/wf-XX-short-name.json` or `workflows/examples/wf-example-short-name.json`.
- [ ] Every node has an intention-revealing name.
- [ ] No node contains hard-coded credentials, tokens, cookies or private Notion text.
- [ ] API nodes have explicit timeout and bounded retry behavior.
- [ ] Success path emits the standard success envelope.
- [ ] Error path emits the standard error envelope.
- [ ] Error context is minimal and masks sensitive values.
- [ ] `run_id` and `correlation_id` are propagated unchanged across workflow calls.
- [ ] Reusable sub-workflow contracts are documented.
- [ ] Workflow remains inactive in exported JSON unless local validation is complete.

This checklist detects the required failure modes for review: unnamed nodes, hard-coded secrets, missing timeout and missing error branches.

## Local validation commands not executed in cloud

The cloud authoring session must not run validation. After importing workflows locally, the user can validate manually by:

```shell
docker compose up -d
```

Then in n8n:

1. Import `workflows/wf-00-healthcheck.json`.
2. Import `workflows/examples/wf-example-conventions.json`.
3. Run the example with the synthetic envelope above.
4. Confirm the success output keeps `run_id` and `correlation_id`.
5. Remove `payload.company.siren` from the fixture and confirm the error output contains no token or secret value.

These steps are documented for later local execution only; they were not run while authoring this ticket.
