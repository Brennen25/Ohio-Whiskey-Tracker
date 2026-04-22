# Phase 1 Build Plan

## Objective
Build a working MVP that shows OHLQ locations and official/community release signals on one map.

## Step 1: Create the source-of-truth data model
Goal: every downstream job writes to one normalized schema.

Deliverables:
- Postgres database with PostGIS
- tables from `db/schema.sql`
- seed list of top tracked bottles

Exit criteria:
- database migrations applied
- at least 20 tracked bottles seeded
- at least 100 OHLQ locations stored with lat/lng

## Step 2: Ingest OHLQ locations
Goal: populate all stores and keep them fresh.

Tasks:
- fetch location directory
- parse store metadata
- normalize address/city/zip
- geocode only if missing coordinates
- upsert by OHLQ location identifier or canonical store slug

Exit criteria:
- every visible OHLQ location appears on a map
- no duplicate stores

## Step 3: Ingest official release/event pages
Goal: capture scheduled bonus releases and participating stores.

Tasks:
- detect event pages
- extract event title, date, time, participating regions/locations
- extract product list if available
- join events to locations

Exit criteria:
- one event page can be turned into rows in `release_events` and `release_event_locations`
- event times display in local time consistently

## Step 4: Build a static map page
Goal: prove the map UX before intelligence complexity.

Tasks:
- render Ohio map
- cluster markers
- click marker to show store drawer
- list official upcoming events per store

Exit criteria:
- working store map
- working location detail drawer

## Step 5: Add Reddit ingestion
Goal: convert Reddit posts into structured, location-aware signals.

Tasks:
- choose communities and search terms
- collect post metadata, permalink, created time, body
- optionally collect top comments only
- send text through extraction prompt
- resolve extracted store/product/date/time
- write to `signals`

Exit criteria:
- at least 10 sample Reddit posts converted into structured signals
- confidence score is visible in admin/debug view

## Step 6: Add selected X-account ingestion
Goal: enrich store-level intelligence from trusted tracked accounts.

Tasks:
- maintain a curated account list
- fetch posts from those accounts only
- extract and normalize entities
- save to `signals`
- keep this provider behind a feature flag and kill switch

Exit criteria:
- tracked accounts can be activated/deactivated without code changes

## Step 7: Add confidence scoring and dedupe
Goal: merge noisy evidence into one useful state.

Tasks:
- score each signal
- decay old signals
- cluster similar signals by store/product/time window
- compute `location_product_state`

Exit criteria:
- a store/product combination has one current state row
- evidence is still explorable as a timeline

## Step 8: Build map filtering
Goal: make the map actually useful for hunting.

Filters:
- bottle
- city or zip radius
- official only
- community only
- corroborated only
- confidence threshold
- freshness window

Exit criteria:
- users can narrow from statewide view to one product + area in seconds

## Step 9: Add alerts
Goal: convert passive map usage into active monitoring.

Tasks:
- store alert preferences
- notify on new high-confidence signals
- dedupe notifications
- support email and push later

Exit criteria:
- one user can subscribe to a bottle + radius or bottle + store

## Step 10: Add admin review
Goal: prevent bad signals from polluting the UX.

Tasks:
- view raw source text
- show extracted entities
- allow approve/reject/edit
- store reviewer action

Exit criteria:
- uncertain or low-confidence signals can be corrected manually

## What not to build in Phase 1
- user submissions
- predictive queue models
- advanced historical analytics
- reputation systems for every random user
- native mobile apps

## The weekly execution rhythm I recommend
- Day 1: schema and local dev stack
- Day 2: OHLQ location ingestion
- Day 3: official event ingestion
- Day 4: map UI
- Day 5: Reddit ingestion
- Day 6: confidence scoring
- Day 7: cleanup and deployment
