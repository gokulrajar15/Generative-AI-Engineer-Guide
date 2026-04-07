# RAG Architectures

## Overview
RAG architectures vary based on use cases, scale, and complexity requirements. This chapter covers different architectural patterns for building production RAG systems.

---

## Basic RAG Architecture

### **Simple RAG Pipeline:**

```
Query → Embed → Vector Search → Retrieve Top-K → Generate Answer
```

```python
class BasicRAG:
    def __init__(self, vector_db, embedding_model, llm):
        self.vector_db = vector_db
        self.embed_model = embedding_model
        self.llm = llm
    
    def query(self, question):
        # 1. Embed query
        query_embedding = self.embed_model.encode(question)
        
        # 2. Search
        results = self.vector_db.search(query_embedding, top_k=5)
        
        # 3. Format context
        context = "\n\n".join([r['text'] for r in results])
        
        # 4. Generate
        prompt = f"Context: {context}\n\nQuestion: {question}\n\nAnswer:"
        answer = self.llm.generate(prompt)
        
        return answer
```

**Pros:**
- Simple to implement
- Fast
- Easy to debug

**Cons:**
- Limited accuracy
- No quality controls
- Single retrieval pass

---

## Advanced RAG Architectures

### **1. Modular RAG**

Separate components for flexibility.

```python
class ModularRAG:
    def __init__(self):
        self.indexing = IndexingModule()
        self.retrieval = RetrievalModule()
        self.reranking = RerankingModule()
        self.generation = GenerationModule()
        self.evaluation = EvaluationModule()
    
    def query(self, question):
        # Retrieve candidates
        candidates = self.retrieval.retrieve(question, top_k=20)
        
        # Rerank
        reranked = self.reranking.rerank(question, candidates, top_k=5)
        
        # Generate
        answer = self.generation.generate(question, reranked)
        
        # Evaluate
        quality_score = self.evaluation.evaluate(question, answer, reranked)
        
        return {
            'answer': answer,
            'sources': reranked,
            'quality_score': quality_score
        }
```

**Benefits:**
- Easy to upgrade individual components
- Better quality control
- Testable modules

---

### **2. Agentic RAG**

LLM decides when and how to retrieve.

```python
class AgenticRAG:
    def __init__(self, retriever, llm):
        self.retriever = retriever
        self.llm = llm
        self.conversation_history = []
    
    def query(self, question):
        # Let LLM decide if retrieval is needed
        decision = self.should_retrieve(question)
        
        if decision['needs_retrieval']:
            # LLM generates search queries
            search_queries = self.llm.generate_search_queries(question)
            
            # Retrieve for each query
            all_docs = []
            for sq in search_queries:
                docs = self.retriever.retrieve(sq)
                all_docs.extend(docs)
            
            # Deduplicate
            unique_docs = self.deduplicate(all_docs)
            
            # Generate with retrieved context
            answer = self.llm.generate_with_context(question, unique_docs)
        else:
            # Answer from knowledge
            answer = self.llm.generate(question)
        
        self.conversation_history.append({
            'question': question,
            'answer': answer,
            'retrieved': decision['needs_retrieval']
        })
        
        return answer
    
    def should_retrieve(self, question):
        """LLM decides if retrieval is needed"""
        prompt = f"""Question: {question}

Should we retrieve external information to answer this question?
Consider:
- Is this factual information that might be in documents?
- Or is this a general knowledge/reasoning question?

Answer YES or NO and explain briefly.

Decision:"""
        
        response = self.llm.generate(prompt)
        needs_retrieval = "YES" in response.upper()
        
        return {
            'needs_retrieval': needs_retrieval,
            'reasoning': response
        }
```

---

### **3. Multi-Stage RAG**

Multiple retrieval and refinement stages.

```python
class MultiStageRAG:
    def query(self, question):
        # Stage 1: Broad retrieval
        broad_results = self.retriever.retrieve(question, top_k=50)
        
        # Stage 2: Rerank
        reranked = self.reranker.rerank(question, broad_results, top_k=20)
        
        # Stage 3: Generate initial answer
        initial_answer = self.llm.generate(question, reranked[:5])
        
        # Stage 4: Validate and refine
        issues = self.validator.check(initial_answer, question)
        
        if issues:
            # Stage 5: Retrieve additional context
            additional_context = self.retriever.retrieve(
                self.generate_clarifying_query(question, issues),
                top_k=10
            )
            
            # Stage 6: Regenerate with full context
            all_context = reranked[:5] + additional_context
            final_answer = self.llm.generate(question, all_context)
        else:
            final_answer = initial_answer
        
        return final_answer
```

---

### **4. Corrective RAG (CRAG)**

Self-correcting RAG with quality checks.

```python
class CorrectiveRAG:
    def query(self, question):
        # Retrieve
        docs = self.retrieve(question)
        
        # Grade relevance
        relevant_docs = []
        irrelevant_docs = []
        
        for doc in docs:
            grade = self.grade_relevance(question, doc)
            
            if grade == 'relevant':
                relevant_docs.append(doc)
            elif grade == 'irrelevant':
                irrelevant_docs.append(doc)
            # else: 'unclear' → might refine
        
        # If all irrelevant, use web search
        if not relevant_docs:
            web_results = self.web_search(question)
            relevant_docs = web_results
        
        # Generate answer
        answer = self.generate(question, relevant_docs)
        
        # Hallucination check
        if self.has_hallucinations(answer, relevant_docs):
            # Regenerate with stricter prompt
            answer = self.generate_strict(question, relevant_docs)
        
        return answer
    
    def grade_relevance(self, question, document):
        """LLM grades document relevance"""
        prompt = f"""Question: {question}

Document: {document}

Is this document relevant to answering the question?
Answer: relevant / irrelevant / unclear

Grade:"""
        
        response = self.llm.generate(prompt).lower()
        
        if 'relevant' in response and 'irrelevant' not in response:
            return 'relevant'
        elif 'irrelevant' in response:
            return 'irrelevant'
        else:
            return 'unclear'
```

---

### **5. GraphRAG**

Use knowledge graphs for structured retrieval.

```python
class GraphRAG:
    def __init__(self, graph_db, vector_db, llm):
        self.graph = graph_db
        self.vector_db = vector_db
        self.llm = llm
    
    def query(self, question):
        # 1. Entity extraction
        entities = self.extract_entities(question)
        
        # 2. Graph retrieval (traverse relationships)
        graph_context = []
        for entity in entities:
            # Get related entities and relationships
            subgraph = self.graph.get_subgraph(entity, depth=2)
            graph_context.append(subgraph)
        
        # 3. Vector retrieval
        vector_context = self.vector_db.search(question, top_k=5)
        
        # 4. Combine contexts
        combined_context = self.merge_contexts(graph_context, vector_context)
        
        # 5. Generate
        answer = self.llm.generate(question, combined_context)
        
        return answer
    
    def extract_entities(self, text):
        """Extract named entities from question"""
        prompt = f"""Extract key entities from this question:
        
Question: {text}

Entities:"""
        
        response = self.llm.generate(prompt)
        return response.strip().split(',')
```

---

### **6. Hierarchical RAG**

Multi-level document structure.

```python
class HierarchicalRAG:
    def __init__(self):
        # Index at multiple levels
        self.document_index = DocumentLevelIndex()
        self.section_index = SectionLevelIndex()
        self.chunk_index = ChunkLevelIndex()
    
    def query(self, question):
        # Level 1: Find relevant documents
        relevant_docs = self.document_index.search(question, top_k=3)
        
        # Level 2: Within those documents, find relevant sections
        relevant_sections = []
        for doc in relevant_docs:
            sections = self.section_index.search_within_document(
                question, doc['id'], top_k=5
            )
            relevant_sections.extend(sections)
        
        # Level 3: Within sections, find specific chunks
        relevant_chunks = []
        for section in relevant_sections:
            chunks = self.chunk_index.search_within_section(
                question, section['id'], top_k=3
            )
            relevant_chunks.extend(chunks)
        
        # Generate with chunk-level context
        answer = self.llm.generate(question, relevant_chunks)
        
        return answer
```

---

### **7. Routing RAG**

Route queries to specialized retrievers.

```python
class RoutingRAG:
    def __init__(self):
        self.routers = {
            'technical': TechnicalRetriever(),
            'general': GeneralRetriever(),
            'recent': RecentDocsRetriever(),
            'historical': HistoricalRetriever()
        }
        self.classifier = QueryClassifier()
    
    def query(self, question):
        # Classify query
        query_type = self.classifier.classify(question)
        
        # Route to appropriate retriever
        retriever = self.routers.get(query_type, self.routers['general'])
        
        # Retrieve and generate
        docs = retriever.retrieve(question)
        answer = self.llm.generate(question, docs)
        
        return {
            'answer': answer,
            'query_type': query_type,
            'retriever_used': query_type
        }
```

---

### **8. Conversational RAG**

Multi-turn conversations with memory.

```python
class ConversationalRAG:
    def __init__(self, retriever, llm):
        self.retriever = retriever
        self.llm = llm
        self.conversation_history = []
    
    def query(self, question):
        # Rewrite query with conversation context
        if self.conversation_history:
            standalone_question = self.rewrite_with_history(
                question,
                self.conversation_history
            )
        else:
            standalone_question = question
        
        # Retrieve with standalone question
        docs = self.retriever.retrieve(standalone_question)
        
        # Generate with both history and retrieved docs
        answer = self.generate_conversational(
            question,
            docs,
            self.conversation_history
        )
        
        # Update history
        self.conversation_history.append({
            'human': question,
            'ai': answer
        })
        
        # Keep last N turns
        if len(self.conversation_history) > 5:
            self.conversation_history = self.conversation_history[-5:]
        
        return answer
    
    def rewrite_with_history(self, question, history):
        """Convert follow-up to standalone question"""
        history_text = "\n".join([
            f"Human: {turn['human']}\nAI: {turn['ai']}"
            for turn in history[-3:]  # Last 3 turns
        ])
        
        prompt = f"""Given the conversation history, rewrite the follow-up question to be standalone.

Conversation history:
{history_text}

Follow-up question: {question}

Standalone question:"""
        
        standalone = self.llm.generate(prompt)
        return standalone
```

---

## Hybrid Architectures

### **Combining Multiple Approaches:**

```python
class HybridRAG:
    def __init__(self):
        self.vector_retriever = VectorRetriever()
        self.keyword_retriever = KeywordRetriever()
        self.graph_retriever = GraphRetriever()
        self.reranker = Reranker()
    
    def query(self, question):
        # Parallel retrieval from multiple sources
        vector_results = self.vector_retriever.retrieve(question, k=20)
        keyword_results = self.keyword_retriever.retrieve(question, k=20)
        graph_results = self.graph_retriever.retrieve(question, k=10)
        
        # Merge and deduplicate
        all_results = self.merge_results([
            vector_results,
            keyword_results,
            graph_results
        ])
        
        # Rerank combined results
        final_results = self.reranker.rerank(question, all_results, top_k=5)
        
        # Generate
        answer = self.llm.generate(question, final_results)
        
        return answer
```

---

## Production Architecture

```python
class ProductionRAG:
    def __init__(self):
         self.cache = RedisCache()
        self.retriever = Retriever()
        self.reranker = Reranker()
        self.llm = LLM()
        self.monitor = Monitor()
        self.rate_limiter = RateLimiter()
    
    async def query(self, question, user_id):
        # Rate limiting
        await self.rate_limiter.check(user_id)
        
        # Check cache
        cache_key = self.get_cache_key(question)
        cached = await self.cache.get(cache_key)
        
        if cached:
            self.monitor.log('cache_hit')
            return cached
        
        # Start monitoring
        with self.monitor.track_query():
            try:
                # Retrieve
                docs = await self.retriever.retrieve(question)
                
                # Rerank
                reranked = await self.reranker.rerank(question, docs)
                
                # Generate
                answer = await self.llm.generate(question, reranked)
                
                # Validate
                if not self.validate_answer(answer):
                    raise ValueError("Invalid answer generated")
                
                # Cache result
                await self.cache.set(cache_key, answer, ttl=3600)
                
                return answer
                
            except Exception as e:
                self.monitor.log_error(e)
                raise
```

---

## Choosing an Architecture

| Use Case | Recommended Architecture |
|----------|-------------------------|
| Simple Q&A | Basic RAG |
| High accuracy | Multi-Stage RAG |
| Conversations | Conversational RAG |
| Complex reasoning | Agentic RAG |
| Structured data | GraphRAG |
| Production scale | Modular + Production patterns |
| Domain-specific | Routing RAG |
| Multi-document | Hierarchical RAG |

---

## Best Practices

1. **Start simple**: Begin with basic RAG, add complexity as needed
2. **Modular design**: Separate concerns for flexibility
3. **Monitor everything**: Track metrics at each stage
4. **Cache aggressively**: Reduce latency and costs
5. **Fail gracefully**: Handle errors at each step
6. **Test thoroughly**: Unit test each component
7. **Version control**: Track changes to prompts and configs
8. **A/B test**: Compare architectures on your data

---

## Next Steps
- Implement basic RAG first
- Add components based on your needs
- Benchmark different architectures
- Optimize for your specific use case
- Build monitoring and observability
