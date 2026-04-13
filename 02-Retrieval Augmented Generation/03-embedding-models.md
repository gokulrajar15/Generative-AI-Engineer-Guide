# Embedding Models

Embedding models transform text, images, or other data into dense vector representations that capture semantic meaning. These embeddings are the foundation of modern RAG systems.

![Embedding Models](../assets/Retrieval%20Augmented%20Generation/03-embedding-models/embeddings.png)


## What are Embeddings?

**Definition:** Numerical representations of data (text, images, etc.) in a continuous vector space where similar items are close together.

**Key characteristics:**
- Fixed-dimensional vectors (e.g., 384, 768, 1536 dimensions)
- Capture semantic meaning, not just keywords
- Enable mathematical operations (similarity, arithmetic)
- Language and domain-specific patterns

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
- **Google text-embedding**

Output: Dense vector

```
[0.123, -0.456, 0.789, ...]
```


[Embedding models](../01-Basics%20of%20Generative%20AI/12-embeddings-semantic-search.md)

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

## Choosing the Right Embedding Model

<table>
	<thead>
		<tr>
			<th>Considerations</th>
			<th>Dense Embeddings</th>
			<th>Sparse Embeddings</th>
			<th>Late Interaction Models</th>
		</tr>
	</thead>
	<tbody>
		<tr>
			<td><b>Accuracy</b></td>
			<td>Good</td>
			<td>Better for keyword matching</td>
			<td>Best for fine-grained semantics</td>
		</tr>
		<tr>
			<td><b>Storage</b></td>
			<td>Compact (1 vector/doc)</td>
			<td>Larger (sparse format)</td>
			<td>Largest (multiple vectors/doc)</td>
		</tr>
		<tr>
			<td><b>Inference Speed</b></td>
			<td>Fast</td>
			<td>Fast</td>
			<td>Slower</td>
		</tr>
		<tr>
			<td><b>Use Cases</b></td>
			<td>General RAG, semantic search</td>
			<td>Legal/medical, hybrid search</td>
			<td>High-accuracy retrieval, multimodal</td>
		</tr>
		<tr>
			<td><b>Complexity</b></td>
			<td>Simple</td>
			<td>Moderate</td>
			<td>Complex</td>
		</tr>
	</tbody>
</table>


---

*This is very cruicial for RAG systems. The choice of embedding model can significantly impact retrieval quality, latency, and storage requirements. In the next section, we'll explore about chunks and how to create them effectively for better retrieval performance.*

---

[← Previous: Vector search algorithms](02-vector-search-algorithms.md) | [Next: Chunks and chunking strategies →](04-chunking-strategies.md)

[← Back to Index](README.md)
