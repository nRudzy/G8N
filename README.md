# G8N

G8N is a local, single-user n8n project for detecting French B2B recruitment signals. The POC runs only on the developer machine with Docker Compose. It uses n8n's embedded SQLite database and Data Tables; it does not require PostgreSQL or a native n8n installation.

## Prerequisites

- Docker Engine with Docker Compose v2, or Docker Desktop
- Git
- A browser

## First start

1. Copy the configuration example without committing the generated file:

   PowerShell:

   ```powershell
   Copy-Item .env.example .env
   ```

   Bash:

   ```bash
   cp .env.example .env
   ```

2. Replace `N8N_ENCRYPTION_KEY` in `.env` with a long, unique value generated locally. Keep this value stable: changing it makes existing encrypted credentials unreadable.
3. Start n8n:

   ```shell
   docker compose up -d
   ```

4. Open <http://localhost:5678> and create the local owner account.

The service is bound to `127.0.0.1`; it is not exposed on the LAN or Internet.

## Daily commands

```shell
docker compose up -d
docker compose ps
docker compose logs --follow n8n
docker compose stop
docker compose down
```

`docker compose down` removes the container and network but preserves the named `g8n_n8n_data` volume. Do not add `--volumes` unless performing the intentional destructive reset documented below.

## Local paths

| Host path | Container path | Purpose |
| --- | --- | --- |
| Docker volume `g8n_n8n_data` | `/home/node/.n8n` | SQLite, workflows, encrypted credentials and n8n state |
| `data/raw/` | `/files/raw` | Large source payloads retained for replay |
| `exports/` | `/files/exports` | Generated CSV/XLSX files |

Structured business records belong in n8n Data Tables. Raw payloads and exports are deliberately ignored by Git.

See [docs/local-stack.md](docs/local-stack.md) for backup, reset and the local validation procedure.
See [docs/security-and-retention.md](docs/security-and-retention.md) before creating credentials, exporting a workflow or sharing diagnostic output.
See [docs/adr/README.md](docs/adr/README.md) for Architecture Decision Records and the ADR template.
See [docs/workflow-conventions.md](docs/workflow-conventions.md) for workflow naming, run envelopes, error contracts and the n8n review checklist.
See [docs/fixtures-and-reset.md](docs/fixtures-and-reset.md) for synthetic fixtures, mock mode and targeted local reset procedures.
See [docs/france-travail-auth-spike.md](docs/france-travail-auth-spike.md) for the France Travail credential contract and unauthenticated cloud-safe auth spike skeleton.
See [docs/france-travail-manual-run.md](docs/france-travail-manual-run.md) for the WF-10 manual search configuration and dry-run summary.
See [docs/france-travail-pagination-checkpoints.md](docs/france-travail-pagination-checkpoints.md) for bounded pagination, retry and checkpoint policy.
See [docs/raw-ingestion-persistence.md](docs/raw-ingestion-persistence.md) for idempotent run and raw offer persistence.
See [docs/job-offer-normalization.md](docs/job-offer-normalization.md) for France Travail raw-to-canonical offer mapping.
See [docs/job-offer-deduplication.md](docs/job-offer-deduplication.md) for canonical offer uniqueness and republication handling.
See [docs/france-travail-incremental-schedule.md](docs/france-travail-incremental-schedule.md) for local incremental collection and bounded backfill.
See [docs/france-travail-vertical-slice-csv.md](docs/france-travail-vertical-slice-csv.md) for the local France Travail to CSV vertical slice.
See [docs/company-identity-matching.md](docs/company-identity-matching.md) for SIREN/SIRET resolution, evidence scoring and ambiguity rules.
See [docs/sirene-lookup-cache.md](docs/sirene-lookup-cache.md) for the local SIRENE lookup contract, cache policy and error handling.
See [docs/company-exact-matching.md](docs/company-exact-matching.md) for deterministic SIRET/name/location matching and persistence.
See [docs/company-tolerant-matching.md](docs/company-tolerant-matching.md) for bounded fuzzy candidate ranking and ambiguity queue rules.
See [docs/company-identity-consolidation.md](docs/company-identity-consolidation.md) for SIREN/SIRET consolidation, aliases and identity snapshots.
See [docs/company-match-review-overrides.md](docs/company-match-review-overrides.md) for CSV ambiguity review and controlled human override imports.
See [docs/pappers-targeted-enrichment.md](docs/pappers-targeted-enrichment.md) for gated Pappers enrichment, cache, whitelist and budget circuit breaker.
See [docs/company-health-normalization.md](docs/company-health-normalization.md) for cautious legal/financial health normalization without false zeroes.
See [docs/company-matching-benchmark.md](docs/company-matching-benchmark.md) for the reproducible matching precision benchmark contract.
See [docs/job-taxonomy-training-needs.md](docs/job-taxonomy-training-needs.md) for the versioned tension job taxonomy and training-need mapping.

## Version

The Compose stack pins `docker.n8n.io/n8nio/n8n:2.36.7`. Version upgrades must be explicit, reviewed and accompanied by a backup of `g8n_n8n_data`.

## Current validation state

The repository contains the implementation and manual validation commands. They have not been executed in the cloud authoring environment; local validation is required before the related ticket can be marked Done.
