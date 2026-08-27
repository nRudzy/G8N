# ADR-001 — Local POC with n8n, SQLite and Data Tables

Date: 2026-08-27

Status: Accepted

## Context

G8N must remain a 100% local POC. The project needs a lightweight automation runtime, local persistence and editable business tables without introducing a managed database service.

## Options

1. n8n with embedded SQLite and Data Tables.
2. n8n with PostgreSQL from day one.
3. Custom code-only service without n8n.

## Decision

Use local n8n in Docker Compose with embedded SQLite and n8n Data Tables. Keep PostgreSQL only as a migration option if local SQLite/Data Tables become a proven bottleneck.

## Consequences

Positive:

- Simple local setup.
- No hosted database or extra service.
- Fits the user's local-only requirement.

Negative:

- SQLite is not a multi-user production database.
- Backups and reset procedures matter.
- Heavy analytical queries may require future migration.

## Revisit when

- Data Tables cannot represent required business tables.
- SQLite becomes too slow or fragile for local volume.
- Multi-user access becomes a real requirement.
