# OpenCode vs. Claude Subscriptions (August 2026)

> ***🤖 Claude generated, human reviewed***

**Last updated:** 2026-08-06
**Key question:** How does OpenCode with pay-as-you-go stack up against the $100 Claude Max plan, against Claude Pro, and against the other providers' subscriptions? Where is the break-even?
**Short answer:** For a heavy user, the break-even sits near 3% of their volume, so it is nowhere close. That usage costs about $3,200 a month on metered API billing, roughly 32 times the plan price. Even routing every token to the cheapest model still costs 7 times the plan. Keep the subscription. OpenCode is worth knowing, but for model choice, not for cost.

---

## The usage profile

The numbers below come from one real Claude Code account rather than estimates. They were pulled from local transcripts in `~/.claude/projects`, covering 1,246 session files and 37,501 assistant messages.

**Profile:** a heavy solo developer on the $100 Max 5x plan, working most days and regularly approaching the weekly limits.

**Window:** 2026-06-18 to 2026-08-06. That is 50 calendar days, 43 of them active.

| | Tokens |
|---|---|
| Cache reads | 7,809,843,510 |
| Cache writes | 193,645,416 |
| Output | 23,136,174 |
| Uncached input | 3,886,882 |
| **Total** | **8.03 billion** |

Cache reads are 97.3% of the token volume. That one fact drives everything below.

If your own usage is lighter, scale the results down using the sensitivity table further on. The shape of the answer holds across a wide range.

## What that costs on the API

These are the rates used throughout, from Anthropic's published pricing. Cache writes cost 1.25x the input rate at the default 5-minute TTL. Cache reads cost 0.10x the input rate. The 1-hour TTL doubles the write multiplier to 2x, which would move the total a little. Cache writes are only 2.4% of volume here, so the effect on the headline is small.

| Model | Input per MTok | Output per MTok |
|---|---|---|
| Opus 5 | $5.00 | $25.00 |
| Opus 4.8 | $5.00 | $25.00 |
| Fable 5 | $10.00 | $50.00 |
| Sonnet 5 | $3.00 ($2.00 intro through Aug 31) | $15.00 ($10.00 intro) |
| Sonnet 4.6 | $3.00 | $15.00 |
| Haiku 4.5 | $1.00 | $5.00 |

Applying those rates:

| Model | API-equivalent cost | Share |
|---|---|---|
| Opus 4.8 | $3,556.27 | 67% |
| Opus 5 | $912.75 | 17% |
| Sonnet 5 | $709.17 | 13% |
| Fable 5 | $95.81 | 2% |
| Sonnet 4.6 | $6.28 | under 1% |
| Haiku 4.5 | $0.74 | under 1% |
| **Total (50 days)** | **$5,281** | |

That works out to $105.62 per calendar day, or about $3,169 per 30-day month.

Against $100 a month, the Max plan returns roughly 32 times its price in metered value. The $200 tier would still be about 16 times.

One caveat worth stating. This measures what existing habits would cost on a meter. It is not what someone would actually spend if they paid by the token. Paying per token changes how people work. You batch more, you interrupt more, you reach for Opus less. Read this as "here is how much value the plan delivers," not "here is the bill."

That caveat weakens the 32x number, so the conclusion does not rest on it. The claim that survives is the floor: even with every habit changed and all 8 billion tokens sent to Haiku 4.5, the cheapest model available, the cost is still about 7 times the plan price. That holds no matter how behavior shifts under metering.

### Same work on a single model

Hold token volume constant and price it all on one model.

| Everything on | Per month |
|---|---|
| Opus 5 ($5 / $25) | $3,428 |
| Sonnet 5 ($3 / $15) | $2,057 |
| Sonnet 5 intro rate ($2 / $10, through Aug 31) | $1,371 |
| Haiku 4.5 ($1 / $5) | $686 |

Treat these as directional floors, not exact quotes. Different models tokenize differently and vary in how much they write, so real token counts would shift. The gaps here are far too wide for that to matter.

Even sending everything to Haiku costs about 7 times the Max plan, and Haiku is not the model you want writing architecture. No model mix makes metered Anthropic billing competitive at this volume.

For comparison, Anthropic publishes $150 to $250 per developer per month as typical, with 90% of users under $30 per active day. This profile runs at about $123 per active day, which puts it in the top tier of Claude Code usage.

### What about Claude Pro at $20?

Worth asking, since it is the obvious way to spend less. For a heavy user the answer is no.

Anthropic defines the tiers as multipliers of Pro. Max 5x ($100) gives five times Pro's usage budget. Max 20x ($200) gives twenty times. Dropping to Pro means one fifth of the budget.

At roughly $123 per active day of metered-equivalent usage, well above Anthropic's stated 90th percentile of $30, cutting the budget to a fifth would mean hitting the 5-hour window limit constantly. Pro is a reasonable plan for someone coding a few hours a day. It does not fit sustained heavy use.

### At what usage would this change?

The conclusion depends on volume, so here is where each option starts to win. These scale the profile's actual model mix down.

| Usage vs. profile | Metered equivalent per month | Cheapest sensible option |
|---|---|---|
| 100% | ~$3,169 | Max 5x at $100 |
| 50% | ~$1,585 | Max 5x at $100 |
| 25% | ~$792 | Max 5x at $100 |
| 10% | ~$317 | Max 5x at $100 |
| 3% | ~$95 | Pay-as-you-go or Pro at $20 |
| 1% | ~$32 | Pay-as-you-go |

Pay-as-you-go only wins below roughly 3% of this volume, which is around 150 million tokens a month. That is a light user, not a heavy user having a slow month. The subscription stays correct through any realistic dip in activity.

---

## Why a subscription cannot drive OpenCode

This is settled, and it is a policy decision rather than a missing feature.

Anthropic's Consumer Terms section 3.7 has barred unauthorized automated access since February 2024. In February 2026 Anthropic said so directly. Using OAuth tokens from Claude Free, Pro, or Max accounts "in any other product, tool, or service, including the Agent SDK, is not permitted." Enforcement ramped up through early 2026, moving from detection to outright rejection of clients that were not genuine Claude Code. Reports put the technical block in early April 2026, though the exact date is not confirmed against a primary Anthropic source. The policy itself is not in doubt.

OpenCode complied. It removed its bundled Claude OAuth plugins in v1.3.0, and its docs now say plainly that Anthropic prohibits this. Community plugins that scrape Claude Code's tokens still exist on GitHub. They break Anthropic's terms and put the account at risk.

Anthropic's stated reason is telemetry. Third party tools produce traffic they cannot attribute, which makes abuse and rate limit debugging harder.

So a Max subscription buys Claude Code and claude.ai. It is not a portable credential. Using Anthropic models in OpenCode means an API key at the prices above.

### Who else allows it

Anthropic is the outlier here.

| Provider | Subscription usable in OpenCode? |
|---|---|
| **GitHub Copilot** | Yes, officially. A GitHub and OpenCode partnership (Jan 16, 2026) makes any paid tier a supported backend through `/connect`. No extra license. |
| **OpenAI** | Yes. OpenAI publicly supports ChatGPT Plus and Pro OAuth in third party tools. OpenCode has a maintained Codex auth plugin. |
| **Anthropic** | No. Prohibited and technically enforced. |
| **Google** | No, and they are aggressive about it. Permanent bans with no refund and no appeal for routing Gemini Pro or Ultra through third party agents. Google also cut Gemini CLI off from Pro and Ultra accounts on June 18, 2026. |

### How the subscriptions compare on price

All prices are per month.

| Provider | Entry | Mid | Top |
|---|---|---|---|
| Anthropic | Pro $20 | Max 5x $100 | Max 20x $200 |
| OpenAI | Plus $20 | Pro $100 (5x Plus) | Pro $200 (20x Plus) |
| Google | AI Pro $19.99 | AI Ultra $99.99 | AI Ultra $200 |
| GitHub Copilot | Pro $10 | Pro+ $39 | Max $100 |

The tiers line up almost exactly across Anthropic, OpenAI, and Google. That is not a coincidence. The $20 / $100 / $200 ladder is the industry pattern now, and each vendor sells roughly 1x, 5x, and 20x of its own base quota.

The practical consequence: switching vendors at the same price buys a different model family, not more usage. Moving from Claude Max to ChatGPT Pro at $100 gets a comparable budget on GPT models instead of Claude. That is a bet on which models you prefer, not a saving. The only real price drop on the board is GitHub Copilot Pro at $10, and that tier is much smaller than heavy use requires.

---

## What OpenCode is

OpenCode is an MIT licensed terminal coding agent from Anomaly, the team behind SST. It launched in June 2025. By mid 2026 it is mainstream, with roughly 160,000 to 170,000 GitHub stars, about 900 contributors, and frequent releases.

Where it beats Claude Code:

- It works with 75+ providers through the AI SDK and Models.dev. This is the whole point of the tool.
- It has built-in LSP integration, which is a real advantage for typed languages.
- Its subagents are inspectable child SQLite sessions rather than opaque calls.
- The TUI supports multiple sessions and link sharing.

Where Claude Code wins:

- A mature plugin ecosystem with an official marketplace.
- First party integration, so new model behavior lands there first.
- Prompt cache handling tuned for long agentic sessions.

Both support MCP, hooks, skills, custom tools, and subagents. Feature parity is closer than the gap in ecosystem size suggests.

### Does OpenCode break prompt caching? No.

A widely shared blog post claims OpenCode's session pruning rebuilds the prompt each turn and defeats Anthropic prompt caching. This matters a lot when 97.3% of tokens are cache reads. If the claim were true, those tokens would reprice from 0.10x to 1.0x. The cache read component is $3,608 of the $5,281 window total, so repricing it takes the month from $3,169 to about $22,700, or 7.1 times higher. That would rule out OpenCode with an Anthropic key at any volume.

Checking the repository and issue tracker instead of the commentary, the claim does not hold up.

- OpenCode does set `cache_control: {"type": "ephemeral"}` on Anthropic requests. Its `applyCaching` function branches on `providerID === "anthropic"` to inject the blocks. Issue #14642 confirms this. That issue is a bug report about the detection logic, so the feature's existence is its starting premise.
- Cache reads are received and billed correctly. Issue #28494 says the tokens come back from the API, get stored, and are billed correctly by Anthropic. The real bug is that OpenCode's own cost display leaves out the cache read line. That is a reporting problem, not a caching problem.
- No primary source reports `cache_read_input_tokens` returning zero on the standard API key path.
- The one real cache bug (#17910, `cache_control` plus OAuth returning HTTP 400) only affects the subscription OAuth path. Anthropic has since banned that path and OpenCode no longer ships it.
- Issue #5416 ("Anthropic caching improvement") closed through merged PRs. The caching code is maintained, not abandoned.

One thing stays open. It is not confirmed whether compaction prunes from the prefix or only from the tail. No primary source answers it. The closest issue (#4416) is a token double counting bug that triggers compaction too early, which says nothing about where the cut lands. TTL support (`"ttl": "1h"`) looks configurable per issue #5416, but the default is unconfirmed.

So $3,169 a month is the better supported number, and the conclusion rests on the price gap alone.

---

## The models

The cheap tier is real, and it is the actual argument for OpenCode.

| Model | $ per MTok (in / out) | Note |
|---|---|---|
| Claude Opus 5 | $5 / $25 | Frontier agentic leader. Terminal-Bench 2.1: 89.1% |
| Claude Sonnet 5 | $3 / $15 ($2 / $10 through Aug 31) | Best quality per dollar in the Anthropic line |
| Gemini 3 Pro | $2 / $12 (up to 200K) | Priced in tiers by context length |
| Kimi K2.7-Code | $0.19 cached / $4.00 out | Most cited open model for long agentic runs |
| MiniMax M2 | $0.26 / $1.02 | Cheap, solid agentic scores |
| DeepSeek V3.2 | $0.21 / $0.32 | Cheapest credible coder |
| Grok 4.1 Fast | $0.20 / $0.50 | 2M context, unproven on hard agentic work |

Treat SWE-bench Verified as saturated and mostly self reported. Only about 1 in 100 recent submissions was independently verified. The community has moved to SWE-bench Pro and Terminal-Bench Hard. On those harder tests the top slots are still closed frontier models, and no open weight model comes close. The gap has narrowed but it has not closed. It is widest on long, ambiguous, multi step sessions, which is exactly the heavy agentic use case.

On data residency: DeepSeek, Kimi (Moonshot), GLM (Zhipu), and Qwen (Alibaba) are all based in China. DeepSeek's privacy policy states that data goes to servers in China, and independent reporting has tied its login infrastructure to state owned China Mobile. For personal projects with no compliance requirements this is a judgment call, not a blocker. It is still a real difference.

### Cheap coding subscriptions

| Provider | Price per month | Quota |
|---|---|---|
| GitHub Copilot Pro | $10 | Roughly $15 of monthly AI credits under the June 2026 token billing model. Works in OpenCode. |
| GLM (Z.ai) Coding Lite | $18 | 2,000 credits per 5 hours |
| Kimi Code | $19 to $199 | Scales about 1x to 30x |
| GitHub Copilot Pro+ | $39 | Roughly $70 of monthly AI credits. Works in OpenCode. |
| Cerebras Code Pro | $50 | 24M tokens a day at about 2,000 tokens per second |

The "$3 a month GLM plan" that circulated widely was a launch promo. Z.ai discontinued it in February 2026. Entry price is now $18. Treat any cached figure in the $3 to $5 range as stale.

---

## Conclusion

Keep the Max plan. At 32 times value delivered it is not a close call, and nothing in pay-as-you-go competes at heavy volume.

OpenCode is worth a place as a second tool, not a replacement.

1. **To try OpenCode, GitHub Copilot Pro at $10 a month is the cheapest legitimate route.** It is the only major subscription that is both cheap and an officially supported OpenCode backend. Run `/connect` and use the device login. Pro, Pro+, Business, and Enterprise all qualify with no extra AI license.

   Do not expect to reach Claude models this way. GitHub's changelog never claims Claude access. A long list of unresolved OpenCode issues (#6628, #11009, #11781, #15068, #19027, #20544, #21481, #24221, spanning many versions across 2026) reports Claude models unavailable, mismapped, or failing with "model not supported" or "Not Found" through the Copilot provider. That is a chronic gap, not a one off bug. Use Copilot in OpenCode for GPT class models, not as a back door to Claude.

2. **Hitting plan limits is the real signal to add capacity.** The cheapest relief is a second subscription such as Copilot, Kimi, or GLM. It is not metered Anthropic tokens.

3. **Do not install community plugins that reuse a Claude Code OAuth token.** They break Anthropic's terms, they are detected, and they put the subscription at risk.

The thing worth revisiting is not the plan. It is the model mix. Opus 4.8 accounts for 67% of metered equivalent spend in this profile, on a subscription where it costs nothing extra. That is the first place to look if you ever do start paying per token.

### Reasons to use OpenCode anyway

Cost is not the only reason to pick a tool, and the cost answer here is lopsided enough that the other reasons matter more. Any of these justify running OpenCode alongside Claude Code:

- **Model variety.** Kimi, DeepSeek, GLM, and local models do not run in Claude Code. OpenCode is how you find out whether they handle your work.
- **Avoiding lock-in.** A workflow that depends on one vendor's client, models, and terms is exposed when those terms change. Anthropic's 2026 OAuth crackdown is the reminder. Knowing a second tool is cheap insurance.
- **Local and offline models.** OpenCode can point at a local model. Claude Code cannot. That matters for work you would rather not send anywhere.
- **LSP integration.** A real advantage on typed languages, independent of which model is behind it.

None of these are cost arguments. Treat OpenCode as a second tool worth keeping sharp, not as a way to shrink the bill.

---

## Open questions

- **Exact Max plan limits are unpublished.** Anthropic describes Pro and Max only as relative multipliers (5x, 20x) enforced through a 5-hour rolling window plus a weekly cap. Third party estimates exist but are back calculated, not confirmed. So "am I close to the ceiling?" cannot be answered directly. You only find out by hitting it.
- **Whether the usage pattern survives a switch of tools.** A 97.3% cache read rate comes from how Claude Code manages sessions. Another tool will have a different cache profile, and that changes metered cost far more than the sticker price per token.
- **Where OpenCode's compaction cuts.** It caches, that much is confirmed. Whether pruning ever changes bytes before the cache breakpoint is not. Answering it needs a real test, and a careful one. Watching `cache_read_input_tokens` stay above zero is not enough, because a plain 5-minute TTL expiry looks the same. The real signature of prefix invalidation is a `cache_creation_input_tokens` spike paired with a cache read collapse. So compare a compaction event against an idle gap of the same length with no compaction. Read those numbers from the raw API responses or the Anthropic console, not from OpenCode's own cost display, which issue #28494 says omits the cache read line.
- **Whether Claude through Copilot in OpenCode gets fixed.** Those issues are open and long running. If that path stabilized it would change the math on cheap Claude access.

---

## Sources

**OpenCode and Anthropic auth policy**

- [The Register: Anthropic clarifies ban on third-party tool access](https://www.theregister.com/software/2026/02/20/anthropic-clarifies-ban-on-third-party-tool-access-to-claude/5014546)
- [OpenCode providers docs](https://opencode.ai/docs/providers/) and [OpenCode Zen](https://opencode.ai/docs/zen/)
- [AlternativeTo: Anthropic bans subscription auth for third-party use](https://alternativeto.net/news/2026/2/anthropic-officially-bans-using-subscription-authentication-for-third-party-claude-use)
- OpenCode caching verification: issues #14642 (`applyCaching` and cache_control injection), #28494 (cache read tokens received and billed, display only bug), #17910 (OAuth plus cache_control 400, closed not planned), #4416 (compaction token double count), #5416 (caching improvements, closed via merged PRs)
- Claude via Copilot gap: OpenCode issues #6628, #11009, #11781, #15068, #19027, #20544, #21481, #24221

**Pricing and token economics**

- [Anthropic pricing](https://platform.claude.com/docs/en/about-claude/pricing)
- [Claude Code costs](https://code.claude.com/docs/en/costs) and [Claude Code prompt caching](https://code.claude.com/docs/en/prompt-caching)
- [Anthropic: prompt caching is everything](https://claude.com/blog/lessons-from-building-claude-code-prompt-caching-is-everything)
- [What is the Max plan?](https://support.claude.com/en/articles/11049741-what-is-the-max-plan)

**Models and benchmarks**

- [Artificial Analysis: Terminal-Bench Hard](https://artificialanalysis.ai/evaluations/terminalbench-hard) and [SWE-bench](https://www.swebench.com/)
- [Z.ai devpack](https://docs.z.ai/devpack/overview) and [Cerebras Code](https://www.cerebras.ai/blog/introducing-cerebras-code)
- [DeepSeek privacy policy](https://cdn.deepseek.com/policies/en-US/deepseek-privacy-policy.html)

**Competing subscriptions**

- [GitHub changelog: Copilot now supports OpenCode](https://github.blog/changelog/2026-01-16-github-copilot-now-supports-opencode/)
- [OpenAI Codex pricing](https://learn.chatgpt.com/docs/pricing) and [opencode-openai-codex-auth](https://github.com/numman-ali/opencode-openai-codex-auth)
- [Antigravity plan changes](https://antigravity.google/blog/changes-to-antigravity-plans) and [WinBuzzer: Google bans AI subscribers](https://winbuzzer.com/2026/02/23/google-bans-ai-subscribers-openclaw-no-refunds-xcxwbn/)

---

## How this doc was generated

| Field | Value |
|---|---|
| **What this is** | Run metadata for the deep-research process that produced this doc. Kept so cost and quality can be reviewed later. |
| Type | deep-research |
| Date | 2026-08-06T08:46-0700 |
| Question | How does OpenCode with pay-as-you-go API access compare to Anthropic's subscription plans for a heavy solo dev on the $100 Claude Code plan? |
| Agents | 4, all on Sonnet: opencode-auth, token-economics, models, competing-subscriptions |
| Cost | Not recorded. Reconcile from `ccusage` or the API console using the date above. |
| Review | See `reviews/2026-08-06-0859-opencode-vs-subscriptions.md` |
