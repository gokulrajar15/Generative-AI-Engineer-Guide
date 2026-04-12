# Graph Databases for RAG

Graph databases store data as nodes and relationships, enabling powerful traversal and context-aware retrieval. GraphRAG combines traditional vector search with graph-based knowledge representation for enhanced reasoning.

![GraphRAG Architecture](../assets/Retrieval%20Augmented%20Generation/16-graph-database/graph_database.png)

## Why Graph Databases for RAG?

**Limitations of vector-only RAG:**
- No explicit relationships between entities
- Difficult multi-hop reasoning
- Limited context about connections
- Misses indirect relevance

**Graph advantages:**
- Explicit relationships (who, what, when, where)
- Multi-hop traversal
- Context propagation
- Better for complex queries

## Popular Graph Databases
- **Neo4j**: Mature, widely used, strong query language (Cypher)
- **Amazon Neptune**: Fully managed, supports multiple graph models
- **ArangoDB**: Multi-model (graph + document), flexible
- **TigerGraph**: High performance, scalable graph analytics
- **RedisGraph**: In-memory graph database, fast for real-time applications

## This is a hands-on tutorial that will be added soon! Stay tuned for a practical guide on document extraction techniques, covering tools and libraries for handling various formats, strategies for preserving structure, and tips for optimizing extraction quality for RAG systems.

---

[<- Previous: RAG Architectures](15-rag-architectures.md) | [Next: Vectorless RAG →](17-vectorless-rag.md)

[<- Back to Index](README.md)