# Data layer rules (database, schema, API boundary)

Opt-in. Import from a project's `CLAUDE.md`.

## Schema

- **The schema file is the single source of truth.** Row and payload types are inferred off it. Never hand-write an interface mirroring a table, and never restate the schema in prose docs. Document only the decisions that are not obvious from reading it.
- **Schema changes go through the migration toolchain.** No process creates or alters tables at boot.
- **One storage convention for timestamps, chosen once and documented,** with a column type wide enough for it. Unix milliseconds in a 32-bit integer silently overflows.
- **JSON columns store objects, not stringified JSON.** If the driver needs a string column, marshal through one helper and read through one parser that normalizes legacy shapes and nil slices, so consumers always see a well-formed value.
- **Narrow stringly-typed columns to unions at the type layer** rather than a database enum, so adding a value is not a migration.
- **One ORM or query builder. Never a second data-access layer on top of it.**
- **Retention is a decision, not an accident.** Raw high-cardinality rows roll up into aggregates on a schedule. Say which tables are kept forever and why.

## Query discipline

The database is over the network. Per-row and per-entity round trips are not free.

- **No N+1 across a collection.** Anything rendering a full list uses a bulk helper that fetches every entity's inputs in a fixed number of queries, not a fixed number per entity.
- **Aggregate in SQL, never in application code.** Never load a time window of rows to count it or average it. A 90-day window at a two-minute cadence is tens of thousands of rows per entity.
- **Every query is async. Independent queries go in a `Promise.all`, never a sequential await chain.**
- **Wrap page loaders in a per-request cache** so metadata generation and the page body share one set of queries, and so a timestamp cannot differ between the two.
- **Keep business rules pure.** Resolution logic operates on already-fetched rows, so the same function serves one entity or all of them without re-querying.

## API boundary

- **One source of truth for API shapes** (Zod schemas or generated types), and every response is validated against it at the fetch boundary. No ad-hoc `fetch` with an inline cast.
- **Layer it:** schemas, then typed fetchers that validate, then hooks that consume the fetchers, then components. No component reaches past its layer.
- **Never trust the client.** Not its numbers, not its ids, not its declared content type. Sniff real file types from the bytes, enforce size caps before doing work, and re-derive anything the client claims to have computed.
- **Pagination is `limit` plus `offset` with a `total`.** The handler parses, the service clamps (a non-positive limit falls back to a default and caps at a max, a negative offset becomes zero), and the response carries `{ entries, total, limit, offset }`. Any list that can grow unbounded gets this from the start.
- **Shape permission-gated responses server-side.** When a capability gates fields rather than route access, resolve the caller's permissions in the service and return a DTO with gated fields omitted. Never rely on the client to hide a field.
- **Public share links use unguessable slugs, never sequential ids,** paired with an explicit published flag. Unpublished records 404 even with the link.
- **Write audit rows inside the same transaction as the mutation,** so a failed audit insert rolls the change back. Audit rows are immutable.
- **Snapshot anything already sent.** A document a recipient received freezes its content at send time. Later edits to the source never mutate it retroactively.
- **Rate limit by user id on authenticated endpoints and by client IP on public ones.**
