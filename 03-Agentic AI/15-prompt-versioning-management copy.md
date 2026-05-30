# Prompt versioning

Prompt versioning is the systematic practice of tracking, managing, and documenting changes to LLM prompts,
treating them as code to ensure reliability.It enables teams to log iterations (v1, v2), audit changes, compare
performance, and roll back if improvements break production. It is crucial for maintaining AI consistency.

![Prompt Versioning](../assets/Agentic%20AI/15-prompt-versioning/prompt_versioning.png)

It does more than just save different versions, though. Good prompt versioning includes:

- Version history that captures what changed and why
- The ability to roll back to previous versions if needed
- Testing prompts before deploying changes
- Managing different prompt variations for A/B testing
- Tracking which prompt versions are running in different environments

The practice of prompt versioning is an important component of a larger system called prompt management.

## Tools for Prompt Versioning
- **Langsmith**: Langsmith provides built-in support for prompt versioning, allowing you to track changes and performance metrics over time.
- **Langfuse**: Langfuse offers features for monitoring and analyzing prompt performance, making it easier to manage different versions effectively.
- [**PezzoAI**](https://github.com/pezzolabs/pezzo):  Open-source, developer-first LLMOps platform designed to streamline prompt design, version management, instant delivery, collaboration, troubleshooting, observability and more.
- [**Agenta**](https://github.com/Agenta-AI/agenta): Agenta is an open-source framework that supports prompt versioning and management, enabling teams to collaborate and optimize their AI agents efficiently.


--- 


[<- Previous: Context Engineering](14-context-engineering.md) | [Next: AI Gateway](16-ai-gateway.md)

[<- Back to Agentic AI Index](README.md)