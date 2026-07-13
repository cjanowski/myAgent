---
name: ai-engineering-review
description: Use when building or reviewing a feature where an LLM is in the request path — prompt construction, tool/function calling, RAG/retrieval, agent loops, or context window management. Fires on tasks like "write a prompt that does X", "add a tool the agent can call", "this agent keeps doing Y wrong", or reviewing code that calls a model API.
---

# AI engineering review

LLM-powered features fail differently from normal code: they don't throw exceptions, they confidently produce the wrong thing. The review focus shifts from "does this compile and pass tests" to "what happens on the inputs I didn't think of, and how would I even notice it went wrong."

## Checklist

**Prompt/context construction**
- Is the prompt built from a template with clearly separated instruction / context / user-input sections, or is user input concatenated directly into an instruction string? (The latter is a prompt-injection surface if any of that input is untrusted.)
- Is anything critical to correctness left implicit ("the model will know what I mean") that should be stated explicitly — format, length, what to do when information is missing?
- How much of the context window does this consume, and does that budget hold up as inputs grow? (See context-budget concerns below.)

**Tool/function calling**
- Does each tool description clearly state when to use it and when not to — or is tool selection left to the model's guess? Ambiguous tool boundaries cause wrong-tool-picked failures.
- Are tool results validated before being trusted downstream, or does the code assume the model always calls tools with well-formed arguments?
- For tools with side effects (writes, sends, deletes): is there a confirmation step, or can the model take an irreversible action based on a single inference?

**Failure modes specific to LLMs**
- What does the system do when the model returns something that doesn't parse (malformed JSON, wrong format, refusal)? Is there a retry/fallback, or does it crash the whole flow?
- Is there any check for the model silently doing less than asked (partial completion, skipped steps) versus an explicit error?
- If the same input is run twice, is the variance in output acceptable for this use case, or does this feature actually need determinism it isn't getting?

**Context management**
- Long-running agent loops: is old/irrelevant context being pruned, or does every turn just keep appending until the window fills and quality degrades?
- Is anything being re-fetched or re-computed every turn that could be cached or summarized once?

**Cost and latency**
- Is this calling the model more times than necessary for the task (e.g., one call per item in a loop instead of a batched call)?
- Is a smaller/cheaper model viable for this specific step, or does everything default to the largest model available?

## Common failure pattern to flag

A tool description that's vague enough that the model sometimes picks the wrong tool for a task, with no test coverage that would catch a regression in tool-selection behavior — because "did it pick the right tool" isn't a thing the normal test suite checks. That gap is exactly what `ai-eval-design` exists to close.

## Not in scope here

Whether the feature's evaluation/testing strategy is adequate → `ai-eval-design`. Non-AI backend concerns (DB, auth, scale) → `senior-backend-design`.
