#!/bin/bash
# PreToolUse hook: blocks writes whose NEW content contains an em dash, en dash,
# figure dash, or horizontal bar. Enforces the unconditional no-dash rule in
# CLAUDE.md without relying on the writing-voice skill being invoked.
#
# Only new content is inspected (Write content, Edit/MultiEdit new_string), so
# editing a legacy file that already contains dashes does not trip the hook.
#
# To allow this for one session (e.g. cleaning up existing dashes on purpose):
#   export CLAUDE_ALLOW_DASHES=1

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

block() {
  local content="$1" path="$2"
  local offenders
  offenders=$(echo "$content" | LC_ALL=C grep -n -E "$DASH_RE" | head -5)
  {
    echo "Blocked: this write contains a banned character, $(name_dash "$content"). CLAUDE.md bans it in all output."
    echo ""
    echo "Offending line(s)${path:+ in $path}:"
    echo "$offenders"
    echo ""
    echo "Rewrite those lines using a period, comma, colon, or parentheses, then retry the same tool call."
    echo "Do not substitute a hyphen where the sentence needs real punctuation."
    echo "If the dash is intentional (quoting a source, existing data), export CLAUDE_ALLOW_DASHES=1 for the session."
  } >&2
  exit 2
}

has_dash() {
  echo "$1" | LC_ALL=C grep -qE "$DASH_RE"
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
    # else (greps, cleanup scripts) is left alone to avoid false positives.
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
has_dash "$CONTENT" && block "$CONTENT" "$FILE_PATH"

exit 0
