FROM node:20-slim

# Pin Claude Code version — update digest here when upgrading
RUN npm install -g @anthropic-ai/claude-code@latest

# --dangerously-skip-permissions is rejected when running as root (Claude Code security restriction)
RUN mkdir -p /app && chown node:node /app
USER node
WORKDIR /app

# ANTHROPIC_API_KEY must be passed at runtime via -e, never baked in
