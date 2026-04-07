# Chunking Strategies

## Overview
Chunking is the process of breaking down large documents into smaller, manageable pieces for indexing and retrieval in RAG systems. Proper chunking is critical for retrieval quality.

---

## Why Chunking Matters

**Challenges with long documents:**
- Embedding models have token limits (512, 8K, etc.)
- Large chunks dilute semantic meaning
- Small chunks lose context
- Affects retrieval accuracy and generation quality

**Goals:**
- Preserve semantic coherence
- Fit within model constraints
- Optimize for retrieval relevance
- Balance context and specificity

---

## Key Chunking Parameters

### 1. **Chunk Size**
- Number of characters or tokens per chunk
- Typical ranges: 200-1000 tokens
- Depends on use case and model

### 2. **Chunk Overlap**
- Number of tokens shared between consecutive chunks
- Typical: 10-20% of chunk size
- Prevents losing context at boundaries

### 3. **Metadata**
- Document ID, section headers, page numbers
- Helps with context and citation
- Used for filtering and routing

---

## Common Chunking Strategies

- **Fixed-size chunking**: Simple, but may split sentences or paragraphs
- **Recursive chunking**: Splits at logical boundaries (e.g., paragraphs) and then further divides if needed
- **Document based chunking**: uses the intrinsic structure of a document
- **Semantic chunking**: Uses NLP techniques to split at logical boundaries (sentences, paragraphs)
- **LLM chunking**: Uses a language model to determine optimal chunk boundaries based on content and context
- **Agentic chunking**: Dynamically adjusts chunking strategy based on retrieval feedback and model performance
- **Hybrid chunking**: Combines fixed size with semantic cues (e.g., split at sentence boundaries but ensure minimum chunk size)
- **Hierarchical chunking**: Creates multiple levels of chunks (e.g., sections, paragraphs, sentences) for multi-granular retrieval
- **Adaptive chunking**: Dynamically adjusts chunk size based on content complexity or model feedback

---

[Take a deep dive into chunking strategies](https://weaviate.io/blog/chunking-strategies-for-rag#what-is-chunking)  <---- This is a great resource that covers various chunking strategies in detail, along with practical tips and examples for implementation.


*Chunking is very important for RAG systems. The right chunking strategy can significantly improve retrieval relevance and generation quality.*


**Next**: [Vector Databases →](05-vector-databases.md)

[← Back to Index](README.md)
