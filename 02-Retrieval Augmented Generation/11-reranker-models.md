# Reranker Models

Rerankers are models that refine initial retrieval results by re-scoring documents based on their relevance to the query. They provide a second stage of ranking that can significantly improve RAG quality.

---

## Why Reranking?

### **The Two-Stage Retrieval Pipeline:**

1. **First stage (Retrieval)**: Fast, broad search
   - Embedding similarity
   - Fetch top 50-100 candidates
   - Focus on recall

2. **Second stage (Reranking)**: Slower, precise ranking
   - Cross-encoder models
   - Re-score top candidates
   - Focus on precision

### **Benefits:**
- **Better accuracy**: 10-30% improvement in quality
- **Efficiency**: Only rerank top-k, not entire corpus
- **Cost-effective**: Balance speed and accuracy
- **Handles negation**: Better understanding of "not", "except"

---

## Retrieval vs. Reranking

| Aspect | Bi-Encoder (Retrieval) | Cross-Encoder (Reranking) |
|--------|----------------------|--------------------------|
| Input | Query & document separate | Query + document together |
| Speed | Very fast | Slower |
| Scale | Millions of docs | Hundreds of docs |
| Accuracy | Good | Excellent |
| Use case | First-stage retrieval | Second-stage reranking |

---

## How Rerankers Work

### **Bi-Encoder (Retrieval):**
```
Query → Encoder → Embedding_Q
Document → Encoder → Embedding_D
Similarity = cosine(Embedding_Q, Embedding_D)
```

### **Cross-Encoder (Reranking):**
```
[Query, Document] → Encoder → Relevance Score
```

Cross-encoders see both query and document together, enabling better understanding of their relationship.

---

## This is a hands-on tutorial that will be added soon! Stay tuned for a practical guide on document extraction techniques, covering tools and libraries for handling various formats, strategies for preserving structure, and tips for optimizing extraction quality for RAG systems.

---

[← Previous: Retrieval Strategies](10-retrieval-strategies.md) | [Generation Strategies →](12-generation-strategies.md)

[← Back to Index](README.md)