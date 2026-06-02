---
name: forge
description: >-
  Self-learning loop — distill finished Claude Code sessions into reusable skills.
  Самообучение: разбор завершённых сессий в навыки (рефлексия → новые/уточнённые скилы +
  дедуп/прополка), с гейтом на применение. Run on the SessionStart nudge, explicitly via
  /skill-forge:forge, or at the end of a session. NOT mid-task — it creates/edits skills.
---

# skill-forge — turn sessions into skills (self-improving loop)

A reflective loop inspired by **Hermes Agent** (Nous Research) and Anthropic's
skills-first practice, built on Claude Code hooks. After a substantial session, reflect on
what was done and write or refine a skill — so next time is faster without re-explaining.

Claude Code already *loads* the right skill before a task (by `description` match). This
automates the other half: **writing** it.

## When to run
- On the SessionStart nudge ("N sessions queued"), explicitly via `/skill-forge:forge`, or at the end of a session.
- NOT mid-task — it has side effects (creates/edits skills).

## Input — two sources
1. **Current session** (if called at end of work): it is already in your context — reflect on it directly.
2. **Queue `${CLAUDE_PLUGIN_DATA}/inbox.jsonl`** — past sessions (>=5 tool calls) captured by
   the SessionEnd hook. Read their transcripts.
If the current session is trivial AND the queue is empty — say "nothing to forge" and stop.

## Process (reflective phase — per session)
1. **Take the session** (current → from context; queued → read transcript). Extract: the
   task and its outcome; what repeated (a reusable move); where it broke and how it was
   fixed; commands/paths/flags that got nailed down.
2. **Decide changes:**
   - a repeated pattern not yet captured → **new skill**;
   - a recurring mistake/fix → a line in the skill's **"Gotchas (Got X)"** section;
   - a better command/path/flag → refine an existing `SKILL.md`.
3. **Dedup & curate (before creating anything new):**
   - check ALL skills (global `~/.claude/skills` + project `<repo>/.claude/skills`);
   - extend an existing skill rather than spawn a duplicate (Hermes ships 118 skills — sprawl eats context every session);
   - co-triggering descriptions (two skills match one request) → disambiguate the wording;
   - flag stale/contradictory instructions (including conflicts with CLAUDE.md).
4. **Prune:** a skill that never triggers (if usage data exists) → mark as a removal candidate.

## Apply gate (default: auto-capture, manual approval of high-risk)
- **LOW-RISK → apply directly:** add a "Got X" line; tighten/scope a `description`; fix a stale command or path.
- **HIGH-RISK → ask the user first:** create a **new** skill; **any** edit to safety or
  irreversible-action wording/invariants (payments, deploys, deletions, external writes);
  delete/merge a skill; any edit to a safety-critical skill.

## Safety
- Transcripts may contain pasted secrets — **never copy a literal secret into a skill**; mask it.
- Run your repo's secret check before committing project skills.
- Never silently rewrite a safety invariant (see high-risk).

## Persistence
- Project skills → commit (with your secret check); don't push without the user's go.
- Global skills (`~/.claude/skills`) — if that directory is under version control, commit there; otherwise warn that there's no backup.

## After forging
- Move processed entries from `inbox.jsonl` to `inbox.processed.jsonl`; clear the inbox.
- Give a digest: what was captured/applied (low-risk) + what's awaiting approval (high-risk).

## The loop
`SessionEnd hook` (>=5 tool calls → queue) → `SessionStart nudge` → `/skill-forge:forge`
(reflect + gate). Scripts: `scripts/session_end_capture.sh`, `scripts/session_start_nudge.sh`.
