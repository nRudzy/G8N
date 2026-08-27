# G8N-041 — Deterministic job offer classification

Status: implemented as rule-based classifier, inactive workflow skeleton and 20 synthetic cases; not executed.

## Purpose

WF-50 is the explainable baseline before any optional LLM. V1 does not require or call an LLM.

## Decision order

1. Structured job code when available.
2. Exact normalized keyword match.
3. Contains keyword fallback.
4. Ambiguous conflict when several unrelated families match.
5. Unclassified when no rule matches.

Every result keeps classifier version, taxonomy version, confidence and reason codes.

## Cache

Classification can be cached by useful offer fingerprint plus taxonomy/classifier version. A taxonomy update only requires replaying affected offers.

## Workflow skeleton

`workflows/wf-50-classify-job-offers.json` is inactive. It expects normalized offers and taxonomy rows, returns classification upsert plans, and does not write Data Tables in the cloud.

## Local validation commands not executed in cloud

```shell
docker compose up -d
```

Then in local n8n:

1. Import WF-50.
2. Load taxonomy from G8N-040.
3. Feed `fixtures/expected/job-classification-20-cases.json`.
4. Verify deterministic replay and version change behavior.

No command, workflow import, classification execution, Data Table operation, test, lint, build or Docker run was executed in the cloud authoring environment.
