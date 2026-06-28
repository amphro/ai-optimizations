---
name: wrap-up
description: End-of-session checklist. Syncs main (and develop if it exists) with remote, checks for uncommitted and unpushed work, scans for anything worth storing in memory, and checks if any reusable skills emerged from the session. Run before clearing context or closing a terminal tab.
---

# Wrap Up

Run this checklist in order before ending a session.

## Step 1: Capture state and check for uncommitted work

Run these together:
```
git branch --show-current
git status --short
git log @{u}.. --oneline 2>/dev/null || echo "(no upstream tracking)"
```

Record the current branch name — you will return to it at the end.

If there is uncommitted or unstaged work:
- **Stop here.** Do not proceed to Step 2 until the tree is clean.
- Ask the user: stash, commit, or discard? Do not guess.
- Once the tree is clean, continue.

Also report any unpushed commits found by `git log @{u}..`. These are the most common thing lost when a session closes.

## Step 2: Sync main with remote

With a clean tree, run:
```
git fetch origin
git checkout main && git pull origin main
```

Then check if a `develop` branch exists:
```
git ls-remote --heads origin develop
```

If it exists, sync it:
```
git checkout develop && git pull origin develop
```

Return to the branch captured in Step 1:
```
git checkout <original-branch>
```

## Step 3: Check open PRs

Run:
```
gh pr list --author "@me" --json number,title,isDraft,url,headRefName
```

If `gh` is not installed or not authenticated, skip this step and note it in the report.

Report:
- Any PRs still in draft
- Any PRs open and awaiting review
- Whether any PRs have branches that were never pushed (cross-check against Step 1's unpushed check)

Do not take action — just surface what's open so nothing gets forgotten.

## Step 4: Scan for memory-worthy items

Look back over the current session for anything that should be saved:
- User preferences or corrections ("don't do X", "always do Y")
- Project decisions (architectural choices, scope changes, deadlines)
- Anything the user would have to re-explain next session

For each item found:
1. Write a new file under `~/.claude/projects/*/memory/` (match the naming convention of existing files there)
2. Add a one-line entry to `MEMORY.md` in that same directory pointing to the new file

Both steps are required — a file with no index entry won't be surfaced next session.

## Step 5: Persist skill candidates

Invoke `mine-session-skills` to scan the session for anything worth turning into a skill. Let it propose candidates — don't build anything without the user approving.

Once candidates are proposed, write a brief memory note listing them (file name: `skill-candidates-<date>.md`, one entry in MEMORY.md). This survives `/clear` and gives the next session a starting point. Without this, any proposals are lost the moment the user clears context.

Note to mine-session-skills: memory items already saved in Step 4 are settled — don't re-propose them as skill candidates.

## Step 6: Report

Summarize what was found and what was done:

- **Working tree**: clean / uncommitted work found (describe)
- **Unpushed commits**: none / list them
- **Branch sync**: main up to date / pulled N commits; develop same
- **Open PRs**: count, state (draft / open / none)
- **Memory saved**: list items written, or none
- **Skill candidates**: list proposed, or none

Keep it short. The user is closing out — do not introduce new work.
