FROM node:20-slim

# jq is required by protect-secrets.sh — without it the hook fails open
RUN apt-get update && apt-get install -y jq && rm -rf /var/lib/apt/lists/*

# Pin Claude Code version — must match clean.Dockerfile
RUN npm install -g @anthropic-ai/claude-code@latest

WORKDIR /app

# Deploy toolkit config with correct filenames (deploy-config skill mapping)
# Build context must be repo root so these paths resolve
COPY tools/claude-code/user-settings.json /root/.claude/settings.json
COPY tools/claude-code/user-CLAUDE.md     /root/.claude/CLAUDE.md
COPY tools/claude-code/hooks/             /root/.claude/hooks/
COPY tools/claude-code/agents/            /root/.claude/agents/
COPY tools/claude-code/skills/            /root/.claude/skills/

RUN chmod +x /root/.claude/hooks/*.sh

# ANTHROPIC_API_KEY must be passed at runtime via -e, never baked in
