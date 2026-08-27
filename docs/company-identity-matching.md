# G8N-030 — SIREN/SIRET resolution and confidence strategy

Status: implemented as a versioned matching specification and synthetic expected cases; not executed.

## Decision

Use a conservative, evidence-first resolver for France-wide employer identity.

The matcher must preserve the original declared employer values and separately store normalized comparison values, evidence, reason codes and `match_rule_version`.

## Thresholds

| Outcome | Score | Rule |
| --- | ---: | --- |
| Auto-match | `>= 85` | Requires legal identifier evidence or a single candidate with exact name and location evidence |
| Ambiguous review | `60–84` | Plausible but incomplete, tolerant or multi-candidate evidence |
| No paid enrichment | `< 70` | Do not call paid enrichment APIs below this threshold |
| Rejected/unresolved | `< 60` | Store reason and keep the offer/company unresolved |

The initial thresholds are intentionally strict. Location alone never validates a company.

## Decision tree

1. Use explicit SIRET when syntactically valid and confirmed by an authoritative lookup.
2. Use explicit SIREN when syntactically valid and confirmed; require location evidence before choosing an establishment.
3. Try exact normalized name plus exact postal code or city; auto-match only if a single candidate remains.
4. Try trade name or enseigne links only when an authoritative source ties the name to the candidate.
5. Use tolerant name matching only as an ambiguous review input unless corroborated by strong location or activity evidence.
6. Keep hidden companies, recruitment intermediaries and inferred clients unresolved unless legal evidence is present.

## Evidence scoring

`config/company-matching.json` defines positive and negative score contributions. Evidence is additive but capped to 100 and must keep reason codes. Negative evidence can prevent an otherwise attractive match from being auto-validated.

Required stored evidence:

- declared company name, city and postal code as originally seen;
- normalized company name used for comparison;
- candidate SIREN/SIRET and establishment status;
- matched rule step;
- score contributions;
- reason codes;
- `match_rule_version`.

## SIREN versus SIRET

Commercial aggregation can happen at SIREN level, but establishment evidence must be retained when a SIRET is selected. A SIREN-level match must not pretend that a specific establishment was proven.

## Recruitment agencies and masked employers

Offers from intermediaries stay assigned to the intermediary only when that is the declared legal employer. The presumed end client is never inferred from a phrase like "pour son client" without explicit legal evidence.

Masked employers remain unresolved and must not trigger paid enrichment.

## Expected cases

`fixtures/expected/company-matching-cases.json` covers:

- explicit SIRET;
- exact name plus postal code;
- enseigne versus legal name;
- homonyms;
- recruitment agency/client inference;
- hidden company;
- location-only rejection.

## Local validation commands not executed in cloud

Later local implementation can validate with:

```shell
docker compose up -d
```

Then:

1. Import the SIRENE workflow once G8N-031 exists.
2. Run the synthetic cases from `fixtures/expected/company-matching-cases.json`.
3. Confirm every decision has evidence and reason codes.
4. Confirm homonyms and agencies do not auto-match.
5. Confirm no paid enrichment is attempted below the configured threshold.

No command, workflow import, API lookup, Data Table operation, test or paid enrichment was executed in the cloud authoring environment.
