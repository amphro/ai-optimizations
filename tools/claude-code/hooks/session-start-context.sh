#!/bin/bash
# SessionStart hook: injects the current git branch and working-tree status
# into Claude's context so it doesn't have to ask or guess. No-op outside a
# git repo. Plain stdout text is injected as context for this event.

input=$(cat)

if ! git rev-parse --git-dir >/dev/null 2>&1; then
  exit 0
fi

BRANCH=$(git branch --show-current 2>/dev/null)
STATUS=$(git status --porcelain 2>/dev/null)

if [ -z "$STATUS" ]; then
  STATUS_SUMMARY="working tree clean"
else
  COUNT=$(echo "$STATUS" | wc -l | tr -d ' ')
  STATUS_SUMMARY="$COUNT uncommitted change(s)"
fi

echo "Git context: on branch '$BRANCH', $STATUS_SUMMARY."
