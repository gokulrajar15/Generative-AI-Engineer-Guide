# Evaluation Metrics in RAG

## Overview
Evaluating RAG systems is crucial for measuring quality, identifying weaknesses, and tracking improvements. This chapter covers metrics for both retrieval and generation components.

---

## Why Evaluate RAG?

**Challenges:**
- Multiple components (retrieval + generation)
- No single metric captures everything
- Ground truth often unavailable
- Context affects generation quality

**Goals:**
- Measure retrieval relevance
- Assess answer quality
- Detect hallucinations
- Track system performance

---

## Retrieval Metrics

### **1. Precision@K**

Fraction of retrieved documents that are relevant.

```python
def precision_at_k(retrieved_docs, relevant_docs, k=5):
    """
    retrieved_docs: List of retrieved document IDs (top k)
    relevant_docs: Set of relevant document IDs
    """
    retrieved_k = set(retrieved_docs[:k])
    relevant_retrieved = retrieved_k.intersection(relevant_docs)
    
    return len(relevant_retrieved) / k

# Example
retrieved = ['doc1', 'doc2', 'doc3', 'doc4', 'doc5']
relevant = {'doc1', 'doc3', 'doc7'}

precision = precision_at_k(retrieved, relevant, k=5)
print(f"Precision@5: {precision}")  # 2/5 = 0.4
```

---

### **2. Recall@K**

Fraction of relevant documents that were retrieved.

```python
def recall_at_k(retrieved_docs, relevant_docs, k=5):
    """Measure coverage of relevant documents"""
    retrieved_k = set(retrieved_docs[:k])
    relevant_retrieved = retrieved_k.intersection(relevant_docs)
    
    if len(relevant_docs) == 0:
        return 0.0
    
    return len(relevant_retrieved) / len(relevant_docs)

# Example
recall = recall_at_k(retrieved, relevant, k=5)
print(f"Recall@5: {recall}")  # 2/3 = 0.667
```

---

### **3. F1 Score**

Harmonic mean of precision and recall.

```python
def f1_score(precision, recall):
    """Balanced measure of precision and recall"""
    if precision + recall == 0:
        return 0.0
    
    return 2 * (precision * recall) / (precision + recall)
```

---

### **4. Mean Reciprocal Rank (MRR)**

Average of reciprocal ranks of first relevant document.

```python
def mean_reciprocal_rank(queries_results, relevant_docs_per_query):
    """
    queries_results: List of lists (retrieved docs per query)
    relevant_docs_per_query: List of sets (relevant docs per query)
    """
    reciprocal_ranks = []
    
    for retrieved, relevant in zip(queries_results, relevant_docs_per_query):
        for rank, doc_id in enumerate(retrieved, start=1):
            if doc_id in relevant:
                reciprocal_ranks.append(1.0 / rank)
                break
        else:
            reciprocal_ranks.append(0.0)
    
    return sum(reciprocal_ranks) / len(reciprocal_ranks)

# Example
queries_results = [
    ['doc1', 'doc2', 'doc3'],  # Query 1
    ['doc4', 'doc5', 'doc6'],  # Query 2
]
relevant_docs = [
    {'doc2', 'doc5'},  # Relevant for Query 1
    {'doc4', 'doc8'},  # Relevant for Query 2
]

mrr = mean_reciprocal_rank(queries_results, relevant_docs)
print(f"MRR: {mrr}")  # (1/2 + 1/1) / 2 = 0.75
```

---

### **5. Mean Average Precision (MAP)**

Mean of average precision scores across queries.

```python
def average_precision(retrieved_docs, relevant_docs):
    """Average precision for a single query"""
    relevant_count = 0
    precision_sum = 0.0
    
    for rank, doc in enumerate(retrieved_docs, start=1):
        if doc in relevant_docs:
            relevant_count += 1
            precision_at_rank = relevant_count / rank
            precision_sum += precision_at_rank
    
    if len(relevant_docs) == 0:
        return 0.0
    
    return precision_sum / len(relevant_docs)

def mean_average_precision(queries_results, relevant_docs_per_query):
    """MAP across all queries"""
    aps = [
        average_precision(retrieved, relevant)
        for retrieved, relevant in zip(queries_results, relevant_docs_per_query)
    ]
    
    return sum(aps) / len(aps)
```

---

### **6. Normalized Discounted Cumulative Gain (NDCG)**

Measures ranking quality with position-based discounting.

```python
import numpy as np

def dcg_at_k(relevance_scores, k):
    """Discounted Cumulative Gain"""
    relevance = np.array(relevance_scores)[:k]
    discounts = np.log2(np.arange(2, len(relevance) + 2))
    return np.sum(relevance / discounts)

def ndcg_at_k(retrieved_docs, relevant_docs_with_scores, k=10):
    """
    relevant_docs_with_scores: Dict mapping doc_id to relevance score (0-3)
    """
    # Actual DCG
    actual_relevance = [
        relevant_docs_with_scores.get(doc, 0) 
        for doc in retrieved_docs[:k]
    ]
    actual_dcg = dcg_at_k(actual_relevance, k)
    
    # Ideal DCG (if we had perfect ranking)
    ideal_relevance = sorted(relevant_docs_with_scores.values(), reverse=True)
    ideal_dcg = dcg_at_k(ideal_relevance, k)
    
    if ideal_dcg == 0:
        return 0.0
    
    return actual_dcg / ideal_dcg

# Example
retrieved = ['doc1', 'doc2', 'doc3', 'doc4', 'doc5']
relevance = {
    'doc1': 3,  # Highly relevant
    'doc2': 1,  # Somewhat relevant
    'doc3': 0,  # Not relevant
    'doc4': 2,  # Relevant
    'doc6': 3   # Highly relevant (but not retrieved)
}

ndcg = ndcg_at_k(retrieved, relevance, k=5)
print(f"NDCG@5: {ndcg}")
```

---

## Generation Metrics

### **1. Faithfulness / Groundedness**

Does the answer stay true to the retrieved context?

```python
from openai import OpenAI

client = OpenAI()

def check_faithfulness(answer, context):
    """LLM-as-judge for faithfulness"""
    prompt = f"""Context:
{context}

Answer:
{answer}

Is the answer faithful to the context? Does it only contain information from the context?
Answer with: FAITHFUL or UNFAITHFUL

Judgment:"""
    
    response = client.chat.completions.create(
        model="gpt-4",
        messages=[{"role": "user", "content": prompt}],
        temperature=0
    )
    
    judgment = response.choices[0].message.content.strip()
    return "FAITHFUL" in judgment.upper()

def faithfulness_score(answer, context):
    """Numerical faithfulness score"""
    # Extract claims from answer
    claims = extract_claims(answer)
    
    # Check each claim
    supported_claims = 0
    for claim in claims:
        if is_supported_by_context(claim, context):
            supported_claims += 1
    
    if len(claims) == 0:
        return 0.0
    
    return supported_claims / len(claims)
```

---

### **2. Answer Relevancy**

Does the answer actually address the question?

```python
def check_answer_relevancy(question, answer):
    """Check if answer addresses the question"""
    prompt = f"""Question: {question}

Answer: {answer}

Does the answer directly address the question?
Rate from 0-5 where:
- 0: Completely irrelevant
- 3: Partially addresses the question
- 5: Fully addresses the question

Score:"""
    
    response = client.chat.completions.create(
        model="gpt-4",
        messages=[{"role": "user", "content": prompt}],
        temperature=0
    )
    
    try:
        score = int(response.choices[0].message.content.strip())
        return score / 5.0  # Normalize to [0, 1]
    except:
        return 0.0
```

---

### **3. Context Relevancy**

Is the retrieved context relevant to the question?

```python
def context_relevancy(question, context_docs):
    """Measure relevance of retrieved context"""
    relevant_count = 0
    
    for doc in context_docs:
        prompt = f"""Question: {question}

Context: {doc}

Is this context relevant for answering the question?
Answer: YES or NO

Judgment:"""
        
        response = client.chat.completions.create(
            model="gpt-4",
            messages=[{"role": "user", "content": prompt}],
            temperature=0
        )
        
        if "YES" in response.choices[0].message.content.upper():
            relevant_count += 1
    
    return relevant_count / len(context_docs)
```

---

### **4. Hallucination Detection**

Identify information not present in context.

```python
def detect_hallucinations(answer, context):
    """Identify hallucinated statements"""
    prompt = f"""Context:
{context}

Answer:
{answer}

List any statements in the answer that are NOT supported by the context.
If all statements are supported, respond with: "NONE"

Hallucinations:"""
    
    response = client.chat.completions.create(
        model="gpt-4",
        messages=[{"role": "user", "content": prompt}],
        temperature=0
    )
    
    hallucinations = response.choices[0].message.content.strip()
    
    if hallucinations.upper() == "NONE":
        return []
    
    return hallucinations.split('\n')
```

---

### **5. BLEU / ROUGE (Reference-Based)**

Compare generated answer to reference answer.

```python
from nltk.translate.bleu_score import sentence_bleu, SmoothingFunction
from rouge import Rouge

def calculate_bleu(reference, generated):
    """BLEU score for generation quality"""
    reference_tokens = [reference.lower().split()]
    generated_tokens = generated.lower().split()
    
    smoothing = SmoothingFunction().method1
    score = sentence_bleu(reference_tokens, generated_tokens, smoothing_function=smoothing)
    
    return score

def calculate_rouge(reference, generated):
    """ROUGE scores"""
    rouge = Rouge()
    scores = rouge.get_scores(generated, reference)[0]
    
    return {
        'rouge-1': scores['rouge-1']['f'],
        'rouge-2': scores['rouge-2']['f'],
        'rouge-l': scores['rouge-l']['f']
    }
```

---

### **6. Semantic Similarity**

Measure semantic similarity to reference answer.

```python
from sentence_transformers import SentenceTransformer, util

model = SentenceTransformer('all-MiniLM-L6-v2')

def semantic_similarity(text1, text2):
    """Cosine similarity between embeddings"""
    emb1 = model.encode(text1, convert_to_tensor=True)
    emb2 = model.encode(text2, convert_to_tensor=True)
    
    similarity = util.cos_sim(emb1, emb2).item()
    return similarity
```

---

## End-to-End RAG Metrics

### **RAGAS Metrics**

Comprehensive evaluation framework.

```python
from ragas import evaluate
from ragas.metrics import (
    faithfulness,
    answer_relevancy,
    context_relevancy,
    context_recall,
    context_precision
)
from datasets import Dataset

def evaluate_with_ragas(test_data):
    """
    test_data: List of dicts with keys:
    - question
    - answer
    - contexts (list of retrieved docs)
    - ground_truth (optional)
    """
    dataset = Dataset.from_list(test_data)
    
    results = evaluate(
        dataset,
        metrics=[
            faithfulness,
            answer_relevancy,
            context_relevancy,
            context_recall,
            context_precision
        ]
    )
    
    return results

# Example
test_data = [{
    'question': 'What is RAG?',
    'answer': 'RAG is Retrieval-Augmented Generation...',
    'contexts': ['RAG combines retrieval with generation...'],
    'ground_truth': 'RAG is a technique that...'
}]

results = evaluate_with_ragas(test_data)
print(results)
```

---

## DeepEval Framework

```python
from deepeval import evaluate
from deepeval.metrics import AnswerRelevancyMetric, FaithfulnessMetric, ContextualRelevancyMetric
from deepeval.test_case import LLMTestCase

def evaluate_with_deepeval(question, answer, context, expected_output=None):
    """Evaluate using DeepEval"""
    
    test_case = LLMTestCase(
        input=question,
        actual_output=answer,
        retrieval_context=[context],
        expected_output=expected_output
    )
    
    metrics = [
        AnswerRelevancyMetric(threshold=0.7),
        FaithfulnessMetric(threshold=0.7),
        ContextualRelevancyMetric(threshold=0.7)
    ]
    
    results = evaluate([test_case], metrics)
    return results
```

---

## Custom Evaluation Pipeline

```python
class RAGEvaluator:
    def __init__(self, llm_judge):
        self.llm = llm_judge
        self.embedding_model = SentenceTransformer('all-MiniLM-L6-v2')
    
    def evaluate(self, test_cases):
        """Complete evaluation"""
        results = []
        
        for test_case in test_cases:
            metrics = {
                # Retrieval metrics
                'precision@5': self.precision_at_k(
                    test_case['retrieved_docs'],
                    test_case['relevant_docs'],
                    k=5
                ),
                'recall@5': self.recall_at_k(
                    test_case['retrieved_docs'],
                    test_case['relevant_docs'],
                    k=5
                ),
                
                # Generation metrics
                'faithfulness': self.check_faithfulness(
                    test_case['answer'],
                    test_case['context']
                ),
                'answer_relevancy': self.check_answer_relevancy(
                    test_case['question'],
                    test_case['answer']
                ),
            }
            
            # Optional: reference-based metrics
            if 'reference_answer' in test_case:
                metrics['semantic_similarity'] = semantic_similarity(
                    test_case['answer'],
                    test_case['reference_answer']
                )
            
            results.append({
                'test_case': test_case['id'],
                'metrics': metrics
            })
        
        return results
    
    def aggregate_results(self, results):
        """Compute average metrics"""
        aggregated = {}
        
        for metric_name in results[0]['metrics'].keys():
            values = [r['metrics'][metric_name] for r in results]
            aggregated[metric_name] = {
                'mean': np.mean(values),
                'std': np.std(values),
                'min': np.min(values),
                'max': np.max(values)
            }
        
        return aggregated
```

---

## A/B Testing RAG Systems

```python
def ab_test_rag_systems(system_a, system_b, test_queries, evaluator):
    """Compare two RAG systems"""
    
    results_a = []
    results_b = []
    
    for query in test_queries:
        # Run both systems
        answer_a = system_a.query(query)
        answer_b = system_b.query(query)
        
        # Evaluate both
        score_a = evaluator.evaluate(query, answer_a)
        score_b = evaluator.evaluate(query, answer_b)
        
        results_a.append(score_a)
        results_b.append(score_b)
    
    # Statistical significance test
    from scipy.stats import ttest_rel
    
    t_stat, p_value = ttest_rel(results_a, results_b)
    
    return {
        'system_a_mean': np.mean(results_a),
        'system_b_mean': np.mean(results_b),
        'improvement': (np.mean(results_b) - np.mean(results_a)) / np.mean(results_a),
        'p_value': p_value,
        'significant': p_value < 0.05
    }
```

---

## Best Practices

1. **Use multiple metrics**: No single metric tells the whole story
2. **Domain-specific evaluation**: Create test sets for your domain
3. **Continuous evaluation**: Track metrics over time
4. **Human evaluation**: Gold standard for quality
5. **Automated + manual**: Combine LLM judges with human review
6. **Track degradation**: Monitor for performance drops
7. **Sample-based evaluation**: Deep dive on failures

---

## Creating Test Sets

```python
def create_test_set():
    """Template for test case creation"""
    test_cases = [
        {
            'id': 'test_001',
            'question': 'What is machine learning?',
            'relevant_docs': {'doc_123', 'doc_456'},
            'reference_answer': 'Machine learning is...',
            'category': 'factual',
            'difficulty': 'easy'
        },
        # ... more test cases
    ]
    
    return test_cases
```

---

## Next Steps
- Build a test set for your domain
- Implement key metrics (faithfulness, relevancy)
- Set up continuous evaluation
- Track metrics over time
- Use LLM-as-judge for scalable evaluation
