# 1. Model Context Protocol (MCP)

The Model Context Protocol (MCP) is an open standard introduced by Anthropic in November 2024 that standardizes how AI systems integrate with external data sources and tools. In December 2025, MCP was donated to the Agentic AI Foundation under the Linux Foundation, co-founded by Anthropic, Block, and OpenAI.

![MCP Protocol](../assets/Agentic%20AI/12-ai-protocol/mcp_protocol.png)

**Simple Definition:** MCP is like a universal connector (similar to USB-C) that allows any AI application to communicate with any tool or data source through a single standardized interface.

## The Problem MCP Solves

**Before MCP:**
- Each AI application needed custom integrations for every data source
- If you had 10 AI apps and 100 tools, you needed 1,000 different integrations
- Developers built separate connectors for each combination (the "N×M problem")

**With MCP:**
- Each application implements MCP client protocol once
- Each tool implements MCP server protocol once
- Any MCP client can connect to any MCP server


## How MCP Works

### **Architecture**

```
AI Application (MCP Client) ←→ MCP Protocol ←→ Data Source/Tool (MCP Server)
```

**MCP Client:**
- Runs inside the host application (like Claude Desktop, IDEs)
- Establishes one-to-one sessions with MCP servers
- Handles capability negotiation and message orchestration
- Maintains security boundaries between different servers

**MCP Server:**
- Provides specialized capabilities or resources
- Can be a local process or remote service
- Wraps data sources, APIs, or utilities (CRMs, Git repos, databases)
- Exposes tools and resources through standardized interfaces

### **Core Components**

1. **Resources:** Data and content that servers expose (files, database records, API responses)
2. **Tools:** Functions that AI can execute (search, create, update, delete operations)
3. **Prompts:** Predefined templates for common tasks
4. **Sampling:** Ability for servers to request LLM completions


# 2. Agent-to-Agent Protocol (A2A)

The Agent2Agent Protocol (A2A) is an open communication protocol for AI agents, initially introduced by Google in April 2025 and donated to the Linux Foundation in June 2025. A2A enables AI agents from different providers and frameworks to discover, communicate, and collaborate with each other.

![A2A Protocol](../assets/Agentic%20AI/12-ai-protocol/a2a.png)

**Simple Definition:** A2A is like a common language or universal translator that allows AI agents to talk to each other and work together, regardless of who built them or what technology they use.


## The Problem A2A Solves

### **Challenge: Agent Silos**
- Different companies build AI agents using different frameworks (LangChain, CrewAI, Google ADK, BeeAI)
- These agents can't communicate or collaborate
- Each organization builds isolated agents that can't leverage collective intelligence
- Enterprise applications need coordinated action across multiple specialized agents

### **Before A2A:**
- Custom integration for each agent-to-agent connection
- No standardized way to discover other agents' capabilities
- Difficult to coordinate multi-step workflows
- Limited scalability

### **With A2A:**
- Agents can discover each other automatically
- Standardized communication protocol
- Coordinate complex workflows autonomously
- Vendor-neutral collaboration


## How A2A Works

### **Core Architecture**

```
Client Agent (Initiates Request) ←→ A2A Protocol ←→ Remote Agent (Executes Task)
```

**Client Agent (A2A Client):**
- Can be an app, service, or another AI agent
- Delegates requests to remote agents
- Uses A2A protocol to initiate communication
- Sends tasks and receives results

**Remote Agent (A2A Server):**
- Takes requests and processes tasks
- Exposes HTTP endpoint compatible with A2A
- Responds with status updates and results
- Can be built with any framework

### **Communication Flow**

1. **Discovery:** Client agent finds remote agents using Agent Cards
2. **Capability Negotiation:** Client checks what the remote agent can do
3. **Task Delegation:** Client sends task with context and instructions
4. **Execution:** Remote agent processes the task
5. **Status Updates:** Agent provides progress updates (optional)
6. **Result Return:** Agent sends final results back to client

# Agent UI Protocol (A2UI)

A2UI (Agent-to-User Interface) is an open-source protocol introduced by Google in December 2025 that enables AI agents to generate rich, interactive user interfaces that render natively across platforms. It solves the critical challenge of how AI agents can safely send UI components across trust boundaries without executing arbitrary code.

![A2UI Protocol](../assets/Agentic%20AI/12-ai-protocol/agent_ui.png)

**Simple Definition:** A2UI lets AI agents describe what UI they want to show (buttons, forms, charts) in JSON format, and each app renders those descriptions using its own native components—ensuring security while enabling rich interactions.

---

## The Problem A2UI Solves

### **Challenge 1: The Chat Wall**
Most AI agents are limited to text-only responses. For tasks like booking a restaurant or filling forms, this creates:
- Many back-and-forth turns
- Dense text responses
- Poor user experience
- Slow interactions

**Without A2UI:**
```
User: "Book a table for 2 tomorrow at 7pm"
Agent: "Okay, for what day?"
User: "Tomorrow"
Agent: "What time?"
User: "7pm"
Agent: "How many people?"
```

**With A2UI:**
Agent generates a form with date picker, time selector, party size input, and submit button. User completes booking in one interaction.

### **Challenge 2: Multi-Agent Trust Boundaries**
In multi-agent systems, remote agents often run on different servers or belong to different organizations. How can they generate UI safely without executing arbitrary code?

**The Problem:**
- Can't let remote agents inject JavaScript (security risk)
- Can't trust HTML from external sources
- Need consistent branding across agents
- Must maintain accessibility standards

**A2UI Solution:**
Agents send declarative JSON describing UI intent. The client app renders using its own trusted components.

---

## How A2UI Works

### **Core Concept: Declarative UI as Data**

```
Agent generates JSON → Client parses JSON → Renders native components
```

**Agent Perspective:**
- Generate JSON payload describing UI structure
- Reference component types from client's catalog
- Specify data bindings and user actions
- Stream updates as conversation progresses

**Client Perspective:**
- Receive JSON specification
- Validate against trusted component catalog
- Map abstract components to concrete native widgets
- Render using framework (React, Flutter, Angular, SwiftUI)

### **Key Innovation**
A2UI treats UI as **data**, not **code**:
- Agents can only reference pre-approved component types
- No arbitrary JavaScript execution
- Client controls security, styling, and accessibility
- Same JSON works across web, mobile, and desktop

---

## A2UI Architecture

### **1. Surfaces**
Containers for UI components (think of as screens or panels).

```json
{
  "createSurface": {
    "surfaceId": "booking",
    "catalogId": "https://example.com/catalog.json"
  }
}
```

### **2. Components**
Individual UI elements referenced from the catalog.

**Basic Components:**
- Text, Button, TextField
- DateTimeInput, Dropdown
- Card, List, Grid

**Advanced Components:**
- Chart, GoogleMap
- DataTable, FileUpload
- Custom domain-specific components

### **3. Data Model**
Application state separated from UI structure.

```json
{
  "dataModelUpdate": {
    "surfaceId": "booking",
    "contents": [
      {
        "key": "booking",
        "valueMap": [
          {"key": "date", "valueString": "2025-12-16T19:00:00Z"},
          {"key": "partySize", "valueInt": 2}
        ]
      }
    ]
  }
}
```

### **4. Data Binding**
Connect UI components to data using JSON Pointers.

```json
{
  "component": {
    "DateTimeInput": {
      "value": {"path": "/booking/date"},
      "enableDate": true
    }
  }
}
```

### **5. Event Handling**
User actions sent back to agent as structured events.

```json
{
  "action": {
    "name": "confirm_booking",
    "parameters": [
      {"key": "date", "path": "/booking/date"},
      {"key": "partySize", "path": "/booking/partySize"}
    ]
  }
}
```

---

## A2UI Message Structure

### **Example: Restaurant Booking Form**

```json
{
  "version": "v0.8",
  "createSurface": {
    "surfaceId": "booking",
    "catalogId": "https://a2ui.org/specification/v0_9/basic_catalog.json"
  }
}

{
  "surfaceUpdate": {
    "surfaceId": "booking",
    "components": [
      {
        "id": "title",
        "component": {
          "Text": {
            "text": {"literalString": "Book Your Table"},
            "usageHint": "h1"
          }
        }
      },
      {
        "id": "datetime",
        "component": {
          "DateTimeInput": {
            "value": {"path": "/booking/date"},
            "enableDate": true,
            "enableTime": true
          }
        }
      },
      {
        "id": "submit-btn",
        "component": {
          "Button": {
            "label": {"literalString": "Confirm"},
            "action": {"name": "confirm_booking"}
          }
        }
      }
    ]
  }
}

{
  "beginRendering": {
    "surfaceId": "booking",
    "root": "title"
  }
}
```

## Integration with Protocol Stack

### **A2UI + A2A (Agent-to-Agent)**
Remote agents use A2A to communicate, then send A2UI for display:

```
Agent A --[A2A]--> Agent B
   ↓
[A2UI] → Client renders UI from Agent B's response
```

### **A2UI + AG-UI (Agent-User Interaction)**
AG-UI is the runtime protocol that carries A2UI messages:

```
Agent Backend ←[AG-UI events]→ User Interface
                    ↓
              [Contains A2UI specs]
```

**Relationship:**
- **A2UI:** The UI specification (what to show)
- **AG-UI:** The transport protocol (how to deliver it)

### **Complete Stack Example**

```
User Request
    ↓
[AG-UI] User input to Agent
    ↓
Agent uses [MCP] to access database
    ↓
Agent uses [A2A] to coordinate with other agents
    ↓
Agent generates [A2UI] UI specification
    ↓
[AG-UI] delivers A2UI to client
    ↓
Client renders native components
```

# Agent Payment Protocol (AP2)

The Agent Payments Protocol (AP2) is an open protocol announced by Google in September 2025 that enables AI agents to securely initiate and execute payments on behalf of users. It addresses the fundamental trust and accountability challenges that arise when autonomous agents handle financial transactions.

![AP2 Protocol](../assets/Agentic%20AI/12-ai-protocol/agent_payment.png)

**Simple Definition:** AP2 is like a secure digital contract system that allows AI agents to make purchases for you, with cryptographic proof that you authorized the transaction and clear accountability if something goes wrong.


## The Problem AP2 Solves

### **The Broken Assumption**
Traditional payment systems assume a human is directly clicking "buy" on a trusted website. When an autonomous AI agent initiates a payment, this core assumption breaks, creating critical questions:

**1. Authorization:** How can we verify that a user gave an agent specific authority for a particular purchase?

**2. Authenticity:** How can a merchant be sure an agent's request accurately reflects the user's true intent, without errors or AI "hallucinations"?

**3. Accountability:** If a fraudulent or incorrect transaction occurs, who is accountable—the user, the agent's developer, the merchant, or the issuer?

### **Without a Standard Protocol**
- Fragmented ecosystem of proprietary solutions
- Confusing for users
- Expensive for merchants
- Difficult for financial institutions to manage
- Limited adoption due to trust issues

### **With AP2**
- Common language for compliant agents and merchants
- Cryptographically verifiable user intent
- Non-repudiable audit trail
- Clear accountability framework
- Global interoperability

---

## How AP2 Works

### **Core Concept: Verifiable Digital Credentials (VDCs)**
AP2 uses cryptographically signed digital objects called **Mandates** that serve as tamper-proof proof of user intent.

```
User Intent → Mandate (cryptographically signed) → Agent → Merchant → Payment Network
```

### **Three Types of Mandates**

#### **1. Intent Mandate**
Captures the conditions under which an agent can make purchases.

**Use Case:** "Human-not-present" scenarios where agent acts autonomously

**Contains:**
- Natural language description of what to buy
- Price limits
- Timing constraints
- Merchant preferences
- Refundability requirements
- Expiration date

**Example:**
```json
{
  "natural_language_description": "espresso coffee maker under $200",
  "requires_refundability": true,
  "intent_expiry": "2025-12-31T23:59:59Z",
  "merchants": ["trusted-retailer-id"],
  "price_limit": 200.00
}
```

#### **2. Cart Mandate**
Captures final explicit authorization for a specific cart.

**Use Case:** "Human-present" scenarios where user approves before purchase

**Contains:**
- Exact items in cart
- Specific prices
- Total amount
- Merchant information
- User's cryptographic signature

**Example:**
```json
{
  "cart_id": "cart_12345",
  "items": [
    {
      "sku": "COFFEE-MAKER-X1",
      "name": "Espresso Machine Pro",
      "price": 189.99,
      "quantity": 1
    }
  ],
  "total": 189.99,
  "user_signature": "0x..."
}
```

#### **3. Payment Mandate**
Shared with payment network and issuer to signal AI agent involvement.

**Purpose:**
- Help assess transaction context
- Flag agent-initiated payments
- Indicate user presence (human-present or not)
- Enable appropriate fraud detection

---

## Transaction Flow

### **Scenario 1: Human-Present Purchase**

**Step-by-Step:**

1. **User Request:**
   ```
   User: "Find me new white running shoes"
   ```

2. **Intent Mandate Created:**
   Agent captures the request as an Intent Mandate (auditable context)

3. **Agent Searches:**
   Agent finds products matching criteria

4. **Agent Presents Cart:**
   Shows specific shoes with price

5. **User Approval:**
   User reviews and approves

6. **Cart Mandate Signed:**
   User's cryptographic signature creates immutable record

7. **Payment Mandate Generated:**
   Separate mandate for payment network

8. **Transaction Executed:**
   Merchant processes payment with all mandates as proof

### **Scenario 2: Human-Not-Present Purchase**

**Step-by-Step:**

1. **User Delegation:**
   ```
   User: "Buy concert tickets the moment they go on sale, max $150 per ticket"
   ```

2. **Detailed Intent Mandate Signed:**
   ```json
   {
     "description": "2 tickets to Artist X concert",
     "price_limit_per_ticket": 150.00,
     "quantity": 2,
     "timing": "on_sale_start",
     "auto_purchase": true
   }
   ```

3. **Agent Monitors:**
   Watches for tickets to become available

4. **Agent Acts Autonomously:**
   When tickets go on sale, agent purchases automatically

5. **Cart Mandate Auto-Generated:**
   Agent creates Cart Mandate based on Intent Mandate rules

6. **Transaction Executed:**
   Purchase completed with cryptographic proof of authorization


## Resources

- **Official Website:** https://ap2-protocol.org
- **GitHub Repository:** https://github.com/google-agentic-commerce/AP2
- **Google Cloud Blog:** https://cloud.google.com/blog/products/ai-machine-learning/announcing-agents-to-payments-ap2-protocol

---

[<- Previous: Guardrails and Safety Protocols](11-guardrails-safety-protocols.md) | [Next: Feedback Loops and Optimization ->](13-feedback-loops-optimization.md)

[<- Back to Agentic AI Index](README.md)