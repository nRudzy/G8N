# G8N-032 — Exact company and establishment matching

Status: implemented as deterministic workflow skeleton, persistence contract and synthetic cases; not executed.

## Purpose

Exact matching resolves offers that have a strong legal identifier or a single coherent name/location candidate. Fuzzy matching and manual review remain out of scope.

## Deterministic branches

| Method | Auto-match condition | Score |
| --- | --- | ---: |
| `explicit_siret` | Valid SIRET checksum and one open SIRENE establishment | 95 |
| `exact_name_postal_code` | Normalized name and postal code leave one open candidate | 87 |
| `exact_name_city` | Normalized name and city leave one open candidate | 85 |
| `trade_name_establishment` | Trade name/enseigne and location leave one open candidate | 82 |
| `exact_name_conflicting_location` | Name matches but location conflicts or establishment is closed | 64 and ambiguous |

Closed establishments are not auto-matched. Multiple exact candidates remain ambiguous.

## Persistence

The local write order is:

1. Upsert `companies` by `company_key = siren:{siren}`.
2. Upsert `establishments` by `establishment_key = siret:{siret}`.
3. Upsert `company_matches` with method, score, evidence and `match_rule_version`.
4. Update `job_offers` with `company_key`, `establishment_key` and match status.

The exported workflow is inactive and returns planned upserts only. Local Data Table nodes must perform the actual transactional write sequence.

## Evidence

Every match must store:

- original declared company name and location;
- normalized name;
- SIREN/SIRET candidate;
- establishment status;
- score contribution;
- reason code;
- `g8n.company-matching.v1` rule version.

## Workflow skeleton

`workflows/wf-32-exact-company-matching.json` expects offer rows and normalized SIRENE candidate envelopes from WF-31. It validates SIREN/SIRET format and Luhn checksum, selects exact deterministic branches, and returns upsert plans.

It does not call SIRENE and does not write Data Tables in the cloud authoring environment.

## Local validation commands not executed in cloud

```shell
docker compose up -d
```

Then in local n8n:

1. Import WF-31 and WF-32.
2. Feed `fixtures/expected/company-exact-matching-cases.json`.
3. Wire Data Table upserts for `companies`, `establishments`, `company_matches` and `job_offers`.
4. Replay the same lot and confirm no duplicate company or establishment rows.
5. Confirm closed and multi-candidate cases go to review.

No command, workflow import, API lookup, Data Table operation, test, lint, build or Docker run was executed in the cloud authoring environment.
