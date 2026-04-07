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

### 1. **HNSW (Hierarchical Navigable Small World)**

One of the most popular and efficient algorithms for vector search.

**How it works:**
- Creates a multi-layer graph structure
- Top layers have long-range connections (highways)
- Bottom layers have short-range connections (local streets)
- Search starts at the top and navigates down

**Advantages:**
- Excellent recall and speed balance
- Good for high-dimensional data
- Scales well to millions of vectors

**Disadvantages:**
- Higher memory usage
- More complex implementation
- Build time can be significant

**Use cases:**
- Real-time semantic search
- Recommendation systems
- Image similarity search

[Learn more about HNSW](https://www.pinecone.io/learn/vector-database/)

---

### 2. **IVF (Inverted File Index)**

A clustering-based approach that divides the vector space into regions.

**How it works:**
- Vectors are clustered using k-means or similar
- Each cluster has a centroid
- Search first finds nearest centroids
- Then searches within those clusters only

**Advantages:**
- Lower memory footprint
- Fast search with proper tuning
- Good for very large datasets

**Disadvantages:**
- Requires tuning (nprobe parameter)
- Build time for clustering
- May miss vectors near cluster boundaries

**Variants:**
- IVF-Flat: Stores full vectors
- IVF-PQ: Uses product quantization for compression

---

### 3. **Product Quantization (PQ)**

A compression technique often combined with other algorithms.

**How it works:**
- Splits vectors into sub-vectors
- Quantizes each sub-vector separately
- Stores compact codes instead of full vectors
- Enables searching compressed data

**Advantages:**
- Massive memory savings (10-100x compression)
- Faster search due to smaller data
- Can be combined with IVF or HNSW

**Disadvantages:**
- Lossy compression (accuracy trade-off)
- More complex implementation

---

### 4. **LSH (Locality-Sensitive Hashing)**

Uses hash functions that preserve similarity.

**How it works:**
- Hash similar vectors to same buckets
- Multiple hash functions for better recall
- Search only within relevant buckets

**Advantages:**
- Simple concept
- Good for certain distance metrics
- Scalable

**Disadvantages:**
- Lower accuracy than HNSW
- Requires careful tuning
- Multiple tables needed

---

### 5. **FAISS (Facebook AI Similarity Search)**

A library implementing multiple algorithms.

**Supported approaches:**
- Flat (brute force)
- IVF variants
- HNSW
- PQ and combinations

**Use case:** Research and experimentation with different algorithms

---

### 6. **ScaNN (Scalable Nearest Neighbors)**

Google's algorithm optimizing speed and accuracy.

**Key features:**
- Advanced quantization techniques
- Optimized for TPU/GPU
- State-of-the-art performance on benchmarks

---

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

---

## Hands-On with FAISS

```python
import faiss
import numpy as np

# Generate sample data
d = 128  # dimension
n = 10000  # number of vectors
np.random.seed(42)
vectors = np.random.random((n, d)).astype('float32')
query = np.random.random((1, d)).astype('float32')

# 1. Flat index (brute force)
index_flat = faiss.IndexFlatL2(d)
index_flat.add(vectors)
D, I = index_flat.search(query, k=5)
print("Flat search results:", I)

# 2. IVF index
nlist = 100  # number of clusters
quantizer = faiss.IndexFlatL2(d)
index_ivf = faiss.IndexIVFFlat(quantizer, d, nlist)
index_ivf.train(vectors)
index_ivf.add(vectors)
index_ivf.nprobe = 10  # search 10 clusters
D, I = index_ivf.search(query, k=5)
print("IVF search results:", I)

# 3. HNSW index
index_hnsw = faiss.IndexHNSWFlat(d, 32)  # 32 connections per layer
index_hnsw.add(vectors)
D, I = index_hnsw.search(query, k=5)
print("HNSW search results:", I)
```

---

## Performance Optimization

**Index building:**
- Use GPU for faster index construction
- Parallelize when possible
- Tune algorithm parameters

**Search optimization:**
- Batch queries together
- Use appropriate nprobe/ef_search values
- Consider quantization for speed

**Monitoring:**
- Track recall@k metrics
- Measure latency percentiles (p50, p95, p99)
- Monitor memory usage

---

## Next Steps
- Experiment with different algorithms
- Benchmark on your specific data
- Learn about vector databases that implement these algorithms
- Explore hybrid search combining multiple approaches
