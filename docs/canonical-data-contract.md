# G8N-005 — Canonical data contract

Status: implemented as a versioned public contract, not validated by runtime tests.

## Scope

This contract defines the objects exchanged between collection, company identity resolution, enrichment, classification, scoring and export.

The contract is stored in `schema/canonical-data-contract.json`.

## Conventions

- Field names use `snake_case`.
- Stored timestamps are UTC ISO-8601 strings.
- User-facing display can convert timestamps to `Europe/Paris`.
- Each inter-workflow message carries `schema_version`, `run_id`, `source` and `collected_at` when applicable.
- Large source payloads stay in local JSON files under `data/raw`; Data Tables only carry useful fields, local path and hash.
- Never replace an unknown value with `0` or an empty string unless the field rule explicitly says so.

## Null semantics

| State | Meaning |
| --- | --- |
| absent | Field not provided by the source or previous workflow |
| unknown | Source says the value exists but is not known |
| not_applicable | Field does not apply to this object |
| error | Value could not be produced because a controlled error happened |

## Canonical objects

- `raw_job_offer`
- `job_offer`
- `company`
- `company_match`
- `company_enrichment`
- `job_classification`
- `company_signal`
- `lead_score`
- `export_batch`

## Identifier rules

- `source_offer_id` is the source-level identifier.
- `offer_id` is the canonical G8N identifier.
- `dedupe_fingerprint` is a technical fingerprint used for duplicate and republication handling.
- `company_id` is canonical and should prefer SIREN when resolved.
- Raw payload hashes use SHA-256 labels such as `sha256:<hex>`.

## Versioning

Schema versions follow semver:

- patch: description/example-only change or optional non-breaking field;
- minor: additive compatible field or enum value;
- major: removed field, renamed field, changed meaning, changed requiredness or incompatible enum change.

Consumers should ignore unknown additive fields for the same major version.

## Valid example

```json
{
  "schema_version": "0.1.0",
  "run_id": "run_20260827_120000_manual",
  "source": "france_travail",
  "collected_at": "2026-08-27T10:00:00Z",
  "offer_id": "offer_france_travail_FT-123456",
  "source_offer_id": "FT-123456",
  "dedupe_fingerprint": "fp_company_title_location_contract",
  "title": "Préparateur de commandes",
  "normalized_title": "preparateur_de_commandes",
  "contract_type": "CDI",
  "location_country": "FR",
  "status": "active"
}
```

## Invalid examples

Missing required canonical identifier:

```json
{
  "schema_version": "0.1.0",
  "source": "france_travail",
  "source_offer_id": "FT-123456",
  "title": "Préparateur de commandes"
}
```

Unknown value incorrectly coerced to zero:

```json
{
  "offer_id": "offer_france_travail_FT-123456",
  "declared_positions": 0
}
```

`declared_positions` may be `null` when unknown; zero is only valid when the business source explicitly states zero, which is not expected for an active job advert.

## Manual validation to run later

These commands are for the user’s local checkout and were not executed here:

```bash
python -m json.tool schema/canonical-data-contract.json >/dev/null
```

Manual review steps:

1. Check that one synthetic offer can flow from `raw_job_offer` to `export_batch` without ad hoc renaming.
2. Check that a missing required field produces an explicit rejection in later workflow code.
3. Review the export mapping before building the workbook.

## Known limits

- Physical n8n Data Tables are not created by this ticket.
- No API calls, tests, lint, build, Docker or CI were executed.
- The contract may need a minor version bump after the first real France Travail/SIRENE sample.
