# G8N-002 — Mass hiring signals

Status: implemented as public technical rules and synthetic reference data, not validated against live sources.

## Time model

All signal windows use `Europe/Paris`.

Windows are rolling intervals evaluated against an `observed_at` cutoff:

- `24h`: `[cutoff - 24 hours, cutoff)`
- `7d`: `[cutoff - 7 days, cutoff)`
- `30d`: `[cutoff - 30 days, cutoff)`

The lower bound is inclusive and the upper bound is exclusive. This avoids double counting records exactly at the next cutoff.

## Counting model

Deduplicate before counting.

1. Prefer the source offer identifier when available.
2. Otherwise use a fallback identity: company identifier, normalized title, normalized location and contract type.
3. Treat republications as the same demand signal when fallback identity is stable.
4. Count multi-position offers as declared headcount when available; otherwise count one advertised position and lower confidence.

## Signals

The editable rules live in `config/mass-hiring-signals.json`.

| Signal | Meaning |
| --- | --- |
| `active_offer_volume` | Deduplicated adverts in the window |
| `declared_position_volume` | Sum of declared positions, falling back to one |
| `acceleration` | Current 7-day volume versus previous 7 days |
| `job_family_diversity` | Distinct normalized job families in 30 days |
| `multi_site_presence` | Distinct work locations in 30 days |
| `tension_job_share` | Share of offers in tension job families |
| `recurrence` | Months with at least one offer over trailing 90 days |
| `republication_pressure` | Republishing ratio, used to reduce confidence rather than inflate demand |

## Labels

| Label | Intended use |
| --- | --- |
| Chaud | Strong signal, likely priority prospect |
| À qualifier | Credible signal requiring business review |
| Veille | Weak, early or incomplete signal to monitor |
| Écarté | Out of ICP, negligible demand or duplicate-only signal |

## Reference data

`fixtures/mass-hiring-reference-cases.json` contains 30 synthetic cases covering:

- small and large volumes;
- multi-site hiring;
- duplicates and republications;
- multi-position adverts;
- incomplete company, location, contract or headcount data;
- the four target labels.

The fixture is intentionally synthetic and safe for a public repository.

## Manual validation to run later

These commands are for the user’s local checkout and were not executed here:

```bash
python -m json.tool config/mass-hiring-signals.json >/dev/null
python -m json.tool fixtures/mass-hiring-reference-cases.json >/dev/null
```

Manual review steps:

1. Pick five fixture cases and calculate the listed signals by hand.
2. Check cases around midnight Europe/Paris using the inclusive/exclusive window rule.
3. Verify that republications increment republication pressure but do not double active offer volume.
4. Confirm whether the default thresholds are too aggressive after the first real France Travail sample.

## Known limits

- No live France Travail, SIRENE, Pappers or other API call has been executed.
- The formulas are deterministic rules for later implementation; this ticket does not implement scoring execution nodes.
- Labels are best-effort defaults delegated by the user and should stay configurable.
