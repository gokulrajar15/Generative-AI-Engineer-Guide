# Types of AI Agents

## Overview
AI agents come in various architectures and configurations, each suited for different use cases. Understanding these types helps you choose the right approach for your specific needs.

---

## 1. Reactive Agents

**Definition:** Agents that respond directly to current inputs without considering history or maintaining state.

### **Characteristics:**
- No memory of past interactions
- Rule-based or pattern-based responses
- Fast and deterministic
- Limited to simple tasks

### **Implementation:**

```python
class ReactiveAgent:
    """Simple reactive agent with no memory"""
    
    def __init__(self, rules):
        self.rules = rules
    
    def respond(self, input_text):
        """React based on current input only"""
        input_lower = input_text.lower()
        
        for pattern, response in self.rules.items():
            if pattern in input_lower:
                return response
        
        return "I don't understand"

# Usage
rules = {
    "hello": "Hi! How can I help?",
    "weather": "I'll check the weather for you",
    "bye": "Goodbye!"
}

agent = ReactiveAgent(rules)
print(agent.respond("Hello there"))  # Hi! How can I help?
print(agent.respond("What's the weather?"))  # I'll check the weather
```

### **Use Cases:**
- Simple chatbot responses
- Rule-based automation
- Trigger-based actions
- Real-time monitoring alerts

### **Pros & Cons:**
✅ Fast and predictable  
✅ Easy to implement  
✅ Low cost  
❌ No context awareness  
❌ Limited flexibility  
❌ Can't handle complex tasks

---

## 2. Model-Based (Deliberative) Agents

**Definition:** Agents that maintain an internal model of the world and use it for decision-making.

### **Characteristics:**
- Maintain state/memory
- Consider history in decisions
- Can plan ahead
- More complex reasoning

### **Implementation:**

```python
from openai import OpenAI

class ModelBasedAgent:
    """Agent with internal state and memory"""
    
    def __init__(self):
        self.client = OpenAI()
        self.conversation_history = []
        self.world_model = {
            'user_preferences': {},
            'task_history': [],
            'current_context': {}
        }
    
    def update_model(self, observation):
        """Update internal world model"""
        # Extract information from observation
        self.world_model['current_context'] = observation
        self.world_model['task_history'].append(observation)
    
    def decide_action(self, goal):
        """Decide action based on goal and world model"""
        prompt = f"""
        Goal: {goal}
        
        Context from world model:
        - User preferences: {self.world_model['user_preferences']}
        - Recent tasks: {self.world_model['task_history'][-3:]}
        - Current context: {self.world_model['current_context']}
        
        What action should I take?
        """
        
        response = self.client.chat.completions.create(
            model="gpt-4",
            messages=[
                {"role": "system", "content": "You are an intelligent agent."},
                {"role": "user", "content": prompt}
            ]
        )
        
        return response.choices[0].message.content
```

### **Use Cases:**
- Personalized assistants
- Context-aware chatbots
- Task management systems
- Recommendation engines

---

## 3. Goal-Based Agents (ReAct, Plan-and-Execute)

**Definition:** Agents that work towards achieving specific goals through planning and execution.

### **A. ReAct Agents**

Alternates between Reasoning (thinking) and Acting (using tools).

```python
class ReActAgent:
    """Reasoning and Acting agent"""
    
    def __init__(self, tools, llm):
        self.tools = tools
        self.llm = llm
    
    def run(self, goal):
        """Execute goal using ReAct pattern"""
        trajectory = []
        
        for step in range(10):
            # Thought step
            thought = self.llm.generate(
                f"Goal: {goal}\n"
                f"Previous steps: {trajectory}\n"
                f"Thought:"
            )
            
            # Action step
            action = self.llm.generate(
                f"Based on thought: {thought}\n"
                f"Choose action from {list(self.tools.keys())}\n"
                f"Action:"
            )
            
            # Execute
            if "FINISH" in action:
                return self.extract_answer(action)
            
            tool_name, tool_input = self.parse_action(action)
            observation = self.tools[tool_name](tool_input)
            
            trajectory.append({
                'thought': thought,
                'action': action,
                'observation': observation
            })
        
        return "Goal not achieved"
```

### **B. Plan-and-Execute Agents**

Create a complete plan upfront, then execute each step.

```python
class PlanAndExecuteAgent:
    """Plan all steps before execution"""
    
    def __init__(self, tools, planner_llm, executor_llm):
        self.tools = tools
        self.planner = planner_llm
        self.executor = executor_llm
    
    def run(self, goal):
        # Step 1: Create plan
        plan = self.create_plan(goal)
        
        # Step 2: Execute plan
        results = []
        for step in plan:
            result = self.execute_step(step)
            results.append(result)
            
            # Replan if necessary
            if self.needs_replanning(result):
                plan = self.create_plan(goal, results)
        
        return self.synthesize_results(results)
    
    def create_plan(self, goal, previous_results=None):
        """Create step-by-step plan"""
        prompt = f"""
        Goal: {goal}
        Available tools: {list(self.tools.keys())}
        Previous results: {previous_results}
        
        Create a detailed step-by-step plan to achieve the goal.
        Format: 
        1. [Action] - [Description]
        2. [Action] - [Description]
        ...
        """
        
        plan_text = self.planner.generate(prompt)
        return self.parse_plan(plan_text)
    
    def execute_step(self, step):
        """Execute a single step"""
        tool_name = step['tool']
        tool_input = step['input']
        return self.tools[tool_name](tool_input)
```

### **Comparison:**

| Feature | ReAct | Plan-and-Execute |
|---------|-------|------------------|
| Planning | Step-by-step | Upfront |
| Flexibility | High | Medium |
| Efficiency | Lower | Higher |
| Replanning | Easy | Requires full replan |
| Best for | Dynamic tasks | Predictable tasks |

---

## 4. Multi-Agent Systems

**Definition:** Multiple agents working together, each with specialized roles.

### **Architectures:**

#### **A. Sequential Multi-Agent:**

```python
class SequentialMultiAgent:
    """Agents process sequentially"""
    
    def __init__(self, agents):
        self.agents = agents  # List of agents in order
    
    def run(self, task):
        """Pass output from one agent to next"""
        result = task
        
        for agent in self.agents:
            print(f"Agent {agent.name} processing...")
            result = agent.process(result)
        
        return result

# Example: Research pipeline
agents = [
    ResearchAgent(name="Researcher"),
    WriterAgent(name="Writer"),
    EditorAgent(name="Editor")
]

pipeline = SequentialMultiAgent(agents)
article = pipeline.run("Write about AI agents")
```

#### **B. Hierarchical Multi-Agent:**

```python
class HierarchicalMultiAgent:
    """Manager agent delegates to worker agents"""
    
    def __init__(self, manager, workers):
        self.manager = manager
        self.workers = {w.name: w for w in workers}
    
    def run(self, task):
        """Manager delegates subtasks to workers"""
        # Manager creates plan
        plan = self.manager.create_plan(task)
        
        results = {}
        for subtask in plan:
            # Manager assigns to appropriate worker
            worker_name = self.manager.assign_worker(subtask, self.workers.keys())
            worker = self.workers[worker_name]
            
            # Worker executes subtask
            result = worker.execute(subtask)
            results[subtask['id']] = result
        
        # Manager synthesizes results
        final_output = self.manager.synthesize(results)
        return final_output
```

#### **C. Collaborative Multi-Agent:**

```python
class CollaborativeMultiAgent:
    """Agents collaborate and communicate"""
    
    def __init__(self, agents):
        self.agents = agents
        self.shared_memory = SharedMemory()
    
    def run(self, task):
        """Agents collaborate on task"""
        iterations = 0
        max_iterations = 10
        
        while not self.is_complete(task) and iterations < max_iterations:
            for agent in self.agents:
                # Agent reviews shared memory
                context = self.shared_memory.get_context()
                
                # Agent contributes
                contribution = agent.contribute(task, context)
                
                # Update shared memory
                self.shared_memory.add(contribution)
                
                # Check if task is complete
                if contribution.get('complete'):
                    return self.shared_memory.get_final_result()
            
            iterations += 1
        
        return self.shared_memory.get_final_result()
```

### **Use Cases:**
- **Sequential**: Writing pipeline (research → draft → edit → publish)
- **Hierarchical**: Project management (manager → team leads → workers)
- **Collaborative**: Brainstorming, debate, consensus building

---

## 5. Specialized Agent Types

### **A. Swarm Agents**

Multiple simple agents that exhibit emergent behavior.

```python
class SwarmAgent:
    """Part of a swarm with simple rules"""
    
    def __init__(self, agent_id):
        self.id = agent_id
        self.local_knowledge = {}
    
    def act(self, environment, neighbors):
        """Act based on local information and neighbors"""
        # Simple rules leading to emergent behavior
        neighbor_actions = [n.last_action for n in neighbors]
        
        # Follow majority
        if neighbor_actions.count('explore') > len(neighbors) / 2:
            return self.explore(environment)
        else:
            return self.exploit(environment)

class SwarmSystem:
    """Coordinate swarm of agents"""
    
    def __init__(self, num_agents):
        self.agents = [SwarmAgent(i) for i in range(num_agents)]
    
    def run(self, environment, iterations=100):
        """Run swarm simulation"""
        for _ in range(iterations):
            for agent in self.agents:
                neighbors = self.get_neighbors(agent)
                agent.act(environment, neighbors)
            
            # Check convergence
            if self.has_converged():
                break
        
        return self.get_swarm_result()
```

**Use Cases:**
- Optimization problems
- Distributed search
- Simulation and modeling
- Parallel processing

### **B. Deep Agents (ReAct + Self-Reflection)**

Agents that deeply reason and reflect on their actions.

```python
class DeepAgent:
    """Agent with deep reasoning and reflection"""
    
    def __init__(self, llm, tools):
        self.llm = llm
        self.tools = tools
        self.reflection_history = []
    
    def run(self, task):
        """Execute with deep reasoning"""
        max_attempts = 3
        
        for attempt in range(max_attempts):
            # Execute task
            result = self.execute_task(task)
            
            # Reflect on result
            reflection = self.reflect(task, result)
            
            if reflection['satisfactory']:
                return result
            
            # Learn from reflection
            self.learn_from_reflection(reflection)
        
        return result
    
    def reflect(self, task, result):
        """Deep reflection on performance"""
        prompt = f"""
        Task: {task}
        Result: {result}
       
         Previous reflections: {self.reflection_history}
        
        Reflect deeply on:
        1. Was the result satisfactory?
        2. What went well?
        3. What could be improved?
        4. What should I do differently next time?
        
        Reflection:
        """
        
        reflection_text = self.llm.generate(prompt)
        
        return {
            'satisfactory': 'yes' in reflection_text.lower(),
            'insights': reflection_text,
            'improvements': self.extract_improvements(reflection_text)
        }
```

---

## 6. Custom Workflow Agents

**Definition:** Agents with custom-designed workflows for specific use cases.

```python
class CustomWorkflowAgent:
    """Agent with custom workflow logic"""
    
    def __init__(self, workflow_definition):
        self.workflow = workflow_definition
    
    def run(self, input_data):
        """Execute custom workflow"""
        context = {'input': input_data}
        
        for step in self.workflow:
            step_type = step['type']
            
            if step_type == 'llm_call':
                result = self.llm_step(step, context)
            elif step_type == 'tool_use':
                result = self.tool_step(step, context)
            elif step_type == 'condition':
                # Branch based on condition
                if self.evaluate_condition(step['condition'], context):
                    self.workflow = step['if_true']
                else:
                    self.workflow = step['if_false']
                continue
            elif step_type == 'loop':
                result = self.loop_step(step, context)
            
            context[step['name']] = result
        
        return context['output']
```

---

## Parallel vs. Sequential Agents

### **Sequential Execution:**
```python
# One agent finishes before next starts
result1 = agent1.run(task)
result2 = agent2.run(result1)
result3 = agent3.run(result2)
```

### **Parallel Execution:**
```python
import asyncio

async def parallel_agents(task):
    """Run multiple agents in parallel"""
    results = await asyncio.gather(
        agent1.run(task),
        agent2.run(task),
        agent3.run(task)
    )
    
    # Aggregate results
    return aggregate(results)
```

---

## Choosing the Right Agent Type

| Use Case | Recommended Type |
|----------|-----------------|
| Simple Q&A | Reactive |
| Personalized assistant | Model-Based |
| Research tasks | ReAct |
| Structured workflows | Plan-and-Execute |
| Team collaboration | Multi-Agent (Collaborative) |
| Complex projects | Multi-Agent (Hierarchical) |
| Optimization | Swarm |
| Critical tasks | Deep Agent (with reflection) |

---

## Best Practices

1. **Start simple**: Begin with reactive or single-agent systems
2. **Add complexity gradually**: Only add agents when needed
3. **Define clear roles**: Each agent should have specific responsibility
4. **Monitor interactions**: Track agent-to-agent communication
5. **Limit autonomy**: Start with human-in-the-loop
6. **Test thoroughly**: Multi-agent systems are hard to debug
7. **Cost awareness**: More agents = more LLM calls

---

## Next Steps
- Learn agent frameworks (LangChain, LangGraph, CrewAI)
- Implement different agent patterns
- Build multi-agent systems
- Master agent orchestration and communication
