# ADR-005 — No Indeed scraping in V1

Date: 2026-08-27

Status: Accepted

## Context

G8N targets a local, compliant POC. The project page excludes reintroducing Indeed scraping in contradiction with the current scope.

## Options

1. Scrape Indeed in V1.
2. Use only authorized APIs and local fixtures in V1.
3. Add Indeed later only through an explicitly authorized and compliant mechanism.

## Decision

Do not scrape Indeed in V1. Keep collection work focused on authorized sources and synthetic/local fixtures until credentials and terms are available through an approved mechanism.

## Consequences

Positive:

- Avoids legal and operational ambiguity.
- Keeps V1 aligned with the project scope.
- Reduces anti-bot and reliability risk.

Negative:

- Source coverage may be lower.
- Some market signals may be missed until a compliant source exists.

## Revisit when

- The user provides an explicitly authorized source or contract.
- Legal/compliance review approves a concrete integration path.
- The backlog is updated to include the source without contradicting the project page.
