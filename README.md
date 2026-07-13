# myAgent

Four role-based review skills for Claude Code (and any agent that reads `SKILL.md`), one always-on behavioral baseline, plus a minimal, fully-documented permission harness.

Two layers, deliberately kept separate:

**Always loaded — `.claude/CLAUDE.md`**: baseline behavior for every task. Think before coding, minimum necessary changes, surgical edits, verifiable goals. This is the floor everything else stands on.

**Conditionally loaded — four skills**, that fire only when relevant:

| skill | fires when |
|---|---|
| `senior-fullstack-review` | building/reviewing a feature that spans UI and API |
| `senior-backend-design` | designing/reviewing endpoints, schemas, jobs, service boundaries |
| `ai-engineering-review` | building/reviewing anything with an LLM in the request path |
| `ai-eval-design` | testing or measuring the quality of an AI feature |

The skills assume `CLAUDE.md`'s behaviors are already happening and add domain-specific things to check for on top.

**On-demand — `.claude/agents/myAgent.md`**: an adversarial subagent. It reads the diff, checks it against 11 known ways agents fake "done" (weakened tests, swallowed errors, placeholder code, scope creep, untested claims, etc.), and returns strict pass/fail JSON — no fixes proposed, no encouragement, no partial credit for one real violation. Runs on Haiku by default to keep it cheap enough to call often.

**Wired to fire automatically — the `Stop` hook in `settings.json`**: every time Claude Code is about to end a turn, an `agent`-type hook spawns a fresh subagent that reads `myAgent.md` and applies its checklist to whatever's currently uncommitted. If it fails, the turn is blocked and Claude has to address the violations before it can actually stop; if it passes (or there's nothing uncommitted to check), the turn ends normally.

Two things to know about this before you rely on it:

- **It's genuinely automatic now, not opt-in.** Every Stop event costs one subagent call. For a long back-and-forth session that's a lot of small checks; if that's too chatty or too expensive for your workflow, delete the `Stop` block from `settings.json` and go back to invoking `myAgent` by name only.
- **Agent-type hooks are marked experimental in Anthropic's own documentation** — the mechanism may change in a future Claude Code release. There's a built-in safety net regardless (Claude Code caps consecutive Stop-hook blocks at 8 by default and ends the session with a warning rather than looping forever), but test this in your own environment before trusting it on something high-stakes. Run a throwaway change through it and confirm it actually blocks on an obvious violation (e.g. delete a test's assertion and see if it catches it) before assuming it's load-bearing.

## What actually happens when you install this

There is no magic. Read `install.sh` — it's ~40 lines. It downloads this repo's tarball from GitHub, and copies exactly these into your project:

- `skills/*` → `.claude/skills/`
- `.claude/settings.json` → `.claude/settings.json`
- `.claude/CLAUDE.md` → `.claude/CLAUDE.md`
- `.claude/agents/myAgent.md` → `.claude/agents/myAgent.md`
- `MEMORY.md` → `MEMORY.md`

Nothing else. No `.mcp.json`, no loop-runner, no third-party servers — those are opt-in additions you bolt on yourself if you want them (see below), not defaults.

**No files outside the destination directory are touched. No network calls happen other than the one GitHub download.**

### Recommended: clone and read, don't pipe-to-bash

```bash
git clone <this-repo-url>
cat install.sh                      # it's short, actually read it
cd your-project
DEST=. bash /path/to/myAgent/install.sh
```

### If you want the one-liner anyway

```bash
curl -fsSL <raw-url>/install.sh | bash
```

Existing files are skipped by default (never silently overwritten). Pass `FORCE=1` to overwrite. Pin to a specific release with `REF=<tag>` instead of trusting whatever is currently on `main`.

## The permission model — read this before your first session

`.claude/settings.json` is the actual trust boundary: it decides what the agent can do *without asking you*. This kit ships with:

**Allowed without prompting:** read-only and low-risk git operations (`status`, `diff`, `log`, `add`, `commit`, `branch`, `checkout`), and common test/lint/build commands (`npm test`, `npm run lint`, `npm run build`, `pytest`, `ruff`, `mypy`).

**Explicitly denied, even if the agent tries:** force-pushes, `rm -rf`, `curl`/`wget` (no arbitrary network fetches from the shell), `sudo`, `chmod 777`, and anything piping into `bash`/`sh`.

Anything not on the allow list falls back to Claude Code's normal ask-first behavior. Adjust this list for your own workflow — it's a starting point, not a claim that it's right for every project. If you add a rule, add a one-line comment in your fork's README explaining why, the same way this one does.

## Optional add-ons (not installed by default)

If you want the MCP wiring or the `run.sh` loop-runner pattern from the original loopkit project, add them yourself deliberately:

- **MCP servers**: only wire up servers you've personally checked. Pull tokens from environment variables, never commit them.
- **Loop runner**: a `while true` script that calls `claude -p` repeatedly is easy to write in 8 lines if you want unattended runs — but it means the agent is acting without a human in the loop each turn, so it deserves a tighter `settings.json` than the interactive default above, not the same one.

## Writing your own skill

Each skill is one file: `skills/<name>/SKILL.md` with YAML frontmatter (`name`, `description`) and a body.

The `description` is what triggers auto-loading — be specific about when it *should* and *shouldn't* fire, not just a topic label. Vague descriptions cause skills to either never trigger or trigger on the wrong tasks.

Keep the body a checklist of what to look for and common failure patterns, not a tutorial. The model already knows how to code; the skill's job is to point it at the specific things it tends to skip.

## License

MIT. Fork it, strip it down further, make it yours.
