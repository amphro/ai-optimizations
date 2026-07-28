# Global Claude Code Instructions

## CLAUDE.md quality rules
When creating or updating ANY CLAUDE.md file:
- Keep it under 50 lines. Every line must pass: "Would removing this cause a mistake?" If no, cut it.
- Only include implicit knowledge Claude cannot derive from reading the code.
- No standard conventions, no tutorials, no file-by-file descriptions.
- Use skills for domain knowledge only needed sometimes, not CLAUDE.md.
- Apply the `claudemd-conventions` skill for full guidance.

## Workflow defaults
- Always enter plan mode before touching multiple files or writing arch docs.
- Write plans to PLAN.md so they can be reviewed before execution.
- After any significant implementation, use the `smart-review` skill to get the right reviewers for the context.
- Delegate exploration, search, and parallelizable research to subagents so the main context stays lean; keep planning and synthesis in the main session. The context isolation is the main win. Pass a cheaper model (Sonnet or Haiku) on the spawn for grunt work as a bonus. Spot-check what a subagent reports before building on it.
- Skip delegation for trivial or tightly coupled sequential work, where a direct pass is faster and cheaper. For hard mid-task decisions, use the advisor, not a subagent.

## Verification
- Always run the available test/lint/build command after making changes.
- Show evidence of passing (output), not just assertions.

## Context hygiene
- /clear between unrelated tasks.
- When compacting: preserve architecture decisions, open questions, modified files list, and any decisions made. Discard raw tool outputs.

## Writing voice
- For prose, docs, comments, or markdown: follow the `writing-voice` skill. Default voice: Simple. Mode: context-aware (infer from context, fall back to Simple, honor any voice named in the prompt).
