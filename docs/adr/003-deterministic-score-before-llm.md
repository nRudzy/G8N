# ADR-003 — Deterministic score before LLM assistance

Date: 2026-08-27

Status: Accepted

## Context

The POC needs explainable B2B priority levels. The user also forbids paid additional OpenAI API usage for this execution.

## Options

1. Deterministic scoring first.
2. LLM-first classification and scoring.
3. Manual scoring only.

## Decision

Implement deterministic scoring before any optional LLM assistance. LLM classification can remain optional, bounded and disabled by default.

## Consequences

Positive:

- Scores are reproducible and explainable.
- No paid AI dependency is required for the POC baseline.
- Easier local validation and calibration.

Negative:

- Some nuanced cases may need manual review.
- Keyword/taxonomy rules need maintenance.
- Optional LLM paths require strict cost and privacy controls later.

## Revisit when

- Deterministic rules cannot classify a meaningful share of offers.
- The user explicitly enables an authorized, bounded LLM mechanism.
- Local validation shows unacceptable false positives or false negatives.
