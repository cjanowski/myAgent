# CLAUDE.md — standing behavior

Baseline behavior for every task in this project. Merge with any project-specific instructions below this file (project conventions win on conflict — these are defaults, not overrides).

**Tradeoff:** these guidelines bias toward caution over speed. For trivial tasks, use judgment — don't turn a one-line fix into a five-step verification ritual.

## 1. Think before coding

Don't assume. Don't hide confusion. Surface tradeoffs.

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them — don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity first

Minimum code that solves the problem. Nothing speculative.
- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical changes

Touch only what you must. Clean up only your own mess.

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it — don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

**The test:** every changed line should trace directly to the user's request.

## 4. Goal-driven execution

Define success criteria. Loop until verified.

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

For the "verify" step above: run the actual checks (tests, lint, build) yourself first. A `Stop` hook automatically runs `myAgent` on any uncommitted diff before a turn is allowed to end, so you don't need to invoke it by hand — but you'll get faster, more useful results if you self-check with real tests/lint/build before letting the hook be the thing that catches it.

## How this relates to the skills in this kit

This file is the always-on baseline. The role skills (`senior-fullstack-review`, `senior-backend-design`, `ai-engineering-review`, `ai-eval-design`) are deeper, conditionally-loaded checklists for specific kinds of work — they assume the behaviors above are already happening and add domain-specific things to check for.

## Signal that this is working

- Fewer unnecessary changes in diffs.
- Fewer rewrites due to overcomplication.
- Clarifying questions come before implementation, not after mistakes.
