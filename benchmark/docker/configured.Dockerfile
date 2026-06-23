FROM node:20-slim

# jq is required by protect-secrets.sh — without it the hook fails open
RUN apt-get update && apt-get install -y jq && rm -rf /var/lib/apt/lists/*

# Pin Claude Code version — must match clean.Dockerfile
RUN npm install -g @anthropic-ai/claude-code@latest

# Deploy toolkit config for the node user (--dangerously-skip-permissions rejected as root)
# Build context must be repo root so these paths resolve
COPY --chown=node:node tools/claude-code/user-settings.json /home/node/.claude/settings.json
COPY --chown=node:node tools/claude-code/user-CLAUDE.md     /home/node/.claude/CLAUDE.md
COPY --chown=node:node tools/claude-code/hooks/             /home/node/.claude/hooks/
COPY --chown=node:node tools/claude-code/agents/            /home/node/.claude/agents/
COPY --chown=node:node tools/claude-code/skills/            /home/node/.claude/skills/

RUN chmod +x /home/node/.claude/hooks/*.sh

RUN mkdir -p /app && chown node:node /app
USER node
WORKDIR /app

# ANTHROPIC_API_KEY must be passed at runtime via -e, never baked in
