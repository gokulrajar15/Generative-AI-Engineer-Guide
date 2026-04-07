# Algorithms Behind Vector Search Engines

## Overview
Vector search algorithms enable efficient similarity search in high-dimensional spaces. Understanding these algorithms is essential for building scalable RAG systems.

---

## Why Specialized Algorithms?

Naive approaches like comparing every vector pair (brute force) don't scale:
- **O(n × d)** complexity for n documents with d dimensions
- Impractical for millions of vectors
- Need for approximate nearest neighbor (ANN) algorithms

---

## Key Vector Search Algorithms

- **HNSW (Hierarchical Navigable Small World)**: Graph-based, fast search with high recall
- **IVF (Inverted File Index)**: Clusters vectors and searches within relevant clusters
- **PQ (Product Quantization)**: Compresses vectors for memory efficiency
- **LSH (Locality-Sensitive Hashing)**: Hashes similar items to the same bucket
- **Flat (Brute Force)**: Exact search, only for small datasets


## Algorithm Comparison

| Algorithm | Speed | Accuracy | Memory | Best For |
|-----------|-------|----------|--------|----------|
| HNSW | ⚡⚡⚡ | ✓✓✓ | High | Real-time search |
| IVF-Flat | ⚡⚡ | ✓✓ | Medium | Large datasets |
| IVF-PQ | ⚡⚡⚡ | ✓ | Low | Memory-constrained |
| LSH | ⚡⚡ | ✓ | Medium | Simple implementation |
| Flat | ⚡ | ✓✓✓ | High | Small datasets |

---

## Choosing the Right Algorithm

**Consider:**
1. **Dataset size**: Millions vs. billions of vectors
2. **Latency requirements**: Real-time vs. batch
3. **Memory constraints**: Available RAM
4. **Accuracy needs**: Exact vs. approximate
5. **Update frequency**: Static vs. dynamic

**General recommendations:**
- **< 100K vectors**: Flat (brute force) is fine
- **100K - 10M vectors**: HNSW for best balance
- **> 10M vectors**: IVF or IVF-PQ for efficiency
- **Memory limited**: PQ-based methods
- **Highest accuracy**: HNSW with high parameters



[Learn more about algorithms](https://www.pinecone.io/learn/vector-database/)  <---- Great resource with detailed explanations and comparisons!

---

*Hope you get a good grasp of vector search and distance metrics! These concepts are fundamental for building effective RAG systems. In the next section, we'll explore different vector search algorithms.*

**Next**: [Model used for vector search →](03-embedding-models.md)

[← Back to Index](README.md)
