# Local n8n stack operations

## Persistence model

The `g8n_n8n_data` named volume is mounted at `/home/node/.n8n`. n8n's default embedded SQLite configuration is intentionally retained. Account data, workflows, credentials encrypted with `N8N_ENCRYPTION_KEY`, and Data Tables therefore survive container recreation.

Raw payloads and exports are bind-mounted separately so workflows can use stable container paths:

- `/files/raw`
- `/files/exports`

Business timestamps must be normalized to UTC by workflows even though the editor and schedules use `Europe/Paris`.

## Start, stop and inspect

```shell
docker compose up -d
docker compose ps
docker compose logs --follow n8n
docker compose stop
docker compose down
```

On Linux, if n8n cannot write to a bind-mounted directory, assign it to the container's default uid/gid before retrying:

```shell
sudo chown -R 1000:1000 data/raw exports
```

## Backup

Stop n8n first to obtain a consistent SQLite backup:

```shell
docker compose stop n8n
docker run --rm --volume g8n_n8n_data:/source:ro --volume "${PWD}/backups:/backup" alpine:3.22 sh -c "cd /source && tar -czf /backup/n8n-data.tgz ."
docker compose start n8n
```

PowerShell uses the same operation with an absolute working directory:

```powershell
docker compose stop n8n
docker run --rm --volume g8n_n8n_data:/source:ro --volume "${PWD}/backups:/backup" alpine:3.22 sh -c "cd /source && tar -czf /backup/n8n-data.tgz ."
docker compose start n8n
```

Copy `data/raw/` and `exports/` separately if those generated files must also be retained. Backups are ignored by Git and must never contain secrets when shared.

## Destructive reset

The following command permanently deletes the local n8n volume, including the owner account, workflows, Data Tables and encrypted credentials:

```shell
docker compose down --volumes
```

To clear generated bind-mounted data as well, delete the contents of `data/raw/` and `exports/` manually while preserving their `.gitkeep` files. Review the paths before deletion.

## Manual validation — not executed remotely

Run these checks on the user's Docker-equipped machine:

1. Copy `.env.example` to `.env`, replace the encryption-key placeholder and run `docker compose up -d`.
2. Run `docker compose ps` and confirm `n8n` becomes healthy.
3. Confirm <http://localhost:5678> opens and complete the local owner-account wizard.
4. Create a temporary workflow and a Data Table row; restart with `docker compose restart n8n` and confirm both persist.
5. Run `docker compose down` followed by `docker compose up -d`; confirm the same state persists.
6. From a temporary n8n workflow, write synthetic files to `/files/raw` and `/files/exports`; confirm they appear in the corresponding host directories.
7. Run `docker compose ps` and confirm the only published service port is `127.0.0.1:5678` (or the locally configured `N8N_PORT`).
8. Run `git status --short --ignored` and confirm `.env`, raw payloads, exports, backups and SQLite files are not tracked.

Record the command output and observations in the G8N-010 ticket before moving it from Review to Done.
