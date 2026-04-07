# Retrieval Strategies

## Overview
Retrieval strategies determine how relevant documents are found and selected for the generation step in RAG systems. Advanced retrieval techniques can significantly improve answer quality.

---

## Basic Retrieval

### **Single-Vector Similarity Search**

The simplest approach: embed query, find nearest neighbors.

```python
def basic_retrieval(query, index, k=5):
    # Embed query
    query_embedding = embed_model.encode(query)
    
    # Search
    results = index.query(vector=query_embedding, top_k=k)
    
    return results
```

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

```python
from openai import OpenAI

client = OpenAI()

def generate_query_variations(original_query, n=3):
    """Generate alternative phrasings of the query"""
    prompt = f"""Generate {n} alternative phrasings of this query:
    
Original: {original_query}

Alternative phrasings (one per line):"""
    
    response = client.chat.completions.create(
        model="gpt-4",
        messages=[{"role": "user", "content": prompt}]
    )
    
    variations = response.choices[0].message.content.strip().split('\n')
    return [original_query] + variations

def multi_query_retrieval(query, index, k=5):
    # Generate variations
    queries = generate_query_variations(query)
    
    # Search with each variation
    all_results = []
    for q in queries:
        q_embedding = embed_model.encode(q)
        results = index.query(vector=q_embedding, top_k=k)
        all_results.extend(results)
    
    # Deduplicate and rank
    unique_docs = deduplicate_and_rank(all_results)
    
    return unique_docs[:k]

def deduplicate_and_rank(results):
    # Combine scores for duplicate documents
    doc_scores = {}
    for result in results:
        doc_id = result['id']
        if doc_id in doc_scores:
            doc_scores[doc_id] = max(doc_scores[doc_id], result['score'])
        else:
            doc_scores[doc_id] = result['score']
    
    # Sort by score
    ranked = sorted(doc_scores.items(), key=lambda x: x[1], reverse=True)
    return ranked
```

**Pros:**
- Better coverage
- Handles query ambiguity
- More robust

**Cons:**
- More LLM calls (cost)
- Slower
- Deduplication needed

**LangChain implementation:**
```python
from langchain.retrievers.multi_query import MultiQueryRetriever

retriever = MultiQueryRetriever.from_llm(
    retriever=base_retriever,
    llm=llm
)

docs = retriever.get_relevant_documents("What is machine learning?")
```

---

### **2. Decomposition (Sub-Query) Retrieval**

Break complex questions into simpler sub-questions.

```python
def decompose_query(complex_query):
    """Break complex query into sub-questions"""
    prompt = f"""Break this complex question into simpler sub-questions:

Question: {complex_query}

Sub-questions:"""
    
    response = client.chat.completions.create(
        model="gpt-4",
        messages=[{"role": "user", "content": prompt}]
    )
    
    sub_queries = response.choices[0].message.content.strip().split('\n')
    return [q.strip('- ') for q in sub_queries if q.strip()]

def sub_query_retrieval(query, index, k=3):
    # Decompose
    sub_queries = decompose_query(query)
    
    # Retrieve for each sub-query
    all_docs = []
    for sq in sub_queries:
        sq_embedding = embed_model.encode(sq)
        results = index.query(vector=sq_embedding, top_k=k)
        all_docs.extend(results)
    
    # Deduplicate
    unique_docs = deduplicate_and_rank(all_docs)
    
    return unique_docs[:k * 2]  # Return more docs for complex queries
```

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

```python
def hyde_retrieval(query, index, k=5):
    # Generate hypothetical answer
    prompt = f"""Write a detailed answer to this question:

{query}

Answer:"""
    
    response = client.chat.completions.create(
        model="gpt-4",
        messages=[{"role": "user", "content": prompt}],
        max_tokens=200
    )
    
    hypothetical_doc = response.choices[0].message.content
    
    # Embed and search with hypothetical document
    hyp_embedding = embed_model.encode(hypothetical_doc)
    results = index.query(vector=hyp_embedding, top_k=k)
    
    return results
```

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

```python
class ParentDocumentRetriever:
    def __init__(self, index):
        self.index = index
        self.parent_map = {}  # Maps chunk_id -> parent_doc_id
    
    def index_documents(self, documents):
        """Index small chunks but track parent documents"""
        for doc in documents:
            # Split into chunks
            chunks = self.chunk_document(doc)
            
            # Index each chunk
            for i, chunk in enumerate(chunks):
                chunk_id = f"{doc['id']}_chunk_{i}"
                chunk_embedding = embed_model.encode(chunk)
                
                self.index.upsert([{
                    'id': chunk_id,
                    'values': chunk_embedding,
                    'metadata': {'text': chunk, 'parent_id': doc['id']}
                }])
                
                # Track parent
                self.parent_map[chunk_id] = doc['id']
    
    def retrieve(self, query, k=5):
        # Search for chunks
        query_embedding = embed_model.encode(query)
        chunk_results = self.index.query(vector=query_embedding, top_k=k*2)
        
        # Get parent documents
        parent_ids = set()
        for result in chunk_results:
            parent_ids.add(self.parent_map[result['id']])
        
        # Return full parent documents
        parent_docs = self.get_parent_documents(list(parent_ids)[:k])
        return parent_docs
```

**Pros:**
- More context for generation
- Better for long-form content
- Preserves document structure

**Cons:**
- More tokens (longer context)
- May include irrelevant parts
- Implementation complexity

**LangChain:**
```python
from langchain.retrievers import ParentDocumentRetriever
from langchain.storage import InMemoryStore

retriever = ParentDocumentRetriever(
    vectorstore=vectorstore,
    docstore=InMemoryStore(),
    child_splitter=child_splitter,
    parent_splitter=parent_splitter
)
```

---

### **5. Contextual Compression Retrieval**

Retrieve documents then compress/filter to most relevant parts.

```python
def contextual_compression_retrieval(query, index, k=5):
    # Initial retrieval (get more docs)
    query_embedding = embed_model.encode(query)
    initial_results = index.query(vector=query_embedding, top_k=k*3)
    
    # Extract relevant passages from each document
    compressed_docs = []
    for result in initial_results:
        compressed = extract_relevant_passages(query, result['text'])
        if compressed:
            compressed_docs.append({
                'id': result['id'],
                'text': compressed,
                'score': result['score']
            })
    
    return compressed_docs[:k]

def extract_relevant_passages(query, document):
    """Use LLM to extract only relevant parts"""
    prompt = f"""Given this query and document, extract ONLY the sentences directly relevant to answering the query.

Query: {query}

Document: {document}

Relevant excerpts:"""
    
    response = client.chat.completions.create(
        model="gpt-4",
        messages=[{"role": "user", "content": prompt}],
        max_tokens=300
    )
    
    return response.choices[0].message.content
```

**Pros:**
- Reduces noise
- More efficient context usage
- Better generation quality

**Cons:**
- Extra LLM processing
- May lose context
- Slower and more expensive

**LangChain:**
```python
from langchain.retrievers import ContextualCompressionRetriever
from langchain.retrievers.document_compressors import LLMChainExtractor

compressor = LLMChainExtractor.from_llm(llm)
compression_retriever = ContextualCompressionRetriever(
    base_compressor=compressor,
    base_retriever=base_retriever
)
```

---

### **6. Ensemble Retrieval**

Combine multiple retrieval methods.

```python
def ensemble_retrieval(query, vector_index, bm25_index, k=5):
    # Vector search
    query_embedding = embed_model.encode(query)
    vector_results = vector_index.query(vector=query_embedding, top_k=k)
    
    # BM25 (keyword) search
    bm25_results = bm25_index.search(query, k=k)
    
    # Combine with Reciprocal Rank Fusion (RRF)
    combined_scores = {}
    
    for rank, result in enumerate(vector_results):
        doc_id = result['id']
        combined_scores[doc_id] = combined_scores.get(doc_id, 0) + 1/(rank + 60)
    
    for rank, result in enumerate(bm25_results):
        doc_id = result['id']
        combined_scores[doc_id] = combined_scores.get(doc_id, 0) + 1/(rank + 60)
    
    # Sort by combined score
    ranked = sorted(combined_scores.items(), key=lambda x: x[1], reverse=True)
    return ranked[:k]
```

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

```python
def hybrid_search(query, vector_index, keyword_index, alpha=0.5, k=5):
    """
    alpha: weight for vector search (0-1)
    1-alpha: weight for keyword search
    """
    # Vector search
    query_embedding = embed_model.encode(query)
    vector_results = vector_index.query(vector=query_embedding, top_k=k*2)
    
    # Keyword search
    keyword_results = keyword_index.search(query, k=k*2)
    
    # Normalize and combine scores
    combined = {}
    
    # Normalize vector scores to [0, 1]
    max_vec_score = max(r['score'] for r in vector_results)
    for result in vector_results:
        doc_id = result['id']
        norm_score = result['score'] / max_vec_score
        combined[doc_id] = combined.get(doc_id, 0) + alpha * norm_score
    
    # Normalize keyword scores to [0, 1]
    max_kw_score = max(r['score'] for r in keyword_results)
    for result in keyword_results:
        doc_id = result['id']
        norm_score = result['score'] / max_kw_score
        combined[doc_id] = combined.get(doc_id, 0) + (1-alpha) * norm_score
    
    # Sort by combined score
    ranked = sorted(combined.items(), key=lambda x: x[1], reverse=True)
    return ranked[:k]
```

---

## Query Routing

Route different types of queries to different retrievers.

```python
def route_query(query, retrievers):
    """Route query to appropriate retriever"""
    # Classify query type
    query_type = classify_query(query)
    
    if query_type == "factual":
        return retrievers['keyword'].retrieve(query)
    elif query_type == "conceptual":
        return retrievers['semantic'].retrieve(query)
    elif query_type == "comparison":
        return retrievers['multi_query'].retrieve(query)
    else:
        return retrievers['default'].retrieve(query)

def classify_query(query):
    """Use LLM to classify query type"""
    prompt = f"""Classify this query into one of: factual, conceptual, comparison, or other.

Query: {query}

Classification:"""
    
    response = client.chat.completions.create(
        model="gpt-4",
        messages=[{"role": "user", "content": prompt}],
        max_tokens=10
    )
    
    return response.choices[0].message.content.strip().lower()
```

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

## Evaluation

```python
def evaluate_retrieval(queries, ground_truth, retriever):
    """Measure retrieval quality"""
    metrics = {
        'precision': [],
        'recall': [],
        'mrr': []  # Mean Reciprocal Rank
    }
    
    for query, relevant_docs in zip(queries, ground_truth):
        retrieved = retriever.retrieve(query, k=10)
        retrieved_ids = [doc['id'] for doc in retrieved]
        
        # Precision@k
        relevant_retrieved = set(retrieved_ids) & set(relevant_docs)
        precision = len(relevant_retrieved) / len(retrieved_ids)
        metrics['precision'].append(precision)
        
        # Recall
        recall = len(relevant_retrieved) / len(relevant_docs)
        metrics['recall'].append(recall)
        
        # MRR
        for rank, doc_id in enumerate(retrieved_ids, 1):
            if doc_id in relevant_docs:
                metrics['mrr'].append(1/rank)
                break
    
    return {
        'avg_precision': np.mean(metrics['precision']),
        'avg_recall': np.mean(metrics['recall']),
        'mrr': np.mean(metrics['mrr'])
    }
```

---

## Next Steps
- Implement and compare different retrieval strategies
- Measure retrieval quality on your data
- Learn about reranking models
- Explore hybrid search implementations
