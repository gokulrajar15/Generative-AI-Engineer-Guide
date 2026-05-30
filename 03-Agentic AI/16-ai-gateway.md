# AI Gateways

An AI Gateway is a reverse proxy and orchestration layer that sits between your application code and upstream LLM provider APIs. It acts as a centralized control plane, abstracting multiple vendor SDKs into a single, unified interface.

![AI Gateway](../assets/Agentic%20AI/16-ai-gateway/ai_gateway.png)

## Benefits of AI Gateways

- **Routing and Fallback**: Direct requests to specific models, providers, and keys. Implement weighted strategies and automatic fallbacks.
- **Centralized Logging and Monitoring**: Aggregate logs, metrics, and performance data across all LLM interactions in one place.
- **Semantic Caching**: Cache responses based on prompt similarity to reduce latency and costs.
- **Rate Limiting and Access Control**: Enforce usage policies, quotas, and access controls at the gateway level.
- **RBAC and SMIP Compliance**: Implement role-based access control and ensure compliance with security and privacy standards.
- **Guardrails and Safety Layers**: Integrate input validation, output filtering, and safety checks before requests reach the LLM.

# AI Gateway Solutions

1. Bifrost - Go-based, adds ~11 microseconds latency (tested at 5k RPS). Adaptive load balancing across providers, semantic caching cut costs 60%, MCP support for tool calls. Open source, zero markup on API costs. Budget caps saved us from $800 runaway loop. Setup: 20 minutes.

2. LiteLLM - Most popular, huge community. Python-based adds ~8ms latency per request. At our scale (2k RPS), that overhead compounds. Open source, zero markup. Good for <1k RPS, struggles at higher throughput. Budget controls exist but basic.

3. Cloudflare AI Gateway - Cloudflare-only deployment. Adds 10-50ms latency. Has semantic caching. Great if you're already on Cloudflare Workers. We needed multi-cloud support. Zero markup.

4. Helicone - Strong observability, health-aware routing. Partial open source. Better for cost tracking than performance optimization. Good analytics UI. Self-hosted or managed options.

5. Kong AI Gateway - Enterprise-grade with RBAC, SSO, multi-cloud. Requires Kubernetes setup. Overkill for startups, perfect for large orgs with existing Kong infrastructure. Custom pricing.

6. OpenRouter - Managed service, high throughput. Adds 25-40ms latency. Easy setup but 5% markup on all API costs. At $2k/month spend, that's $100/month just for routing. No self-hosting.


[<- Back to Agentic AI Index](README.md)