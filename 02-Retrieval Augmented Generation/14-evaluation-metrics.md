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

## Retrieval Metrics(Quantitative)

- **Contextual Relevancy:** How relevant the retrieval context is to the input.
- **Contextual Recall:** Whether the retrieval context contains all the information required to produce the ideal output (for a given input).
- **Contextual Precision:** Whether the retrieval context is ranked in the correct order (higher relevancy goes first) for a given input.

## Generation Metrics(Qualitative)
- **Answer Relevancy:** How relevant the generated response is to the given input.
- **Faithfulness:** Whether the generated response contains hallucinations to the retrieval context.
- **Hallucination Rate:** The frequency of generated content that is not supported by the retrieved context.

## Performance Metrics
- **Latency:** Time taken for retrieval and generation.
- **Cost:** Computational resources used for retrieval and generation.
- **User Satisfaction:** Subjective feedback from users on the quality of responses.

[RAG Evaluation Metrics Blog](https://www.confident-ai.com/blog/rag-evaluation-metrics-answer-relevancy-faithfulness-and-more#ways-in-which-your-rag-pipeline-can-fail)


If we use agent in RAG, we'll also track the agentic performance metrics such as:

## Agentic Performance Metrics
- **Task Completion:** Whether the agent successfully completes the assigned task.
- **Argument Correctness:** Accuracy of the agent's reasoning or arguments.
- **Tool Correctness:** Proper usage of tools or external resources.
- **Step Efficiency:** Efficiency in completing each step of the task.
- **Plan Adherence:** How well the agent follows the planned steps.
- **Plan Quality:** Overall quality and effectiveness of the agent's plan.

*Note: we'll look into agents and agentic performance metrics in more detail in a later chapter.*

## Frameworks used for evaluation(Major players in the RAG evaluation ecosystem):
- [**Deepeval:**](https://deepeval.com/docs/getting-started) Open-source framework for evaluating LLMs and RAG systems.
- [**RAGAS:**](https://docs.ragas.io/en/stable/) RAG Evaluation Suite for comprehensive assessment of retrieval and generation quality.

---

[<- Previous: Multimodal Vector Search](13-multimodal-vector-search.md) | [Next: RAG Architectures →](15-rag-architectures.md)

[<- Back to Index](README.md)