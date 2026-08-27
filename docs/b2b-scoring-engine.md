# G8N-045 — Versioned B2B scoring engine

Status: implemented as a deterministic scoring configuration, inactive n8n workflow skeleton and synthetic expected cases; not executed.

## Rule version

The active rule is `g8n.b2b-scoring.v1` in `config/b2b-scoring.rules.json`.

Only a rule with `status: active` may write the current score. Simulation rows use a separate key and do not replace production scoring.

## Components

| Component | Max points | Main input |
| --- | ---: | --- |
| Volume | 25 | `company_signals.active_offer_count_30d` |
| Acceleration | 20 | `company_derived_signals.acceleration_index` |
| Tension | 15 | classified tension-job share |
| Diversity / training | 10 | `diversity_index` and training needs |
| Multi-site | 10 | proven `multisite_index` |
| ICP | 10 | V1 ICP score |
| Freshness / quality | 10 | source freshness and data completeness |

Each component returns points, observed value, threshold and reason. Unknown inputs produce zero points plus an explicit missing-input reason instead of fake confidence.

## Penalties

Risk penalties are separate from commercial points and capped at -30 total. They cover hard exclusions, republication inflation, uncertain identity, stale data, health risk and missing core inputs.

Final score is:

```text
score = clamp(business_points + max(total_penalties, -30), 0, 100)
```

## Persistence

`lead_scores` stores:

- `score`, `business_points`, `risk_penalty_points`;
- `breakdown_json`, `penalties_json`, `reasons_json`;
- `score_version`, `inputs_version`, `score_as_of`, `scored_at`;
- `confidence` and `freshness`, later refined by G8N-046.

The current score key is `company_key:rule_version:current`, so replaying the same version updates the same current row.

## Workflow skeleton

`workflows/wf-70-score-b2b-leads.json` is inactive. It contains pure JavaScript scoring helpers only; no external calls, no LLM and no prospecting action.

## Local validation commands not executed in cloud

```shell
docker compose up -d
```

Then in local n8n:

1. Import WF-70.
2. Feed `fixtures/expected/b2b-scoring-cases.json`.
3. Verify minimal, maximal, penalty, unknown-data, version-comparison and replay scenarios.
4. Confirm that inactive rules cannot write current scores.

No command, workflow import, test, lint, build, Docker run or Data Table write was executed in the cloud authoring environment.
