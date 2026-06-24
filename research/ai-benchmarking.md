# AI/LLM Benchmarking Methodologies

> ***🤖 Claude generated, human reviewed***

## Established Coding Benchmarks

**HumanEval** (2021): 164 hand-written Python function-completion tasks, scored by unit test pass rate (pass@k). Saturated at the frontier (95%+); contaminated by training data exposure since release.

**MBPP** (2021): 974 crowd-sourced Python problems, same pass@k methodology. Saturated for frontier models; serves as a minimum-competency floor.

**SWE-bench** (2023): 2,294 real GitHub issues from 12 Python repos paired with gold patches and test suites; scored by resolved rate. Verified (2024) subsets to 500 human-confirmed solvable tasks. Limitations: static corpus invites overfitting; environment construction is brittle; binary pass/fail scoring ignores solution quality. SWE-bench Live (2025) uses post-training-cutoff issues to reduce contamination.

**LiveCodeBench** (2024, continuous): competitive programming problems from Codeforces, LeetCode, and AtCoder, refreshed past each model's training cutoff. Contamination-resistant by design; measures algorithm synthesis, not repository-level engineering.

## Config and Prompt Evaluation Frameworks

**promptfoo**: Open-source CLI/library for prompt regression testing. Runs prompt templates against a test case matrix and reports pass/fail against user-defined assertions (regex, LLM-judge, semantic similarity). Best fit: CI gates on prompt changes, A/B model selection, red-teaming.

**RAGAS**: Metrics library for RAG pipelines. Core metrics: faithfulness, answer relevancy, context precision, context recall, each computed via LLM call per sample. Best fit: retriever quality and hallucination rate in document-QA. Not applicable to non-RAG tasks.

**LangSmith**: Observability and eval platform for LangChain/LangGraph. Captures production traces, supports human annotation, runs offline evals. Best fit: LangChain users who need offline test sets and production monitoring in one platform.

## LLM-as-Judge

A model scores or ranks candidate outputs against a rubric, supplementing human annotation where deterministic metrics fail.

**Known biases:**
- **Self-preference**: Model rates its own outputs higher even when authorship is masked. Scales with model size and RLHF intensity.
- **Position bias**: Judge inflates scores for whichever candidate appears first in a pairwise prompt.
- **Verbosity bias**: Longer responses score higher regardless of quality.

**Mitigations:** Swap candidate order and average both scores (position bias). Use a heterogeneous multi-judge ensemble (self-preference). Prefer per-dimension analytic rubrics over holistic ratings. Force chain-of-thought before scoring. Calibrate against human labels before deployment.

## Deterministic vs. Probabilistic Evaluation

Deterministic evaluation (exact match, regex, unit test pass/fail, schema validation) applies when the requirement admits a unique correct answer. Fast, cheap, reproducible.

Probabilistic/LLM-judge evaluation applies when the output space is too broad for rules: coherence, factual consistency against unstructured context, multi-step reasoning. Slower, costlier, carries judge-model variance.

Practical pattern: deterministic gates filter obvious failures; LLM-judge runs on passing candidates.

## Evaluating Claude Code and Coding Assistant Configurations

No standardized benchmark exists for assistant configuration quality (CLAUDE.md, system prompts, tool policies, hooks). Community practice:

- **Task-specific test suites**: Representative tasks with known outputs or acceptance criteria; score pass rate. promptfoo supports this via YAML test cases.
- **Regression sets**: Real production failures captured as negative examples; re-run after config changes.
- **Blind subagent review**: Fresh-context subagent reviews the output diff, decoupled from the reasoning chain that produced it.
- **Hook-gated CI**: Stop hooks running linters or tests after each turn provide deterministic pass/fail independent of model self-assessment.

## Multi-Run Aggregation for Non-Determinism

At temperature > 0, the same prompt produces different outputs across runs; a single-run eval conflates capability with sampling variance.

- **pass@k** for code generation: probability at least one of k samples passes; common k values: 1, 5, 10.
- **Agent evals**: run 3-10 independent trials; report mean resolved rate with 95% confidence interval.
- **LLM-judge evals**: run each sample through multiple passes or a multi-judge ensemble; aggregate by majority vote or mean. Single-judge, single-pass is insufficient.
- Temperature = 0 reduces variance (hardware floating-point non-determinism persists). Not a substitute for multi-run sampling.
