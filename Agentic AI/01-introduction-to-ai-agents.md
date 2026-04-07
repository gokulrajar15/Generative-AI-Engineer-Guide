# Introduction to AI Agents

## Overview
AI Agents are autonomous systems that can perceive their environment, make decisions, and take actions to achieve specific goals. Unlike traditional chatbots that simply respond to queries, agents can plan, use tools, maintain memory, and execute complex multi-step tasks.

---

## What are AI Agents?

**Definition:** An AI agent is an autonomous entity that uses an LLM as its reasoning engine to:
- Perceive its environment (inputs, context, data)
- Make decisions based on goals
- Take actions (call tools, APIs, functions)
- Learn from feedback
- Adapt behavior over time

**Key Difference from Basic LLMs:**
```
Basic LLM:      Input → Processing → Output
AI Agent:       Goal → Plan → Act → Observe → Reflect → Repeat
```

---

## Core Components of AI Agents

### **1. Brain (LLM)**
The reasoning engine that processes information and makes decisions.

```python
# Agent brain powered by LLM
class AgentBrain:
    def __init__(self, llm):
        self.llm = llm
    
    def reason(self, observation, goal):
        """Decide next action based on observation and goal"""
        prompt = f"""
        Goal: {goal}
        Current Observation: {observation}
        
        What should I do next? Think step by step.
        """
        return self.llm.generate(prompt)
```

### **2. Memory**
Short-term and long-term storage of information.

- **Short-term memory**: Current conversation/task context
- **Long-term memory**: Persistent knowledge across sessions

### **3. Tools**
Functions and APIs the agent can use to interact with the world.

```python
tools = [
    {"name": "search", "function": web_search},
    {"name": "calculator", "function": calculate},
    {"name": "database_query", "function": query_db}
]
```

### **4. Planning**
Ability to break down complex goals into steps.

### **5. Action Execution**
Calling tools and executing decisions.

---

## How AI Agents Work

### **The Agent Loop:**

```python
class BasicAgent:
    def __init__(self, llm, tools):
        self.llm = llm
        self.tools = tools
        self.memory = []
    
    def run(self, goal, max_iterations=10):
        """Main agent loop"""
        for i in range(max_iterations):
            # 1. Observe current state
            observation = self.get_current_state()
            
            # 2. Think (reasoning)
            thought = self.llm.generate(
                f"Goal: {goal}\n"
                f"Observation: {observation}\n"
                f"What should I do next?"
            )
            
            # 3. Decide action
            action = self.parse_action(thought)
            
            # 4. Execute action
            if action['type'] == 'tool':
                result = self.execute_tool(action['tool'], action['input'])
            elif action['type'] == 'finish':
                return action['output']
            
            # 5. Store in memory
            self.memory.append({
                'observation': observation,
                'thought': thought,
                'action': action,
                'result': result
            })
            
            # 6. Continue loop
            if self.is_goal_achieved(goal, result):
                return result
        
        return "Max iterations reached"
```

---

## Agent Types Overview

### **1. Simple Reflex Agents**
React directly to current percepts without considering history.

```python
def reflex_agent(percept):
    if "hello" in percept.lower():
        return "Hi there!"
    elif "weather" in percept.lower():
        return get_weather()
```

### **2. Model-Based Agents**
Maintain internal state/model of the world.

### **3. Goal-Based Agents**
Take actions to achieve specific goals.

### **4. Utility-Based Agents**
Choose actions that maximize a utility function.

### **5. Learning Agents**
Improve performance over time through feedback.

---

## Why Use AI Agents?

**Traditional Approach:**
- Fixed workflows
- Manual orchestration
- Limited adaptability
- No autonomous decision-making

**Agent Approach:**
- Dynamic task execution
- Autonomous problem-solving
- Adaptive to changing conditions
- Can handle unexpected scenarios

**Use Cases:**
- **Customer support**: Autonomous ticket resolution
- **Data analysis**: Self-directed exploration
- **Task automation**: Complex multi-step workflows
- **Research**: Autonomous information gathering
- **Software development**: Code generation and debugging

---

## Basic Agent Implementation

### **Simple ReAct Agent:**

```python
from openai import OpenAI

class SimpleReActAgent:
    """
    ReAct: Reasoning + Acting
    Paper: https://arxiv.org/abs/2210.03629
    """
    
    def __init__(self, tools):
        self.client = OpenAI()
        self.tools = {tool['name']: tool['function'] for tool in tools}
    
    def run(self, task, max_steps=5):
        """Execute task using ReAct pattern"""
        history = []
        
        for step in range(max_steps):
            # Generate thought and action
            prompt = self.create_prompt(task, history)
            
            response = self.client.chat.completions.create(
                model="gpt-4",
                messages=[
                    {"role": "system", "content": "You are a helpful agent that thinks step by step."},
                    {"role": "user", "content": prompt}
                ]
            )
            
            output = response.choices[0].message.content
            
            # Parse output
            thought, action, action_input = self.parse_output(output)
            
            # Execute action
            if action == "FINISH":
                return action_input
            elif action in self.tools:
                observation = self.tools[action](action_input)
            else:
                observation = f"Error: Unknown action {action}"
            
            # Add to history
            history.append({
                'thought': thought,
                'action': action,
                'action_input': action_input,
                'observation': observation
            })
        
        return "Task incomplete after max steps"
    
    def create_prompt(self, task, history):
        """Create prompt with task and history"""
        prompt = f"Task: {task}\n\n"
        
        for i, step in enumerate(history, 1):
            prompt += f"Step {i}:\n"
            prompt += f"Thought: {step['thought']}\n"
            prompt += f"Action: {step['action']}: {step['action_input']}\n"
            prompt += f"Observation: {step['observation']}\n\n"
        
        prompt += """What should I do next?
Format your response as:
Thought: [your reasoning]
Action: [action name or FINISH]
Action Input: [input for the action or final answer]
"""
        return prompt
    
    def parse_output(self, output):
        """Parse LLM output into components"""
        lines = output.strip().split('\n')
        thought = ""
        action = ""
        action_input = ""
        
        for line in lines:
            if line.startswith("Thought:"):
                thought = line.replace("Thought:", "").strip()
            elif line.startswith("Action:"):
                action = line.replace("Action:", "").strip()
            elif line.startswith("Action Input:"):
                action_input = line.replace("Action Input:", "").strip()
        
        return thought, action, action_input


# Usage
def search_tool(query):
    """Simulated search tool"""
    return f"Search results for: {query}"

def calculator_tool(expression):
    """Calculator tool"""
    return str(eval(expression))

tools = [
    {'name': 'search', 'function': search_tool},
    {'name': 'calculator', 'function': calculator_tool}
]

agent = SimpleReActAgent(tools)
result = agent.run("What is 25 * 4 + 10?")
print(result)
```

---

## Agent Patterns

### **1. ReAct (Reasoning + Acting)**
Interleave reasoning and action steps.

### **2. Plan-and-Execute**
Plan all steps upfront, then execute.

### **3. ReWOO (Reasoning WithOut Observation)**
Plan all tool calls before execution.

### **4. Reflexion**
Self-reflect and improve from failures.

---

## Key Concepts

### **Autonomy Levels:**

| Level | Description | Example |
|-------|-------------|---------|
| 0 | No automation | Human does everything |
| 1 | Assistance | Agent suggests, human decides |
| 2 | Partial | Agent acts, human approves |
| 3 | Conditional | Agent acts autonomously with constraints |
| 4 | Full | Completely autonomous |

### **Agent vs. Chain:**

```python
# Chain: Fixed sequence
result = chain.run(input)  # Same path every time

# Agent: Dynamic decision-making
result = agent.run(goal)   # Path depends on observations
```

---

## When to Use Agents

**Use Agents When:**
- ✅ Tasks require multi-step reasoning
- ✅ Need dynamic tool selection
- ✅ Must adapt to changing conditions
- ✅ Goal-oriented behavior needed
- ✅ Autonomous operation required

**Use Simple Chains When:**
- ✅ Fixed, predictable workflow
- ✅ Simple input → output transformation
- ✅ No decision-making needed
- ✅ Performance critical (agents are slower)

---

## Agent Architecture Patterns

### **1. Single Agent:**
```
User → Agent (LLM + Tools) → Output
```

### **2. Sequential Agents:**
```
User → Agent1 → Agent2 → Agent3 → Output
```

### **3. Hierarchical Agents:**
```
        Manager Agent
           /    \
    Agent1    Agent2
      |         |
   Worker1   Worker2
```

### **4. Collaborative Agents:**
```
User → [Agent1 ⟷ Agent2 ⟷ Agent3] → Output
```

---

## Challenges with AI Agents

1. **Reliability**: Agents can make mistakes or get stuck in loops
2. **Costs**: Multiple LLM calls can be expensive
3. **Latency**: Sequential reasoning takes time
4. **Unpredictability**: Hard to guarantee specific behavior
5. **Debugging**: Complex to trace decision-making
6. **Safety**: Need guardrails for autonomous actions

---

## Best Practices

1. **Clear goals**: Define specific, measurable objectives
2. **Limited autonomy**: Start with human-in-the-loop
3. **Tool constraints**: Limit available actions initially
4. **Monitoring**: Track all agent actions
5. **Fallbacks**: Have recovery mechanisms
6. **Testing**: Extensive testing with edge cases
7. **Cost controls**: Set budget limits
8. **Timeouts**: Prevent infinite loops

---

## Evaluation Metrics

- **Task success rate**: % of goals achieved
- **Steps to completion**: Efficiency measure
- **Tool usage accuracy**: Correct tool selection
- **Cost per task**: LLM API costs
- **Latency**: Time to complete
- **Error rate**: Failures and retries

---

## Getting Started

### **Minimal Agent Example:**

```python
from openai import OpenAI

client = OpenAI()

def simple_agent(goal):
    """Minimal agent implementation"""
    messages = [
        {"role": "system", "content": "You are a helpful agent."},
        {"role": "user", "content": goal}
    ]
    
    for _ in range(5):  # Max 5 steps
        response = client.chat.completions.create(
            model="gpt-4",
            messages=messages
        )
        
        assistant_msg = response.choices[0].message.content
        
        # Check if task is complete
        if "DONE:" in assistant_msg:
            return assistant_msg.replace("DONE:", "").strip()
        
        # Add to conversation
        messages.append({"role": "assistant", "content": assistant_msg})
        
        # Simulate observation (in real agent, this would be tool result)
        observation = "Continue..."
        messages.append({"role": "user", "content": observation})
    
    return "Task incomplete"

# Run
result = simple_agent("Create a plan to organize a team meeting")
print(result)
```

---

## Tools and Frameworks

- **LangChain**: Comprehensive agent framework
- **LangGraph**: Graph-based agent orchestration
- **AutoGPT**: Autonomous agent
- **BabyAGI**: Task-driven autonomous agent
- **CrewAI**: Multi-agent orchestration
- **Semantic Kernel**: Microsoft's agent framework

---

## Next Steps

- Understand different agent types and architectures
- Learn agent frameworks (LangChain, LangGraph)
- Implement tool use and function calling
- Build multi-agent systems
- Master agent evaluation and monitoring

---

## Resources

**Papers:**
- ReAct: Synergizing Reasoning and Acting in Language Models
- Reflexion: Language Agents with Verbal Reinforcement Learning
- AutoGPT: An Autonomous GPT-4 Experiment

**Courses:**
- DeepLearning.AI - AI Agents courses
- LangChain documentation on agents

**Communities:**
- LangChain Discord
- r/artificial
- Agent-focused AI communities

---

Ready to dive deeper? Continue with [Types of AI Agents](02-types-of-ai-agents.md) to explore different agent architectures.
