# Vector Databases and Cloud-Based Services

Vector databases are specialized storage systems optimized for storing, indexing, and querying high-dimensional vector embeddings. Essential infrastructure for production RAG systems.

![Vector Databases](../assets/Retrieval%20Augmented%20Generation/05-vector-databases/vector_databases.png)


## What is a Vector Database?

**Traditional databases** store structured data (rows, columns)
**Vector databases** store and search high-dimensional vectors

**Key capabilities:**
- Efficient similarity search (ANN)
- Scalable storage for millions/billions of vectors
- Fast retrieval with low latency
- Metadata filtering
- CRUD operations on vectors
- Hybrid search (vector + keyword)


## Popular Vector Databases

- **Qdrant**: Open-source, scalable, supports hybrid search
- **Milvus**: Open-source, high performance, distributed
- **Chroma**: Open-source, designed for LLM applications
- **Weaviate**: Open-source, graph-based, hybrid search
- **Vespa**: Open-source, real-time search and analytics
- **Pinecone**: Fully managed, scalable, easy to use
- **Redis Vector Search**: In-memory, fast, simple

Most of the sql and nosql databases now also support vector search capabilities:
- **PostgreSQL with pgvector**: Vector search extension for PostgreSQL
- **MongoDB Atlas Vector Search**: Managed vector search in MongoDB

Nowadays, many cloud providers also offer vector database services:
- **AWS OpenSearch Service**: Managed search with vector capabilities
- **Azure AI Search**: Vector search support
- **Google Vertex AI**:  RAG Engine with integrated vector search and Vector Search.

---

[← Previous: Chunking strategies](04-chunking-strategies.md) | [Next: Building a RAG system →](06-building-rag-system.md)


[← Back to Index](README.md)
