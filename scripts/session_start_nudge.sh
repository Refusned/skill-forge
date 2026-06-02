#!/usr/bin/env bash
# SessionStart hook — if sessions are queued, print a gentle nudge (stdout becomes
# session-start context). Stays silent on compact (mid-work).
set -uo pipefail
FORGE="${CLAUDE_PLUGIN_DATA:-$HOME/.claude/skill-forge}"
inbox="$FORGE/inbox.jsonl"

payload="$(cat)"
src="$(printf '%s' "$payload" | python3 -c "import sys,json
try: print(json.load(sys.stdin).get('source',''))
except Exception: print('')" 2>/dev/null)"
[ "$src" = "compact" ] && exit 0

[ -s "$inbox" ] || exit 0
n="$(grep -c . "$inbox" 2>/dev/null | tr -d ' ')"
[ "${n:-0}" -lt 1 ] && exit 0

echo "📌 skill-forge: $n past session(s) queued for distillation into skills. Run /skill-forge:forge when you have a moment (reflect → skill edits; high-risk changes ask for your approval)."
exit 0
