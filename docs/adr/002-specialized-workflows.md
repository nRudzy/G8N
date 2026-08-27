# ADR-002 — Specialized workflows instead of a monolith

Date: 2026-08-27

Status: Accepted

## Context

G8N includes collection, normalization, matching, enrichment, scoring and export. A single n8n workflow would become hard to debug and rerun.

## Options

1. One monolithic workflow.
2. Several specialized workflows connected through canonical records and run IDs.
3. Mostly external scripts with n8n only as a launcher.

## Decision

Use specialized workflows with explicit inputs/outputs, `run_id`, `schema_version` and canonical records from the data contract.

## Consequences

Positive:

- Easier debugging and replay.
- Clearer ownership per workflow.
- Safer partial reruns.

Negative:

- More workflow files to manage.
- Requires stricter naming and error conventions.
- Cross-workflow state must be explicit.

## Revisit when

- Workflow count becomes difficult to operate locally.
- n8n import/export becomes too cumbersome.
- A later ticket proves a specific flow must be merged for reliability.
