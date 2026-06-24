# AI Model Landscape (June 2026)

> ***🤖 Claude generated, human reviewed***

**Last updated:** 2026-06-18  
**Reliability:** High — sourced from official docs and recent benchmarks  
**Next review:** 2026-09-18

---

## Anthropic (Claude)

Claude's current lineup spans four tiers:

| Model | Price (in/out per MTok) | Best for |
|---|---|---|
| Fable 5 | $10 / $50 | Top-tier reasoning, new flagship above Opus |
| Opus 4.8 | $5 / $25 | Complex reasoning, agentic coding, architecture decisions |
| Sonnet 4.6 | $3 / $15 | Best workhorse — 79.6% SWE-bench, ~97-99% of Opus quality |
| Haiku 4.5 | $1 / $5 | High-volume pipelines, classification, 97 tokens/sec |

**Context windows:** Opus/Sonnet/Fable at 1M tokens (beta), Haiku at 200K  
**Prompt caching:** Available across all models, cuts costs up to 90%  
**All models support:** Tool use, system prompts, structured outputs

**SWE-bench scores (current):**
- Opus 4.8: 80.8% (highest commercial)
- Sonnet 4.6: 79.6%

**Products:**
- Claude.ai (chat, Pro/Max/Team/Enterprise plans)
- Claude Code (CLI agentic coding)
- Claude Cowork (desktop tool, file/task automation)
- Claude for Chrome, Slack, Excel, PowerPoint, Word
- Claude Platform (API)
- Claude Managed Agents (production-ready agent infrastructure)

**Notable new model tier — Mythos (preview):** Anthropic is previewing a "Mythos" model tier above Fable, details sparse.

---

## OpenAI (GPT)

OpenAI retired all pre-GPT-5 models from ChatGPT in early 2026. The API still supports legacy models.

| Model | Notes |
|---|---|
| GPT-5.5 | Flagship for complex reasoning and coding |
| GPT-5.4 | Main model, 1M context, native computer-use built in |
| GPT-5.4 Mini | 2x faster than GPT-5.4, main production workhorse |
| GPT-5.4 Pro | Maximum reasoning tier |
| GPT-5.4 Nano | Lowest latency/cost |

**Key differentiator:** GPT-5.4 ships native desktop computer-use as a core feature — first major provider to do this built-in.

**API:** Responses API + Client SDKs

---

## Google (Gemini)

| Model | Best for |
|---|---|
| Gemini 2.5 Pro | Most capable, enterprise: scientific discovery, complex reasoning, code |
| Gemini 2.5 Flash | High-throughput: summarization, chat, data extraction |
| Gemini 2.5 Flash-Lite | Cost-sensitive scale: classification, translation, routing |

Flash-Lite is 1.5x faster than 2.0 Flash at lower cost.

**Available via:** Google AI Studio, Vertex AI, Gemini Enterprise Agent Platform

---

## xAI (Grok)

| Model | Notes |
|---|---|
| Grok 4.3 | Frontier model, currently leads on pure reasoning benchmarks |
| Grok 4.1 Fast | 2M token context window |

**Key differentiator:** Native access to X (Twitter) real-time data feed. Built-in tools: Web Search, X Search, Code Execution, Document Search.

---

## Meta (Llama)

Open-weight models — can self-host.

| Model | Notes |
|---|---|
| Llama 4 Scout | **10M token context window** — unmatched for long context |
| Llama 4 Maverick | High-performance variant, MoE architecture |

**Key differentiator:** Apache-licensed, self-hostable, Mixture of Experts architecture. Most-downloaded open-weight family.

---

## Mistral AI

| Model | Notes |
|---|---|
| Mistral Large 3 | Trained on 3,000 H200 GPUs, Apache 2.0 license |
| Mixtral | MoE architecture variants |
| Le Chat | Consumer product (like Claude.ai) |

**European company**, strong open-weight ethos, competitive second-tier.

---

## DeepSeek

Open-weight Chinese competitor. In Feb 2026, the capability gap between frontier (Claude/GPT/Gemini) and second-tier (DeepSeek, Mistral, Qwen) closed meaningfully. DeepSeek now handles most tasks competently.

---

## 2026 Landscape Notes

- No single model dominates every benchmark — specialization matters
- Open-weight models (Llama, Mistral, DeepSeek) now competitive on most general tasks
- Context windows are a non-issue for most tasks (all frontier models at 1M+)
- Pricing convergence: the gap between tiers is narrowing
- Multimodal is table stakes — all frontier models support vision/text/code
- Computer use / agentic capabilities are the new battleground

---

## Sources
- [Claude models overview — Anthropic](https://platform.claude.com/docs/en/about-claude/models/overview)
- [OpenAI Models](https://developers.openai.com/api/docs/models)
- [Gemini API Models](https://ai.google.dev/gemini-api/docs/models)
- [AI Model Leaderboard 2026](https://llm-stats.com/)
- [Every AI Model Worth Knowing 2026](https://beginnersinai.org/ai-models-2026/)
