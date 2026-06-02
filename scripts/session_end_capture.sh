#!/usr/bin/env bash
# SessionEnd hook — queue a substantial session (>=5 tool calls) for later reflection
# into skills. No model call here: cheap and deterministic. Threshold mirrors Hermes Agent.
set -uo pipefail
FORGE="${CLAUDE_PLUGIN_DATA:-$HOME/.claude/skill-forge}"
mkdir -p "$FORGE"
inbox="$FORGE/inbox.jsonl"

payload="$(cat)"
get() { printf '%s' "$payload" | python3 -c "import sys,json
try: print(json.load(sys.stdin).get('$1',''))
except Exception: print('')" 2>/dev/null; }
tp="$(get transcript_path)"
cwd="$(get cwd)"

# no transcript → nothing to queue
{ [ -z "$tp" ] || [ ! -f "$tp" ]; } && exit 0

# count tool calls in the transcript (rough; good enough for a threshold)
calls="$(grep -o '"type":"tool_use"' "$tp" 2>/dev/null | wc -l | tr -d ' ')"
[ "${calls:-0}" -lt 5 ] && exit 0

# dedup: already queued?
[ -f "$inbox" ] && grep -qF "\"$tp\"" "$inbox" && exit 0

ts="$(date '+%Y-%m-%dT%H:%M:%S')"
printf '{"transcript":"%s","cwd":"%s","tool_calls":%s,"ended":"%s"}\n' \
  "$tp" "$cwd" "$calls" "$ts" >> "$inbox"
exit 0
