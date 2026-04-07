# Vectorless RAG

## Overview
Vectorless RAG is an alternative approach to traditional vector-based retrieval that uses different methods for document indexing and search. While vector embeddings have become the standard, vectorless approaches offer unique advantages in specific scenarios, particularly for complex professional documents that require reasoning and explainability.

---

## What is Vectorless RAG?

**Traditional RAG:**
- Documents → Embeddings → Vector DB → Similarity Search → LLM Generation

**Vectorless RAG:**
- Documents → Structured Index → Reasoning-Based Retrieval → LLM Generation

**Key difference:** No embeddings or vector similarity computations. Instead, uses document structure, reasoning, and alternative indexing methods.

---

## Why Consider Vectorless RAG?

### **Advantages:**
1. **Lower computational cost**: No embedding generation needed
2. **Faster indexing**: Skip embedding step
3. **More explainable**: Clear reasoning for why documents matched
4. **Better for exact matches**: Keyword-based precision
5. **Lower memory**: No vector storage required
6. **Simpler infrastructure**: Standard databases work
7. **Higher accuracy**: Reasoning-based retrieval can outperform similarity search for complex documents
8. **Better traceability**: Clear page and section references

### **Disadvantages:**
1. **Less semantic understanding**: May miss synonyms/paraphrases (addressed by LLM-based approaches)
2. **Keyword dependency**: Traditional methods require query reformulation
3. **No out-of-vocabulary handling**: Exact term matching in traditional methods
4. **Less flexible**: Traditional keyword methods can't capture nuanced similarity

---

## Types of Vectorless RAG

### 1. **Keyword-Based Methods**

**Traditional approaches:**
- **BM25**: Statistical ranking function
- **TF-IDF**: Term frequency inverse document frequency
- **Elasticsearch**: Full-text search

**Characteristics:**
- Fast and efficient
- Good for exact term matching
- No ML models required
- Limited semantic understanding

---

### 2. **Reasoning-Based Methods (Modern Approach)**

**LLM-powered retrieval** using structured document indexes.

**Key innovation:** Uses LLM reasoning to navigate document structure, mimicking how humans find information.

---

## PageIndex: Reasoning-Based Vectorless RAG

[PageIndex](https://github.com/VectifyAI/PageIndex) is a modern vectorless RAG system that combines tree-based document indexing with LLM reasoning for intelligent retrieval.

### **Core Features**

1. **No Vector Database**: Uses document structure and LLM reasoning for retrieval
2. **No Chunking**: Documents organized into natural sections, not artificial chunks
3. **Human-like Retrieval**: Simulates how experts navigate complex documents
4. **Better Explainability**: Reasoning-based, traceable retrieval with page/section references
5. **High Accuracy**: Achieved 98.7% accuracy on FinanceBench benchmark

## Comparison: Vector vs Vectorless RAG

<table>
  <thead>
    <tr>
      <th>Aspect</th>
      <th>Vector-Based RAG</th>
      <th>Vectorless RAG (PageIndex)</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><b>Retrieval Method</b></td>
      <td>Semantic similarity (cosine, dot product)</td>
      <td>LLM reasoning over tree structure</td>
    </tr>
    <tr>
      <td><b>Indexing</b></td>
      <td>Generate embeddings for chunks</td>
      <td>Generate hierarchical tree structure</td>
    </tr>
    <tr>
      <td><b>Chunking</b></td>
      <td>Required (fixed or semantic chunks)</td>
      <td>Not required (natural sections)</td>
    </tr>
    <tr>
      <td><b>Storage</b></td>
      <td>Vector database (Pinecone, Qdrant, etc.)</td>
      <td>Standard JSON/database</td>
    </tr>
    <tr>
      <td><b>Explainability</b></td>
      <td>Limited (similarity scores)</td>
      <td>High (reasoning trace, page references)</td>
    </tr>
    <tr>
      <td><b>Accuracy (Complex Docs)</b></td>
      <td>~85% (typical)</td>
      <td>98.7% (FinanceBench)</td>
    </tr>
    <tr>
      <td><b>Infrastructure</b></td>
      <td>Vector DB + Embedding API</td>
      <td>LLM API only</td>
    </tr>
    <tr>
      <td><b>Cost</b></td>
      <td>Embedding costs + vector DB</td>
      <td>LLM reasoning costs</td>
    </tr>
    <tr>
      <td><b>Best For</b></td>
      <td>General semantic search, high volume</td>
      <td>Complex professional documents, accuracy-critical</td>
    </tr>
  </tbody>
</table>

---

## When to Use Vectorless RAG

### **Choose Vectorless (PageIndex) When:**

✅ Working with long, complex professional documents  
✅ Accuracy is critical (financial, legal, medical)  
✅ Need explainable retrieval with citations  
✅ Document has natural hierarchical structure  
✅ Multi-step reasoning required  
✅ Want simpler infrastructure (no vector DB)  

### **Choose Vector-Based RAG When:**

✅ General semantic search across diverse content  
✅ High-volume, low-latency requirements  
✅ Short documents or simple queries  
✅ Cost-sensitive (large scale)  
✅ Real-time indexing needs  


## Resources

- **PageIndex GitHub**: [github.com/VectifyAI/PageIndex](https://github.com/VectifyAI/PageIndex)
- **Documentation**: [docs.pageindex.ai](https://docs.pageindex.ai/)


*Vectorless RAG represents an evolution in retrieval methods, particularly for complex professional documents where accuracy and explainability are paramount. As LLMs become more capable, reasoning-based approaches will likely play an increasingly important role alongside traditional vector search.*

[<- Previous: Graph Databases](17-graph-databases.md)

[<- Back to Index](README.md)