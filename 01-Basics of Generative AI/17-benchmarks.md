## Understanding LLM Benchmarks

Key benchmarks for evaluating LLM performance across reasoning, math, coding, agentic tasks, and human preference. Focus on non-saturated benchmarks that differentiate frontier models.

---

### 🧠 Reasoning & General Intelligence

#### 1. GPQA-Diamond — PhD-Level Science Reasoning
- 448 expert-level questions in biology, chemistry, and physics
- Non-PhD humans score only ~34% even with web access
- **Current leaders:** Gemini 3.1 Pro (94.3%), Claude Opus 4.6 (91.3%), GPT-5.3 Codex (81%)
- Still the gold standard for expert reasoning differentiation

#### 2. HLE — Humanity's Last Exam
- 2,500+ of the toughest, crowd-sourced questions across all academic disciplines
- ~14% of questions are multimodal (text + image)
- Designed as the "final exam" before superhuman AI
- Even top models score only ~25–40% — far from saturated
- **Status:** The most challenging public benchmark as of 2026

#### 3. MMLU-Pro — Broad Knowledge & Reasoning
- Advanced version of MMLU (Massive Multitask Language Understanding)
- 10 answer choices instead of 4 — much harder to game
- Covers 57 subjects: STEM, humanities, law, medicine, and more
- **Note:** Original MMLU is now considered saturated and excluded from most modern leaderboards

---

### ➗ Mathematics

#### 4. AIME 2025 / AIME 2026 — Competitive Math
- Problems from the American Invitational Mathematics Examination
- Multi-step symbolic and logical reasoning required
- Now the **standard frontier math benchmark** (replaced older MATH-500 for top models)
- **Current leaders:** GPT-5.3 Codex (~94%), Qwen3.5-plus (91.3% on AIME 2026)

#### 5. MATH-500 — Competition Mathematics
- 500 problems drawn from AMC 10, AMC 12, and AIME competitions
- Still widely used for mid-tier model comparison
- Top models now score 95–98%, approaching saturation at frontier level

#### 6. MGSM — Multilingual Mathematical Reasoning
- Same 250 GSM8K problems translated into 10 languages
- Languages: Bengali, Chinese, French, German, Japanese, Russian, Spanish, Swahili, Telugu, Thai
- Reveals reasoning consistency across languages — critical for multilingual products

---

### 💻 Coding

#### 7. SWE-bench Verified — Real-World Software Engineering
- 500 verified real GitHub issues from Python repos that the model must resolve end-to-end
- **Most production-relevant coding benchmark** — tests actual software engineering ability
- **Current leaders:** MiniMax M2.5 (80.2%), Claude Sonnet 4.6 Thinking (top score on proprietary evals)
- Preferred over HumanEval for frontier model comparison

#### 8. LiveCodeBench — Competitive Programming (Live)
- Problems continuously pulled from LeetCode, AtCoder, and Codeforces
- Prevents data contamination — new problems added regularly
- Holistic eval: code generation, self-repair, test output prediction
- **Go-to coding benchmark** alongside SWE-bench

#### 9. HumanEval — Python Code Generation (Baseline)
- 164 Python programming tasks tested with unit tests
- Widely cited in model papers; still useful as a baseline
- **Note:** Frontier models now score ~93–99% — nearing saturation; use LiveCodeBench or SWE-bench for frontier comparisons

---

### 🤖 Agentic & Instruction Following

#### 10. TerminalBench — CLI Task Completion
- Measures ability to complete terminal/CLI tasks end-to-end
- Critical for developer tooling and DevOps AI agents
- Claude Sonnet 4.6 (Thinking) currently holds the top spot

#### 11. IFEval (IFBench) — Instruction Following
- Tests how precisely a model follows specific formatting and structural instructions
- **Current leader:** Kimi K2.5 (94.0%)

#### 12. TAU-bench Retail — Agentic Workflow Tasks
- One of 6 benchmarks used across major platforms for agentic evaluation
- Simulates realistic multi-step retail workflows

---

### 💬 Human Preference

#### 13. Chatbot Arena (LMArena / LMSYS)
- Crowd-sourced ELO-style ratings based on blind A/B human comparisons
- Most reflective of real-world user preference
- **Current leaders:** GLM-5 (1451 ELO), Kimi K2.5 (1447 ELO)

---

### 📊 Summary Table

| Benchmark | Category | Saturation Risk | Best For |
|-----------|----------|-----------------|----------|
| GPQA-Diamond | Reasoning | Low–Medium | Expert science tasks |
| HLE | Reasoning | Very Low | Frontier differentiation |
| MMLU-Pro | Knowledge | Low | Broad knowledge eval |
| AIME 2025/26 | Math | Low | Hard math reasoning |
| MATH-500 | Math | Medium | Mid-tier math comparison |
| MGSM | Math (Multilingual) | Low | Multilingual products |
| SWE-bench Verified | Coding | Low | Production engineering |
| LiveCodeBench | Coding | Very Low | Competitive programming |
| HumanEval | Coding | High | Baseline only |
| TerminalBench | Agentic | Low | CLI/DevOps agents |
| IFEval | Instruction | Low | Structured output tasks |
| TAU-bench | Agentic | Low | Workflow automation |
| Chatbot Arena | Human Preference | N/A | Real-world user quality |

---

### ⚠️ Deprecated / Saturated Benchmarks (Avoid for Frontier)

- **MMLU** — Saturated; most leaderboards now exclude it
- **HellaSwag** — Frontier models score 95%+; no longer differentiating
- **GSM8K** — Replaced by AIME and MATH-500 for meaningful comparison

---

### 🔑 Choosing the Right Benchmark

| Use Case | Recommended Benchmarks |
|----------|------------------------|
| Code assistant | SWE-bench Verified + LiveCodeBench |
| Math/reasoning agent | AIME 2025 + GPQA-Diamond |
| Multilingual product | MGSM + MMLU-Pro |
| General reasoning | GPQA-Diamond + HLE |
| Agentic/DevOps tool | TerminalBench + TAU-bench |
| Human-facing chat | Chatbot Arena ELO |


References:

- [LLM Benchmarks](https://www.lxt.ai/blog/llm-benchmarks/)

---

[← Previous: Inference Metrics](16-inference-metrics.md) | [Next: Leaderboards and Model Cards →](18-leaderboards.md)

[← Back to Index](README.md)
