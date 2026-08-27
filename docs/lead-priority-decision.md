# G8N-047 — Lead priority levels and exclusions

Status: implemented as versioned priority rules, inactive workflow skeleton and boundary cases; not executed.

## Levels

| Level | Score range | Gate |
| --- | ---: | --- |
| Chaud | 70–100 | confidence ≥65 and validated identity |
| À qualifier | 45–69 | confidence ≥50 and validated identity |
| Veille | 25–44 | no priority export gate |
| Écarté | 0–24 | no priority export |

Thresholds live in `config/lead-priority.rules.json` and can be edited without changing workflow code.

## Hard exclusions

Hard exclusions keep the calculated score for audit but block or force priority:

- inactive company: force `Écarté`;
- identity not validated: block priority export;
- ICP-excluded sector: force `Écarté`.

## Reasons

The decision uses only real scoring artifacts:

- up to three positive reasons from `breakdown_json`;
- up to three penalty/exclusion reasons from `penalties_json` and exclusion codes.

No LLM text generation is used for priority wording.

## Workflow skeleton

`workflows/wf-72-assign-lead-priority.json` is inactive. It expects scored rows from WF-70/WF-71 and emits `priority_label`, `priority_export_allowed`, `decision_code`, positive reasons and penalty reasons.

## Local validation commands not executed in cloud

```shell
docker compose up -d
```

Then in local n8n:

1. Import WF-72.
2. Feed `fixtures/expected/lead-priority-cases.json`.
3. Verify boundaries 24/25, 44/45 and 69/70.
4. Verify high score/low confidence, inactive company, excluded sector and score ties.

No command, workflow import, test, lint, build, Docker run or Data Table write was executed in the cloud authoring environment.
