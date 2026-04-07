# Reranker Models

## Overview
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

## Popular Reranker Models

### **1. Cohere Rerank**

Commercial API with excellent performance.

```python
import cohere

co = cohere.Client('your-api-key')

def rerank_with_cohere(query, documents, top_n=5):
    # Documents is a list of strings
    results = co.rerank(
        model='rerank-english-v3.0',
        query=query,
        documents=documents,
        top_n=top_n,
        return_documents=True
    )
    
    reranked = []
    for result in results.results:
        reranked.append({
            'index': result.index,
            'relevance_score': result.relevance_score,
            'document': result.document.text
        })
    
    return reranked

# Example
query = "What is machine learning?"
docs = [
    "Machine learning is a subset of AI...",
    "I love pizza and pasta...",
    "Deep learning uses neural networks..."
]

reranked = rerank_with_cohere(query, docs, top_n=2)
for doc in reranked:
    print(f"Score: {doc['relevance_score']:.4f} - {doc['document'][:50]}...")
```

**Pros:**
- State-of-the-art accuracy
- Easy to use
- Multilingual support
- No infrastructure needed

**Cons:**
- Costs money (per search)
- API dependency
- Privacy concerns (data sent to Cohere)

---

### **2. Cross-Encoders (Sentence Transformers)**

Open-source cross-encoder models.

```python
from sentence_transformers import CrossEncoder

# Load model
model = CrossEncoder('cross-encoder/ms-marco-MiniLM-L-6-v2')

def rerank_with_cross_encoder(query, documents, top_k=5):
    # Create query-document pairs
    pairs = [[query, doc] for doc in documents]
    
    # Score pairs
    scores = model.predict(pairs)
    
    # Sort by score
    results = [
        {'document': doc, 'score': score}
        for doc, score in zip(documents, scores)
    ]
    results.sort(key=lambda x: x['score'], reverse=True)
    
    return results[:top_k]

# Example
query = "How do transformers work?"
docs = [
    "Transformers use attention mechanisms...",
    "Electric transformers change voltage...",
    "The movie Transformers features robots..."
]

reranked = rerank_with_cross_encoder(query, docs)
for result in reranked:
    print(f"Score: {result['score']:.4f} - {result['document']}")
```

**Available models:**
- `cross-encoder/ms-marco-TinyBERT-L-2-v2` (Fast, small)
- `cross-encoder/ms-marco-MiniLM-L-6-v2` (Balanced)
- `cross-encoder/ms-marco-MiniLM-L-12-v2` (Better quality)
- `cross-encoder/ms-marco-electra-base` (High quality)

**Pros:**
- Open source and free
- Can run locally
- Good accuracy
- No external API

**Cons:**
- Requires GPU for speed
- Slower than retrieval
- Need to host/manage

---

### **3. BGE Reranker**

High-quality reranker from BAAI.

```python
from FlagEmbedding import FlagReranker

reranker = FlagReranker('BAAI/bge-reranker-large', use_fp16=True)

def rerank_with_bge(query, documents, top_k=5):
    # Create pairs
    pairs = [[query, doc] for doc in documents]
    
    # Compute scores
    scores = reranker.compute_score(pairs)
    
    # Sort and return
    results = [
        {'document': doc, 'score': score}
        for doc, score in zip(documents, scores)
    ]
    results.sort(key=lambda x: x['score'], reverse=True)
    
    return results[:top_k]
```

**Models:**
- `BAAI/bge-reranker-base`
- `BAAI/bge-reranker-large`
- `BAAI/bge-reranker-v2-m3` (Multilingual)

**Pros:**
- Excellent accuracy
- Multilingual support
- Active development
- Good documentation

---

### **4. Jina Reranker**

Optimized for production use.

```python
from transformers import AutoModelForSequenceClassification, AutoTokenizer
import torch

model_name = "jinaai/jina-reranker-v1-turbo-en"
tokenizer = AutoTokenizer.from_pretrained(model_name)
model = AutoModelForSequenceClassification.from_pretrained(model_name)

def rerank_with_jina(query, documents, top_k=5):
    model.eval()
    results = []
    
    for doc in documents:
        inputs = tokenizer(
            query, doc,
            padding=True,
            truncation=True,
            return_tensors='pt',
            max_length=512
        )
        
        with torch.no_grad():
            outputs = model(**inputs)
            score = torch.sigmoid(outputs.logits).item()
        
        results.append({'document': doc, 'score': score})
    
    results.sort(key=lambda x: x['score'], reverse=True)
    return results[:top_k]
```

---

## Complete RAG Pipeline with Reranking

```python
class RAGWithReranking:
    def __init__(self, vector_index, reranker):
        self.vector_index = vector_index
        self.reranker = reranker
    
    def retrieve_and_rerank(self, query, initial_k=20, final_k=5):
        # Stage 1: Fast vector search (high recall)
        query_embedding = self.embed(query)
        initial_results = self.vector_index.query(
            vector=query_embedding,
            top_k=initial_k
        )
        
        # Extract documents
        documents = [result['metadata']['text'] for result in initial_results]
        
        # Stage 2: Rerank (high precision)
        reranked = self.reranker.rerank(query, documents, top_k=final_k)
        
        return reranked
    
    def generate_answer(self, query):
        # Retrieve and rerank
        context_docs = self.retrieve_and_rerank(query, initial_k=20, final_k=5)
        
        # Prepare context
        context = "\n\n".join([doc['document'] for doc in context_docs])
        
        # Generate
        prompt = f"""Answer the question based on the context below.

Context:
{context}

Question: {query}

Answer:"""
        
        response = self.llm.generate(prompt)
        return response, context_docs
```

---

## Hybrid Retrieval + Reranking

```python
def hybrid_search_with_reranking(
    query,
    vector_index,
    keyword_index,
    reranker,
    initial_k=50,
    final_k=5
):
    # Stage 1: Hybrid retrieval (vector + keyword)
    vector_results = vector_index.query(query, top_k=initial_k)
    keyword_results = keyword_index.search(query, top_k=initial_k)
    
    # Combine and deduplicate
    all_docs = {}
    for result in vector_results + keyword_results:
        doc_id = result['id']
        if doc_id not in all_docs:
            all_docs[doc_id] = result['text']
    
    # Stage 2: Rerank
    documents = list(all_docs.values())
    reranked = reranker.rerank(query, documents, top_k=final_k)
    
    return reranked
```

---

## Optimizing Reranking

### **1. Batch Processing**

```python
def batch_rerank(query, documents, reranker, batch_size=32):
    """Process documents in batches for efficiency"""
    all_scores = []
    
    for i in range(0, len(documents), batch_size):
        batch = documents[i:i+batch_size]
        pairs = [[query, doc] for doc in batch]
        scores = reranker.predict(pairs)
        all_scores.extend(scores)
    
    # Sort by score
    results = sorted(
        zip(documents, all_scores),
        key=lambda x: x[1],
        reverse=True
    )
    
    return results
```

---

### **2. Caching**

```python
import hashlib
from functools import lru_cache

class CachedReranker:
    def __init__(self, reranker):
        self.reranker = reranker
        self.cache = {}
    
    def get_cache_key(self, query, document):
        combined = f"{query}|{document}"
        return hashlib.md5(combined.encode()).hexdigest()
    
    def rerank(self, query, documents, top_k=5):
        results = []
        
        for doc in documents:
            cache_key = self.get_cache_key(query, doc)
            
            if cache_key in self.cache:
                score = self.cache[cache_key]
            else:
                score = self.reranker.predict([[query, doc]])[0]
                self.cache[cache_key] = score
            
            results.append({'document': doc, 'score': score})
        
        results.sort(key=lambda x: x['score'], reverse=True)
        return results[:top_k]
```

---

### **3. GPU Acceleration**

```python
# Use GPU if available
device = 'cuda' if torch.cuda.is_available() else 'cpu'

model = CrossEncoder(
    'cross-encoder/ms-marco-MiniLM-L-6-v2',
    device=device
)

# Batch processing on GPU
scores = model.predict(pairs, batch_size=32, show_progress_bar=True)
```

---

## Choosing a Reranker

| Use Case | Recommended | Alternative |
|----------|-------------|-------------|
| Production (API) | Cohere Rerank | Voyage Rerank |
| Self-hosted | BGE Reranker | Cross-Encoder |
| Fast/Small | ms-marco-MiniLM-L-6 | Jina Turbo |
| High Quality | BGE-large | ms-marco-electra |
| Multilingual | Cohere/BGE-m3 | mDeBERTa |
| Cost-sensitive | Open-source | Cross-Encoder |

---

## Evaluation

```python
def evaluate_reranker(queries, ground_truth, retriever, reranker):
    metrics = {'ndcg': [], 'precision': [], 'map': []}
    
    for query, relevant_docs in zip(queries, ground_truth):
        # Retrieve candidates
        candidates = retriever.retrieve(query, k=50)
        docs = [c['text'] for c in candidates]
        
        # Rerank
        reranked = reranker.rerank(query, docs, top_k=10)
        
        # Compute metrics
        # ... NDCG, MAP, Precision calculations
    
    return metrics
```

---

## Best Practices

1. **Two-stage pipeline**: Always use retrieval + reranking
2. **Retrieve more, rerank less**: e.g., retrieve 50, rerank to 5
3. **Choose appropriate model**: Balance quality, speed, cost
4. **Batch processing**: Process multiple docs together
5. **Monitor performance**: Track reranking latency
6. **Cache when possible**: Especially for common queries
7. **Evaluate on your data**: Test different rerankers
8. **Consider cost**: API vs. self-hosted trade-offs

---

## Common Pitfalls

1. **Reranking too many docs**: Defeats the purpose
2. **Skipping retrieval**: Rerankers aren't retrievers
3. **Wrong model choice**: Not all rerankers are equal
4. **No evaluation**: Always measure impact
5. **Ignoring latency**: Reranking adds time
6. **One-size-fits-all**: Domain matters

---

## Integration with LangChain

```python
from langchain.retrievers import ContextualCompressionRetriever
from langchain.retrievers.document_compressors import CohereRerank

# Setup
base_retriever = vectorstore.as_retriever(search_kwargs={"k": 20})
compressor = CohereRerank(cohere_api_key="...", top_n=5)

# Create compression retriever
compression_retriever = ContextualCompressionRetriever(
    base_compressor=compressor,
    base_retriever=base_retriever
)

# Use
docs = compression_retriever.get_relevant_documents("What is RAG?")
```

---

## Next Steps
- Benchmark rerankers on your data
- Implement two-stage retrieval pipeline
- Measure quality improvement
- Optimize for latency and cost
- Explore domain-specific rerankers
