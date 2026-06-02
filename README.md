# skill-forge 🔨

**A self-learning loop for Claude Code — your agent turns finished sessions into reusable skills, so it gets sharper every session.**

Inspired by [Hermes Agent](https://github.com/NousResearch)'s reflective loop and [Anthropic's skills-first practice](https://code.claude.com/docs/en/skills), built entirely on Claude Code hooks — no external service, no server.

> **Honest scope.** skill-forge does **not** rewrite your application code. It grows your agent's **skill library** — the procedures Claude reuses — so day 30 is sharper than day 1. The thing that self-improves is the *agent*, not your codebase.

## The loop

```
every session ends
   │
 SessionEnd hook ── ≥5 tool calls? ──► queue the transcript     (no model call; cheap)
   │
 next session starts
   │
 SessionStart hook ──► "📌 N sessions queued → /skill-forge:forge"
   │
 /skill-forge:forge ──► reflect:  new skill · "Got X" · refine   + dedup + prune
   │
 apply gate ──► low-risk: auto   ·   high-risk (new skill / safety / deletion): you approve
```

Claude Code already *loads* the right skill before a task. skill-forge automates the other half — **writing** it.

## Install

```text
/plugin marketplace add Refusned/skill-forge
/plugin install skill-forge@refusned
```

Then `/reload-plugins` (or restart). The SessionEnd/SessionStart hooks register **automatically** — no `settings.json` editing.

Try it: after your next real session, run `/skill-forge:forge`.

## How it works

| Stage | What happens |
|---|---|
| **Capture** | A `SessionEnd` hook counts tool calls; sessions with **≥5** get queued to `${CLAUDE_PLUGIN_DATA}/inbox.jsonl`. Trivial chats are skipped. No model is invoked — it's a few lines of shell. |
| **Nudge** | A `SessionStart` hook reminds you when sessions are waiting. Silent when there's nothing to do. |
| **Reflect** | `/skill-forge:forge` reads the queued transcripts (and the current session from context), finds repeated patterns, recurring fixes, and refined commands. |
| **Curate** | Before creating anything, it dedups against your existing skills, disambiguates co-triggering descriptions, and flags stale instructions. |
| **Apply (gated)** | Low-risk edits (a "Got X" line, a description tweak) apply automatically. High-risk changes (a new skill, any safety-invariant edit, a deletion) wait for your approval. |

## Safety by design

- **Gated autonomy.** It captures automatically, but never *silently* creates a skill, edits a safety invariant, or deletes anything — those ask first. Tune the gate in the skill.
- **No secret leakage.** Transcripts can contain pasted tokens; the skill never copies a literal secret into a skill file.
- **No sprawl.** A conservative `≥5 tool calls` threshold skips noise, and the dedup step extends existing skills instead of spawning duplicates.

## Configuration

- **Threshold** — edit `≥5` in `scripts/session_end_capture.sh`.
- **Queue location** — `${CLAUDE_PLUGIN_DATA}/inbox.jsonl` (per-plugin data dir; falls back to `~/.claude/skill-forge/`).
- **Autonomy** — v0.1 ships *auto-capture + manual approval*. A scheduled fully-autonomous mode (cron/Routine, like Hermes 24/7) is on the roadmap.

## Credits

- Reflective-loop concept: **Hermes Agent** by Nous Research.
- Skills-first practice & hooks: **Anthropic** (Claude Code).

## License

MIT © Roman Barmin ([@Refusned](https://github.com/Refusned))

---

## 🇷🇺 По-русски

**Самообучающаяся петля для Claude Code: агент сам превращает завершённые сессии в переиспользуемые навыки и умнеет с каждой сессией.**

Вдохновлено рефлексивной петлёй **Hermes Agent** (Nous Research) и подходом «skills-first» от Anthropic, собрано на хуках Claude Code — без внешнего сервиса.

> **Честно:** скил не переписывает твой прикладной код. Растёт **библиотека навыков агента** — процедуры, которые Claude переиспользует. Саморазвивается *агент*, а не кодовая база.

**Как ставить:**
```text
/plugin marketplace add Refusned/skill-forge
/plugin install skill-forge@refusned
```
Хуки регистрируются сами — `settings.json` руками править не нужно.

**Петля:** `SessionEnd`-хук копит сессии (≥5 тул-коллов) → `SessionStart`-нудж → `/skill-forge:forge` (рефлексия → новый скил / «Грабли» / уточнение + дедуп) → **гейт**: low-risk авто, high-risk (новый скил / правка money-safety / удаление) — с твоим аппрувом.
