---
name: ai-eval-design
description: Use when a task involves testing, measuring, or validating the quality of an AI/LLM-powered feature — building an eval set, defining success metrics for a prompt or agent, catching regressions after a prompt change, or someone asks "how do we know this is actually working." Fires on tasks like "write evals for this", "how do I test a prompt", "did this change make things better or worse", or reviewing a PR that changes prompts/model behavior with no accompanying eval update.
---

# AI evaluation engineering

Normal software has a test suite that catches regressions. AI features usually don't, because "does this still work" isn't a pass/fail question — it's a distribution question. The job here is turning a vague "does it still feel good" into something measured.

## Checklist

**What are you actually measuring**
- Is there a concrete, checkable definition of success for this task, or only a vibe ("the output should be helpful")? Push for a rubric or a programmatic check wherever possible before falling back to model-graded eval.
- Separate correctness failures (wrong answer, wrong tool called, factually wrong) from style failures (right answer, wrong tone/format). They need different fixes and shouldn't be lumped into one pass/fail number.

**Eval set construction**
- Does the eval set include real failure cases you've actually seen in production/testing, not just cases that were easy to write? A set built only from happy-path examples won't catch the regressions that matter.
- Is there coverage for edge cases: empty input, adversarial/injected input, very long input, ambiguous requests, requests the system should refuse or decline?
- Is the eval set frozen/versioned so a score change means the model/prompt changed, not that the test cases quietly changed too?

**Grading**
- If using a model to grade another model's output (LLM-as-judge), is the judge prompt specific enough to be consistent, and has it been spot-checked against human judgment on a sample? An ungrounded judge just adds a second unreliable component instead of measuring the first one.
- Is grading deterministic enough to compare two runs meaningfully, or is noise in the grader as large as the signal you're trying to detect?

**Regression detection**
- When a prompt, model version, or tool changes, does anything actually re-run the eval set before it ships, or is "it seemed fine in a few manual tries" the actual QA process?
- Is there a stored baseline score to diff against, so a drop is visible instead of discovered by a user?

**Reporting**
- Does the eval output tell you *why* something failed (which category, which examples) or just a single aggregate number that hides which failure mode got worse?

## Common failure pattern to flag

A prompt change ships because it "looked better on the three examples someone tried by hand" — with no eval set run before or after, so a regression on a case outside those three examples ships silently and is only caught when a user hits it.

## Not in scope here

Whether the prompt/tool design itself is sound → `ai-engineering-review`. This skill is about measurement, not construction.
