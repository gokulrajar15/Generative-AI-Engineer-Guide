# Generation Strategies

## Overview
Generation is the final stage of RAG where the LLM produces an answer using retrieved context. The quality of generation depends on prompt engineering, context management, and various strategies to ensure accuracy and relevance.

---

## Basic RAG Generation

### **Simple Prompt Template:**

```python
def basic_rag_generation(query, context_documents, llm):
    # Combine context
    context = "\n\n".join([doc['text'] for doc in context_documents])
    
    # Create prompt
    prompt = f"""Answer the question based on the context below.

Context:
{context}

Question: {query}

Answer:"""
    
    # Generate
    response = llm.generate(prompt)
    return response
```

---

## Advanced Generation Strategies

### **1. Prompt Engineering for RAG**

#### **Structured Prompt Template:**

```python
SYSTEM_PROMPT = """You are a helpful AI assistant. Answer questions based ONLY on the provided context. 
If the context doesn't contain enough information to answer, say so.
Be concise and accurate."""

def structured_rag_prompt(query, context_documents):
    # Number and format contexts
    formatted_contexts = []
    for i, doc in enumerate(context_documents, 1):
        formatted_contexts.append(f"[{i}] {doc['text']}")
    
    context = "\n\n".join(formatted_contexts)
    
    user_prompt = f"""Context:
{context}

Question: {query}

Instructions:
1. Answer based only on the provided context
2. Cite sources using [number] notation
3. If information is insufficient, state that clearly

Answer:"""
    
    return SYSTEM_PROMPT, user_prompt
```

---

#### **With Chain of Thought:**

```python
def cot_rag_prompt(query, context):
    prompt = f"""Context:
{context}

Question: {query}

Let's approach this step by step:
1. First, identify the relevant information from the context
2. Then, reason through the question
3. Finally, provide a concise answer

Answer:"""
    return prompt
```

---

#### **With Instructions for Citations:**

```python
def citation_prompt(query, context_documents):
    # Add source IDs to documents
    contexts_with_sources = []
    for i, doc in enumerate(context_documents):
        source_id = doc.get('metadata', {}).get('source', f'doc_{i}')
        contexts_with_sources.append(
            f"[Source: {source_id}]\n{doc['text']}"
        )
    
    context = "\n\n".join(contexts_with_sources)
    
    prompt = f"""Answer the question using the context below. 
Always cite your sources using [Source: X] notation.

Context:
{context}

Question: {query}

Answer (with citations):"""
    
    return prompt
```

---

### **2. Context Windowing**

Handle context length limits effectively.

```python
def truncate_context(context_documents, max_tokens=3000, tokenizer=None):
    """Fit context within token limit"""
    selected_docs = []
    total_tokens = 0
    
    for doc in context_documents:
        # Count tokens
        doc_tokens = count_tokens(doc['text'], tokenizer)
        
        if total_tokens + doc_tokens <= max_tokens:
            selected_docs.append(doc)
            total_tokens += doc_tokens
        else:
            # Can't fit more docs
            break
    
    return selected_docs

def count_tokens(text, tokenizer):
    if tokenizer:
        return len(tokenizer.encode(text))
    else:
        # Rough estimate: 1 token ≈ 4 characters
        return len(text) // 4
```

---

### **3. Iterative RAG (Self-Refining)**

Generate, evaluate, and refine answer if needed.

```python
def iterative_rag(query, retriever, llm, max_iterations=2):
    # Initial retrieval
    context_docs = retriever.retrieve(query)
    
    for iteration in range(max_iterations):
        # Generate answer
        answer = generate_answer(query, context_docs, llm)
        
        # Self-evaluate
        is_sufficient = evaluate_answer(query, answer, llm)
        
        if is_sufficient:
            return answer
        else:
            # Generate follow-up query for more info
            follow_up = generate_follow_up_query(query, answer, llm)
            
            # Retrieve additional context
            additional_docs = retriever.retrieve(follow_up)
            context_docs.extend(additional_docs)
    
    # Final attempt
    return generate_answer(query, context_docs, llm)

def evaluate_answer(query, answer, llm):
    """Check if answer is complete"""
    eval_prompt = f"""Question: {query}
Answer: {answer}

Is this answer complete and directly addresses the question? 
Respond with YES or NO.

Evaluation:"""
    
    evaluation = llm.generate(eval_prompt)
    return "YES" in evaluation.upper()

def generate_follow_up_query(query, partial_answer, llm):
    """Generate query to fill gaps"""
    prompt = f"""Original question: {query}
Current answer: {partial_answer}

What additional information is needed? Generate a search query.

Query:"""
    
    return llm.generate(prompt)
```

---

### **4. FLARE (Forward-Looking Active Retrieval)**

Retrieve only when needed during generation.

```python
def flare_generation(query, retriever, llm):
    """Generate while actively retrieving when uncertain"""
    
    # Start generation
    generated_text = ""
    current_context = ""
    
    while True:
        # Generate next sentence
        prompt = f"""Context: {current_context}

Question: {query}

Generated so far: {generated_text}

Continue generating (one sentence):"""
        
        next_sentence = llm.generate(prompt, max_tokens=50)
        
        # Check confidence (simplified: check for uncertainty markers)
        if has_uncertainty(next_sentence):
            # Retrieve more context
            new_docs = retriever.retrieve(next_sentence)
            current_context += "\n" + format_docs(new_docs)
            continue
        
        generated_text += " " + next_sentence
        
        # Check if complete
        if is_complete_answer(generated_text, query):
            break
    
    return generated_text

def has_uncertainty(text):
    """Check for uncertainty indicators"""
    uncertainty_markers = [
        "unclear", "unsure", "don't know", "cannot determine",
        "insufficient information", "not specified"
    ]
    return any(marker in text.lower() for marker in uncertainty_markers)
```

---

### **5. Fusion (Generate from Multiple Perspectives)**

Retrieve and generate multiple answers, then fuse.

```python
def fusion_generation(query, retriever, llm):
    # Generate query variations
    query_variations = generate_variations(query)
    
    # Retrieve for each variation
    all_answers = []
    for q in query_variations:
        docs = retriever.retrieve(q)
        answer = generate_answer(q, docs, llm)
        all_answers.append(answer)
    
    # Fuse answers
    fusion_prompt = f"""Given these different answers to the question "{query}":

{format_answers(all_answers)}

Synthesize a comprehensive final answer:"""
    
    final_answer = llm.generate(fusion_prompt)
    return final_answer
```

---

### **6. Constrained Generation**

Ensure outputs follow specific formats.

```python
def constrained_generation(query, context, llm, output_format="json"):
    if output_format == "json":
        prompt = f"""Context: {context}

Question: {query}

Provide your answer in the following JSON format:
{{
  "answer": "your detailed answer here",
  "confidence": "high/medium/low",
  "sources": ["source1", "source2"]
}}

Response:"""
    
    elif output_format == "bullets":
        prompt = f"""Context: {context}

Question: {query}

Provide your answer as a bulleted list of key points:

Answer:"""
    
    response = llm.generate(prompt)
    return response
```

---

### **7. Fact-Checking During Generation**

Verify facts before including in answer.

```python
def fact_checked_generation(query, context, llm):
    # Generate initial answer
    initial_prompt = f"""Based on this context:
{context}

Answer this question: {query}

Answer:"""
    
    answer = llm.generate(initial_prompt)
    
    # Extract claims from answer
    claims = extract_claims(answer, llm)
    
    # Verify each claim
    verified_claims = []
    for claim in claims:
        is_supported = verify_claim(claim, context, llm)
        if is_supported:
            verified_claims.append(claim)
    
    # Regenerate with only verified claims
    verified_answer = reconstruct_answer(verified_claims, query, llm)
    return verified_answer

def verify_claim(claim, context, llm):
    """Check if claim is supported by context"""
    verification_prompt = f"""Context:
{context}

Claim: {claim}

Is this claim supported by the context? Answer YES or NO.

Verification:"""
    
    result = llm.generate(verification_prompt)
    return "YES" in result.upper()
```

---

## Handling Edge Cases

### **1. No Relevant Context Found**

```python
def generate_with_fallback(query, context_documents, llm):
    if not context_documents or all(doc['score'] < 0.5 for doc in context_documents):
        # Low relevance fallback
        return "I don't have enough relevant information to answer this question accurately."
    
    # Normal generation
    return generate_answer(query, context_documents, llm)
```

---

### **2. Contradictory Information**

```python
def handle_contradictions(query, context, llm):
    prompt = f"""The context below may contain contradictory information.

Context:
{context}

Question: {query}

Instructions:
1. Identify any contradictions
2. Explain the different viewpoints
3. Provide the most well-supported answer

Answer:"""
    
    return llm.generate(prompt)
```

---

### **3. Multi-Hop Questions**

```python
def multi_hop_generation(query, retriever, llm):
    """Handle questions requiring multiple reasoning steps"""
    
    # Decompose question
    sub_questions = decompose_question(query, llm)
    
    # Answer each sub-question
    sub_answers = []
    for sq in sub_questions:
        docs = retriever.retrieve(sq)
        answer = generate_answer(sq, docs, llm)
        sub_answers.append({'question': sq, 'answer': answer})
    
    # Synthesize final answer
    synthesis_prompt = f"""Original question: {query}

Sub-questions and answers:
{format_sub_answers(sub_answers)}

Synthesize a comprehensive answer to the original question:"""
    
    final_answer = llm.generate(synthesis_prompt)
    return final_answer, sub_answers
```

---

## Streaming Responses

```python
async def streaming_rag_generation(query, context, llm):
    """Generate answer with streaming"""
    prompt = create_prompt(query, context)
    
    full_response = ""
    async for chunk in llm.stream(prompt):
        full_response += chunk
        yield chunk  # Stream to user
    
    return full_response
```

---

## Best Practices

### **1. Clear Instructions**
- Specify answer format
- Request citations
- Set boundaries (only use context)

### **2. Context Quality**
- Rerank before generation
- Remove duplicates
- Filter low-relevance docs

### **3. Prompt Structure**
```python
PROMPT_TEMPLATE = """System: {system_instructions}

Context:
{context}

Question: {query}

Requirements:
- {requirements}

Answer:"""
```

### **4. Temperature Settings**
- **Factual answers**: Temperature 0-0.3
- **Creative responses**: Temperature 0.7-1.0
- **RAG default**: 0.1-0.2 (more deterministic)

### **5. Output Validation**
```python
def validate_output(answer, context):
    """Ensure answer is grounded in context"""
    checks = {
        'non_empty': len(answer.strip()) > 0,
        'no_hallucination': check_grounding(answer, context),
        'answers_question': check_relevance(answer, query)
    }
    return all(checks.values())
```

---

## Evaluation

```python
def evaluate_generation(query, answer, context, ground_truth):
    """Measure generation quality"""
    metrics = {
        'faithfulness': check_faithfulness(answer, context),
        'answer_relevancy': check_relevancy(answer, query),
        'correctness': compare_to_ground_truth(answer, ground_truth)
    }
    return metrics
```

---

## Common Pitfalls

1. **Hallucination**: LLM adds info not in context
2. **Context overflow**: Exceeding token limits
3. **Ignoring context**: Model relies on training data
4. **Poor citations**: Not referencing sources
5. **Inconsistent format**: Variable output structure

---

## Next Steps
- Implement structured prompts for your use case
- Experiment with different generation strategies
- Add citation and fact-checking
- Measure generation quality
- Optimize for your specific domain
