# Training Generative AI Models

Training modern generative AI models is not a single-step process unlike traditional machine learning models. It involves multiple stages and techniques to optimize performance, alignment, and efficiency. Below are the key stages involved:

![Training Pipeline](../assets/Basics_of_Generative_AI/19-training-generativeai-models/training%20llm.gif)

---

## Stage 1: Pre-training

Pre-training is the foundational phase where the model learns from a massive, unlabeled corpus of data — internet text, books, code, and more. The model learns general language patterns, grammar, world knowledge, and contextual understanding through self-supervised objectives.

### Common Pre-training Objectives

| Objective | Description | Used In |
|-----------|-------------|---------|
| **Causal Language Modeling (CLM)** | Next-token prediction | GPT-style decoder models |
| **Masked Language Modeling (MLM)** | Predict randomly masked tokens | BERT-style encoder models |
| **Contrastive Learning** | Learn similarity between representations | CLIP, SentenceBERT |
| **Span Corruption** | Mask and reconstruct text spans | T5, PaLM |

### Key Characteristics

- Requires enormous compute (thousands of GPUs/TPUs for weeks or months)
- Dataset scale: hundreds of billions to trillions of tokens
- Produces a general-purpose base model (e.g., Llama 3, Mistral, GPT-4 base)

> **Note:** Base models are not instruction-following — they are next-token predictors. All subsequent stages build on top of this foundation.

---

## Stage 2: Supervised Fine-Tuning (SFT)

Fine-tuning takes a pre-trained base model and trains it further on a smaller, high-quality dataset of instruction-response pairs. This teaches the model to follow instructions, respond helpfully, and adapt to a specific domain or task.

### Fine-tuning Approaches

**Full Fine-Tuning** — All model weights are updated. Expensive but thorough. Rarely used for LLMs due to compute cost.

**PEFT (Parameter-Efficient Fine-Tuning)** — Only a small subset of parameters are trained, keeping the base model largely frozen.

---

### PEFT Methods

#### Adapter-Based

| Method | Description |
|--------|-------------|
| **Adapters (Houlsby et al.)** | Insert small bottleneck layers between transformer blocks; only adapter weights are trained |
| **AdapterFusion** | Combines multiple task-specific adapters without catastrophic forgetting |
| **AdapterDrop** | Drops adapters from lower layers for inference efficiency |
| **Parallel Adapters** | Adapters run in parallel with attention/FFN instead of sequentially |

#### Low-Rank Decomposition

| Method | Description |
|--------|-------------|
| **LoRA** | Injects trainable rank-decomposition matrices (A×B) into attention weights; most widely used PEFT method |
| **QLoRA** | LoRA on a 4-bit quantized (NF4) base model; enables fine-tuning large models on consumer GPUs |
| **DoRA** | Decomposes weights into magnitude + direction; applies LoRA to the direction component |
| **LoRA+** | Uses different learning rates for A and B matrices for better optimization |
| **LoftQ** | Jointly initializes quantization and LoRA for better alignment between quantized base and LoRA weights |
| **rsLoRA** | Scales LoRA by 1/√r instead of 1/r for stable training at higher ranks |
| **GLoRA** | Generalized LoRA with more expressive reparameterization across layers |

#### Prompt / Prefix-Based

| Method | Description |
|--------|-------------|
| **Prompt Tuning** | Prepends trainable soft tokens to the input; only prompt embeddings are updated |
| **Prefix Tuning** | Adds trainable prefix vectors to keys and values in every attention layer |
| **P-Tuning** | Uses an LSTM/MLP encoder to generate continuous prompt embeddings |
| **P-Tuning v2** | Extends P-Tuning with deep prefix tuning applied at every transformer layer |

#### Selective / Sparse

| Method | Description |
|--------|-------------|
| **BitFit** | Fine-tunes only bias terms in the model; surprisingly effective for small tasks |
| **Diff Pruning** | Learns a sparse diff vector over full model weights |
| **Sparse Fine-Tuning (SFT)** | Selectively updates a small subset of the most task-relevant parameters |
| **FishMask** | Selects parameters to update using Fisher information |

#### Scaling Vector Methods

| Method | Description |
|--------|-------------|
| **IA³** | Learns per-layer scaling vectors for keys, values, and FFN activations; extremely parameter-efficient |
| **VeRA** | Shares frozen random matrices across layers; learns only small scaling vectors per layer |

#### Hybrid / Advanced

| Method | Description |
|--------|-------------|
| **UniPELT** | Combines LoRA, prefix tuning, and adapters with learned gating mechanisms |
| **MAM Adapter** | Mix-and-Match unified framework combining prefix tuning + parallel adapters |
| **LLaMA-Adapter** | Adds learnable adaptation prompts with zero-init attention gating |
| **LLaMA-Adapter V2** | Extends LLaMA-Adapter to multimodal/visual instruction tuning |

#### Parameter Efficiency Spectrum

```
BitFit < IA³ < VeRA < Prompt Tuning < LoRA < Prefix Tuning < Full Adapters
(fewest params)                                               (most params)
```

### Key Characteristics

- Requires far less data and compute compared to pre-training
- Dataset: thousands to millions of high-quality (prompt, response) pairs
- Produces an instruction-following model (e.g., Llama-3-Instruct, Mistral-Instruct)

---

## Stage 3: Preference Alignment

Preference alignment ensures the model's outputs reflect human values, safety guidelines, and user expectations — not just statistical plausibility. This is what separates a raw instruction-tuned model from a safe, production-ready assistant.

### RLHF (Reinforcement Learning from Human Feedback)

1. Human annotators rank model responses (preferred vs. rejected)
2. A **reward model** is trained on these rankings
3. The base model is fine-tuned using **PPO (Proximal Policy Optimization)** to maximize reward

Used in: GPT-4, Claude 2/3, InstructGPT

### DPO Family (Direct Preference Optimization)

Eliminates the separate reward model — optimizes directly on preference pairs. More stable and lower compute overhead than RLHF.

| Variant | Key Difference |
|---------|----------------|
| **DPO** | Core method; directly optimizes policy on (chosen, rejected) pairs |
| **IPO** | Fixes DPO overfitting with a regularized objective |
| **KTO** | Uses binary good/bad signals instead of ranked pairs |
| **ORPO** | Combines SFT + alignment in a single step; no reference model needed |
| **SimPO** | Uses average log-probability as implicit reward; no reference model |
| **CPO** | Adds contrastive loss to prevent reward hacking |

Widely adopted in: Llama 3, Mistral, Zephyr

### RLAIF (RL from AI Feedback)

- A stronger AI model generates preference labels instead of humans
- Scales annotation without massive human labeling costs
- Used in: Constitutional AI (Anthropic), Gemini training pipeline

### Constitutional AI (CAI)

Anthropic's approach: defines a set of principles (a "constitution"), then the model critiques and revises its own outputs against those principles. Reduces reliance on human annotation for safety training.

### Inference-Time Alignment

Alignment applied at generation time without any additional training:

| Technique | Description |
|-----------|-------------|
| **Best-of-N Sampling** | Generate N responses; return highest reward-model score |
| **Contrastive Decoding** | Subtract logits of a weak model from a strong model to reduce hallucination |
| **ITI (Inference-Time Intervention)** | Shift activations along "truthful" directions during forward pass |
| **Self-Refinement** | Model iteratively critiques and revises its own output at inference |

### Representation Engineering

| Technique | Description |
|-----------|-------------|
| **RepE (Representation Engineering)** | Identifies and steers high-level concepts (honesty, harm) in activation space |
| **Activation Steering** | Adds concept vectors to the residual stream during the forward pass |

---

## Stage 4: Post-training Optimization

After alignment, models are compressed and optimized for efficient deployment — reducing memory footprint, latency, and serving costs.

### Quantization

Reduces model weight precision from FP32/FP16 → INT8 or INT4.

| Format | Description |
|--------|-------------|
| **GGUF / GGML** | Popular formats for running quantized models locally (llama.cpp) |
| **GPTQ** | Post-training quantization optimized for GPU inference |
| **AWQ** | Activation-aware weight quantization; better quality at 4-bit |
| **bitsandbytes** | Library for 8-bit and 4-bit quantization in Python |

Minimal quality loss with significant memory and speed gains.

### Knowledge Distillation

A large "teacher" model trains a smaller "student" model to mimic its outputs. Produces smaller, faster models that retain most capability.

Examples: DistilBERT, Phi-series (Microsoft), Gemma (Google)

### Pruning

Removes redundant or low-importance weights from the model. Often combined with quantization for maximum compression.

- **Unstructured pruning** — Remove individual weights (fine-grained, hardware-unfriendly)
- **Structured pruning** — Remove entire heads/layers (coarser, hardware-friendly)

### Speculative Decoding

Uses a small draft model to predict tokens, verified by the larger model in parallel. Reduces generation latency without changing model quality.

[Speculative Decoding Blog](https://www.adaptive-ml.com/post/speculative-decoding-visualized)

---

## Stage 5: Evaluation

Evaluation ensures the model meets quality, safety, and task-specific benchmarks before and after deployment.

### Automated Benchmarks

| Benchmark | Measures |
|-----------|----------|
| **MMLU** | Multitask language understanding across 57 subjects |
| **HumanEval / MBPP** | Code generation correctness |
| **MT-Bench** | Multi-turn instruction following quality |
| **TruthfulQA** | Tendency to produce truthful vs. hallucinated answers |
| **HellaSwag / ARC** | Commonsense and reasoning ability |

### LLM-as-Judge

- Use a strong model (e.g., GPT-4, Claude) to score outputs on helpfulness, safety, and coherence
- More scalable than human evaluation; less expensive than full benchmarking pipelines
- Frameworks: **MT-Bench**, **Alpaca Eval**, **LLM-Eval**

### Human Evaluation

- Preferred vs. rejected ratings from human annotators
- A/B testing of model versions in production
- Red-teaming for safety and adversarial robustness

### Key Metrics

| Metric | Used For |
|--------|----------|
| **Perplexity** | Language model quality on held-out text |
| **ROUGE / BLEU** | Summarization and translation |
| **Pass@k** | Code generation correctness |
| **Win Rate** | Head-to-head model comparisons |
| **Refusal Rate** | Safety and alignment auditing |

---

## Summary

| Stage | Goal | Key Techniques | Output |
|-------|------|---------------|--------|
| **Pre-training** | Learn language & world knowledge | CLM, MLM, contrastive learning | Base model |
| **Supervised Fine-Tuning** | Follow instructions | LoRA, QLoRA, full fine-tune | Instruction model |
| **Preference Alignment** | Be helpful, safe & honest | RLHF/PPO, DPO, ORPO, CAI, RLAIF | Aligned assistant |
| **Post-training Optimization** | Fast, efficient deployment | Quantization, distillation, pruning | Production model |
| **Evaluation** | Validate quality & safety | Benchmarks, LLM-as-Judge, red-teaming | Certified release |

> **Modern frontier models** (GPT-4, Claude, Gemini, Llama 3) go through all five stages. Open-source practitioners typically start from a pre-trained base and apply SFT + DPO using frameworks like **Hugging Face TRL**, **Axolotl**, or **LLaMA-Factory**.

### Typical Training Pipeline

```
Pretrain → SFT → Reward Modeling → RLHF / DPO → Optimization → Evaluate → Deploy
```

---

[← Previous: Leaderboards and Model Cards](18-leaderboards.md) | [Next: Quantization →](20-quantization.md)

[← Back to Index](README.md)
