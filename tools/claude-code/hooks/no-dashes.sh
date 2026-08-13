#!/bin/bash
# PreToolUse hook: blocks writes that introduce an em dash, en dash, figure
# dash, or horizontal bar. Enforces the unconditional no-dash rule in CLAUDE.md
# without relying on the writing-voice skill being invoked.
#
# Only NEWLY introduced dashes are blocked:
#   Edit/MultiEdit  payload carries just new_string, so legacy content is unseen.
#   Write           payload carries the WHOLE file body, so lines that already
#                   exist verbatim in the file on disk are filtered out first.
# Without that filter, rewriting any legacy file would be impossible.
#
# To allow dashes on purpose, either add to the "env" block of settings.json:
#   "CLAUDE_ALLOW_DASHES": "1"
# or start Claude Code with it set:
#   CLAUDE_ALLOW_DASHES=1 claude
# An `export` inside a Bash tool call does NOT reach this hook. Hooks are
# spawned from Claude Code's own environment, which that export never mutates.

if [ "$CLAUDE_ALLOW_DASHES" = "1" ]; then
  exit 0
fi

input=$(cat)

if ! command -v jq >/dev/null 2>&1; then
  exit 0
fi

TOOL=$(echo "$input" | jq -r '.tool_name // empty')

# UTF-8 bytes for U+2012 figure dash through U+2015 horizontal bar, which covers
# en dash (U+2013) and em dash (U+2014). Built with printf because macOS bash 3.2
# has no $'\uXXXX' escape, and matched under LC_ALL=C so the range is byte-wise.
DASH_RE=$(printf '\xe2\x80[\x92-\x95]')

# Names the exact character so the rewrite lands in one attempt.
name_dash() {
  case "$1" in
    *$(printf '\xe2\x80\x94')*) echo "em dash (U+2014)" ;;
    *$(printf '\xe2\x80\x93')*) echo "en dash (U+2013)" ;;
    *$(printf '\xe2\x80\x92')*) echo "figure dash (U+2012)" ;;
    *) echo "horizontal bar (U+2015)" ;;
  esac
}

# Emits "lineno:text" for each dash line. For a full-file Write over an existing
# file, lines already present verbatim on disk are pre-existing, not new.
new_dash_lines() {
  local content="$1" path="$2" all line
  all=$(echo "$content" | LC_ALL=C grep -n -E "$DASH_RE")
  [ -z "$all" ] && return
  if [ "$TOOL" != "Write" ] || [ -z "$path" ] || [ ! -f "$path" ]; then
    echo "$all"
    return
  fi
  # One awk pass rather than a grep per line. A per-line grep costs seconds on
  # a large legacy file, which is far too slow for a hook on every write.
  echo "$all" | LC_ALL=C awk '
    NR==FNR { seen[$0]=1; next }
    { text = $0; sub(/^[0-9]+:/, "", text); if (!(text in seen)) print }
  ' "$path" -
}

block() {
  local offenders="$1" path="$2"
  {
    echo "Blocked: this write introduces a banned character, $(name_dash "$offenders"). CLAUDE.md bans it in all output."
    echo ""
    echo "Newly introduced line(s)${path:+ in $path}:"
    echo "$offenders" | head -5
    echo ""
    echo "Rewrite those lines using a period, comma, colon, or parentheses, then retry the same tool call."
    echo "Do not substitute a hyphen where the sentence needs real punctuation."
    echo "Pre-existing dashes already in the file are ignored, so only the lines above need changing."
    echo ""
    echo "If the dash is genuinely required (quoting a source, fixed data, a script that rewrites dashes),"
    echo "it cannot be waived mid-session. Ask the user to add \"CLAUDE_ALLOW_DASHES\": \"1\" to the env block"
    echo "of ~/.claude/settings.json, or to relaunch with: CLAUDE_ALLOW_DASHES=1 claude"
  } >&2
  exit 2
}

FILE_PATH=$(echo "$input" | jq -r '.tool_input.file_path // empty')

case "$TOOL" in
  Write)
    CONTENT=$(echo "$input" | jq -r '.tool_input.content // empty')
    ;;
  Edit)
    CONTENT=$(echo "$input" | jq -r '.tool_input.new_string // empty')
    ;;
  MultiEdit)
    CONTENT=$(echo "$input" | jq -r '[.tool_input.edits[]?.new_string] | join("\n")')
    ;;
  Bash)
    # Commit messages are the one Bash surface that is really prose. Everything
    # else (greps, heredocs, cleanup scripts) is left alone to avoid false
    # positives. This is a deliberate gap: a heredoc can still write a dash.
    COMMAND=$(echo "$input" | jq -r '.tool_input.command // empty')
    case "$COMMAND" in
      *"git commit"*) CONTENT="$COMMAND" ;;
      *) exit 0 ;;
    esac
    ;;
  *)
    exit 0
    ;;
esac

[ -z "$CONTENT" ] && exit 0

OFFENDERS=$(new_dash_lines "$CONTENT" "$FILE_PATH")
[ -n "$OFFENDERS" ] && block "$OFFENDERS" "$FILE_PATH"

exit 0
