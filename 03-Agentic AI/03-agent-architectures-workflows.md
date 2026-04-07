# Agent Architectures and Workflows

## Overview
Agent architectures define how agents structure their reasoning, planning, and execution processes. Understanding these patterns helps you build more effective and reliable agent systems.

---

## Core Agent Architectures

### **1. ReAct (Reasoning + Acting)**

**Pattern:** Alternate between thinking and acting in a loop.

**Structure:**
```
Thought → Action → Observation → Thought → Action → Observation → ...
```

**Implementation:**
```python
from openai import OpenAI

class ReActAgent:
    """
    Paper: ReAct: Synergizing Reasoning and Acting in Language Models
    https://arxiv.org/abs/2210.03629
    """
    
    def __init__(self, tools):
        self.client = OpenAI()
        self.tools = tools
    
    def run(self, question, max_steps=10):
        """Execute ReAct loop"""
        scratchpad = []
        
        for step in range(1, max_steps + 1):
            # Generate thought and action
            prompt = self.format_prompt(question, scratchpad, step)
            
            response = self.client.chat.completions.create(
                model="gpt-4",
                messages=[
                    {"role": "system", "content": self.get_system_prompt()},
                    {"role": "user", "content": prompt}
                ],
                temperature=0
            )
            
            text = response.choices[0].message.content
            
            # Parse output
            thought = self.extract_thought(text)
            action = self.extract_action(text)
            action_input = self.extract_action_input(text)
            
            scratchpad.append(f"Thought {step}: {thought}")
            scratchpad.append(f"Action {step}: {action}[{action_input}]")
            
            # Check if finished
            if action.lower() == "finish":
                return action_input
            
            # Execute action
            if action in self.tools:
                observation = self.tools[action](action_input)
            else:
                observation = f"Error: Tool '{action}' not found"
            
            scratchpad.append(f"Observation {step}: {observation}")
        
        return "Failed to complete task within step limit"
    
    def get_system_prompt(self):
        return f"""You are an agent that uses tools to solve problems.

Available tools:
{self.format_tools()}

Instructions:
1. Think step-by-step about what to do
2. Choose an action to take
3. Observe the result
4. Repeat until you can answer

Format your response as:
Thought: [your reasoning about what to do next]
Action: [tool name or Finish]
Action Input: [input for the tool or final answer]
"""
    
    def format_tools(self):
        return "\n".join([f"- {name}: {tool.__doc__}" for name, tool in self.tools.items()])

# Example tools
def search(query):
    """Search the web for information"""
    return f"Results for '{query}': [simulated search results]"

def calculator(expression):
    """Evaluate a mathematical expression"""
    try:
        return str(eval(expression))
    except:
        return "Invalid expression"

# Usage
agent = ReActAgent({
    'search': search,
    'calculator': calculator
})

result = agent.run("What is the population of France multiplied by 2?")
print(result)
```

**Pros:**
- ✅ Interpretable reasoning
- ✅ Can recover from mistakes
- ✅ Flexible and adaptive

**Cons:**
- ❌ Can be verbose (many LLM calls)
- ❌ May get stuck in loops
- ❌ Expensive for complex tasks

---

### **2. Plan-and-Execute**

**Pattern:** Create complete plan first, then execute all steps.

**Structure:**
```
Plan → Execute Step 1 → Execute Step 2 → ... → Synthesize
```

**Implementation:**
```python
class PlanAndExecuteAgent:
    """Plan all steps upfront, then execute"""
    
    def __init__(self, tools, planner_llm, executor_llm):
        self.tools = tools
        self.planner = planner_llm
        self.executor = executor_llm
    
    def run(self, objective):
        """Execute plan-and-execute workflow"""
        # Step 1: Create plan
        plan = self.create_plan(objective)
        print(f"Plan created with {len(plan)} steps")
        
        # Step 2: Execute each step
        results = []
        for i, step in enumerate(plan, 1):
            print(f"\nExecuting step {i}: {step['description']}")
            
            result = self.execute_step(step, results)
            results.append({
                'step': step,
                'result': result
            })
            
            # Optional: Replan if needed
            if self.should_replan(step, result, objective):
                print("Replanning...")
                remaining_steps = self.replan(objective, plan[i:], results)
                plan = plan[:i] + remaining_steps
        
        # Step 3: Synthesize final answer
        final_answer = self.synthesize(objective, results)
        return final_answer
    
    def create_plan(self, objective):
        """Generate step-by-step plan"""
        prompt = f"""Create a detailed plan to achieve this objective:
        
Objective: {objective}

Available tools: {list(self.tools.keys())}

Create a plan as a numbered list of steps.
Each step should specify:
- What to do
- Which tool to use (if any)
- What information is needed

Plan:"""
        
        plan_text = self.planner.generate(prompt)
        return self.parse_plan(plan_text)
    
    def execute_step(self, step, previous_results):
        """Execute a single planned step"""
        tool_name = step.get('tool')
        
        if tool_name and tool_name in self.tools:
            # Extract input for tool
            tool_input = self.prepare_tool_input(step, previous_results)
            
            # Execute tool
            result = self.tools[tool_name](tool_input)
        else:
            # Use LLM to complete step
            result = self.executor.generate(
                f"Complete this step: {step['description']}\n"
                f"Previous results: {previous_results}"
            )
        
        return result
    
    def should_replan(self, step, result, objective):
        """Determine if replanning is needed"""
        # Check if result indicates failure or unexpected outcome
        if "error" in result.lower() or "failed" in result.lower():
            return True
        
        # Use LLM to decide
        check_prompt = f"""
        Objective: {objective}
        Step completed: {step['description']}
        Result: {result}
        
        Should we replan the remaining steps? (yes/no)
        Answer:"""
        
        response = self.planner.generate(check_prompt)
        return "yes" in response.lower()
    
    def synthesize(self, objective, results):
        """Combine all results into final answer"""
        results_text = "\n".join([
            f"Step {i}: {r['step']['description']}\nResult: {r['result']}"
            for i, r in enumerate(results, 1)
        ])
        
        prompt = f"""Objective: {objective}

Execution results:
{results_text}

Synthesize a final answer to the objective based on these results:"""
        
        return self.planner.generate(prompt)
```

**Pros:**
- ✅ Efficient (fewer LLM calls)
- ✅ Can parallelize execution
- ✅ Clear structure

**Cons:**
- ❌ Less adaptive to unexpected results
- ❌ Harder to recover from errors
- ❌ May create suboptimal plans

---

### **3. ReWOO (Reasoning WithOut Observation)**

**Pattern:** Plan all tool calls upfront without waiting for results.

**Structure:**
```
Plan all tool calls → Execute all in parallel → Solve with results
```

**Implementation:**
```python
class ReWOOAgent:
    """
    Paper: ReWOO: Decoupling Reasoning from Observations
    """
    
    def __init__(self, tools):
        self.tools = tools
        self.llm = LLM()
    
    def run(self, task):
        # Step 1: Planner - Generate plan with placeholders
        plan = self.plan(task)
        # Example: ["#E1 = search[AI agents]", "#E2 = calculator[#E1.count * 2]"]
        
        # Step 2: Worker - Execute all tool calls
        evidence = self.execute_plan(plan)
        # Example: {"#E1": "10 results found", "#E2": "20"}
        
        # Step 3: Solver - Generate final answer
        answer = self.solve(task, plan, evidence)
        
        return answer
    
    def plan(self, task):
        """Generate plan with variable placeholders"""
        prompt = f"""Task: {task}

Create a plan using these tools: {list(self.tools.keys())}

Format each step as: #E[number] = tool[input]
Use #E[number] to reference previous results.

Plan:"""
        
        plan_text = self.llm.generate(prompt)
        return self.parse_plan_steps(plan_text)
    
    def execute_plan(self, plan):
        """Execute all planned tool calls"""
        evidence = {}
        
        for step in plan:
            var_name = step['var']  # e.g., "#E1"
            tool_name = step['tool']
            tool_input = step['input']
            
            # Replace variable references
            for prev_var, prev_result in evidence.items():
                tool_input = tool_input.replace(prev_var, str(prev_result))
            
            # Execute tool
            result = self.tools[tool_name](tool_input)
            evidence[var_name] = result
        
        return evidence
    
    def solve(self, task, plan, evidence):
        """Generate final answer using evidence"""
        evidence_text = "\n".join([f"{k} = {v}" for k, v in evidence.items()])
        
        prompt = f"""Task: {task}

Plan executed:
{self.format_plan(plan)}

Evidence:
{evidence_text}

Based on this evidence, what is the answer to the task?

Answer:"""
        
        return self.llm.generate(prompt)
```

**Pros:**
- ✅ Very efficient (parallel execution)
- ✅ Fewer LLM calls than ReAct
- ✅ Explicit dependency management

**Cons:**
- ❌ Can't adapt to observations
- ❌ May plan unnecessary steps
- ❌ Requires accurate upfront planning

---

### **4. Reflexion (Self-Reflecting Agent)**

**Pattern:** Execute → Reflect → Learn → Retry

**Structure:**
```
Attempt → Evaluate → Reflect → Store learning → Retry with improvements
```

**Implementation:**
```python
class ReflexionAgent:
    """
    Paper: Reflexion: Language Agents with Verbal Reinforcement Learning
    """
    
    def __init__(self, tools, max_attempts=3):
        self.tools = tools
        self.llm = LLM()
        self.max_attempts = max_attempts
        self.memory = []  # Store reflections
    
    def run(self, task):
        """Execute with reflection and improvement"""
        
        for attempt in range(1, self.max_attempts + 1):
            print(f"\n=== Attempt {attempt} ===")
            
            # Execute task
            trajectory, answer = self.execute(task, self.memory)
            
            # Evaluate result
            score = self.evaluate(task, answer)
            
            if score >= 0.8:  # Success threshold
                return answer
            
            # Reflect on failure
            reflection = self.reflect(task, trajectory, answer, score)
            
            # Store reflection in memory
            self.memory.append({
                'attempt': attempt,
                'trajectory': trajectory,
                'answer': answer,
                'score': score,
                'reflection': reflection
            })
            
            print(f"Score: {score}")
            print(f"Reflection: {reflection}")
        
        return answer  # Return best attempt
    
    def execute(self, task, memory):
        """Execute task with awareness of past reflections"""
        prompt = f"""Task: {task}

{self.format_memory(memory)}

Execute the task step by step. Learn from past mistakes.

Response:"""
        
        response = self.llm.generate(prompt)
        
        # Parse trajectory and answer
        trajectory = self.extract_trajectory(response)
        answer = self.extract_answer(response)
        
        return trajectory, answer
    
    def reflect(self, task, trajectory, answer, score):
        """Generate reflection on performance"""
        prompt = f"""Task: {task}

Your attempt:
{trajectory}

Your answer: {answer}
Score: {score}/1.0

Reflect on what went wrong and how to improve:
1. What mistakes did you make?
2. What could you have done differently?
3. What will you do better next time?

Reflection:"""
        
        reflection = self.llm.generate(prompt)
        return reflection
    
    def evaluate(self, task, answer):
        """Evaluate answer quality"""
        # Could use various methods:
        # - LLM-as-judge
        # - Comparison with ground truth
        # - Execution-based validation
        
        eval_prompt = f"""Task: {task}
Answer: {answer}

Rate this answer from 0.0 to 1.0:
Score:"""
        
        score_text = self.llm.generate(eval_prompt)
        return float(score_text.strip())
```

**Pros:**
- ✅ Learns from failures
- ✅ Improves over attempts
- ✅ Builds experiential memory

**Cons:**
- ❌ Requires multiple attempts
- ❌ Expensive (many LLM calls)
- ❌ May not converge

---

## Workflow Patterns

### **1. Sequential Workflow**
```python
class SequentialWorkflow:
    """Linear sequence of steps"""
    
    def run(self, input_data):
        result = input_data
        
        # Step 1
        result = self.step1(result)
        
        # Step 2
        result = self.step2(result)
        
        # Step 3
        result = self.step3(result)
        
        return result
```

### **2. Conditional Workflow**
```python
class ConditionalWorkflow:
    """Branch based on conditions"""
    
    def run(self, input_data):
        result = self.initial_step(input_data)
        
        if self.condition_a(result):
            return self.branch_a(result)
        elif self.condition_b(result):
            return self.branch_b(result)
        else:
            return self.default_branch(result)
```

### **3. Loop Workflow**
```python
class LoopWorkflow:
    """Repeat until condition met"""
    
    def run(self, input_data):
        result = input_data
        iterations = 0
        max_iterations = 10
        
        while not self.is_complete(result) and iterations < max_iterations:
            result = self.process_iteration(result)
            iterations += 1
        
        return result
```

### **4. Parallel Workflow**
```python
import asyncio

class ParallelWorkflow:
    """Execute multiple branches in parallel"""
    
    async def run(self, input_data):
        # Start all branches
        tasks = [
            self.branch_a(input_data),
            self.branch_b(input_data),
            self.branch_c(input_data)
        ]
        
        # Wait for all to complete
        results = await asyncio.gather(*tasks)
        
        # Combine results
        return self.merge(results)
```

---

## Architecture Comparison

| Architecture | LLM Calls | Adaptability | Efficiency | Complexity |
|--------------|-----------|--------------|------------|------------|
| ReAct | High | High | Low | Medium |
| Plan-and-Execute | Medium | Medium | High | Medium |
| ReWOO | Low | Low | Very High | Low |
| Reflexion | Very High | Very High | Low | High |

---

## Best Practices

1. **Choose based on task:**
   - Dynamic tasks → ReAct
   - Predictable tasks → Plan-and-Execute
   - Parallel tasks → ReWOO
   - Critical tasks → Reflexion

2. **Hybrid approaches:** Combine patterns as needed

3. **Add guardrails:** Prevent infinite loops and excessive costs

4. **Monitor performance:** Track success rates and costs

5. **Iterative development:** Start simple, add complexity

---

## Next Steps
- Implement each architecture pattern
- Compare performance on your use cases
- Learn agent frameworks that support these patterns
- Build hybrid architectures
