# Vectorless RAG

## Overview
Vectorless RAG is an alternative approach to traditional vector-based retrieval that uses different methods for document indexing and search. While vector embeddings have become the standard, vectorless approaches offer unique advantages in specific scenarios.

---

## What is Vectorless RAG?

**Traditional RAG:**
- Documents → Embeddings → Vector DB → Similarity Search

**Vectorless RAG:**
- Documents → Structured Index → Alternative Search Methods → Retrieval

**Key difference:** No embeddings or vector similarity computations

---

## Why Consider Vectorless RAG?

### **Advantages:**
1. **Lower computational cost**: No embedding generation needed
2. **Faster indexing**: Skip embedding step
3. **More explainable**: Clear why documents matched
4. **Better for exact matches**: Keyword-based precision
5. **Lower memory**: No vector storage
6. **Simpler infrastructure**: Standard databases work

### **Disadvantages:**
1. **Less semantic understanding**: Misses synonyms/paraphrases
2. **Keyword dependency**: Query reformulation needed
3. **No out-of-vocabulary handling**: Exact term matching
4. **Less flexible**: Can't capture nuanced similarity

---

## Vectorless Retrieval Methods

### **1. BM25 (Best Matching 25)**

Statistical ranking function based on term frequency.

```python
from rank_bm25 import BM25Okapi
import nltk
from nltk.tokenize import word_tokenize

class BM25Retriever:
    def __init__(self, documents):
        # Tokenize documents
        self.documents = documents
        self.tokenized_docs = [
            word_tokenize(doc.lower()) 
            for doc in documents
        ]
        
        # Create BM25 index
        self.bm25 = BM25Okapi(self.tokenized_docs)
    
    def search(self, query, top_k=5):
        # Tokenize query
        tokenized_query = word_tokenize(query.lower())
        
        # Get scores
        scores = self.bm25.get_scores(tokenized_query)
        
        # Get top k
        top_indices = sorted(
            range(len(scores)),
            key=lambda i: scores[i],
            reverse=True
        )[:top_k]
        
        results = [
            {
                'document': self.documents[i],
                'score': scores[i],
                'rank': rank + 1
            }
            for rank, i in enumerate(top_indices)
        ]
        
        return results

# Usage
documents = [
    "Machine learning is a subset of artificial intelligence",
    "Deep learning uses neural networks with many layers",
    "Natural language processing helps computers understand text"
]

retriever = BM25Retriever(documents)
results = retriever.search("What is machine learning?", top_k=2)

for result in results:
    print(f"Rank {result['rank']}: {result['document'][:50]}...")
    print(f"Score: {result['score']:.4f}\n")
```

---

### **2. TF-IDF (Term Frequency-Inverse Document Frequency)**

Classic information retrieval method.

```python
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity
import numpy as np

class TFIDFRetriever:
    def __init__(self, documents):
        self.documents = documents
        
        # Create TF-IDF vectorizer
        self.vectorizer = TfidfVectorizer(
            lowercase=True,
            stop_words='english',
            ngram_range=(1, 2)  # Unigrams and bigrams
        )
        
        # Fit and transform documents
        self.doc_vectors = self.vectorizer.fit_transform(documents)
    
    def search(self, query, top_k=5):
        # Transform query
        query_vector = self.vectorizer.transform([query])
        
        # Compute similarity
        similarities = cosine_similarity(query_vector, self.doc_vectors)[0]
        
        # Get top k
        top_indices = np.argsort(similarities)[::-1][:top_k]
        
        results = [
            {
                'document': self.documents[i],
                'score': similarities[i],
                'rank': rank + 1
            }
            for rank, i in enumerate(top_indices)
        ]
        
        return results

# Usage
retriever = TFIDFRetriever(documents)
results = retriever.search("neural networks and deep learning")
```

---

### **3. Full-Text Search (Elasticsearch/OpenSearch)**

Database-native full-text search capabilities.

```python
from elasticsearch import Elasticsearch

class ElasticsearchRetriever:
    def __init__(self, index_name='documents'):
        self.es = Elasticsearch(['http://localhost:9200'])
        self.index_name = index_name
        
        # Create index if doesn't exist
        if not self.es.indices.exists(index=self.index_name):
            self.es.indices.create(
                index=self.index_name,
                body={
                    'mappings': {
                        'properties': {
                            'text': {'type': 'text'},
                            'title': {'type': 'text'},
                            'id': {'type': 'keyword'}
                        }
                    }
                }
            )
    
    def index_document(self, doc_id, text, title):
        """Add document to index"""
        self.es.index(
            index=self.index_name,
            id=doc_id,
            body={
                'text': text,
                'title': title
            }
        )
    
    def search(self, query, top_k=5):
        """Search documents"""
        response = self.es.search(
            index=self.index_name,
            body={
                'query': {
                    'multi_match': {
                        'query': query,
                        'fields': ['text^2', 'title^3'],  # Boost title
                        'type': 'best_fields',
                        'operator': 'or'
                    }
                },
                'size': top_k
            }
        )
        
        results = [
            {
                'id': hit['_id'],
                'document': hit['_source']['text'],
                'title': hit['_source']['title'],
                'score': hit['_score'],
                'rank': i + 1
            }
            for i, hit in enumerate(response['hits']['hits'])
        ]
        
        return results

# Usage
es_retriever = ElasticsearchRetriever()

# Index documents
es_retriever.index_document('1', 'Machine learning content...', 'ML Basics')
es_retriever.index_document('2', 'Deep learning content...', 'DL Overview')

# Search
results = es_retriever.search("machine learning")
```

---

### **4. PageIndex (Novel Approach)**

Document-centric indexing without embeddings.

**Concept:** Index based on document structure, metadata, and relationships rather than semantic embeddings.

```python
class PageIndexRetriever:
    """
    Based on VectifyAI's PageIndex approach
    Reference: https://github.com/VectifyAI/PageIndex
    """
    
    def __init__(self):
        self.index = {}
        self.documents = []
    
    def index_document(self, doc_id, content, metadata):
        """Index document with structural features"""
        # Extract features
        features = self.extract_features(content, metadata)
        
        # Store document
        self.documents.append({
            'id': doc_id,
            'content': content,
            'metadata': metadata,
            'features': features
        })
        
        # Build inverted index
        for feature, value in features.items():
            if feature not in self.index:
                self.index[feature] = {}
            
            if value not in self.index[feature]:
                self.index[feature][value] = []
            
            self.index[feature][value].append(doc_id)
    
    def extract_features(self, content, metadata):
        """Extract indexable features"""
        features = {}
        
        # Structural features
        features['word_count'] = len(content.split())
        features['has_code'] = '```' in content
        features['has_list'] = any(line.strip().startswith(('-', '*', '1.')) 
                                   for line in content.split('\n'))
        
        # Metadata features
        if metadata:
            features['category'] = metadata.get('category')
            features['author'] = metadata.get('author')
            features['date'] = metadata.get('date')
        
        # Topic keywords (simple extraction)
        features['keywords'] = self.extract_keywords(content)
        
        return features
    
    def extract_keywords(self, content):
        """Simple keyword extraction"""
        # Use TF-IDF or RAKE
        words = content.lower().split()
        # Simple: most frequent words (should use better method)
        from collections import Counter
        common = Counter(words).most_common(10)
        return [word for word, _ in common]
    
    def search(self, query, filters=None, top_k=5):
        """Search based on features and filters"""
        candidates = set(doc['id'] for doc in self.documents)
        
        # Apply filters
        if filters:
            for feature, value in filters.items():
                if feature in self.index and value in self.index[feature]:
                    candidates &= set(self.index[feature][value])
        
        # Score candidates (simple keyword matching)
        scores = {}
        query_words = set(query.lower().split())
        
        for doc in self.documents:
            if doc['id'] in candidates:
                # Simple scoring: keyword overlap
                doc_words = set(doc['content'].lower().split())
                overlap = len(query_words & doc_words)
                scores[doc['id']] = overlap
        
        # Return top k
        sorted_docs = sorted(
            scores.items(),
            key=lambda x: x[1],
            reverse=True
        )[:top_k]
        
        return [
            {
                'id': doc_id,
                'document': next(d['content'] for d in self.documents if d['id'] == doc_id),
                'score': score
            }
            for doc_id, score in sorted_docs
        ]
```

---

## Hybrid Vectorless Approaches

### **Combining Multiple Methods:**

```python
class HybridVectorlessRAG:
    def __init__(self, documents):
        self.documents = documents
        
        # Multiple retrievers
        self.bm25 = BM25Retriever(documents)
        self.tfidf = TFIDFRetriever(documents)
    
    def search(self, query, top_k=5, weights={'bm25': 0.5, 'tfidf': 0.5}):
        """Combine multiple vectorless methods"""
        # Get results from each
        bm25_results = self.bm25.search(query, top_k=top_k*2)
        tfidf_results = self.tfidf.search(query, top_k=top_k*2)
        
        # Normalize scores
        bm25_scores = self.normalize_scores([r['score'] for r in bm25_results])
        tfidf_scores = self.normalize_scores([r['score'] for r in tfidf_results])
        
        # Combine scores
        combined = {}
        for i, result in enumerate(bm25_results):
            doc = result['document']
            combined[doc] = combined.get(doc, 0) + weights['bm25'] * bm25_scores[i]
        
        for i, result in enumerate(tfidf_results):
            doc = result['document']
            combined[doc] = combined.get(doc, 0) + weights['tfidf'] * tfidf_scores[i]
        
        # Sort and return top k
        sorted_results = sorted(
            combined.items(),
            key=lambda x: x[1],
            reverse=True
        )[:top_k]
        
        return [
            {'document': doc, 'score': score}
            for doc, score in sorted_results
        ]
    
    def normalize_scores(self, scores):
        """Min-max normalization"""
        if not scores or max(scores) == min(scores):
            return scores
        
        min_score = min(scores)
        max_score = max(scores)
        
        return [
            (score - min_score) / (max_score - min_score)
            for score in scores
        ]
```

---

## When to Use Vectorless RAG

### **Best suited for:**

1. **Exact keyword matching domains:**
   - Legal documents (specific terms matter)
   - Technical documentation (precise terminology)
   - Code search (exact function/variable names)

2. **Low-resource scenarios:**
   - Limited compute/memory
   - Edge devices
   - Real-time requirements

3. **Explainability requirements:**
   - Need to show exact matches
   - Regulatory compliance
   - Debugging/transparency

4. **Structured queries:**
   - SQL-like filters
   - Metadata-based search
   - Faceted navigation

---

## Vectorless RAG Pipeline

```python
class VectorlessRAGSystem:
    def __init__(self, documents):
        self.retriever = BM25Retriever(documents)
        self.llm = LLM()
    
    def query(self, question):
        # 1. Query reformulation (optional)
        reformulated = self.reformulate_query(question)
        
        # 2. Retrieve with BM25
        results = self.retriever.search(reformulated, top_k=5)
        
        # 3. Format context
        context = "\n\n".join([r['document'] for r in results])
        
        # 4. Generate answer
        prompt = f"""Context:
{context}

Question: {question}

Answer:"""
        
        answer = self.llm.generate(prompt)
        
        return {
            'answer': answer,
            'sources': results,
            'query_used': reformulated
        }
    
    def reformulate_query(self, query):
        """Expand query with synonyms/related terms"""
        # Could use WordNet, GPT, or custom synonym dictionary
        expanded = query + " " + self.get_synonyms(query)
        return expanded
    
    def get_synonyms(self, query):
        """Get synonyms to expand query"""
        # Simplified - in practice, use WordNet or LLM
        synonym_dict = {
            'machine learning': 'ML artificial intelligence AI',
            'deep learning': 'neural networks DL',
        }
        
        for key, synonyms in synonym_dict.items():
            if key in query.lower():
                return synonyms
        
        return ""
```

---

## Comparison: Vector vs. Vectorless

| Aspect | Vector RAG | Vectorless RAG |
|--------|-----------|----------------|
| Semantic understanding | ✓✓✓ | ✓ |
| Exact matching | ✓ | ✓✓✓ |
| Speed | Medium | Fast |
| Memory | High | Low |
| Explainability | Low | High |
| Setup complexity | Medium | Low |
| Synonym handling | ✓✓✓ | ✓ |
| Out-of-domain | ✓✓✓ | ✓ |

---

## Hybrid Vector + Vectorless

**Best of both worlds:**

```python
class HybridRAG:
    def __init__(self, documents, embedding_model):
        # Vectorless retriever
        self.bm25 = BM25Retriever(documents)
        
        # Vector retriever
        self.vector_db = VectorDatabase()
        for doc in documents:
            emb = embedding_model.encode(doc)
            self.vector_db.insert(emb, doc)
    
    def search(self, query, alpha=0.5):
        """
        alpha: weight for vector search (0-1)
        1-alpha: weight for BM25
        """
        # Vector search
        vector_results = self.vector_db.search(query, top_k=10)
        
        # BM25 search
        bm25_results = self.bm25.search(query, top_k=10)
        
        # Reciprocal Rank Fusion
        combined = self.reciprocal_rank_fusion(
            vector_results,
            bm25_results
        )
        
        return combined[:5]
    
    def reciprocal_rank_fusion(self, results1, results2, k=60):
        """Combine rankings using RRF"""
        scores = {}
        
        for rank, result in enumerate(results1):
            doc = result['document']
            scores[doc] = scores.get(doc, 0) + 1 / (rank + k)
        
        for rank, result in enumerate(results2):
            doc = result['document']
            scores[doc] = scores.get(doc, 0) + 1 / (rank + k)
        
        sorted_results = sorted(
            scores.items(),
            key=lambda x: x[1],
            reverse=True
        )
        
        return [{'document': doc, 'score': score} for doc, score in sorted_results]
```

---

## PostgreSQL Full-Text Search

Use database native capabilities.

```python
import psycopg2

class PostgresFullTextSearch:
    def __init__(self, db_config):
        self.conn = psycopg2.connect(**db_config)
        self.setup_fts()
    
    def setup_fts(self):
        """Setup full-text search"""
        with self.conn.cursor() as cur:
            cur.execute("""
                CREATE TABLE IF NOT EXISTS documents (
                    id SERIAL PRIMARY KEY,
                    content TEXT,
                    search_vector tsvector
                );
                
                CREATE INDEX IF NOT EXISTS search_idx 
                ON documents USING GIN(search_vector);
            """)
            self.conn.commit()
    
    def index_document(self, content):
        """Add document with search vector"""
        with self.conn.cursor() as cur:
            cur.execute("""
                INSERT INTO documents (content, search_vector)
                VALUES (%s, to_tsvector('english', %s))
            """, (content, content))
            self.conn.commit()
    
    def search(self, query, top_k=5):
        """Full-text search"""
        with self.conn.cursor() as cur:
            cur.execute("""
                SELECT id, content, 
                       ts_rank(search_vector, query) AS rank
                FROM documents, 
                     to_tsquery('english', %s) query
                WHERE search_vector @@ query
                ORDER BY rank DESC
                LIMIT %s
            """, (query, top_k))
            
            results = cur.fetchall()
            
        return [
            {'id': r[0], 'document': r[1], 'score': r[2]}
            for r in results
        ]
```

---

## Best Practices

1. **Query preprocessing:**
   - Remove stop words
   - Stem/lemmatize
   - Expand with synonyms

2. **Index optimization:**
   - Regular maintenance
   - Proper tokenization
   - Field boosting

3. **Fallback strategy:**
   - Use vectorless as fallback
   - Combine with vector search
   - A/B test approaches

4. **Monitor performance:**
   - Track precision/recall
   - Measure latency
   - Optimize based on data

---

## Limitations

1. **Vocabulary mismatch**: Query and document use different terms
2. **No semantic understanding**: "big" vs "large" treated as different
3. **Context ignorance**: Word order not fully captured
4. **Domain specific**: Performance varies by domain

---

## Next Steps
- Implement BM25 for your documents
- Compare with vector-based retrieval
- Try hybrid approach (vector + BM25)
- Measure performance on your specific use case
- Consider PostgreSQL full-text search for SQL-based systems
- Evaluate cost/performance trade-offs
