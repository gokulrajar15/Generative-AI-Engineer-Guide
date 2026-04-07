# Generation Strategies

## Overview
Generation is the final stage of RAG where the LLM produces an answer using retrieved context. The quality of generation depends on prompt engineering, context management, and various strategies to ensure accuracy and relevance.

---

## Key Generation Strategies

### 1. **Simple RAG**
Retrive relevant documents, concatenate them, and feed to LLM.

**Pros:**
- Simple to implement
- Works well for straightforward queries
**Cons:**
- May produce generic answers
- Context may be too long or noisy


### 2. **Generating with citations**
Include source references in the generated answer.

**Pros:**
- Increases trust and transparency
- Allows users to verify information
**Cons:**
- More complex prompt engineering
- May require additional formatting
- Can be verbose

### 3. **Generating with UI protocols**
which is user interface protocols that guide the generation process, such as structured output formats (JSON, XML) or specific response templates.

**Pros:**
- Ensures consistent output
- Easier to parse and use downstream
**Cons:**
- Requires careful prompt design
- May limit creativity of the model
- Can be rigid for complex queries


