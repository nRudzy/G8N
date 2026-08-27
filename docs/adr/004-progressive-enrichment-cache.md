# ADR-004 — Progressive enrichment with local cache

Date: 2026-08-27

Status: Accepted

## Context

External sources such as SIRENE and Pappers may have quotas, costs, latency or credentials. G8N must avoid unnecessary calls and preserve raw evidence locally.

## Options

1. Enrich every company immediately from every source.
2. Enrich progressively only when needed, with local cache and normalized snapshots.
3. Skip enrichment entirely.

## Decision

Use progressive enrichment with local cache. Start with the cheapest/most authoritative source available, store raw payload paths and hashes, and call optional paid or capped sources only when the score or ambiguity justifies it.

## Consequences

Positive:

- Lower quota/cost pressure.
- Reproducible local evidence.
- Better control over incomplete values.

Negative:

- Cache invalidation rules must be explicit.
- Some early scores may have lower confidence.
- More bookkeeping is required.

## Revisit when

- Cached data becomes stale for scoring decisions.
- API terms, quotas or available credentials change.
- Manual review shows enrichment should happen earlier or later.
