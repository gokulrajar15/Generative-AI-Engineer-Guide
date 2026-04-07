# Chunking Strategies

## Overview
Chunking is the process of breaking down large documents into smaller, manageable pieces for indexing and retrieval in RAG systems. Proper chunking is critical for retrieval quality.

---

## Why Chunking Matters

**Challenges with long documents:**
- Embedding models have token limits (512, 8K, etc.)
- Large chunks dilute semantic meaning
- Small chunks lose context
- Affects retrieval accuracy and generation quality

**Goals:**
- Preserve semantic coherence
- Fit within model constraints
- Optimize for retrieval relevance
- Balance context and specificity

[Learn more about chunking](https://weaviate.io/blog/chunking-strategies-for-rag#what-is-chunking)

---

## Key Chunking Parameters

### 1. **Chunk Size**
- Number of characters or tokens per chunk
- Typical ranges: 200-1000 tokens
- Depends on use case and model

### 2. **Chunk Overlap**
- Number of tokens shared between consecutive chunks
- Typical: 10-20% of chunk size
- Prevents losing context at boundaries

### 3. **Metadata**
- Document ID, section headers, page numbers
- Helps with context and citation
- Used for filtering and routing

---

## Common Chunking Strategies

### 1. **Fixed-Size Chunking**

**Method:** Split text into equal-sized chunks.

```python
def fixed_size_chunking(text, chunk_size=500, overlap=50):
    chunks = []
    start = 0
    while start < len(text):
        end = start + chunk_size
        chunks.append(text[start:end])
        start += chunk_size - overlap
    return chunks
```

**Pros:**
- Simple to implement
- Predictable chunk count
- Consistent processing

**Cons:**
- May split sentences/paragraphs
- Ignores document structure
- Can lose semantic coherence

**Use case:** Quick prototyping, unstructured text

---

### 2. **Sentence-Based Chunking**

**Method:** Combine sentences until reaching target size.

```python
import nltk
nltk.download('punkt')

def sentence_chunking(text, max_chunk_size=500):
    sentences = nltk.sent_tokenize(text)
    chunks = []
    current_chunk = ""
    
    for sentence in sentences:
        if len(current_chunk) + len(sentence) <= max_chunk_size:
            current_chunk += " " + sentence
        else:
            chunks.append(current_chunk.strip())
            current_chunk = sentence
    
    if current_chunk:
        chunks.append(current_chunk.strip())
    
    return chunks
```

**Pros:**
- Preserves sentence boundaries
- More semantic coherence
- Natural language units

**Cons:**
- Variable chunk sizes
- Doesn't consider paragraph structure
- May still split related content

**Use case:** General text, articles, documentation

---

### 3. **Paragraph-Based Chunking**

**Method:** Use paragraphs as natural boundaries.

```python
def paragraph_chunking(text, max_chunk_size=1000):
    paragraphs = text.split('\n\n')
    chunks = []
    current_chunk = ""
    
    for para in paragraphs:
        if len(current_chunk) + len(para) <= max_chunk_size:
            current_chunk += "\n\n" + para
        else:
            if current_chunk:
                chunks.append(current_chunk.strip())
            current_chunk = para
    
    if current_chunk:
        chunks.append(current_chunk.strip())
    
    return chunks
```

**Pros:**
- Respects document structure
- Strong semantic coherence
- User-friendly chunks

**Cons:**
- Highly variable sizes
- Long paragraphs may exceed limits
- Requires paragraph markers

**Use case:** Blog posts, reports, books

---

### 4. **Recursive Chunking**

**Method:** Split by multiple separators in order of preference.

```python
def recursive_chunking(text, chunk_size=500, separators=["\n\n", "\n", ". ", " "]):
    if len(text) <= chunk_size:
        return [text]
    
    for separator in separators:
        if separator in text:
            splits = text.split(separator)
            chunks = []
            current_chunk = ""
            
            for split in splits:
                if len(current_chunk) + len(split) <= chunk_size:
                    current_chunk += split + separator
                else:
                    if current_chunk:
                        chunks.append(current_chunk.strip())
                    current_chunk = split + separator
            
            if current_chunk:
                chunks.append(current_chunk.strip())
            
            return chunks
    
    return [text]
```

**Pros:**
- Flexible and adaptive
- Tries to preserve structure
- Good default strategy

**Cons:**
- More complex logic
- May still split inappropriately
- Requires tuning separator order

**Use case:** General purpose, mixed content

---

### 5. **Semantic Chunking**

**Method:** Group sentences based on semantic similarity.

```python
from sentence_transformers import SentenceTransformer
import numpy as np

model = SentenceTransformer('all-MiniLM-L6-v2')

def semantic_chunking(text, similarity_threshold=0.7):
    sentences = nltk.sent_tokenize(text)
    embeddings = model.encode(sentences)
    
    chunks = []
    current_chunk = [sentences[0]]
    
    for i in range(1, len(sentences)):
        similarity = cosine_similarity(
            embeddings[i-1].reshape(1, -1),
            embeddings[i].reshape(1, -1)
        )[0][0]
        
        if similarity > similarity_threshold:
            current_chunk.append(sentences[i])
        else:
            chunks.append(" ".join(current_chunk))
            current_chunk = [sentences[i]]
    
    if current_chunk:
        chunks.append(" ".join(current_chunk))
    
    return chunks
```

**Pros:**
- Highest semantic coherence
- Adapts to content
- Better retrieval quality

**Cons:**
- Computationally expensive
- Requires embedding model
- Variable chunk sizes

**Use case:** High-quality RAG, critical applications

---

### 6. **Document Structure-Based Chunking**

**Method:** Use document structure (headers, sections, etc.).

```python
def structure_based_chunking(markdown_text):
    chunks = []
    current_section = ""
    current_header = ""
    
    for line in markdown_text.split('\n'):
        if line.startswith('#'):
            if current_section:
                chunks.append({
                    'header': current_header,
                    'content': current_section.strip()
                })
            current_header = line
            current_section = line + '\n'
        else:
            current_section += line + '\n'
    
    if current_section:
        chunks.append({
            'header': current_header,
            'content': current_section.strip()
        })
    
    return chunks
```

**Pros:**
- Preserves logical structure
- Includes context (headers)
- Natural for structured documents

**Cons:**
- Requires structured documents
- Variable sizes
- May need further splitting

**Use case:** Documentation, technical manuals, wikis

---

### 7. **Agentic/Proposition-Based Chunking**

**Method:** Use LLM to extract atomic facts/propositions.

```python
from openai import OpenAI

client = OpenAI()

def proposition_chunking(text):
    response = client.chat.completions.create(
        model="gpt-4",
        messages=[{
            "role": "system",
            "content": "Extract atomic, self-contained propositions from the text. Each proposition should be independently understandable."
        }, {
            "role": "user",
            "content": text
        }]
    )
    
    propositions = response.choices[0].message.content.split('\n')
    return [p.strip() for p in propositions if p.strip()]
```

**Pros:**
- Highly precise retrieval
- Self-contained facts
- Best for Q&A

**Cons:**
- Expensive (LLM calls)
- Slow processing
- Loses narrative flow

**Use case:** Knowledge bases, fact-based Q&A

---

## Context Window Considerations

### **Sliding Window Chunking**

Add surrounding context to each chunk:

```python
def sliding_window_chunking(text, chunk_size=500, window_size=100):
    chunks = []
    start = 0
    
    while start < len(text):
        # Add context from before
        context_start = max(0, start - window_size)
        # Add context from after
        context_end = min(len(text), start + chunk_size + window_size)
        
        chunk = text[context_start:context_end]
        chunks.append({
            'content': chunk,
            'main_start': start - context_start,
            'main_end': start - context_start + chunk_size
        })
        
        start += chunk_size
    
    return chunks
```

**Benefits:**
- Preserves context across boundaries
- Better for generation
- Reduces information loss

---

## Best Practices

### 1. **Start with defaults, then optimize:**
   - Begin with 500-1000 token chunks
   - 10-20% overlap
   - Test and iterate

### 2. **Consider your use case:**
   - Q&A: Smaller, precise chunks (200-400)
   - Summarization: Larger chunks (800-1200)
   - Chat: Medium chunks (400-800)

### 3. **Metadata is crucial:**
   ```python
   chunk = {
       'content': chunk_text,
       'metadata': {
           'document_id': doc_id,
           'chunk_index': i,
           'section': section_name,
           'page': page_num,
           'chunk_type': 'paragraph'
       }
   }
   ```

### 4. **Preserve critical information:**
   - Include headers in chunks
   - Add document title
   - Keep table/figure captions

### 5. **Test different strategies:**
   - Evaluate retrieval quality
   - Measure end-to-end performance
   - A/B test with users

### 6. **Document-specific approaches:**
   - Code: Function/class boundaries
   - Tables: Keep rows together
   - Lists: Keep items grouped
   - Conversations: Keep exchanges together

---

## Tools and Libraries

### **LangChain TextSplitters:**
```python
from langchain.text_splitter import (
    RecursiveCharacterTextSplitter,
    CharacterTextSplitter,
    TokenTextSplitter
)

splitter = RecursiveCharacterTextSplitter(
    chunk_size=1000,
    chunk_overlap=200,
    separators=["\n\n", "\n", ". ", " ", ""]
)

chunks = splitter.split_text(text)
```

### **LlamaIndex Node Parsers:**
```python
from llama_index.node_parser import SimpleNodeParser

parser = SimpleNodeParser.from_defaults(
    chunk_size=1024,
    chunk_overlap=20
)

nodes = parser.get_nodes_from_documents(documents)
```

---

## Evaluation Metrics

- **Chunk coherence**: Do chunks make sense?
- **Retrieval accuracy**: Are relevant chunks retrieved?
- **Generation quality**: Do retrieved chunks help generation?
- **Coverage**: Is critical information preserved?

---

## Next Steps
- Experiment with different strategies on your data
- Measure impact on retrieval quality
- Implement hybrid chunking for different document types
- Learn about advanced RAG architectures
