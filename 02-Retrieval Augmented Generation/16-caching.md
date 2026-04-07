# Caching in RAG Systems

## Overview
Caching is a critical optimization technique for RAG systems that reduces latency, costs, and load on underlying services. Proper caching strategies can improve performance by 10-100x for repeated queries.

---

## Why Caching Matters in RAG

**Benefits:**
- **Reduced latency**: Instant responses for cached queries
- **Lower costs**: Fewer LLM API calls and embeddings
- **Better UX**: Faster responses to users
- **Reduced load**: Less pressure on vector DBs and LLMs
- **Scalability**: Handle more users with same infrastructure

**What to cache:**
- Query embeddings
- Search results
- Generated answers
- Frequently accessed documents
- Intermediate computations

---

## Types of Caching

### **1. Query Result Caching**

Cache complete RAG responses.

```python
import hashlib
import json
from datetime import datetime, timedelta

class QueryCache:
    def __init__(self, ttl_seconds=3600):
        self.cache = {}
        self.ttl = ttl_seconds
    
    def get_cache_key(self, query, filters=None):
        """Generate unique key for query + filters"""
        cache_data = {
            'query': query.lower().strip(),
            'filters': filters or {}
        }
        key_string = json.dumps(cache_data, sort_keys=True)
        return hashlib.md5(key_string.encode()).hexdigest()
    
    def get(self, query, filters=None):
        """Get cached result if available and fresh"""
        key = self.get_cache_key(query, filters)
        
        if key in self.cache:
            result, timestamp = self.cache[key]
            
            # Check if still fresh
            if datetime.now() - timestamp < timedelta(seconds=self.ttl):
                return result
            else:
                # Expired, remove from cache
                del self.cache[key]
        
        return None
    
    def set(self, query, result, filters=None):
        """Cache query result"""
        key = self.get_cache_key(query, filters)
        self.cache[key] = (result, datetime.now())
    
    def invalidate(self, query=None, filters=None):
        """Invalidate specific query or all cache"""
        if query:
            key = self.get_cache_key(query, filters)
            if key in self.cache:
                del self.cache[key]
        else:
            self.cache.clear()

# Usage
cache = QueryCache(ttl_seconds=3600)  # 1 hour TTL

def rag_with_caching(query, rag_system, cache):
    # Check cache first
    cached_result = cache.get(query)
    if cached_result:
        print("Cache hit!")
        return cached_result
    
    # Cache miss - compute result
    print("Cache miss - computing...")
    result = rag_system.query(query)
    
    # Store in cache
    cache.set(query, result)
    
    return result
```

---

### **2. Embedding Cache**

Cache query and document embeddings.

```python
class EmbeddingCache:
    def __init__(self):
        self.cache = {}
    
    def get_embedding(self, text, embed_function):
        """Get embedding from cache or compute"""
        # Normalize text for cache key
        cache_key = text.lower().strip()
        
        if cache_key in self.cache:
            return self.cache[cache_key]
        
        # Compute embedding
        embedding = embed_function(text)
        
        # Cache it
        self.cache[cache_key] = embedding
        
        return embedding
    
    def warm_up(self, texts, embed_function):
        """Pre-populate cache with common queries"""
        for text in texts:
            self.get_embedding(text, embed_function)

# Usage
embed_cache = EmbeddingCache()

def cached_embed(text, model):
    return embed_cache.get_embedding(text, lambda t: model.encode(t))

# Warm up with common queries
common_queries = ["What is AI?", "How does ML work?", "Explain RAG"]
embed_cache.warm_up(common_queries, model.encode)
```

---

### **3. Semantic Cache**

Match semantically similar queries instead of exact matches.

```python
from sentence_transformers import SentenceTransformer, util

class SemanticCache:
    def __init__(self, similarity_threshold=0.95, ttl_seconds=3600):
        self.cache = []  # List of (query, embedding, result, timestamp)
        self.threshold = similarity_threshold
        self.ttl = ttl_seconds
        self.embed_model = SentenceTransformer('all-MiniLM-L6-v2')
    
    def get(self, query):
        """Find semantically similar cached query"""
        query_embedding = self.embed_model.encode(query)
        current_time = datetime.now()
        
        best_match = None
        best_similarity = 0
        
        for cached_query, cached_emb, result, timestamp in self.cache:
            # Check if expired
            if current_time - timestamp > timedelta(seconds=self.ttl):
                continue
            
            # Compute similarity
            similarity = util.cos_sim(query_embedding, cached_emb).item()
            
            if similarity > best_similarity and similarity >= self.threshold:
                best_similarity = similarity
                best_match = result
        
        return best_match, best_similarity if best_match else (None, 0)
    
    def set(self, query, result):
        """Add to semantic cache"""
        query_embedding = self.embed_model.encode(query)
        self.cache.append((query, query_embedding, result, datetime.now()))
        
        # Cleanup old entries periodically
        if len(self.cache) > 1000:
            self.cleanup()
    
    def cleanup(self):
        """Remove expired entries"""
        current_time = datetime.now()
        self.cache = [
            entry for entry in self.cache
            if current_time - entry[3] <= timedelta(seconds=self.ttl)
        ]

# Usage
semantic_cache = SemanticCache(similarity_threshold=0.95)

def rag_with_semantic_cache(query, rag_system):
    # Check semantic similarity
    cached_result, similarity = semantic_cache.get(query)
    
    if cached_result:
        print(f"Semantic cache hit! (similarity: {similarity:.2f})")
        return cached_result
    
    # Compute result
    result = rag_system.query(query)
    
    # Cache it
    semantic_cache.set(query, result)
    
    return result
```

---

### **4. Redis-Based Caching**

Distributed caching for production.

```python
import redis
import pickle

class RedisRAGCache:
    def __init__(self, host='localhost', port=6379, ttl=3600):
        self.redis_client = redis.Redis(
            host=host,
            port=port,
            decode_responses=False
        )
        self.ttl = ttl
    
    def get_cache_key(self, query, prefix="rag"):
        query_hash = hashlib.md5(query.encode()).hexdigest()
        return f"{prefix}:{query_hash}"
    
    def get(self, query):
        """Get from Redis"""
        key = self.get_cache_key(query)
        cached = self.redis_client.get(key)
        
        if cached:
            return pickle.loads(cached)
        
        return None
    
    def set(self, query, result):
        """Store in Redis with TTL"""
        key = self.get_cache_key(query)
        serialized = pickle.dumps(result)
        self.redis_client.setex(key, self.ttl, serialized)
    
    def invalidate(self, query=None):
        """Invalidate cache"""
        if query:
            key = self.get_cache_key(query)
            self.redis_client.delete(key)
        else:
            # Clear all RAG cache
            for key in self.redis_client.scan_iter("rag:*"):
                self.redis_client.delete(key)
    
    def get_stats(self):
        """Get cache statistics"""
        info = self.redis_client.info('stats')
        return {
            'hits': info.get('keyspace_hits', 0),
            'misses': info.get('keyspace_misses', 0),
            'hit_rate': info.get('keyspace_hits', 0) / 
                       (info.get('keyspace_hits', 0) + info.get('keyspace_misses', 0) + 1)
        }

# Usage
redis_cache = RedisRAGCache(ttl=3600)

async def rag_with_redis(query, rag_system):
    # Check Redis cache
    cached = redis_cache.get(query)
    if cached:
        return cached
    
    # Compute
    result = await rag_system.query(query)
    
    # Cache in Redis
    redis_cache.set(query, result)
    
    return result
```

---

## Multi-Level Caching

Combine different cache layers for optimal performance.

```python
class MultiLevelCache:
    def __init__(self):
        # L1: In-memory (fastest, smallest)
        self.l1_cache = QueryCache(ttl_seconds=300)  # 5 min
        
        # L2: Redis (fast, larger)
        self.l2_cache = RedisRAGCache(ttl=3600)  # 1 hour
        
        # L3: Semantic cache (slower, most flexible)
        self.l3_cache = SemanticCache(similarity_threshold=0.95)
        
        self.stats = {'l1_hits': 0, 'l2_hits': 0, 'l3_hits': 0, 'misses': 0}
    
    def get(self, query):
        """Try each cache level in order"""
        # L1: In-memory
        result = self.l1_cache.get(query)
        if result:
            self.stats['l1_hits'] += 1
            return result
        
        # L2: Redis
        result = self.l2_cache.get(query)
        if result:
            self.stats['l2_hits'] += 1
            # Promote to L1
            self.l1_cache.set(query, result)
            return result
        
        # L3: Semantic
        result, similarity = self.l3_cache.get(query)
        if result:
            self.stats['l3_hits'] += 1
            # Promote to upper levels
            self.l1_cache.set(query, result)
            self.l2_cache.set(query, result)
            return result
        
        self.stats['misses'] += 1
        return None
    
    def set(self, query, result):
        """Set in all cache levels"""
        self.l1_cache.set(query, result)
        self.l2_cache.set(query, result)
        self.l3_cache.set(query, result)
    
    def get_stats(self):
        """Cache performance statistics"""
        total = sum(self.stats.values())
        if total == 0:
            return self.stats
        
        return {
            **self.stats,
            'total_requests': total,
            'overall_hit_rate': (total - self.stats['misses']) / total
        }
```

---

## GPTCache Integration

Using GPTCache for LLM response caching.

```python
from gptcache import cache
from gptcache.adapter import openai

# Initialize cache
cache.init()
cache.set_openai_key()

# Cached LLM calls
def cached_llm_call(prompt):
    """Automatically cached by GPTCache"""
    response = openai.ChatCompletion.create(
        model='gpt-4',
        messages=[{'role': 'user', 'content': prompt}]
    )
    return response.choices[0].message.content
```

---

## LangChain Caching

```python
from langchain.cache import InMemoryCache, RedisCache
from langchain.globals import set_llm_cache
import langchain

# In-memory cache
set_llm_cache(InMemoryCache())

# Redis cache
redis_cache = RedisCache(redis_url="redis://localhost:6379")
set_llm_cache(redis_cache)

# Now all LLM calls are automatically cached
from langchain.llms import OpenAI

llm = OpenAI()
response = llm("What is RAG?")  # Cached automatically
```

---

## Cache Invalidation Strategies

### **1. Time-Based Invalidation (TTL)**

```python
class TTLCache:
    def __init__(self, default_ttl=3600):
        self.cache = {}
        self.default_ttl = default_ttl
    
    def set(self, key, value, ttl=None):
        expiry = datetime.now() + timedelta(seconds=ttl or self.default_ttl)
        self.cache[key] = (value, expiry)
    
    def get(self, key):
        if key in self.cache:
            value, expiry = self.cache[key]
            if datetime.now() < expiry:
                return value
            else:
                del self.cache[key]
        return None
```

---

### **2. Event-Based Invalidation**

```python
class EventBasedCache:
    def __init__(self):
        self.cache = {}
        self.document_to_queries = {}  # Track which queries use which docs
    
    def set(self, query, result, related_doc_ids):
        """Cache result and track document dependencies"""
        self.cache[query] = result
        
        # Track relationship
        for doc_id in related_doc_ids:
            if doc_id not in self.document_to_queries:
                self.document_to_queries[doc_id] = set()
            self.document_to_queries[doc_id].add(query)
    
    def invalidate_by_document(self, doc_id):
        """Invalidate all queries using this document"""
        if doc_id in self.document_to_queries:
            affected_queries = self.document_to_queries[doc_id]
            
            for query in affected_queries:
                if query in self.cache:
                    del self.cache[query]
            
            del self.document_to_queries[doc_id]
    
    def on_document_update(self, doc_id):
        """Call this when a document is updated"""
        self.invalidate_by_document(doc_id)
```

---

### **3. LRU (Least Recently Used)**

```python
from collections import OrderedDict

class LRUCache:
    def __init__(self, capacity=1000):
        self.cache = OrderedDict()
        self.capacity = capacity
    
    def get(self, key):
        if key in self.cache:
            # Move to end (most recently used)
            self.cache.move_to_end(key)
            return self.cache[key]
        return None
    
    def set(self, key, value):
        if key in self.cache:
            # Update and move to end
            self.cache.move_to_end(key)
        
        self.cache[key] = value
        
        # Remove least recently used if over capacity
        if len(self.cache) > self.capacity:
            self.cache.popitem(last=False)
```

---

## Cache Warming

Pre-populate cache with common queries.

```python
class CacheWarmer:
    def __init__(self, cache, rag_system):
        self.cache = cache
        self.rag_system = rag_system
    
    def warm_from_list(self, queries):
        """Pre-compute and cache common queries"""
        print(f"Warming cache with {len(queries)} queries...")
        
        for i, query in enumerate(queries):
            if i % 10 == 0:
                print(f"Progress: {i}/{len(queries)}")
            
            # Check if already cached
            if not self.cache.get(query):
                result = self.rag_system.query(query)
                self.cache.set(query, result)
        
        print("Cache warming complete!")
    
    def warm_from_logs(self, log_file, top_n=100):
        """Warm cache from query logs"""
        # Parse logs to get most common queries
        query_counts = self.parse_query_logs(log_file)
        
        # Get top N queries
        top_queries = sorted(
            query_counts.items(),
            key=lambda x: x[1],
            reverse=True
        )[:top_n]
        
        # Warm cache
        queries = [q for q, _ in top_queries]
        self.warm_from_list(queries)

# Usage
warmer = CacheWarmer(redis_cache, rag_system)
common_queries = [
    "What is machine learning?",
    "How does RAG work?",
    "Explain transformer architecture"
]
warmer.warm_from_list(common_queries)
```

---

## Monitoring Cache Performance

```python
class CacheMonitor:
    def __init__(self, cache):
        self.cache = cache
        self.metrics = {
            'hits': 0,
            'misses': 0,
            'total_latency_saved': 0,
            'avg_compute_time': 0
        }
    
    def record_hit(self, saved_time):
        self.metrics['hits'] += 1
        self.metrics['total_latency_saved'] += saved_time
    
    def record_miss(self, compute_time):
        self.metrics['misses'] += 1
        self.metrics['avg_compute_time'] = (
            (self.metrics['avg_compute_time'] * (self.metrics['misses'] - 1) + compute_time)
            / self.metrics['misses']
        )
    
    def get_hit_rate(self):
        total = self.metrics['hits'] + self.metrics['misses']
        if total == 0:
            return 0
        return self.metrics['hits'] / total
    
    def get_report(self):
        return {
            'hit_rate': self.get_hit_rate(),
            'total_latency_saved': self.metrics['total_latency_saved'],
            'avg_compute_time': self.metrics['avg_compute_time'],
            **self.metrics
        }
```

---

## Best Practices

1. **Layer your caches**: In-memory → Redis → Database
2. **Set appropriate TTLs**: Balance freshness vs. hit rate
3. **Use semantic caching**: For similar but not identical queries
4. **Monitor hit rates**: Track and optimize cache performance
5. **Invalidate intelligently**: Clear cache when data changes
6. **Warm strategically**: Pre-populate with common queries
7. **Consider costs**: Balance cache size vs. compute costs
8. **Handle cache aside**: Implement fallback when cache fails

---

## Common Pitfalls

1. **Over-caching**: Serving stale data
2. **Under-caching**: Missing optimization opportunities
3. **No invalidation**: Outdated cached responses
4. **Cache stampede**: All requests hit at once when cache expires
5. **Memory bloat**: Unlimited cache growth
6. **Wrong granularity**: Caching at wrong level

---

## Cache Implementations Comparison

| Type | Speed | Scalability | Complexity | Cost |
|------|-------|-------------|------------|------|
| In-memory | Fastest | Low | Simple | Free |
| Redis | Fast | High | Medium | Low |
| Semantic | Medium | Medium | High | Medium |
| Multi-level | Fast | High | High | Medium |

---

## Next Steps
- Implement basic caching for your RAG system
- Monitor cache hit rates
- Experiment with semantic caching
- Set up Redis for production
- Implement cache warming for common queries
- Build cache invalidation strategy
