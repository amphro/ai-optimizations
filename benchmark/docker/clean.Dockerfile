FROM node:20-slim

# Pin Claude Code version — bump this intentionally when upgrading
RUN npm install -g @anthropic-ai/claude-code@2.1.186

# --dangerously-skip-permissions is rejected when running as root (Claude Code security restriction)
RUN mkdir -p /app && chown node:node /app
USER node
WORKDIR /app

# ANTHROPIC_API_KEY must be passed at runtime via -e, never baked in
