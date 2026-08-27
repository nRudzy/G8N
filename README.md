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

## Version

The Compose stack pins `docker.n8n.io/n8nio/n8n:2.36.7`. Version upgrades must be explicit, reviewed and accompanied by a backup of `g8n_n8n_data`.

## Current validation state

The repository contains the implementation and manual validation commands. They have not been executed in the cloud authoring environment; local validation is required before the related ticket can be marked Done.
