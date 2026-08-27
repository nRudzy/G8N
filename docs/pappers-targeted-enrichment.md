# G8N-036 — Targeted Pappers enrichment

Status: implemented as gated enrichment contract, inactive workflow skeleton and synthetic cases; real Pappers call not executed.

## Purpose

Pappers is optional and must be called only for eligible companies. It does not replace SIRENE identity and must not store personal contact, representative or document data.

## Gate

An enrichment call is allowed only when:

- Pappers is enabled locally;
- a SIREN/company key is validated;
- identity confidence is at least 85;
- minimal signal is present;
- cache is absent or expired;
- per-run and daily budgets are available.

Quota reached returns `deferred`, never `company invalid`.

## Whitelist

Only company-level legal/health fields listed in `config/pappers.enrichment.json` are retained. Phones, emails, representatives, beneficial owners and documents are forbidden.

## Workflow skeleton

`workflows/wf-40-pappers-targeted-enrichment.json` is inactive. It evaluates eligibility, cache, budget and normalized output. It has no connected HTTP node and performs no Data Table operation in the cloud.

## Local validation commands not executed in cloud

```shell
docker compose up -d
```

Then in local n8n:

1. Create the `Pappers API — local` credential after G8N-003.
2. Import WF-40.
3. Wire `pappers_cache` and `company_enrichments`.
4. Run `fixtures/pappers/pappers-enrichment-gate-cases.json`.
5. Confirm under-threshold, cache hit, quota, divergence and disabled cases.

No command, credential read, API call, workflow import, Data Table operation, test, lint, build or Docker run was executed in the cloud authoring environment.
