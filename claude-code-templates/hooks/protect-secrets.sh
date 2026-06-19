#!/bin/bash
# PreToolUse hook: blocks reads/writes of common secret files (.env, SSH keys,
# AWS credentials, etc), including via Bash workarounds like `cat .env`.
# This extends the Read(.env)/Write(.env) permission denies in settings.json
# to cover the Bash-tool bypass path those rules don't catch.
#
# To allow this for one session (e.g. editing a test .env on purpose):
#   export CLAUDE_ALLOW_ENV_EDIT=1
# or for a single command:
#   CLAUDE_ALLOW_ENV_EDIT=1 claude

if [ "$CLAUDE_ALLOW_ENV_EDIT" = "1" ]; then
  exit 0
fi

input=$(cat)

if ! command -v jq >/dev/null 2>&1; then
  exit 0
fi

TOOL=$(echo "$input" | jq -r '.tool_name // empty')

# .env.example/.sample/.template are common safe placeholders, excluded on purpose.
ALLOW_PATTERN='\.env\.(example|sample|template)$'
BLOCK_PATTERN='(^|/)\.env($|\.[^.]*$)|\.ssh/id_[a-zA-Z0-9_]+$|\.aws/credentials$|\.pem$|\.key$'

block() {
  echo "Blocked: $1 matches a protected secrets pattern. To allow this for the session, export CLAUDE_ALLOW_ENV_EDIT=1 before starting Claude Code." >&2
  exit 2
}

# Anchored to ^/$ so it works on any token (whole path or whole word), no
# regex word-boundary support required, BSD and GNU grep both handle this.
matches_block() {
  local s="$1"
  echo "$s" | grep -qE "$ALLOW_PATTERN" && return 1
  echo "$s" | grep -qE "$BLOCK_PATTERN"
}

case "$TOOL" in
  Read|Edit|Write|MultiEdit)
    FILE_PATH=$(echo "$input" | jq -r '.tool_input.file_path // empty')
    [ -z "$FILE_PATH" ] && exit 0
    matches_block "$FILE_PATH" && block "$FILE_PATH"
    ;;
  Bash)
    COMMAND=$(echo "$input" | jq -r '.tool_input.command // empty')
    [ -z "$COMMAND" ] && exit 0
    # Break the command into whitespace/punctuation-separated tokens and
    # check each one, so ".env" matches whether it's a bare arg, part of a
    # path, or follows a pipe/semicolon.
    for tok in $(echo "$COMMAND" | tr -d "'\"" | tr -s ';|&()<>' ' '); do
      matches_block "$tok" && block "the command"
    done
    ;;
esac

exit 0
