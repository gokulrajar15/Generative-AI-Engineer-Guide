# RAG Architectures

## Overview
RAG architectures vary based on use cases, scale, and complexity requirements. This chapter covers different architectural patterns for building production RAG systems.

---

## Basic RAG Architecture

### **Simple RAG Pipeline:**
```
Query → Embed → Vector Search → Retrieve Top-K → Generate Answer
```

**How it works:**
1. User asks a question
2. Convert question to vector embedding
3. Search vector database for similar chunks
4. Retrieve top matching documents
5. Feed documents to LLM to generate answer

**Pros:**
- Simple to implement
- Fast response times
- Easy to debug

**Cons:**
- Limited accuracy for complex queries
- No quality controls
- Single retrieval pass misses nuanced information

---

## Advanced RAG Architectures

### **1. Modular RAG**
Breaks RAG into independent, swappable components.

**Components:**
- Query processor (rewrites, expands queries)
- Retriever (fetches documents)
- Re-ranker (sorts by relevance)
- Generator (creates final answer)

**Benefits:**
- Easy to upgrade individual components
- Better quality control at each stage
- Testable modules
- Mix and match different retrieval strategies

**Use when:** Building production systems that need flexibility and maintainability.

---

### **2. Agentic RAG**
LLM acts as an agent that decides when and how to retrieve information.

**How it works:**
1. LLM analyzes the query
2. Decides if retrieval is needed
3. Formulates search queries
4. Retrieves documents
5. Analyzes results and decides if more retrieval is needed
6. Generates final answer

**Benefits:**
- Handles complex multi-step reasoning
- Self-corrects when information is insufficient
- Can call multiple tools (search, calculator, database)

**Use when:** Queries require multiple steps or external tool usage.

---

### **3. Multi-Stage RAG**
Performs retrieval in multiple passes to refine results.

**How it works:**
1. **Stage 1:** Initial broad retrieval (top 100 documents)
2. **Stage 2:** Re-rank to top 20
3. **Stage 3:** Extract precise passages
4. **Stage 4:** Generate answer with verified context

**Benefits:**
- Higher accuracy than single-pass
- Filters noise progressively
- Better handles ambiguous queries

**Use when:** Accuracy is critical and you can afford extra latency.

---

### **4. Corrective RAG (CRAG)**
Self-correcting RAG with built-in quality checks.

**How it works:**
1. Retrieve documents
2. **Evaluate relevance** (are these documents useful?)
3. If poor quality → trigger web search or alternative sources
4. If good quality → proceed to generation
5. Verify answer against sources

**Benefits:**
- Detects and fixes retrieval failures
- Falls back to alternative sources
- Higher reliability

**Use when:** You need reliable answers even when internal knowledge is incomplete.

---

### **5. GraphRAG**
Uses knowledge graphs to understand relationships between entities.

**How it works:**
1. Build knowledge graph from documents (entities + relationships)
2. Query traverses graph to find connected information
3. Retrieve subgraphs relevant to query
4. Generate answer from graph context

**Benefits:**
- Understands relationships (e.g., "Who worked with John at Microsoft?")
- Better for multi-hop reasoning
- Explainable retrieval paths

**Use when:** Your domain has rich entity relationships (legal, medical, corporate knowledge).

---

### **6. Hierarchical RAG**
Organizes documents in a multi-level structure (summaries → sections → chunks).

**How it works:**
1. **Level 1:** Search document summaries
2. **Level 2:** Narrow to relevant sections
3. **Level 3:** Retrieve specific chunks
4. Generate answer from precise context

**Benefits:**
- Faster for large document collections
- Provides document-level context
- Better handles long documents

**Use when:** Working with large structured documents (reports, manuals, books).

---

### **7. Routing RAG**
Routes queries to specialized retrievers based on intent.

**How it works:**
1. Classify query intent (technical doc, FAQ, code example, etc.)
2. Route to appropriate retriever:
   - Technical questions → API documentation retriever
   - Code questions → code snippet retriever
   - General questions → full-text search
3. Generate answer from specialized source

**Benefits:**
- Each retriever optimized for specific content type
- Higher precision
- Faster search in specialized indexes

**Use when:** You have diverse content types requiring different retrieval strategies.

---

### **8. Conversational RAG**
Maintains conversation history for multi-turn dialogues.

**How it works:**
1. Track conversation history
2. Rewrite current query using context from previous turns
3. Retrieve documents based on full conversation
4. Generate answer aware of conversation flow
5. Update conversation memory

**Benefits:**
- Handles follow-up questions ("What about Python instead?")
- Maintains context across turns
- More natural user experience

**Use when:** Building chatbots or assistants with ongoing conversations.

---

## Hybrid Architectures

### **Combining Multiple Approaches:**
Real-world systems often combine architectures for better results.

**Example: GraphRAG + Vector Search**
- Use vector search for broad initial retrieval
- Use knowledge graph to find related entities and relationships
- Combine both results for comprehensive context

**Example: Agentic + Multi-Stage**
- Agent decides retrieval strategy
- Each retrieval uses multi-stage refinement
- Best of both worlds: intelligent routing + high precision

**Key principle:** Layer architectures to get benefits of each approach.

---

## Choosing an Architecture

| Use Case | Recommended Architecture |
|----------|-------------------------|
| Simple Q&A | Basic RAG |
| High accuracy needed | Multi-Stage RAG |
| Chat/conversations | Conversational RAG |
| Complex reasoning | Agentic RAG |
| Structured data with relationships | GraphRAG |
| Production scale | Modular + Multi-Stage |
| Multiple document types | Routing RAG |
| Large document collections | Hierarchical RAG |
| Incomplete knowledge base | Corrective RAG (CRAG) |

---

## Best Practices

1. **Start simple**: Begin with basic RAG, add complexity only when needed. Most problems don't require advanced architectures.

2. **Modular design**: Separate retrieval, ranking, and generation. Makes debugging and upgrades easier.

3. **Monitor everything**: Track retrieval quality, latency, and user satisfaction at each stage.

4. **Cache aggressively**: Cache embeddings, retrieved documents, and even generated answers to reduce costs and latency.

5. **Fail gracefully**: Handle errors at each step. If retrieval fails, fallback to web search or a default response.

6. **Test thoroughly**: Unit test each component. Create test sets of queries with expected retrieved documents.

7. **Version control**: Track changes to prompts, chunking strategies, and system configurations.

8. **A/B test**: Compare architectures on real user queries, not just toy examples. Measure precision, recall, and user satisfaction.

*So far, we have covered the core components of RAG systems. Next, we will explore how graph databases can enhance RAG by providing structured knowledge representation and powerful traversal capabilities.*


[<- Previous: Evaluation Metrics](14-evaluation-metrics.md) | [Next: Graph Databases →](16-graph-databases.md)

[<- Back to Index](README.md)