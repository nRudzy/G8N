# G8N-001 — ICP and targeting filters

Status: implemented as a configurable public technical baseline, not validated with real business data.

## Decision baseline

G8N V1 targets employers hiring in France. The initial geographic scope is the whole country (`FR`) rather than a region or department shortlist.

The ICP is intentionally broad for the POC. Unknown values are not rejected silently; they remain neutral unless a hard exclusion is explicitly met.

## Decision order

1. Apply hard exclusions.
2. Add geography, sector, company-size, job-family and contract scores.
3. Keep unknown values neutral.
4. Classify the prospect with configurable score thresholds.

Default thresholds are defined in `config/targeting.icp.json`:

| Score | Class |
| ---: | --- |
| >= 55 | Target |
| >= 30 | Qualified |
| >= 10 | Watch |
| < 10 | Out of scope |

## Effects

| Criterion | Effect | Default handling |
| --- | --- | --- |
| Geography | Bonus | Whole France is accepted |
| NAF sector | Bonus, neutral, or hard exclusion | Unknown NAF is neutral |
| Employee band | Bonus, penalty, or information | Unknown size is information only |
| Job family | Bonus or penalty | Unknown job family is neutral |
| Contract type | Bonus or penalty | Unknown contract is neutral |
| Hard exclusions | Filter | Only when the condition is explicit |

## Config files

- `config/targeting.icp.json` contains the editable ICP parameters.
- `fixtures/icp-classification-examples.json` contains synthetic classification examples for later manual review.

Both files are safe to publish because they contain no Notion export, no real customer data and no secret.

## Manual validation to run later

These commands are examples for the user to run locally after checkout. They were not executed during implementation:

```bash
python -m json.tool config/targeting.icp.json >/dev/null
python -m json.tool fixtures/icp-classification-examples.json >/dev/null
```

Manual review steps:

1. Review whether the France-wide scope is still desired after first collection volume.
2. Apply the ICP to at least ten heterogeneous offers.
3. Confirm that missing employee count, NAF or contract information does not reject a prospect silently.
4. Adjust score weights in `config/targeting.icp.json` before wiring the scoring workflow.

## Known limits

- The sector and job-family lists are broad starting defaults, not a proven conversion model.
- The examples are synthetic and exist to exercise cases; they are not evidence that the market behaves this way.
- Real acceptance requires the user’s local validation and may change thresholds before later scoring tickets.
