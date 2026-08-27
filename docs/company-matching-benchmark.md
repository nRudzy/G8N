# G8N-038 — Company matching precision benchmark

Status: implemented as benchmark contract, synthetic 50-case dataset and inactive report workflow; not executed.

## Purpose

The matching benchmark measures precision before downstream scoring. Ambiguous cases are not counted as false successes; the priority is avoiding false auto-validations.

## Dataset

`fixtures/expected/company-matching-benchmark-synthetic-50.json` provides a 50-case synthetic structure stratified across:

- explicit SIRET;
- exact name/location;
- trade name;
- typo;
- homonym;
- hidden employer or recruitment agency.

The synthetic dataset is a runnable structure only. Local authorized real or mock-faithful cases should replace/extend it before a real go/no-go.

## Metrics

The benchmark reports:

- precision of auto-validated matches;
- ambiguity rate;
- coverage;
- exact versus tolerant results;
- error categories;
- go/no-go recommendation.

The V1 rule is: auto-validated precision must be at least 90%, otherwise thresholds are raised.

Pappers remains gated by free/approved budget. LLM is not part of V1, but not excluded later.

## Workflow skeleton

`workflows/wf-38-company-matching-benchmark.json` is inactive. It expects expected cases and actual match outputs, computes counts and emits a report payload. It does not execute matching workflows or tests.

## Local validation commands not executed in cloud

```shell
docker compose up -d
```

Then in local n8n:

1. Import WF-38.
2. Run WF-31/WF-32/WF-33/WF-35 locally on the benchmark cases.
3. Feed actual outputs into WF-38.
4. Replay twice and compare deterministic results.
5. Change thresholds and compare precision versus coverage.

No command, workflow import, matching execution, benchmark execution, test, lint, build or Docker run was executed in the cloud authoring environment.
