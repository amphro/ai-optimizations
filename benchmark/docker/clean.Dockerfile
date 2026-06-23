FROM node:20-slim

# Pin Claude Code version — update digest here when upgrading
RUN npm install -g @anthropic-ai/claude-code@latest

WORKDIR /app

# ANTHROPIC_API_KEY must be passed at runtime via -e, never baked in
