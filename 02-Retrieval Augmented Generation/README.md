# Retrieval-Augmented Generation (RAG)

Welcome to the RAG (Retrieval-Augmented Generation) module! This comprehensive guide covers everything you need to build production-ready RAG systems, from understanding vector search fundamentals to implementing advanced architectures.

![RAG Overview](../assets/Retrieval%20Augmented%20Generation/rag.png)

In general, the LLM's won't have knowledge of internal or organization data because it's properatry data and not public data. 

RAG enhances Large Language Models by combining them with external knowledge retrieval like databases, APIs, and other data sources, enabling:
- ✅ Access to current information beyond training cutoff
- ✅ Grounded responses with source citations
- ✅ Domain-specific knowledge without fine-tuning
- ✅ Reduced hallucinations through factual grounding
- ✅ Cost-effective scaling compared to model retraining

In simple terms, RAG uses external knowledge sources to supplement the LLM's capabilities, allowing it to provide more accurate and up-to-date information.

## 📚 Table of Contents

### Foundations (Week 1-2)

1. **[Vector Search and Distance Metrics](01-vector-search-distance-metrics.md)**
   - Introduction to vector search and similarity
   - Distance metrics: Cosine, Euclidean, Manhattan
   - Choosing the right metric for your use case

2. **[Vector Search Algorithms](02-vector-search-algorithms.md)**
   - HNSW (Hierarchical Navigable Small World)
   - IVF (Inverted File Index)
   - Product Quantization and other techniques
   - Algorithm comparison and selection

3. **[Embedding Models](03-embedding-models.md)**
   - Dense embeddings (OpenAI, Sentence Transformers, BGE)
   - Sparse embeddings (BM25, SPLADE)
   - Late interaction models (ColBERT, ColPali)
   - Choosing and evaluating embedding models

4. **[Chunking Strategies](04-chunking-strategies.md)**
   - Fixed-size, sentence, and paragraph chunking
   - Semantic and recursive chunking
   - Structure-aware strategies
   - Best practices for different document types

5. **[Vector Databases and Cloud Services](05-vector-databases.md)**
   - Popular databases: Pinecone, Weaviate, Qdrant, Milvus, Chroma
   - Cloud services: AWS OpenSearch, Azure AI Search, Vertex AI
   - PGVector for PostgreSQL
   - Choosing the right database for your scale

6. **[Hands on: Building a RAG System](06-building-rag-system.md)**
   - Building a simple RAG pipeline with Python

### Document Processing (Week 2-3)

7. **[Document Extraction Techniques](07-document-extraction.md)**
   - PDF, DOCX, HTML, and other formats
   - Libraries: PyPDF, PyMuPDF, pdfplumber, python-docx
   - Table and layout extraction
   - Building robust extraction pipelines

8. **[OCR-Based Document Extraction](08-ocr-document-extraction.md)**
   - Tesseract, EasyOCR, PaddleOCR
   - Cloud OCR: Google Vision, Azure, AWS Textract
   - Image preprocessing techniques
   - Handling scanned documents and forms

### Infrastructure & Optimization (Week 3-4)


9. **[Optimization Strategies](09-optimization-strategies.md)**
   - Quantization techniques (Scalar, Product, Binary)
   - Multitenancy patterns
   - Sharding strategies
   - Performance tuning and cost optimization

### Advanced Retrieval (Week 4-5)

10. **[Retrieval Strategies](10-retrieval-strategies.md)**
   - Multi-query retrieval
   - Hypothetical Document Embeddings (HyDE)
   - Parent document retrieval
   - Contextual compression
   - Hybrid search (vector + keyword)

11. **[Reranker Models](11-reranker-models.md)**
    - Cross-encoders vs. bi-encoders
    - Cohere Rerank, BGE Reranker, Jina
    - Two-stage retrieval pipelines
    - Performance optimization

### Generation & Quality (Week 5-6)

12. **[Generation Strategies](12-generation-strategies.md)**
    - Prompt engineering for RAG
    - Chain of Thought reasoning
    - Iterative refinement (Self-RAG, FLARE)
    - Citation and fact-checking
    - Handling edge cases

13. **[Multimodal Vector Search](13-multimodal-vector-search.md)**
    - CLIP and SigLIP for image-text search
    - ImageBind for multi-modal embeddings
    - ColPali for document understanding
    - Building multimodal RAG systems

14. **[Evaluation Metrics](14-evaluation-metrics.md)**
    - Retrieval metrics: Precision@K, Recall@K, NDCG, MRR
    - Generation metrics: Faithfulness, Answer relevancy
    - Hallucination detection
    - End-to-end evaluation with RAGAS and DeepEval

### Production & Advanced (Week 6-8)

15. **[RAG Architectures](15-rag-architectures.md)**
    - Basic, Modular, and Agentic RAG
    - Multi-stage and Corrective RAG (CRAG)
    - GraphRAG and Hierarchical RAG
    - Conversational and Production patterns

16. **[Caching Strategies](16-caching.md)**
    - Query result caching
    - Embedding cache
    - Semantic cache
    - Multi-level caching with Redis
    - Cache invalidation strategies

17. **[Graph Databases](17-graph-databases.md)**
    - Neo4j, Amazon Neptune, ArangoDB
    - Knowledge graph construction
    - Entity and relationship extraction
    - Hybrid vector + graph retrieval
    - Microsoft GraphRAG approach

18. **[Vectorless RAG](18-vectorless-rag.md)**
    - BM25 and TF-IDF retrieval
    - Elasticsearch full-text search
    - PageIndex approach
    - When to use vectorless methods
    - Hybrid vector + vectorless strategies

*This comprehensive guide takes you from RAG fundamentals through production deployment. Each topic builds on the previous ones, so following the weekly structure is recommended for beginners. Advanced practitioners can jump directly to specific topics of interest.*


## 💡 Key Concepts

**The RAG Pipeline:**
```
Documents → Chunk → Embed → Index → Vector DB
                                         ↓
User Query → Embed → Retrieve → Rerank → Generate Answer
```

**Core Components:**
1. **Indexing**: Document processing, chunking, and embedding
2. **Retrieval**: Vector search and similarity matching
3. **Reranking**: Improving precision with cross-encoders
4. **Generation**: LLM creates contextual answers

---

*RAG is a foundational technique for building production AI systems. This guide provides the complete knowledge needed to implement, optimize, and scale RAG applications. The next section covers AI Agents, which build on RAG concepts to create autonomous, reasoning systems.*

Next: [AI Agents](../agents.md)

[← Back to Main Guide](../README.md)
