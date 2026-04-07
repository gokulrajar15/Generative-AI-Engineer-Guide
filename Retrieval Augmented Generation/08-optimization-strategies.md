# Optimization Strategies for Vector Database Indexing

## Overview
Optimizing vector database indexing is crucial for balancing performance, accuracy, cost, and scalability in production RAG systems. This chapter covers techniques to maximize efficiency.

---

## Key Performance Metrics

### **1. Recall (Accuracy)**
- Percentage of true nearest neighbors found
- Recall@k: Top-k retrieval accuracy
- Target: Usually 95%+ for production

### **2. Latency**
- Query response time
- p50, p95, p99 percentiles
- Target: < 100ms for real-time

### **3. Throughput**
- Queries per second (QPS)
- Concurrent request handling
- Scale with load

### **4. Memory Usage**
- RAM for index structures
- Affects cost and scalability
- Trade-off with speed

### **5. Build Time**
- Index construction duration
- Important for dynamic updates
- Batch vs. incremental

---

## Quantization

**Definition:** Compressing vector representations to use less memory and compute.

### **Types of Quantization:**

#### **1. Scalar Quantization (SQ)**

Convert float32 to int8 (4x compression).

```python
import numpy as np

def scalar_quantize(vectors):
    # Find min/max
    vmin = vectors.min()
    vmax = vectors.max()
    
    # Scale to [0, 255]
    quantized = ((vectors - vmin) / (vmax - vmin) * 255).astype(np.uint8)
    
    return quantized, vmin, vmax

def scalar_dequantize(quantized, vmin, vmax):
    return quantized.astype(np.float32) / 255 * (vmax - vmin) + vmin
```

**FAISS Example:**
```python
import faiss

# Create scalar quantizer index
quantizer = faiss.IndexFlatL2(dimension)
index = faiss.IndexIVFScalarQuantizer(
    quantizer,
    dimension,
    nlist,  # number of clusters
    faiss.ScalarQuantizer.QT_8bit  # 8-bit quantization
)
```

**Pros:**
- 4x memory reduction
- 2-3x speedup
- Minimal accuracy loss (1-2%)

**Cons:**
- Lossy compression
- Some precision loss
- Not always enough compression

---

#### **2. Product Quantization (PQ)**

Divide vectors into subvectors and quantize each separately.

```python
# FAISS Product Quantization
import faiss

dimension = 768
m = 8  # Number of subquantizers
nbits = 8  # Bits per subquantizer

# Create PQ index
index = faiss.IndexPQ(dimension, m, nbits)
index.train(training_vectors)
index.add(vectors)

# Search
D, I = index.search(query_vectors, k=10)
```

**Parameters:**
- `m`: Number of subspaces (divisor of dimension)
- `nbits`: Bits per code (typically 8)
- Compression: ~(dimension / m) × 8 / nbits

**Example:**
- 768 dims, m=8, nbits=8
- Compressed to 8 bytes (vs 3072 bytes)
- ~384x compression!

**Pros:**
- 10-100x memory reduction
- Still fast search
- Configurable compression

**Cons:**
- More accuracy loss (5-10%)
- Requires training
- Limited precision

---

#### **3. Binary Quantization**

Use 1 bit per dimension (sign only).

```python
def binary_quantize(vectors):
    # Keep only sign: positive = 1, negative = 0
    return (vectors > 0).astype(np.uint8)

# Hamming distance for similarity
def hamming_similarity(a, b):
    return np.sum(a == b) / len(a)
```

**Pros:**
- 32x compression (float32 → binary)
- Very fast (bit operations)
- Simple implementation

**Cons:**
- Significant accuracy loss
- Only suitable for certain embeddings
- Limited use cases

---

### **Quantization Comparison:**

| Method | Compression | Accuracy Loss | Speed | Use Case |
|--------|-------------|---------------|-------|----------|
| No quantization | 1x | 0% | Baseline | Highest accuracy |
| Scalar Quantization | 4x | 1-2% | 2-3x | Balanced |
| Product Quantization | 10-100x | 5-10% | Similar | Large scale |
| Binary | 32x | 15-20% | Very fast | Speed critical |

---

## Multitenancy

**Definition:** Serving multiple tenants (users, organizations) from the same vector database while maintaining isolation.

### **Strategies:**

#### **1. Namespace/Partition-Based**

```python
# Pinecone namespaces
index.upsert(
    vectors=[...],
    namespace="tenant_123"
)

results = index.query(
    vector=query,
    namespace="tenant_123",
    top_k=5
)
```

**Pros:**
- Simple isolation
- Built-in support (Pinecone, Qdrant)
- Good performance

**Cons:**
- Limited to supported databases
- May have limits on namespace count

---

#### **2. Metadata Filtering**

```python
# Store tenant ID in metadata
index.upsert(vectors=[{
    "id": "doc1",
    "values": embedding,
    "metadata": {"tenant_id": "123", "content": "..."}
}])

# Filter by tenant
results = index.query(
    vector=query,
    filter={"tenant_id": {"$eq": "123"}},
    top_k=5
)
```

**Pros:**
- Works with most databases
- Flexible filtering
- Easy to implement

**Cons:**
- Performance impact on large deployments
- Index includes all tenants
- Security concerns

---

#### **3. Separate Collections/Indexes**

```python
# Create index per tenant
def create_tenant_index(tenant_id):
    pc.create_index(
        name=f"tenant_{tenant_id}",
        dimension=1536,
        metric="cosine"
    )

# Query specific tenant
tenant_index = pc.Index(f"tenant_{tenant_id}")
results = tenant_index.query(...)
```

**Pros:**
- Complete isolation
- Optimal performance
- Easier billing/monitoring

**Cons:**
- Management overhead
- More resources
- Database limits on index count

---

#### **4. Hybrid Approach**

```python
# Small tenants: shared index with metadata filtering
# Large tenants: dedicated indexes

def get_index_for_tenant(tenant_id, vector_count):
    if vector_count > THRESHOLD:
        return pc.Index(f"tenant_{tenant_id}")
    else:
        return pc.Index("shared"), {"tenant_id": tenant_id}
```

---

### **Multitenancy Best Practices:**

1. **Tenant sizing**: Groups similar-sized tenants
2. **Isolation levels**: Balance security vs. efficiency
3. **Monitoring**: Per-tenant metrics
4. **Quotas**: Prevent abuse
5. **Migration**: Plan for tenant growth

---

## Sharding

**Definition:** Distributing data across multiple nodes/partitions for horizontal scaling.

### **Sharding Strategies:**

#### **1. Hash-Based Sharding**

```python
def get_shard(document_id, num_shards):
    return hash(document_id) % num_shards

# Insert
shard_id = get_shard(doc_id, 4)
shards[shard_id].insert(vector, metadata)

# Query all shards and merge results
results = []
for shard in shards:
    shard_results = shard.query(query_vector, k=10)
    results.extend(shard_results)

# Take top k from merged results
final_results = sorted(results, key=lambda x: x.score)[:k]
```

**Pros:**
- Even distribution
- Simple implementation
- Good for uniform access

**Cons:**
- Must query all shards
- Latency = slowest shard
- No data locality

---

#### **2. Range-Based Sharding**

```python
# Shard by date, category, etc.
def get_shard_by_range(created_date):
    if created_date.year == 2024:
        return shard_2024
    elif created_date.year == 2023:
        return shard_2023
    # ...

# Query relevant shards only
relevant_shards = get_shards_for_date_range(start_date, end_date)
```

**Pros:**
- Query only relevant shards
- Better for time-series data
- Data locality

**Cons:**
- Potential hotspots
- Uneven distribution
- Complex logic

---

#### **3. Geo-Based Sharding**

```python
def get_geo_shard(user_location):
    if user_location in ["US", "CA"]:
        return us_shard
    elif user_location in ["UK", "EU"]:
        return eu_shard
    # ...
```

**Pros:**
- Lower latency (closer to users)
- Compliance (data residency)
- Regional isolation

**Cons:**
- Geographic constraints
- Complexity
- Uneven load

---

### **Sharding Best Practices:**

1. **Replication**: Replicate shards for availability
2. **Rebalancing**: Monitor and redistribute
3. **Query routing**: Smart shard selection
4. **Monitoring**: Per-shard metrics
5. **Backup**: Consistent snapshots

---

## Index Configuration Tuning

### **HNSW Parameters:**

```python
# Weaviate example
{
    "class": "Document",
    "vectorIndexType": "hnsw",
    "vectorIndexConfig": {
        "ef": -1,  # Dynamic ef (use efConstruction)
        "efConstruction": 128,  # Build quality (higher = better, slower)
        "maxConnections": 64,  # Links per node (higher = better recall, more memory)
        "skip": false,
        "cleanupIntervalSeconds": 300,
        "vectorCacheMaxObjects": 1000000  # Cache size
    }
}
```

**Tuning guidelines:**
- **efConstruction**: 64-512 (higher for better quality)
- **maxConnections**: 16-64 (higher for better recall)
- **ef** (search): 50-500 (higher for better recall, slower)

**Trade-offs:**
- High efConstruction: Slower build, better recall
- High maxConnections: More memory, better recall
- High ef: Slower queries, better recall

---

### **IVF Parameters:**

```python
# FAISS IVF
nlist = 100  # Number of clusters (sqrt(N) to 4*sqrt(N))
nprobe = 10  # Clusters to search (1-nlist, higher = better recall)

quantizer = faiss.IndexFlatL2(dimension)
index = faiss.IndexIVFFlat(quantizer, dimension, nlist)
index.nprobe = nprobe
```

**Tuning:**
- **nlist**: sqrt(N) for N vectors
- **nprobe**: 1-20% of nlist
- Higher nprobe: Better recall, slower

---

## Caching Strategies

### **1. Query Result Caching**

```python
from functools import lru_cache
import hashlib

class VectorSearchCache:
    def __init__(self, ttl=3600):
        self.cache = {}
        self.ttl = ttl
    
    def get_cache_key(self, query_vector, filters):
        # Hash query + filters
        key = hashlib.md5(
            (str(query_vector) + str(filters)).encode()
        ).hexdigest()
        return key
    
    def get(self, query_vector, filters):
        key = self.get_cache_key(query_vector, filters)
        if key in self.cache:
            result, timestamp = self.cache[key]
            if time.time() - timestamp < self.ttl:
                return result
        return None
    
    def set(self, query_vector, filters, result):
        key = self.get_cache_key(query_vector, filters)
        self.cache[key] = (result, time.time())
```

---

### **2. Embedding Caching**

```python
# Cache embeddings for frequently accessed documents
class EmbeddingCache:
    def __init__(self):
        self.cache = {}
    
    def get_embedding(self, text, embed_fn):
        if text in self.cache:
            return self.cache[text]
        
        embedding = embed_fn(text)
        self.cache[text] = embedding
        return embedding
```

---

## Performance Monitoring

```python
import time

class VectorDBMonitor:
    def __init__(self):
        self.metrics = {
            'query_latency': [],
            'vector_count': 0,
            'cache_hits': 0,
            'cache_misses': 0
        }
    
    def record_query(self, latency):
        self.metrics['query_latency'].append(latency)
    
    def get_stats(self):
        latencies = self.metrics['query_latency']
        return {
            'p50': np.percentile(latencies, 50),
            'p95': np.percentile(latencies, 95),
            'p99': np.percentile(latencies, 99),
            'cache_hit_rate': self.metrics['cache_hits'] / 
                            (self.metrics['cache_hits'] + self.metrics['cache_misses'])
        }
```

---

## Cost Optimization

### **Strategies:**

1. **Right-sizing:**
   - Choose appropriate dimensions
   - Use quantization
   - Tune index parameters

2. **Tiered storage:**
   - Hot data: Fast index
   - Cold data: Compressed/slower index
   - Archive: Object storage

3. **Batching:**
   - Batch inserts
   - Batch queries
   - Reduce API calls

4. **Autoscaling:**
   - Scale based on load
   - Scheduled scaling
   - Serverless options

---

## Best Practices Summary

1. **Start simple**: Don't over-optimize initially
2. **Measure first**: Profile before optimizing
3. **Test thoroughly**: Benchmark on real data
4. **Monitor continuously**: Track key metrics
5. **Document decisions**: Record tuning choices
6. **Plan for growth**: Design for 10x scale
7. **Security**: Tenant isolation, access control
8. **Backup**: Regular snapshots, disaster recovery

---

## Next Steps
- Benchmark different configurations on your data
- Implement monitoring and alerting
- Experiment with quantization
- Design for your specific scale and latency requirements
