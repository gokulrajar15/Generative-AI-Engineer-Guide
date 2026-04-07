# Retrieval Strategies

## Overview
Retrieval strategies determine how relevant documents are found and selected for the generation step in RAG systems. Advanced retrieval techniques can significantly improve answer quality.

---


## Basic Retrieval

### **Single-Vector Similarity Search**

The simplest approach: embed query, find nearest neighbors.

**Pros:**
- Simple and fast
- Works well for straightforward queries

**Cons:**
- May miss relevant docs
- Single perspective
- No query refinement

---

## Advanced Retrieval Strategies

### **1. Multi-Query Retrieval**

Generate multiple variations of the query to improve coverage.

**Pros:**
- Better coverage
- Handles query ambiguity
- More robust

**Cons:**
- More LLM calls (cost)
- Slower
- Deduplication needed

---

### **2. Decomposition (Sub-Query) Retrieval**

Break complex questions into simpler sub-questions.

**Example:**
- Complex: "Compare the architectures and use cases of BERT and GPT"
- Sub-queries:
  - "What is the architecture of BERT?"
  - "What is the architecture of GPT?"
  - "What are use cases for BERT?"
  - "What are use cases for GPT?"

**Pros:**
- Handles complex queries
- More comprehensive
- Better for multi-faceted questions

**Cons:**
- Expensive (multiple retrievals)
- May retrieve irrelevant sub-answers
- More tokens for generation

---

### **3. Hypothetical Document Embeddings (HyDE)**

Generate a hypothetical answer, then search for similar documents.

**Why it works:**
- Hypothetical answer is in "document space"
- Better semantic match than query
- Bridges query-document vocabulary gap

**Pros:**
- Better for complex domains
- Handles terminology differences
- Good when queries don't match doc language

**Cons:**
- Extra LLM call
- Hallucination risk
- Slower

---

### **4. Parent Document Retrieval**

Retrieve small chunks but return larger parent documents.

**Pros:**
- More context for generation
- Better for long-form content
- Preserves document structure

**Cons:**
- More tokens (longer context)
- May include irrelevant parts
- Implementation complexity

---

### **5. Contextual Compression Retrieval**

Retrieve documents then compress/filter to most relevant parts.

**Pros:**
- Reduces noise
- More efficient context usage
- Better generation quality

**Cons:**
- Extra LLM processing
- May lose context
- Slower and more expensive

---

### **6. Ensemble Retrieval**

Combine multiple retrieval methods.

**Pros:**
- Best of multiple methods
- More robust
- Handles different query types

**Cons:**
- More complex
- Slower (multiple searches)
- Need to tune combination weights

---

## Hybrid Search Strategies

### **Combining Dense + Sparse Retrieval:**

---

## Query Routing

Route different types of queries to different retrievers.
---

## Best Practices

1. **Start simple**: Basic retrieval first, add complexity as needed
2. **Measure impact**: A/B test retrieval strategies
3. **Consider cost**: Balance quality vs. LLM calls
4. **Cache results**: Especially for query variations
5. **Monitor performance**: Track retrieval quality metrics
6. **Combine strategies**: Ensemble often works best
7. **Domain-specific**: Customize for your use case

---

[<- Previous: Optimization Strategies](09-optimization-strategies.md) | [Next: Vector Databases →](11-reranker-models.md)

[<- Back to Index](README.md)