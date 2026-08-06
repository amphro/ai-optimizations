---
type: smart-review
date: 2026-08-06T08:59-0700
task: Review research/opencode-vs-subscriptions.md for factual accuracy, cost-analysis soundness, and whether the recommendation follows from the evidence
models:
  - agent: staff-engineer
    model: sonnet
  - agent: domain-expert
    model: sonnet
  - agent: product-reviewer
    model: sonnet
agent_count: 3
cost_usd: null   # fill later from ccusage or the console, keyed by the date above
---

# Review: OpenCode vs. Claude Subscriptions

All three reviewers agreed the recommendation is correct. Every finding was about the supporting analysis, not the decision. All were fixed before merge.

## Critical issues

**1. Unit error in the caching counterfactual.** The doc claimed that if OpenCode broke prompt caching, monthly cost would jump to $36,000. That took a 50-day repriced total and compared it against a monthly baseline. Correct figure is about $22,700 a month, or 7.1x the baseline. Overstated the stakes by roughly 60%. Raised by staff-engineer, independently confirmed by domain-expert working from a different derivation. Fixed.

**2. Claude Pro at $20 was never addressed.** The reader asked about it by name. The doc compared only against Max and pay-as-you-go, which set up a strawman ("cancel everything") rather than the realistic alternative ("step down a tier"). Raised by product-reviewer. Fixed by adding a section that prices Pro against actual usage and concludes it does not fit, plus a sensitivity table showing where the break-even sits.

**3. Four of six model rates were never stated in the doc.** Opus 4.8, Fable 5, Sonnet 4.6, and Haiku 4.5 rates appeared nowhere, yet Opus 4.8 alone is 67% of the headline number. A reader could not audit the largest input to the conclusion. Raised by staff-engineer and domain-expert. Fixed by adding a rate table.

## Agreement across reviewers

Two or three reviewers independently raised these, so confidence is highest:

- The $36,000 figure was wrong (staff-engineer, domain-expert).
- Undisclosed model rates made the cost model unauditable (staff-engineer, domain-expert).
- The doc under-answered the multi-part question it was given (product-reviewer, and implied by staff-engineer's note that it dodged its own stated break-even question).

## Divergent perspectives

**Where the break-even sits.** Staff-engineer computed roughly 5% of current volume using the blended all-Sonnet figure. My sensitivity table says roughly 3% using the reader's actual model mix. Both are right for their assumptions. I kept the actual-mix basis because the reader's real question is about their own usage, not a hypothetical all-Sonnet workload. The distinction does not matter to the decision, since both are far below current volume.

**Domain-expert could not verify pricing.** That reviewer had no web access, so it flagged most external figures as unconfirmed rather than wrong. Its attempt to back-solve the Opus 4.8 rate failed because it lacked the per-model token split. Checked independently: the Opus 4.8 line reconciles exactly at $5/$25. No change needed, but the rate table now makes this auditable from the doc alone.

## Prioritized action list

1. Fix the $36,000 figure to about $22,700 a month. Wrong arithmetic in the section whose whole job is neutralizing an objection. **Done.**
2. Add a Claude Pro section with a verdict. Directly answers a question the reader asked. **Done.**
3. Add the per-model rate table. Makes the headline number auditable. **Done.**
4. Stop resting the recommendation on the 32x figure, which the doc's own caveat undercuts. Lead with the caveat-proof floor instead: all-Haiku still costs 7x the plan. **Done.**
5. Add subscription price comparison for OpenAI and Google. The reader asked about other providers and only got an auth-compatibility table. **Done.**
6. Add a usage sensitivity table. Natural check for a cost-driven recommendation. **Done.**
7. Tighten the proposed empirical cache test. As written it could not distinguish prefix invalidation from ordinary TTL expiry, and it read from a source the doc itself says is unreliable. **Done.**
8. Add non-cost reasons to use OpenCode. The cost answer is lopsided, so the other reasons carry the weight. **Done.**
9. Note the 1-hour TTL doubles the cache write multiplier. Small effect here, but the doc raised TTL without noting it changes the math. **Done.**
10. Soften the unsourced April 4, 2026 enforcement date and the informal Copilot credit figures. **Done.**

## What looks good

- The short answer leads with the decision-relevant number before any detail. Correct structure for a decision doc.
- Every per-model total, the $5,281 sum, the daily and monthly rates, and the 32x and 16x claims reconcile exactly against the stated rates and token counts. Staff-engineer hand-checked all of them.
- The 43-active-days versus 50-calendar-days distinction is labeled and used consistently throughout.
- The caveat that metered billing would change behavior is honest and non-obvious. It guards against reading $3,169 as a real future bill.
- Recommendations are concrete and fit a solo developer. No team-coordination advice.
- The caching claim is debunked with primary sources rather than counter-commentary, and the one genuinely unresolved part is labeled unresolved instead of being smoothed over.
