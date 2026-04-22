# OHLQ Allocation Tracker Starter Kit

This starter kit is the planning and schema layer for an app that:
- maps all OHLQ locations,
- tracks official release pages and participating locations,
- ingests community signals from Reddit and selected X accounts,
- scores confidence per store/product,
- presents everything on one interactive map.

## What to build first

1. Create a repo and commit the files in this folder.
2. Provision Postgres with PostGIS.
3. Implement the database in `db/schema.sql`.
4. Build the OHLQ ingester first.
5. Add release-event ingestion.
6. Add Reddit ingestion.
7. Add selected X-account ingestion.
8. Build the map UI only after the OHLQ and event pipelines are stable.
9. Add AI extraction and signal deduping.
10. Add alerts and admin review.

## Recommended build order

Read these files in order:
1. `docs/phase-1-build-plan.md`
2. `db/schema.sql`
3. `docs/source-trust-model.md`
4. `schemas/community-signal.schema.json`
5. `prompts/extract-community-signal.md`
6. `docs/copilot-workflow.md`

## Copilot vs ChatGPT

Use ChatGPT for:
- architecture,
- data modeling,
- prompt design,
- source-trust rules,
- debugging ingestion logic,
- reviewing PRs and schemas.

Use GitHub Copilot for:
- writing the repetitive implementation,
- generating route handlers,
- test scaffolding,
- iterative refactors inside your repo,
- issue-to-PR execution.

## Minimal MVP

- OHLQ locations
- OHLQ release pages
- top allocated bottle catalog
- interactive Ohio map
- location detail drawer
- Reddit search ingestion
- curated X account ingestion
- confidence scoring
- source links and evidence timeline

## Non-negotiable product rules

- OHLQ is the highest-trust source.
- Community chatter is evidence, not truth.
- Preserve source URLs and timestamps.
- Mark unverified claims as unverified.
- Apply freshness decay to all signals.
- Keep X ingestion behind a feature flag.

## Suggested repo layout

```text
apps/
  web/
    app/
    components/
    lib/
services/
  ingest/
    ohlq/
    reddit/
    x/
    enrichment/
db/
  schema.sql
docs/
prompts/
schemas/
```

## First coding milestone

Get to the point where you can answer this query from your own database:

> Show every OHLQ location within 50 miles of Columbus that has either an official release event in the next 7 days or a corroborated community signal for Weller Antique in the last 24 hours.

Once that works, the rest of the app becomes much easier.
