# Basics of Generative AI

Welcome to the Basics of Generative AI module! This comprehensive guide covers everything you need to know to get started with generative AI, from understanding different models to deploying them in production.

## 📚 Table of Contents

### Foundation (Week 1-2)
1. [**Introduction to Large Language Models**](01-introduction-to-llms.md)
   - What are LLMs and how they work
   - Open-source vs Closed-source models
   - Common use cases and applications

2. [**Transformers and Other Architectures**](02-transformers-architecture.md)
   - Core architecture behind modern generative models
   - Attention mechanisms
   - Model architecture patterns

3. [**Understanding Tokenizers**](03-tokenizers.md)
   - Text to token conversion
   - Tokenization strategies (BPE, WordPiece, SentencePiece)
   - Token limits and optimization

4. [**Model Parameters and Key Terms**](04-model-parameters.md)
   - Top-k, Top-p, Temperature
   - Context window, Max tokens
   - Frequency/Presence penalties

### Practical Skills (Week 2-3)
5. [**Hands-on Practice with APIs**](05-hands-on-practice.md)
   - Working with OpenAI, Google Gemini, Groq APIs
   - Text generation and basic interactions

6. [**Prompting Best Practices and Strategies**](06-prompting-strategies.md)
   - Prompt engineering techniques
   - Few-shot learning, Chain-of-thought prompting
   - Role-based prompting, System messages

7. [**Context Management**](07-context-management.md)
   - Rolling window, Recursive summarization
   - Selective retention
   - Best practices for long conversations

8. [**Structured Output Generation**](08-structured-output.md)
   - Generating JSON and structured data
   - Schema validation
   - Framework support (Pydantic, JSON Schema)

### Integration (Week 3-4)
9. [**Function Calling**](09-function-calling.md)
   - API-based function calling
   - Framework implementations
   - Tool use and execution

10. [**Streaming Outputs**](10-streaming-outputs.md)
    - Streaming text generation
    - WebSocket integration
    - Handling partial responses

11. [**Real-time APIs**](12-realtime-apis.md)
    - Voice-to-voice systems
    - OpenAI real-time API
    - Low-latency implementations

### Other-model (Week 4-5)
12. [**Embeddings and Semantic Search**](11-embeddings-semantic-search.md)
    - Understanding embeddings and rerankers
    - Vector databases
    - Similarity search and retrieval

13. [**Text-to-Speech (TTS) and Speech-to-Text (STT)**](13-text-to-speech.md)
    - TTS and STT models and providers
    - Voice customization
    - Streaming audio output

14. [**Image Generation**](14-image-generation.md)
    - Text-to-image models
    - Open-source vs closed-source options
    - Practical applications

15. [**Video Generation**](15-video-generation.md)
    - Text-to-video models
    - Video editing with AI
    - Multi-modal video understanding

### Evaluation & Quality (Week 5-6)
16. [**LLM Evaluation Metrics**](16-evaluation-metrics.md)
    - Technical Metrics (Perplexity, BLEU, ROUGE)
    - Business Metrics (ROI, Customer satisfaction)
    - Quality assessment

17. [**LLM Inference Metrics**](17-inference-metrics.md)
    - Latency, Throughput
    - Memory usage, Cost efficiency
    - Performance optimization

18. [**Understanding LLM Benchmarks**](18-benchmarks.md)
    - GPQA, MMLU-PRO, AIME
    - LiveCode Bench, MuSR, HLE
    - How to interpret benchmark scores

19. [**LLM Leaderboards**](19-leaderboards.md)
    - Artificial Analysis, Vellum, Scale.com
    - Hugging Face, Live Bench
    - Choosing the right model

### Advanced & Production (Week 6-8)  <- Optional for beginners>
20. [**LLM Fine-tuning (Hands-on)**](20-fine-tuning.md)
    - Pre-training and data preparation
    - Fine-tuning Techniques (PEFT, LoRA, QLoRA)
    - Preference Alignment (RLHF, DPO, PPO)

21. [**Quantization**](21-quantization.md)
    - INT8, INT4 Quantization
    - GPTQ, AWQ, GGUF
    - Benefits and trade-offs

22. [**Model Serving and Inference Strategies**](22-serving-strategies.md)
    - Batching, KV Cache
    - Speculative decoding, Continuous batching
    - Model parallelism, Tensor parallelism

23. [**Model Hosting and Inference**](23-model-hosting.md)
    - Inference Servers (vLLM, SGLang, Triton, LitServe)
    - Deployment best practices
    - Scaling considerations



[← Back to Main Guide](../README.md)
