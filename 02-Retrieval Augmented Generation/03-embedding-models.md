# Embedding Models

## Overview
Embedding models transform text, images, or other data into dense vector representations that capture semantic meaning. These embeddings are the foundation of modern RAG systems.

---

## What are Embeddings?

**Definition:** Numerical representations of data (text, images, etc.) in a continuous vector space where similar items are close together.

**Key characteristics:**
- Fixed-dimensional vectors (e.g., 384, 768, 1536 dimensions)
- Capture semantic meaning, not just keywords
- Enable mathematical operations (similarity, arithmetic)
- Language and domain-specific patterns

---

## Types of Embedding Models

### 1. **Dense Embeddings**

The most common type where every dimension has a non-zero value.

**Characteristics:**
- All dimensions are typically non-zero
- Compact representation
- Captures rich semantic information
- Works well with cosine similarity

**Popular models:**
- **OpenAI text-embedding-3-small/large**
- **Sentence Transformers** (all-MiniLM-L6-v2, all-mpnet-base-v2)
- **E5** (e5-small, e5-base, e5-large)
- **BGE** (BAAI/bge-small-en, bge-base-en, bge-large-en)
- **Cohere embed-v3**
- **Google text-embedding-gecko**

**Use cases:**
- Semantic search
- Document similarity
- Question answering
- General RAG applications

[Learn more about dense embeddings](https://www.pinecone.io/learn/series/nlp/dense-vector-embeddings-nlp/)

---

### 2. **Sparse Embeddings**

High-dimensional vectors with mostly zero values.

**Characteristics:**
- Most dimensions are zero
- Interpretable (dimensions often correspond to terms)
- Better for keyword-based matching
- Larger dimensionality (10K-30K dimensions)

**Models/Methods:**
- **BM25**: Traditional sparse retrieval
- **SPLADE**: Neural sparse retrieval
- **DeepImpact**
- **TILDEv2**

**Advantages:**
- Better for exact keyword matches
- Interpretable results
- Efficient storage (sparse format)

**Use cases:**
- Legal/medical domains (exact term matching)
- Hybrid search with dense embeddings
- When explainability is important

[Learn more about sparse embeddings](https://www.pinecone.io/learn/series/nlp/sparse-vector-embeddings-nlp/)

---

### 3. **Late Interaction Models**

Models that delay the interaction between query and document vectors.

**Key innovation:** Instead of creating a single vector for the entire text, these models:
1. Create vectors for each token
2. Delay similarity computation until query time
3. Perform token-level interactions

**Popular models:**

#### **ColBERT (Contextualized Late Interaction over BERT)**
- Token-level embeddings
- MaxSim operation for scoring
- Better accuracy than dense embeddings
- Higher storage requirements

#### **ColPali**
- Extends ColBERT to multimodal (vision + text)
- Processes document images directly
- No OCR required
- Preserves layout information

**Advantages:**
- Higher accuracy than single-vector dense
- Captures fine-grained semantics
- Context-aware matching

**Trade-offs:**
- More storage (multiple vectors per document)
- Slower inference
- More complex implementation

[Learn more about late interaction models](https://weaviate.io/blog/late-interaction-overview#3-types-of-interaction-in-dense-retrieval-models)

---

## Choosing an Embedding Model

### Factors to consider:

1. **Quality metrics:**
   - MTEB (Massive Text Embedding Benchmark) scores
   - Domain-specific evaluation

2. **Dimensionality:**
   - Lower (384): Faster, less storage
   - Higher (1536): More accurate, more expensive

3. **Model size:**
   - Smaller: Faster inference, lower cost
   - Larger: Better quality

4. **Language support:**
   - Multilingual vs. English-only
   - Domain-specific (code, medical, legal)

5. **Licensing:**
   - Open source vs. proprietary
   - Commercial use restrictions

6. **Cost:**
   - API-based (per token)
   - Self-hosted (infrastructure)

---

## Popular Embedding Models

### **Open Source Models:**

| Model | Dimensions | Best For |
|-------|-----------|----------|
| all-MiniLM-L6-v2 | 384 | Fast, efficient |
| all-mpnet-base-v2 | 768 | Balanced quality |
| bge-large-en-v1.5 | 1024 | High quality |
| e5-large-v2 | 1024 | Instruction-following |
| jina-embeddings-v2 | 768 | Long context (8K) |

### **Commercial APIs:**

| Provider | Model | Dimensions | Notes |
|----------|-------|-----------|-------|
| OpenAI | text-embedding-3-large | 3072 | Adjustable dimensions |
| Cohere | embed-v3 | 1024 | Multiple languages |
| Google | text-embedding-gecko | 768 | Multimodal support |
| Anthropic | Voyage AI | 1024 | Domain-specific |

---

## Hands-On: Using Embedding Models

### With Sentence Transformers:
```python
from sentence_transformers import SentenceTransformer

# Load model
model = SentenceTransformer('all-MiniLM-L6-v2')

# Create embeddings
texts = [
    "What is machine learning?",
    "Machine learning is a subset of AI",
    "I love pizza"
]
embeddings = model.encode(texts)

print(f"Shape: {embeddings.shape}")  # (3, 384)

# Compute similarity
from sklearn.metrics.pairwise import cosine_similarity
similarities = cosine_similarity(embeddings)
print(similarities)
```

### With OpenAI API:
```python
from openai import OpenAI

client = OpenAI()

response = client.embeddings.create(
    model="text-embedding-3-small",
    input="Your text here"
)

embedding = response.data[0].embedding
print(f"Dimensions: {len(embedding)}")
```

### With Hugging Face:
```python
from transformers import AutoTokenizer, AutoModel
import torch

tokenizer = AutoTokenizer.from_pretrained('BAAI/bge-base-en-v1.5')
model = AutoModel.from_pretrained('BAAI/bge-base-en-v1.5')

texts = ["Sample text for embedding"]
encoded_input = tokenizer(texts, padding=True, truncation=True, return_tensors='pt')

with torch.no_grad():
    model_output = model(**encoded_input)
    embeddings = model_output[0][:, 0]  # CLS token

print(embeddings.shape)
```

---

## Best Practices

1. **Normalization:**
   - Normalize embeddings for cosine similarity
   - Check model documentation

2. **Batch processing:**
   - Process multiple texts together
   - Improves efficiency

3. **Caching:**
   - Cache embeddings for frequently accessed documents
   - Reduces API costs

4. **Version control:**
   - Track embedding model versions
   - Re-embed when upgrading models

5. **Evaluation:**
   - Test on your specific domain
   - Don't rely solely on benchmark scores

6. **Hybrid approaches:**
   - Combine dense + sparse for better results
   - Use rerankers for final refinement

---

## Advanced Topics

### **Matryoshka Embeddings:**
- Variable dimension embeddings
- Truncate dimensions as needed
- Trade accuracy for efficiency

### **Multi-vector representations:**
- Multiple embeddings per document
- Context-aware retrieval
- Better for long documents

### **Domain adaptation:**
- Fine-tune on domain-specific data
- Transfer learning approaches
- Contrastive learning

---

## Next Steps
- Benchmark models on your data
- Implement hybrid search (dense + sparse)
- Explore late interaction models
- Learn about reranking models
