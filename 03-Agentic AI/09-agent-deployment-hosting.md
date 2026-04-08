# Agent Hosting

Hosting and deployment are critical for making your AI agents accessible, scalable, and reliable in production environments. This section covers best practices for deploying agents, choosing hosting platforms, and ensuring performance and security.

## Common Agent Hosting Strategies

**Managed Services (AaaS):** this is managed infrastructure, scaling, and runtime, allowing developers to focus on orchestration logic and tool integration.

- **Amazon Bedrock AgentCore:** Fully managed service for building and deploying agents with support for multiple foundation models and tools.
- **Azure AI Foundry:** Managed platform for developing and hosting AI agents with integrated monitoring and scaling.
- **GCP Vertex AI(Agent Engine):** Managed service for building and deploying agents with support for multi-modal models and tool integration.
- **OpenAI Assistants API:** Managed hosting for OpenAI-based agents with built-in scaling and monitoring.

 also few agent frameworks like Langchain, CrewAI, etc also provide their own hosting solutions.


**Containerized Hosting:** Agents are deployed as container images (Docker/Kubernetes) on platforms such as Cloud Run, offering flexibility in frameworks and environment control.

- **AWS ECS/EKS:** For container orchestration with deep AWS integration.
- **Google Cloud Run:** Serverless container hosting with automatic scaling.
- **Azure Container Instances:** For easy container deployment on Azure.


[<- Previous: Hands-on Agent Building](08-hands-on.md) | [Next: Long term memory management →](10-longterm-memory-systems.md)

[<- Back to Agentic AI Index](README.md)