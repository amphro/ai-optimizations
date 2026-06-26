# AI Council Prompting: Research Compendium

## 1. Origin and Popularizers

### The Karpathy Connection

The technique traces to **Andrej Karpathy**, a co-founder of OpenAI who **joined Anthropic in May 2026** to lead pretraining research. Karpathy built an open-source project called **LLM Council** (`github.com/karpathy/llm-council`) in late 2025, describing it as "99% vibe coded as a fun Saturday hack" while exploring reading books with multiple LLMs side-by-side. The system:

1. Sends a query to multiple LLMs in parallel
2. Has each model anonymously rank and critique the others' responses
3. Routes all responses + peer rankings to a designated "Chairman" model for final synthesis

He explicitly said he would not maintain it, offering it as inspiration to fork. The repo spawned dozens of forks and a wave of blog posts, newsletter guides, and commercial implementations through late 2025–2026.

**Sources:**
- [GitHub: karpathy/llm-council](https://github.com/karpathy/llm-council)
- [Analytics Vidhya: LLM Council by Andrej Karpathy](https://www.analyticsvidhya.com/blog/2025/12/llm-council-by-andrej-karpathy/)
- [VentureBeat: Andrej Karpathy announces he's joining Anthropic](https://venturebeat.com/technology/andrej-karpathy-announces-hes-joining-anthropic)
- [Learn AI with Mariah: The LLM Council Prompt](https://learnaiwithmariah.com/guides/llm-council-prompt/)

### Earlier Related Work

- **Dennis Kennedy's G-A-L Method** (September 2023): "Group Advisory Layer" using a PCRO (Persona-Context-Request-Output) framework, 5-7 detailed personas. Among the earliest formalized named frameworks.
- **OpenAI's AI Debate safety research** (Irving et al., 2018): Proposed having agents debate as a safety mechanism; cited as early academic precursor.
- **Du et al. (2023)**: Multi-agent debate paper showing factual accuracy and math reasoning improvements through inter-LLM debate.
- **Perplexity Model Council** (February 2026): Brought the pattern to mainstream consumer products with a three-frontier-model council.

### Commercial Products

- **LLMCouncil.ai** — commercial product
- **Council-AI.app** — multi-AI collaboration platform
- **Suprmind** — 5-model panel with 6 orchestration modes (Sequential, Debate, Red Team, Research Symphony, First Principles)

---

## 2. Best Personas

### The Canonical Five (Karpathy / Jam AI / Mariah)

The most widely cited set across guides:

| Persona | Mandate |
|---|---|
| **The Contrarian** | Identifies failure points exclusively. Lists every reason this decision fails. No solutions — only failures. |
| **The First Principles Thinker** | Questions whether you're solving the right problem. Rebuilds from fundamentals. Strips assumptions. |
| **The Expansionist** | Surfaces hidden upside. Explores asymmetric outcomes if this succeeds. What are we underestimating? |
| **The Outsider** | Cross-industry, naive perspective. Asks questions insiders stopped asking. |
| **The Executor** | Converts everything to immediate action. Monday-morning tasks. Week-one plans only. |

**Plus a Chairman/Synthesizer** — not a debater, a resolver.

### Marius Silo's "Council of Chaos" (Three Archetypes)

Deliberately colorful, simpler:
- **Gary the Gremlin** — "You've seen it all and you're not impressed. Professional pessimist."
- **Celeste the Visionary** — "You just drank three espressos and can see the future."
- **Dave the Doer** — "You just want to get home by 5pm." (Practical next step.)

### Duke DDMC Six-Role Framework (Verification Focus)

Designed for research and fact-intensive tasks:
1. **Analyst** — Summarizes situation, proposes practical answers
2. **Skeptic** — Identifies unsupported claims and hidden assumptions
3. **Evidence Checker** — Lists claims requiring verification/citations
4. **Student/User Advocate** — Evaluates clarity, fairness, accessibility
5. **Implementation Lead** — Assesses feasibility, workflow, adoption barriers
6. **Final Synthesizer** — Concise recommendations with caveats

### Claude Blattman's /council Panels (Task-Specific)

| Panel Type | Critics |
|---|---|
| **Plan review** | skills-engineer, skeptic, pre-mortem, budget-hawk |
| **Academic paper** | academic-editor, harsh-referee, methodologist |
| **Grant proposal** | academic-editor, harsh-referee, methodologist, grant-strategist, funder-officer |
| **Decision** | skeptic, pre-mortem, chief-of-staff |

### Dennis Kennedy's G-A-L Approach

Generate 25+ candidate persona types, narrow to 5-7, write ~100-word descriptions per persona, store in a reusable prompt library. Better for "what should I consider?" questions than adversarial stress-testing.

---

## 3. Moderator / Chair Techniques

### The Chairman's Core Deliverables (Karpathy Model)

The Chairman does not debate — it resolves. Standard deliverables:
- **The one thing to do** (not a list, a single decision)
- **The single biggest risk** to watch
- **The very first step** to take (this week, not "eventually")

"It depends" is unacceptable. The Chairman must take a position.

### Synthesis Architecture (Best Practice)

The synthesis agent should operate in **fresh context** — reads critic outputs as raw data, not a conversation continuation. Prevents rubber-stamping reasoning it was anchored to.

The Chairman's output should explicitly:
- Identify **areas of agreement vs. genuine disagreement**
- Report **confidence levels with justification**
- Flag **human decision points** — things the council cannot resolve
- Distinguish **evidence-based claims from model-generated analysis**

### The No-Majority-Vote Rule

From claudeblattman.com's /council implementation: "A lone dissent on the right point outweighs unanimous agreement on the wrong frame." Synthesis ranks competing perspectives; it does not vote on narrative conclusions.

### Anti-Sycophancy Synthesis Prompt

```
You are synthesizing disagreement, not finding the average.
Where advisors disagree, identify which position has stronger evidence.
If you cannot resolve the disagreement, say so and explain what information would resolve it.
Do not produce a diplomatic non-answer.
```

---

## 4. Debate Mechanics

### Karpathy's Original Three-Stage Pipeline

```
Stage 1: INDEPENDENT RESPONSES
  Each persona receives the question with no cross-visibility
  Isolation prevents herding / anchoring

Stage 2: ANONYMOUS PEER REVIEW
  Each model receives other responses labeled A, B, C... (no identity)
  Models rank by accuracy and logical soundness

Stage 3: CHAIRMAN SYNTHESIS
  Chairman receives all responses + all peer rankings
  Produces final synthesized recommendation
```

Key insight on anonymization: "When an LLM doesn't know it's grading its own prior response, it grades honestly." Stripping names forces evaluation of actual reasoning rather than model-brand loyalty.

### Single-Model Sequential (Most Common for Claude)

When running council in a single Claude context:
1. Define all personas upfront in the prompt
2. Instruct Claude to respond sequentially in each persona's voice
3. Optional: include a "cross-evaluation" round where each persona comments on others
4. Chairman synthesizes last

### Multi-Round Structure (Academic Town Hall)

From Sandwar et al. (2025) "Town Hall Debate Prompting":
- 5 personas (LLM-determined personalities, not predefined)
- 3-round townhall debate
- Personas give critical comments and rebuttals each round
- Results: **+13% improvement on GPT-4o** over one-shot CoT, **+9% on Claude 3.5 Sonnet**
- Optimal: 5 personas; performance degrades with fewer or more

### The Single-Round-Only Argument

From claudeblattman.com's /council: "No iterative debate. Round-two-and-beyond debate among critics drifts toward conformity." Second rounds produce social convergence rather than logical convergence. One honest round of disagreement beats three rounds of diplomatic softening.

---

## 5. Techniques Specific to Claude

### Single-Model Council Prompt (XML Structure)

Claude's native XML parsing makes it well-suited for structured council prompts:

```xml
<council_rules>
  For every question, you run the full council process:
  1. Each advisor speaks from their defined role only
  2. Advisors may directly contradict each other
  3. No advisor softens their view to seem agreeable
  4. Chairman synthesizes last with a concrete verdict
</council_rules>

<council_personas>
  <persona id="contrarian">
    You are The Contrarian. Your only job is to find where this breaks.
    List every reason this decision fails. Do not offer solutions — only failures.
    Minimum 3 failure modes, maximum 5 sentences total.
  </persona>
  <persona id="first_principles">
    You are The First Principles Thinker. Question whether we are solving
    the right problem. Strip every assumption. Rebuild from zero.
  </persona>
  <persona id="expansionist">
    You are The Expansionist. Find the hidden upside. What asymmetric
    outcome is possible if this works? What are we underestimating?
  </persona>
  <persona id="outsider">
    You are The Outsider. You have no industry context. Ask the naive
    questions that experts stopped asking. What obvious thing are we missing?
  </persona>
  <persona id="executor">
    You are The Executor. Convert everything to action. What happens
    Monday morning? Give me week-one tasks only.
  </persona>
  <persona id="chairman">
    You are The Chairman. Read all five advisors. Take a position.
    Deliver: (1) the one decision to make, (2) the biggest risk,
    (3) the first step. No hedging. "It depends" is a failure.
  </persona>
</council_personas>
```

### Trigger Phrases (Community Practice)

Design the skill to activate on natural language:
- "council this"
- "run the council on [question]"
- "pressure-test this"
- "war room this"
- "give me the full council"
- "stress test this idea"

### Claude Projects Integration

From Jam AI's guide: Save the council definition as a **Claude Project** with personas in project knowledge. Gives persistent council access across all chats without re-pasting the full prompt each session.

### Subagent (Claude Code) Implementation

Karpathy's pattern in Claude Code uses parallel subagents:

```python
# Round 1: Parallel, isolated — prevent anchoring
contrarian = spawn_agent(persona="contrarian", question=q)
first_principles = spawn_agent(persona="first_principles", question=q)
# ... etc.

# Round 2: Anonymous peer review
all_responses = collect([contrarian, first_principles, ...])
anonymized = anonymize(all_responses)  # Label as A, B, C, D, E
peer_rankings = chairman.evaluate(anonymized)

# Round 3: Chairman synthesis
final = chairman.synthesize(all_responses, peer_rankings)
```

Key: Each persona's context is clean in Round 1. Anonymization in Round 2 forces honest evaluation. From Abhijay Vuyyuru's implementation: "The anonymized review stage proved most valuable — models become harsh critics when they don't know they're grading themselves."

### Model Recommendations (as of June 2026)

- **Council members**: Claude Sonnet 4.6 (cost-effective, strong reasoning)
- **Chairman/Synthesizer**: Claude Opus 4.8 (superior synthesis quality)
- **Convergence checks / summarization**: Claude Haiku 4.5 (cheap, fast)

### Context Scanning Before Council

Scan workspace files (CLAUDE.md, memory files, relevant project files) before spawning advisors to give them domain context. Without this, personas give generic answers; with this, they engage with actual project constraints.

### Response Constraints to Prevent Bloat

Enforce hard limits per persona:
- Each advisor: 3-5 sentences maximum
- Chairman: one decision + one risk + one first step
- Hard output cap (e.g., 800 words total) to prevent sprawl

---

## 6. Comparison to Related Techniques

### vs. Six Thinking Hats (de Bono, 1985)

| Dimension | Six Hats | AI Council |
|---|---|---|
| Roles | Fixed 6 (facts, emotion, caution, optimism, creativity, process) | Domain-adaptive, problem-specific |
| Adversarial | No (hats cooperate) | Yes (personas explicitly disagree) |
| Best for | Group facilitation, brainstorming | High-stakes decisions, stress-testing |
| Weakness | No built-in disagreement mechanism | Requires explicit dissent mandate |

### vs. Red Team / Blue Team

| Dimension | Red/Blue Team | AI Council |
|---|---|---|
| Structure | Binary (attacker vs. defender) | Multi-perspective (5+ roles) |
| Adversarial depth | Deep (one side tries to break things) | Broad (many angles, some constructive) |
| Best for | Security testing, vulnerability finding | Decision-making, strategy, design review |

### vs. Multi-Agent Debate (Academic, Du et al. 2023)

| Dimension | Academic MAD | Practical AI Council |
|---|---|---|
| Implementation | Separate model instances | Personas in one prompt OR subagents |
| Purpose | Research on reasoning improvement | Practical decision support |
| Debate structure | Strict rounds, rebuttals | Flexible (1-3 rounds typical) |
| Cost | High (N models × N rounds) | Moderate (single model) to High (multi-model) |

### vs. smart-review Skill

| Dimension | smart-review | AI Council |
|---|---|---|
| Persona selection | Context-adaptive (right experts for the work) | Fixed adversarial set (or task-specific panels) |
| Focus | Engineering, test, security, design quality | Decision pressure-testing, strategy, idea validation |
| Output | Expert critique per domain | Synthesized verdict with one decision |
| Best for | Code / doc review | Ideas, plans, high-stakes choices |

---

## 7. Best Practices and Pitfalls

### Best Practices

**Structural:**
1. Cap at 5 personas. Beyond 5, synthesis quality degrades.
2. Single debate round for single-model councils. Multi-round drifts toward social convergence, not logical convergence.
3. Separate synthesis context. The Chair receives critic outputs as fresh data, not a conversation continuation.
4. Anonymize peer review. Label responses A, B, C. Forces honest evaluation by preventing model-brand bias.
5. Run Round 1 in parallel (in multi-agent setup) to prevent anchoring.

**Prompting:**
6. Mandate explicit dissent. "You MUST identify at least 3 failure modes" is stronger than "feel free to disagree."
7. Give each persona a single optimization mandate. "Your only job is to find where this breaks" beats "offer a balanced view."
8. Force the Chairman to take a position. Explicitly state: "'It depends' is a failure. Make a decision."
9. Include temporal specificity. "What happens Monday morning?" beats "what should we do?"
10. Forbid diplomatic softening. "Do not soften your view to seem agreeable" must be explicit.

**Process:**
11. Reserve for genuinely complex questions. Council is wasteful for factual lookups or simple tasks.
12. Scan workspace context before council to give personas domain-specific grounding.
13. The council doesn't decide — you do. Treat output as structured input to your judgment, not an oracle.
14. Test on past decisions with known outcomes before trusting for new high-stakes ones.

### Pitfalls

**Structural:**
1. **The sycophancy trap.** Stanford research found LLMs affirm user decisions 49% more often than humans — even when wrong. A council of sycophantic models can still converge on what you want to hear, just from five angles.
2. **Persona drift.** Without strong per-persona constraints, personas regress to "helpful AI" regardless of assigned role. The Contrarian starts offering solutions; the Expansionist starts raising risks.
3. **Premature consensus.** Personas cave to each other's framing in later rounds without requiring evidence-based reasoning for position changes.
4. **Generic Chairman output.** Without explicit anti-hedging instructions, the Chair produces: "There are valid points on both sides..."

**Epistemics:**
5. **Adversarial persuasion risk.** A 2026 *Scientific Reports* paper found a single persuasive adversarial agent can push debate toward wrong answers. A confident wrong persona can override correct ones.
6. **Citation hallucination.** Evidence Checker and Analyst personas may fabricate citations when instructed to verify claims. Treat all claimed citations as unverified.
7. **Echo chamber under different labels.** All personas share the same underlying model trained on the same data. Fundamental epistemic blind spots are shared across all personas.
8. **Groupthink by agreement.** Multi-round debates where models can see each other's responses tend toward convergence, not toward truth.

**Practical:**
9. **Scale without purpose.** Multi-model councils cost 7-10x single queries. Without a clear signal the question warrants it, you're spending more for marginally better answers.
10. **Verbose preference bias in peer review.** Models reviewing each other favor longer, more detailed responses regardless of accuracy. Brief, precise answers get underrated.
11. **Human abdication.** Treating council output as a final answer removes the human from the loop. The value is structured input, not automated decision-making.

---

## 8. Academic Foundations

| Paper | Key Finding |
|---|---|
| Du et al. (2023), "Improving Factuality and Reasoning in LLMs Through Multi-Agent Debate" | Multi-agent debate improves factual accuracy and math reasoning over single-agent |
| Wang et al. (2023), "Self-Consistency Improves Chain of Thought Reasoning" (ICLR 2023) | +17.9pp on GSM8K via multiple reasoning paths + majority vote |
| Yao et al. (2023), "Tree of Thoughts" (NeurIPS 2023) | GPT-4 improved from 4% to 74% on Game of 24 via branching reasoning |
| Sandwar et al. (2025), "Town Hall Debate Prompting" (arXiv 2502.15725) | 5-persona single-model debate: +13% GPT-4o, +9% Claude 3.5 Sonnet on ZebraLogic |
| Kraidia et al. (2026), *Scientific Reports* | Single persuasive adversarial agent can push debate toward wrong answers |
| PLOS Digital Health (2025/2026), Medical Council | Council of AIs on USMLE Step 1: 97% accuracy; corrected errors 83% of the time when models initially disagreed |

---

## Key Sources

- [GitHub: karpathy/llm-council](https://github.com/karpathy/llm-council)
- [VentureBeat: Karpathy joins Anthropic](https://venturebeat.com/technology/andrej-karpathy-announces-hes-joining-anthropic)
- [Analytics Vidhya: LLM Council by Andrej Karpathy](https://www.analyticsvidhya.com/blog/2025/12/llm-council-by-andrej-karpathy/)
- [Learn AI with Mariah: The LLM Council Prompt](https://learnaiwithmariah.com/guides/llm-council-prompt/)
- [Jam AI: How to Build an AI Council in Claude](https://jamout.ai/blog/how-to-build-an-ai-council-in-claude-5-advisors-that-give-you-10x-better-answers)
- [Marius Silo: The Council of AI](https://medium.com/@Silotech.xyz/the-council-of-ai-a-multi-agent-prompting-framework-for-better-decision-making-8e7569c10584)
- [Duke DDMC: Using an AI Council](https://sites.duke.edu/ddmc/2026/05/10/using-an-ai-council-to-improve-reasoning-verification-and-decision-making/)
- [MindStudio: Multi-Model AI Agent Councils](https://www.mindstudio.ai/blog/multi-model-ai-agent-council)
- [Claude Blattman: /council workflow](https://claudeblattman.com/workflows/council/)
- [Abhijay Vuyyuru: Karpathy's Council as Claude Skill](https://abhijayvuyyuru.substack.com/p/i-let-5-ais-fight-over-my-decisions)
- [Solopreneur Code: LLM Council in Notion AI](https://solopreneurcode.substack.com/p/how-i-built-the-llm-council-inside)
- [Hassan Lâasri: The Multi-LLM Strategy](https://hassan-laasri.medium.com/the-multi-llm-strategy-c9f3c46a69db)
- [Dennis Kennedy: G-A-L Method](https://www.denniskennedy.com/blog/2023/09/adding-a-group-advisory-layer-to-your-use-of-generative-ai-tools-through-structured-prompting-the-g-a-l-method/)
- [Suprmind: Pro LLM Council](https://suprmind.ai/hub/llm-council/)
- [Dubell.io: Council of Experts](https://dubell.io/building-your-personal-council-of-experts/)
- [arXiv: Town Hall Debate Prompting (2502.15725)](https://arxiv.org/abs/2502.15725)
- [arXiv: Persona-based Multi-Agent Collaboration (2512.04488)](https://arxiv.org/pdf/2512.04488)
- [medRxiv: Collaborative Intelligence on USMLE](https://www.medrxiv.org/content/10.1101/2025.02.17.25322388)
