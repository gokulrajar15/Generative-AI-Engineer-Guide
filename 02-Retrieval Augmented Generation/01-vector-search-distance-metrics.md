# Vector Search and Distance Metrics

Vector search enables finding similar items by representing data as numerical vectors in high-dimensional space. This is fundamental to RAG systems for retrieving relevant documents.

![Vector Search](../assets/Retrieval%20Augmented%20Generation/01-vector-search-distance-metrics/vector_search.png)

I would suggest you to visualize the vector space, how beautiful it is before entering into the technical details. It will help you to understand the concepts better.

[High-dimensional vector space](https://anvaka.github.io/pm/#/galaxy/word2vec-wiki?cx=-5825&cy=4632&cz=-3912&lx=-0.6654&ly=-0.6405&lz=0.0845&lw=0.3740&ml=300&s=1.75&l=1&v=d50_clean_small). Check out this interactive visualization of word embeddings!

---

## Vector Search

Vector search is a technique used to find similar items in a dataset by representing them as vectors in a high-dimensional space. This approach is particularly useful in RAG systems for retrieving relevant documents based on semantic similarity.

**Key Concepts:**
- Embedding vectors represent text, images, or other data
- Similarity is computed using distance metrics
- Efficient indexing enables fast search at scale

[Learn more about vector search](https://weaviate.io/blog/vector-search-explained)


## Distance Metrics

Distance metrics quantify how similar or different two vectors are. Choosing the right metric is crucial for retrieval quality.

### Common Distance Metrics:

#### 1. **Cosine Similarity**
- Measures the angle between two vectors
- Range: -1 to 1 (higher is more similar)
- Best for: Text embeddings, normalized vectors
- Ignores magnitude, focuses on direction

#### 2. **Euclidean Distance**
- Measures straight-line distance between points
- Range: 0 to ∞ (lower is more similar)
- Best for: When magnitude matters
- Most intuitive geometric distance

#### 3. **Manhattan Distance**
- Sum of absolute differences along each dimension
- Range: 0 to ∞ (lower is more similar)
- Best for: Grid-like spaces, certain optimization problems
- Also called L1 distance or taxicab distance

#### 4. **Dot Product**
- Simple multiplication and summation
- Fast to compute
- Used in some embedding models

---

## Choosing a Distance Metric

The choice of distance metric depends on:
- **Embedding model**: Some models are optimized for specific metrics
- **Data characteristics**: Normalized vs. unnormalized vectors
- **Use case**: Semantic search, image similarity, recommendation
- **Performance**: Some metrics compute faster than others

[Learn more about distance metrics](https://weaviate.io/blog/distance-metrics-in-vector-search#how-to-choose-a-distance-metric)

---

## Practical Considerations

- **Normalization**: Cosine similarity requires normalized vectors
- **Dimensionality**: Higher dimensions can lead to the "curse of dimensionality"
- **Indexing**: Different metrics may benefit from different indexing strategies
- **Performance**: Consider computation cost vs. accuracy trade-offs

---

## Hands-On Practice

**Exercise 1**: Compare different distance metrics
```python
import numpy as np
from numpy.linalg import norm

def cosine_similarity(a, b):
    return np.dot(a, b) / (norm(a) * norm(b))

def euclidean_distance(a, b):
    return norm(a - b)

def manhattan_distance(a, b):
    return np.sum(np.abs(a - b))

# Test with sample vectors
vec1 = np.array([1, 2, 3])
vec2 = np.array([4, 5, 6])

print(f"Cosine Similarity: {cosine_similarity(vec1, vec2)}")
print(f"Euclidean Distance: {euclidean_distance(vec1, vec2)}")
print(f"Manhattan Distance: {manhattan_distance(vec1, vec2)}")
```

**Exercise 2**: Implement a simple vector search
```python
# Find the most similar document to a query
def find_similar(query_vector, document_vectors, k=5):
    similarities = [cosine_similarity(query_vector, doc) 
                   for doc in document_vectors]
    top_k_indices = np.argsort(similarities)[-k:][::-1]
    return top_k_indices
```

---

*Hope you get a good grasp of vector search and distance metrics! These concepts are fundamental for building effective RAG systems. In the next section, we'll explore different vector search algorithms.*

**Next**: [Vector search algorithms →](02-vector-search-algorithms.md)

[← Back to Index](README.md)
