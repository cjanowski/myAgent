---
name: senior-backend-design
description: Use when designing or reviewing backend code — API endpoints, database schemas, service boundaries, background jobs, or anything concerned with correctness under concurrency, failure, and scale rather than UI. Fires on tasks like "design a schema for X", "add an endpoint that does Y", "this job needs to process N records", or reviewing a PR that's server-only.
---

# Senior backend design review

The junior version of backend work makes the happy path work. The senior version asks what happens when two requests hit at once, when the process dies mid-write, and when the input is 100x bigger than the test data.

## Checklist

**Data model**
- Are the invariants actually enforced by the schema (constraints, foreign keys, unique indexes), or only by application code that every future write path has to remember to respect?
- Nullable fields: is each one nullable because it's genuinely optional, or because someone didn't want to deal with a migration?
- Is there a clear owner for each piece of derived/duplicated data (denormalized fields, caches) and how it stays in sync?

**Concurrency**
- What happens if this endpoint/job runs twice for the same input at the same time? (Double-submit, retry storms, duplicate webhook delivery are all normal, not edge cases.)
- Does anything here need a transaction, a unique constraint, or an idempotency key — and does it have one?
- Are read-then-write sequences vulnerable to a race between the read and the write?

**Failure and partial failure**
- If this operation touches multiple systems (DB + queue + external API), what's the failure mode when step 2 of 3 fails? Is that state recoverable, or does it silently drift?
- Are retries safe here (idempotent) or could a retry double-charge, double-send, double-create?
- What's logged when this fails, and is it enough to debug without reproducing locally?

**Authorization**
- Is authorization checked per-resource (can *this* user act on *this* record), not just per-endpoint (is *a* logged-in user allowed to call this endpoint at all)? This is the single most common real-world authz bug — object-level checks missing even though route-level checks exist.

**Scale sanity check**
- Does this do an unbounded query (no pagination, no limit) against a table that will grow?
- Is there an N+1 query pattern hiding in a loop?
- If this runs as a background job, does it handle being killed and restarted partway through?

## Common failure pattern to flag

An endpoint that works correctly for one request, checks that the user is authenticated, but never checks that the record being modified actually belongs to that user — and there's no test that would catch it because the test suite only uses one test user.

## Not in scope here

UI/API contract concerns → `senior-fullstack-review`. Anything where the "backend logic" is actually a prompt or model call → `ai-engineering-review`.
