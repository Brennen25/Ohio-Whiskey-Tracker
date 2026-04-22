# Practical Copilot Workflow

## Bottom line
Use Copilot after you have the schema, task list, and trust rules pinned down.

## Where Copilot helps most
- creating API route boilerplate
- generating TypeScript types from the schema
- writing parsing helpers
- writing test fixtures for OHLQ pages and community posts
- iterating on map filters and UI components
- repo-wide refactors

## Where Copilot is not enough by itself
- deciding your source-trust policy
- designing confidence scoring
- making product decisions about what counts as verified
- sorting out API/terms strategy for Reddit and X
- validating whether an extraction rule is actually safe

## Best working style
1. Create a GitHub repo.
2. Paste in the files from this starter kit.
3. Open an issue for each step in `phase-1-build-plan.md`.
4. Ask Copilot agent mode to implement one issue at a time.
5. Review every PR against the source-trust and schema docs.

## Example issues to hand Copilot
### Issue 1
Create a Postgres migration from `db/schema.sql` and add a seed script for 20 tracked allocated bourbons.

### Issue 2
Implement an OHLQ location ingester that upserts stores into `locations` and preserves the original source URL and hours JSON.

### Issue 3
Implement an event-page parser that extracts title, dates, sale start time, participating stores, and product names into `release_events` and `release_event_locations`.

### Issue 4
Build a map page that renders all locations from the database and opens a detail drawer on click.

### Issue 5
Add a service that accepts raw Reddit or X text, runs structured extraction, resolves store and product guesses, and inserts rows into `signals`.

## Prompting Copilot effectively
Bad:
- Build the whole app.

Good:
- Implement `parseOhlqEventPage(html: string)` and return a typed object with title, event times, locations, and product names. Add unit tests for two sample HTML fixtures.

Good:
- Create a map drawer component that shows store name, address, upcoming official events, latest community signals, and evidence count. Use the fields already defined in the schema.

## Recommended division of labor
- You: choose priorities, review correctness, own product decisions.
- Copilot: write code for one bounded issue at a time.
- ChatGPT: refine prompts, schemas, extraction logic, SQL, edge-case handling, and review architecture.
