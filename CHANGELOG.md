# Changelog

All notable changes to skill-forge are documented here.
This project follows [Semantic Versioning](https://semver.org).

## [0.1.0] — 2026-06-02

Initial release.

- `SessionEnd` hook: queues substantial sessions (≥5 tool calls) for reflection.
- `SessionStart` hook: nudges when sessions are waiting.
- `forge` skill (`/skill-forge:forge`): reflective phase — capture new skills, append
  "Got X" gotchas, refine existing skills, dedup and prune.
- Apply gate: auto-apply low-risk edits; high-risk changes (new skill, safety-invariant
  edits, deletions) require approval.
- Secret-safety: never copies literal secrets from transcripts into skills.
