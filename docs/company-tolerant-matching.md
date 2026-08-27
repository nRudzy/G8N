# G8N-033 — Tolerant company matching and ambiguity queue

Status: implemented as deterministic candidate ranking, ambiguity queue contract and synthetic cases; not executed.

## Purpose

Tolerant matching helps with accents, legal forms, abbreviations and light typos without inventing a company. It is never allowed to auto-match from name similarity alone.

## Candidate bounds

Candidate search must be bounded before scoring:

1. Same postal code when available.
2. Same city.
3. Same department.
4. Token-filtered fallback only when location is weak.

The candidate list is capped to five rows.

## Scoring dimensions

| Dimension | Weight |
| --- | ---: |
| Name similarity | 55 |
| Location | 25 |
| Activity/NAF | 10 |
| Identifier hint | 10 |

Auto-match requires score `>= 85` and a top-1 margin of at least 12 points. Scores from 60 to 84, close top candidates, location conflicts and weak evidence go to the ambiguity queue.

## Ambiguity queue

`company_match_reviews` stores cases that need local human review. Each row keeps top candidates, score by dimension, reason code and `match_rule_version`.

No LLM is used. Recruitment agencies and hidden employers remain unresolved unless legal evidence exists.

## Workflow skeleton

`workflows/wf-33-tolerant-company-matching.json` is inactive. It ranks supplied candidates, prepares `company_match_candidates`, and emits review queue rows. It does not call APIs or write Data Tables.

## Local validation commands not executed in cloud

```shell
docker compose up -d
```

Then in local n8n:

1. Import WF-33 after WF-31/WF-32.
2. Feed `fixtures/expected/company-tolerant-matching-cases.json`.
3. Wire Data Table upserts for candidates, reviews and matches.
4. Change thresholds and replay to confirm idempotent match keys.
5. Measure false positives and false negatives on the reference set.

No command, workflow import, API lookup, Data Table operation, test, lint, build or Docker run was executed in the cloud authoring environment.
