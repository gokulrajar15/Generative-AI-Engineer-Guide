# Vector Databases and Cloud-Based Services

## Overview
Vector databases are specialized storage systems optimized for storing, indexing, and querying high-dimensional vector embeddings. Essential infrastructure for production RAG systems.

---

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

---

## Vector Database vs. Vector Library

| Feature | Vector Library (FAISS) | Vector Database |
|---------|----------------------|-----------------|
| Persistence | Manual | Built-in |
| Scalability | Single machine | Distributed |
| CRUD Operations | Limited | Full support |
| Filtering | Manual | Native |
| Production Ready | No | Yes |
| Ease of Use | Complex | Simple API |

---

## Popular Vector Databases

### **1. Pinecone**

Fully managed cloud vector database.

**Features:**
- Serverless and managed
- No infrastructure management
- Built-in scaling
- Namespaces for multitenancy
- Metadata filtering

**Setup:**
```python
from pinecone import Pinecone, ServerlessSpec

pc = Pinecone(api_key="your-api-key")

# Create index
pc.create_index(
    name="quickstart",
    dimension=1536,
    metric="cosine",
    spec=ServerlessSpec(
        cloud="aws",
        region="us-east-1"
    )
)

# Get index
index = pc.Index("quickstart")
```

**Usage:**
```python
# Upsert vectors
index.upsert(
    vectors=[
        {
            "id": "doc1",
            "values": embedding_vector,
            "metadata": {"text": "sample text", "category": "tech"}
        }
    ]
)

# Query
results = index.query(
    vector=query_embedding,
    top_k=5,
    include_metadata=True,
    filter={"category": "tech"}
)
```

**Pros:**
- Easiest to get started
- No ops required
- Excellent documentation
- Built-in monitoring

**Cons:**
- Cloud-only (vendor lock-in)
- Can be expensive at scale
- Limited customization

---

### **2. Weaviate**

Open-source vector database with rich features.

**Features:**
- Hybrid search (vector + BM25)
- GraphQL API
- Automatic vectorization
- Multi-modal support
- Self-hosted or cloud

**Setup with Docker:**
```bash
docker run -d \
  -p 8080:8080 \
  -e AUTHENTICATION_ANONYMOUS_ACCESS_ENABLED=true \
  -e PERSISTENCE_DATA_PATH=/var/lib/weaviate \
  semitechnologies/weaviate:latest
```

**Usage:**
```python
import weaviate

client = weaviate.Client("http://localhost:8080")

# Create schema
class_obj = {
    "class": "Document",
    "vectorizer": "none",  # Use custom embeddings
    "properties": [
        {"name": "text", "dataType": ["text"]},
        {"name": "category", "dataType": ["string"]}
    ]
}
client.schema.create_class(class_obj)

# Insert data
client.data_object.create(
    data_object={
        "text": "Sample document",
        "category": "tech"
    },
    class_name="Document",
    vector=embedding_vector
)

# Query
result = client.query.get("Document", ["text", "category"])\
    .with_near_vector({"vector": query_embedding})\
    .with_limit(5)\
    .do()
```

**Pros:**
- Feature-rich
- Hybrid search
- Good for complex queries
- Open source

**Cons:**
- Steeper learning curve
- More setup required
- Resource intensive

---

### **3. Qdrant**

High-performance vector database written in Rust.

**Features:**
- Written in Rust (fast!)
- Rich filtering
- Payload storage
- Snapshot support
- Easy deployment

**Setup with Docker:**
```bash
docker run -p 6333:6333 qdrant/qdrant
```

**Usage:**
```python
from qdrant_client import QdrantClient
from qdrant_client.models import Distance, VectorParams, PointStruct

client = QdrantClient(url="http://localhost:6333")

# Create collection
client.create_collection(
    collection_name="documents",
    vectors_config=VectorParams(size=1536, distance=Distance.COSINE)
)

# Insert vectors
client.upsert(
    collection_name="documents",
    points=[
        PointStruct(
            id=1,
            vector=embedding_vector,
            payload={"text": "sample", "category": "tech"}
        )
    ]
)

# Search
results = client.search(
    collection_name="documents",
    query_vector=query_embedding,
    limit=5,
    query_filter={"must": [{"key": "category", "match": {"value": "tech"}}]}
)
```

**Pros:**
- Very fast
- Excellent filtering
- Good documentation
- Easy to deploy

**Cons:**
- Smaller community
- Fewer integrations

---

### **4. Milvus**

Open-source vector database for billion-scale.

**Features:**
- Highly scalable
- Multiple index types
- GPU support
- Complex filtering
- Enterprise-grade

**Setup with Docker Compose:**
```bash
wget https://github.com/milvus-io/milvus/releases/download/v2.3.0/milvus-standalone-docker-compose.yml -O docker-compose.yml
docker-compose up -d
```

**Usage:**
```python
from pymilvus import connections, Collection, FieldSchema, CollectionSchema, DataType

# Connect
connections.connect(host="localhost", port="19530")

# Define schema
fields = [
    FieldSchema(name="id", dtype=DataType.INT64, is_primary=True, auto_id=True),
    FieldSchema(name="embedding", dtype=DataType.FLOAT_VECTOR, dim=1536),
    FieldSchema(name="text", dtype=DataType.VARCHAR, max_length=65535)
]
schema = CollectionSchema(fields, description="Documents")

# Create collection
collection = Collection(name="documents", schema=schema)

# Insert
collection.insert([
    [embedding_vector],
    ["sample text"]
])

# Create index
collection.create_index(
    field_name="embedding",
    index_params={"index_type": "IVF_FLAT", "metric_type": "L2", "params": {"nlist": 128}}
)

# Search
collection.load()
results = collection.search(
    data=[query_embedding],
    anns_field="embedding",
    param={"metric_type": "L2", "params": {"nprobe": 10}},
    limit=5
)
```

**Pros:**
- Extremely scalable
- Production-ready
- Multiple deployment options
- Strong community

**Cons:**
- Complex setup
- Resource heavy
- Steep learning curve

---

### **5. Chroma**

Simple, open-source embedding database.

**Features:**
- Lightweight
- Easy to use
- Good for prototyping
- Python-first

**Usage:**
```python
import chromadb

client = chromadb.Client()

# Create collection
collection = client.create_collection(name="documents")

# Add documents
collection.add(
    embeddings=[embedding_vector],
    documents=["sample text"],
    metadatas=[{"category": "tech"}],
    ids=["doc1"]
)

# Query
results = collection.query(
    query_embeddings=[query_embedding],
    n_results=5,
    where={"category": "tech"}
)
```

**Pros:**
- Simplest to use
- Perfect for prototyping
- Lightweight
- Good defaults

**Cons:**
- Not for production scale
- Limited features
- Performance at scale

---

### **6. PGVector**

Vector extension for PostgreSQL.

**Setup:**
```sql
CREATE EXTENSION vector;

CREATE TABLE documents (
  id SERIAL PRIMARY KEY,
  content TEXT,
  embedding vector(1536)
);

CREATE INDEX ON documents USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);
```

**Usage:**
```python
import psycopg2
from pgvector.psycopg2 import register_vector

conn = psycopg2.connect(database="mydb")
register_vector(conn)

cur = conn.cursor()

# Insert
cur.execute("INSERT INTO documents (content, embedding) VALUES (%s, %s)",
           ("sample text", embedding_vector))

# Query
cur.execute("""
    SELECT content, embedding <=> %s AS distance
    FROM documents
    ORDER BY distance
    LIMIT 5
""", (query_embedding,))
```

**Pros:**
- Use existing PostgreSQL knowledge
- ACID transactions
- Mature ecosystem
- Free and open source

**Cons:**
- Not purpose-built for vectors
- Slower than specialized DBs
- Limited vector operations

---

## Cloud-Based Vector Database Services

### **1. AWS - Amazon OpenSearch Service**

**Features:**
- Managed Elasticsearch with k-NN
- Integrated with AWS ecosystem
- Vector search using k-NN plugin

```python
from opensearchpy import OpenSearch

client = OpenSearch(
    hosts=[{'host': 'your-domain.region.es.amazonaws.com', 'port': 443}],
    use_ssl=True
)

# Create index
client.indices.create(
    index="documents",
    body={
        "settings": {"index.knn": True},
        "mappings": {
            "properties": {
                "embedding": {
                    "type": "knn_vector",
                    "dimension": 1536
                }
            }
        }
    }
)
```

---

### **2. AWS Bedrock Knowledge Bases**

Fully managed RAG solution.

```python
import boto3

bedrock = boto3.client('bedrock-agent')

# Create knowledge base
response = bedrock.create_knowledge_base(
    name='my-knowledge-base',
    roleArn='arn:aws:iam::...',
    knowledgeBaseConfiguration={
        'type': 'VECTOR',
        'vectorKnowledgeBaseConfiguration': {
            'embeddingModelArn': 'arn:aws:bedrock:...'
        }
    }, storageConfiguration={
   'type': 'OPENSEARCH_SERVERLESS'
    }
)
```

---

### **3. Azure AI Search (formerly Cognitive Search)**

```python
from azure.search.documents import SearchClient
from azure.search.documents.indexes import SearchIndexClient
from azure.core.credentials import AzureKeyCredential

index_client = SearchIndexClient(endpoint, AzureKeyCredential(key))

# Create index with vector field
index = {
    "name": "documents",
    "fields": [
        {"name": "id", "type": "Edm.String", "key": True},
        {"name": "content", "type": "Edm.String"},
        {"name": "embedding", "type": "Collection(Edm.Single)",
         "dimensions": 1536, "vectorSearchProfile": "my-profile"}
    ]
}
```

---

### **4. Google Vertex AI Matching Engine**

```python
from google.cloud import aiplatform

aiplatform.init(project='my-project', location='us-central1')

# Create index
index = aiplatform.MatchingEngineIndex.create_tree_ah_index(
    display_name="my-index",
    dimensions=1536,
    approximate_neighbors_count=10
)
```

---

## Choosing the Right Vector Database

### Decision Matrix:

| Use Case | Recommendation |
|----------|---------------|
| Prototype/MVP | Chroma, Pinecone |
| Small-medium scale | Qdrant, Weaviate |
| Large scale (billions) | Milvus, Pinecone (enterprise) |
| Existing PostgreSQL | PGVector |
| AWS ecosystem | OpenSearch, Bedrock KB |
| Azure ecosystem | Azure AI Search |
| GCP ecosystem | Vertex AI Matching Engine |
| On-premise | Milvus, Weaviate, Qdrant |

### Consider:

1. **Scale**: Current and future vector count
2. **Latency**: Query speed requirements
3. **Cost**: Infrastructure vs. managed service
4. **Features**: Filtering, hybrid search, multitenancy
5. **Ops**: Team expertise and resources
6. **Lock-in**: Open source vs. proprietary

---

## Best Practices

### **1. Indexing Strategy:**
```python
# Choose appropriate index type
# HNSW for speed, IVF for scale
index_params = {
    "index_type": "HNSW",
    "metric_type": "COSINE",
    "params": {
        "M": 16,  # Number of connections
        "efConstruction": 200  # Build quality
    }
}
```

### **2. Metadata Management:**
```python
# Rich metadata for filtering
metadata = {
    "source": "documentation",
    "created_at": timestamp,
    "author": "user_id",
    "tags": ["python", "tutorial"],
    "version": "1.0"
}
```

### **3. Batch Operations:**
```python
# Upsert in batches for performance
batch_size = 100
for i in range(0, len(vectors), batch_size):
    batch = vectors[i:i+batch_size]
    index.upsert(vectors=batch)
```

### **4. Monitoring:**
- Query latency (p50, p95, p99)
- Vector count and growth
- Index size and memory usage
- Query patterns and hot spots

---

## Next Steps
- Set up a vector database for your use case
- Implement batch ingestion pipeline
- Optimize index parameters for your data
- Learn about hybrid search and reranking
