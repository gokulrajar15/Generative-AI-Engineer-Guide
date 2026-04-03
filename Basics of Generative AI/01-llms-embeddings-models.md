# 1. Open-source and Closed-source LLMs

Understanding LLMs, embeddings, TTS, STT, and other models.

---

## 1.1 Large Language Models (LLMs)

Large Language Models (LLMs) are artificial intelligence models designed to understand and generate human-like text. They are trained on vast amounts of text data and can perform language-related tasks such as:
- Translation
- Summarization
- Question-answering
- Content generation

![Open-source vs Closed-source LLMs](../assets/Basics_of_Generative_AI/01-llms-embeddings-models/opensource_vs_closedsource.png)
*Open-source vs Closed-source LLMs*

### Open-source LLMs

- **Alibaba**: Qwen 3.5
- **MoonshotAI**: Kimi 2.5, Kimi 2
- **ZAI**: GLM 5, 4.7, 4.6
- **Meta**: LLaMA 4, LLaMA 3.3, LLaMA 3.2
- **Google**: Gemma 4, Gemma 3
- **Mistral**: Mistral Large 3, Mistral Small 3, Ministral 3, Devstral 3
- **OpenAI**: GPT-oss

📚 [Explore more open-source LLMs](https://huggingface.co/models)

### Closed-source LLMs

- **OpenAI**: GPT-5.4, GPT-5, GPT-4.1
- **Anthropic**: Claude 4.6 (Opus, Haiku, Sonnet), Claude 4.5, Claude 4
- **Google**: Gemini 3.1 (Pro, Flash), Gemini 2.5 (Pro, Flash)
- **Deepseek**: Deepseek Chat and Reasoner

**Note**: Companies like Groq, Cerebras, and SambaNova host open-source models on their hardware and provide APIs for inference.

---

## 1.2 Embeddings and Rerankers

**Embeddings** are numerical representations of data (text, images, or audio) that capture semantic meaning and relationships. They are used in:
- Natural language processing
- Computer vision
- Recommendation systems
- Semantic search

![Embeddings](../assets/Basics_of_Generative_AI/01-llms-embeddings-models/embedding_model.png)
*Embeddings represent data in a continuous vector space, enabling machines to understand and process complex relationships.*

In NLP, word embeddings represent words in a continuous vector space where similar words are closer together.

**Rerankers** take a list of candidate outputs (like search results) and rank them based on relevance or quality. They are often used with LLMs to improve output quality.

![Rerankers](../assets/Basics_of_Generative_AI/01-llms-embeddings-models/reranker.png)
*Rerankers evaluate and reorder candidate outputs to enhance relevance and quality.*

### Open-source Embeddings and Rerankers

- **Microsoft**: harrier-oss-v1-27b
- **Google**: EmbeddingGemma-300m
- **Alibaba**: Qwen3-embedding

📚 [Explore more open-source embeddings](https://huggingface.co/models)

### Closed-source Embeddings and Rerankers

- **OpenAI**: Text-embedding-3-small, Text-embedding-3-large
- **Google** (Multi-modality support): gemini-embedding-2, gemini-embedding-1
- **Cohere**: Embed v4, Embed v3, Reranker v4, Reranker v3
- **Jina AI**: Jina Embeddings 2.0, Jina Embeddings 1.0, Jina Reranker V3

---

## 1.3 Text-to-Speech (TTS) and Speech-to-Text (STT)

**TTS models** generate natural-sounding speech from text input.  
**STT models** transcribe spoken language into written text.

![TTS and STT](../assets/Basics_of_Generative_AI/01-llms-embeddings-models/stt_tts.png)
*TTS models convert text to speech, while STT models convert speech to text.*

### Common Applications
- Virtual assistants
- Accessibility tools
- Voice-controlled devices

### Open-source TTS and STT Models

- **Alibaba**: Qwen3 ASR, Qwen3 TTS
- **OpenAI**: Whisper large v3 series
- **NVIDIA**: Personaplex-7b-v1 (Speech-to-Speech)
- **Suno**: Bark TTS

📚 [Explore more open-source TTS and STT models](https://huggingface.co/models)

### Closed-source TTS and STT Models

- **Google**: gemini-2.5-flash-preview-tts
- **OpenAI**: gpt-4o-mini-tts, gpt-4o-mini-transcribe

---

## 1.4 Image and Video Generation Models

**Image generation models** create images from text descriptions or other inputs.  
**Video generation models** produce video content based on textual prompts or other media inputs.

**Applications**: Content creation, Design, Entertainment, Advertising, and more.

![Image and Video Generation](../assets/Basics_of_Generative_AI/01-llms-embeddings-models/veo-3-ai-text-to-video.gif)
*Modern video generation models can create realistic videos from text prompts.*

### Open-source Image and Video Generation Models

- **Stable Diffusion**: Stable Diffusion 2.1, Stable Diffusion 2.0
- **Runway**: Gen-2
- **Alibaba**: Qwen-Image-Layered

📚 [Explore more open-source image and video generation models](https://huggingface.co/models)

### Closed-source Image and Video Generation Models

- **OpenAI**: GPT image 1.5, GPT image 1.0, Sora 2 Pro
- **Google**: Nano Banana 2 and Pro, Veo 3.1

---

## Multi-modal Capabilities

Most modern LLMs support multi-modal capabilities, processing and generating:
- Text
- Images
- Audio
- Video

**Example**: Google's Gemini 2.5 Flash supports multi-modal input and output, allowing it to understand and generate content across different media types.

---

## 📚 Additional Resources

- [Hugging Face Model Hub](https://huggingface.co/models)
- [OpenAI Model Documentation](https://platform.openai.com/docs/models)
- [Google AI Models](https://ai.google.dev/models)
- [Meta LLaMA](https://ai.meta.com/llama/)

---

**Next**: [Transformers and Other Architectures →](02-transformers-architecture.md)

[← Back to Index](README.md)
