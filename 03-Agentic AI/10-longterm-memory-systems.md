# Long-term Memory Systems for AI Agents

Long-term memory (LTM) for AI agents enables the storage and retrieval of information across multiple sessions, allowing for personalized, context-aware interactions. It uses vector databases or knowledge graphs to store episodic (experiences), semantic (facts), and procedural (rules) data, retrieving relevant context for tasks. 

## Types of Long-term Memory
- **Episodic memory:** stores specific past events and experiences, creating a personal history of interactions. A travel agent might remember that a user previously booked a trip to London for a conference and prefers city-center hotels.
- **Procedural memory:** stores learned skills and operational knowledge, forming the agent's repertoire of effective actions. An agent could learn the optimal process for booking flights, like ensuring appropriate layover times or avoiding specific airports based on past connection failures.
- **Semantic memory:** stores general knowledge, facts, and relationships the agent draws on—often backed by a knowledge base (such as visa rules, policies, or FAQs) retrieved when contextually relevant.

*Implementing LTM is esay task but amount of information need be unlearned is crucial, otherwise it can lead to information overload and performance degradation. LTM systems must balance retention of useful information with forgetting irrelevant or outdated data to maintain efficiency and relevance in interactions.*

## Managing Memory Decay

LTM without memory decay is great for the first 10-15 sessions. After that, the notes become noise. Contradictory entries co-exist. user preferences change. So, we need to implement memory decay to forget irrelevant or outdated information and keep the memory relevant and efficient.

Memory decay is the process of forgetting or deprioritizing information over time to prevent overload and maintain relevance. In AI agents, this can be implemented through techniques like:

- **Time-based decay:** Information is automatically forgotten after a certain period, ensuring that only recent and relevant data is retained.
- **Usage-based decay:** Information that is accessed less frequently is deprioritized or removed, allowing the agent to focus on more relevant data.
- **Relevance-based decay:** Information that is deemed less relevant to the agent's current tasks or user interactions is forgotten, keeping the memory focused on useful data.
- **User-controlled decay:** Allowing users to manually delete or update stored information, giving them control over what the agent remembers.
- **Contextual decay:** Information that is no longer relevant to the current context or user goals is deprioritized, ensuring that the agent's memory remains focused on what matters most in the current interaction.

*Implementing Both LTM with memory decay strategies ensures that the agent's memory remains relevant, efficient, and aligned with user needs.*


References:
[Long term memory management blog](https://towardsdatascience.com/agentic-ai-implementing-long-term-memory/) <-- Must read blog for understanding long-term memory management for AI agents in detail with examples and best practices.

[Long term memory management blog by Redis](https://redis.io/blog/build-smarter-ai-agents-manage-short-term-and-long-term-memory-with-redis/) <-- Must read blog


## Long term memory as a service

- **Mem0:** is a universal, self‑improving AI memory layer for LLM applications, powering personalised AI experiences that cut costs and enhance user delight.
- **Letta (formerly MemGPT):** is a long-term memory system for AI agents, designed to store and retrieve information across sessions, enabling personalized and context-aware interactions.
- **Zep:** is an end-to-end context engineering platform that delivers the right information at the right time with sub-200ms latency.
- **Self-managed vector databases:** such as Pinecone, Weaviate, and Redis can also be used to implement long-term memory for AI agents, allowing for efficient storage and retrieval of vectorized information.

---

One of the good example for LTM with memory decay is the [Claude Code Auto memory and Auto Dream Feature](https://dmarketertayeeb.com/blog/claude-code-auto-dream-memory-feature/) which provides LTM as a service with built-in memory decay strategies to ensure that the agent's memory remains relevant and efficient over time.

![Claude Auto Memory and Auto Dream](../assets/Agentic%20AI/10-longterm-memory-systems/claude_code.png)

---

[<- Previous: Agent Deployment and Hosting](09-agent-deployment-hosting.md) | [Next: Guardrails →](11-agent-security-guardrails.md)

[<- Back to Agentic AI Index](README.md)