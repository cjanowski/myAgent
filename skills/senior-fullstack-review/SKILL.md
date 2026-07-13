---
name: senior-fullstack-review
description: Use when building or reviewing a feature that spans both frontend and backend (a new UI flow backed by an API, a form that writes to a database, anything touching the full request/response round trip). Fires on tasks like "add a settings page", "wire up this form to save", "build a dashboard that shows X", or when reviewing a PR that touches both client and server code.
---

# Senior full-stack review

A full-stack feature isn't "frontend part + backend part" reviewed separately. Most bugs live at the seam: the contract between what the UI expects and what the API actually returns, and what happens when that contract is violated.

## Mental model

Trace the feature as one continuous flow, not two halves:

```
user action → client validation → request → server validation →
business logic → persistence → response → client state update → render
```

Every arrow above is a place data can be lost, malformed, or trusted incorrectly. Review each arrow, not just each box.

## Checklist

**Contract**
- Is the API shape (request + response) written down somewhere (types, OpenAPI, a shared schema) or just inferred by both sides independently? Independent inference is where drift happens.
- Do frontend and backend validation actually agree? Client-side validation is UX, not security — confirm the server re-checks everything the client checks.

**State**
- What does the UI show while the request is in flight? On success? On failure? On partial failure (e.g., saved but a secondary write failed)?
- Is there a stale-data path — could the user see old state after a mutation because a cache or local state wasn't invalidated?

**Errors**
- Does a 4xx/5xx from the server produce a specific, actionable message, or does it silently fail / show a generic error?
- Network failure (not server error — no response at all): is that distinguished from "server said no"?

**Data integrity**
- If this write can partially fail (multiple tables, a DB write plus a side effect like an email or webhook), what's the recovery story? Retry, rollback, or accepted inconsistency?
- Pagination/sorting/filtering: does the UI's assumption about ordering match what the query actually guarantees?

**Auth boundary**
- Is authorization checked on the server for this exact action, not just "user is logged in"? (See senior-backend-design for the deeper authz pass.)

## Common failure pattern to flag

The feature works end-to-end on the happy path in dev, but: the loading state is missing, the error state was never designed so it just shows nothing, and the contract between client and server was never written down — so the next person who touches either side will silently break the other.

## Not in scope here

Deep backend architecture (schema design, scaling) → `senior-backend-design`. Anything involving an LLM call in the flow → `ai-engineering-review`.
