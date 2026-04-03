# Basics of Generative AI

Welcome to the Basics of Generative AI module! This comprehensive guide covers everything you need to know to get started with generative AI, from understanding different models to deploying them in production.

## 📚 Table of Contents

### Foundation Models
1. [**LLMs, Embeddings, and Models**](01-llms-embeddings-models.md)
   - Large Language Models (Open-source & Closed-source)
   - Embeddings and Rerankers
   - Text-to-Speech (TTS) and Speech-to-Text (STT)
   - Image and Video Generation Models
   - Multi-modal Capabilities

2. [**Transformers and Other Architectures**](02-transformers-architecture.md)
   - Core architecture behind modern generative models

3. [**Model Parameters and Key Terms**](03-model-parameters.md)
   - Top-k, Top-p, Temperature
   - Context window, Max tokens
   - Frequency/Presence penalties

### Working with Models
4. [**Understanding and Hands-on with Tokenizers**](04-tokenizers.md)
   - Text to token conversion
   - Tokenization strategies (BPE, WordPiece, SentencePiece)
   - Token limits and optimization

5. [**Hands-on Practice with APIs**](05-hands-on-practice.md)
   - Working with OpenAI, Google Gemini, Groq APIs
   - Text generation, Vision, TTS, STT, Embeddings

6. [**Prompting Best Practices and Strategies**](06-prompting-strategies.md)
   - Prompt engineering techniques
   - Few-shot learning, Chain-of-thought prompting
   - Role-based prompting, System messages

7. [**Context Management**](07-context-management.md)
   - Rolling window, Recursive summarization
   - Selective retention
   - Best practices for long conversations

### Advanced Integration
8. [**Structured Output Generation**](08-structured-output.md)
   - Generating JSON and structured data
   - Schema validation
   - Framework support (Pydantic, JSON Schema)

9. [**Function Calling**](09-function-calling.md)
   - API-based function calling
   - Framework implementations
   - Tool use and execution

10. [**Streaming Outputs**](10-streaming-outputs.md)
    - Streaming text and audio
    - WebSocket integration
    - Handling partial responses

11. [**Real-time APIs**](11-realtime-apis.md)
    - Voice-to-voice systems
    - OpenAI real-time API
    - Low-latency implementations

### Model Customization
12. [**LLM Fine-tuning (Hands-on)**](12-fine-tuning.md)
    - Pre-training and data preparation
    - Fine-tuning Techniques (PEFT, LoRA, QLoRA)
    - Model Alignment (RLHF, DPO, PPO)

### Evaluation and Optimization
13. [**Understanding LLM Benchmarks**](13-benchmarks.md)
    - GPQA, MMLU-PRO, AIME
    - LiveCode Bench, MuSR, HLE

14. [**LLM Evaluation Metrics**](14-evaluation-metrics.md)
    - Technical Metrics (Perplexity, BLEU, ROUGE)
    - Business Metrics (ROI, Customer satisfaction)

15. [**LLM Inference Metrics**](15-inference-metrics.md)
    - Latency, Throughput
    - Memory usage, Cost efficiency

16. [**LLM Leaderboards**](16-leaderboards.md)
    - Artificial Analysis, Vellum, Scale.com
    - Hugging Face, Live Bench

### Production Deployment
17. [**Quantization**](17-quantization.md)
    - INT8, INT4 Quantization
    - GPTQ, AWQ, GGUF
    - Benefits and trade-offs

18. [**Model Serving and Inference Strategies**](18-serving-strategies.md)
    - Batching, KV Cache
    - Speculative decoding, Continuous batching
    - Model parallelism, Tensor parallelism

19. [**Model Hosting and Inference**](19-model-hosting.md)
    - Inference Servers (vLLM, SGLang, Triton, LitServe)
    - Deployment best practices

---

## 🚀 How to Use This Guide

1. **Sequential Learning**: Follow the topics in order for a structured learning path
2. **Jump to Topics**: Use the table of contents to navigate to specific topics
3. **Hands-on Practice**: Each section includes practical examples and exercises
4. **Reference**: Use as a quick reference guide when building applications

---

## 🎯 Learning Path Recommendation

### Beginner (Weeks 1-2)
- Topics 1-7: Foundation models, parameters, and basic usage

### Intermediate (Weeks 3-4)
- Topics 8-11: Advanced integration and real-time systems

### Advanced (Weeks 5-6)
- Topics 12-16: Fine-tuning, evaluation, and benchmarking

### Production (Weeks 7-8)
- Topics 17-19: Optimization and deployment

---

## 📖 Additional Resources

- [OpenAI Documentation](https://platform.openai.com/docs)
- [Anthropic Claude Docs](https://docs.anthropic.com)
- [Google Gemini Docs](https://ai.google.dev)
- [Hugging Face Models](https://huggingface.co/models)

---

[← Back to Main Guide](../README.md)
