# Hands-On Agent Building

## Overview

This hands-on guide provides practical, working code examples for building AI agents from scratch using modern frameworks. We'll cover everything from simple agents to complex multi-agent systems with real-world implementations.

**Prerequisites:**
- Python 3.10+
- Basic understanding of LLMs
- Familiarity with async programming
- API keys (OpenAI, Anthropic, or Google)

---

## Setup & Installation

### **Install Dependencies**

```bash
# Create virtual environment
python -m venv agent-env
source agent-env/bin/activate  # On Windows: agent-env\Scripts\activate

# Install core packages
pip install -U pip

# LangChain ecosystem
pip install langchain langchain-openai langchain-community langgraph langsmith

# CrewAI
pip install crewai crewai-tools

# Additional tools
pip install python-dotenv requests beautifulsoup4 duckduckgo-search

# Monitoring
pip install opentelemetry-api opentelemetry-sdk
```

### **Environment Configuration**

```python
# .env file
OPENAI_API_KEY=sk-...
ANTHROPIC_API_KEY=sk-ant-...
GOOGLE_API_KEY=...
LANGSMITH_API_KEY=...
LANGSMITH_TRACING=true
```

```python
# config.py
from dotenv import load_dotenv
import os

load_dotenv()

OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
ANTHROPIC_API_KEY = os.getenv("ANTHROPIC_API_KEY")
```

---

## Example 1: Simple ReAct Agent (LangChain)

### **Basic Agent with Tools**

```python
from langchain.agents import AgentExecutor, create_react_agent
from langchain_openai import ChatOpenAI
from langchain.tools import Tool
from langchain import hub
import requests

# Define custom tools
def search_web(query: str) -> str:
    """Search the web using DuckDuckGo."""
    from duckduckgo_search import DDGS
    
    try:
        results = DDGS().text(query, max_results=5)
        formatted = "\n\n".join([
            f"Title: {r['title']}\nSnippet: {r['body']}\nURL: {r['href']}"
            for r in results
        ])
        return formatted
    except Exception as e:
        return f"Error searching: {str(e)}"

def calculate(expression: str) -> str:
    """Safely evaluate mathematical expressions."""
    try:
        # Safe eval - only allow numbers and operators
        allowed_chars = set("0123456789+-*/(). ")
        if not set(expression) <= allowed_chars:
            return "Invalid expression"
        result = eval(expression)
        return str(result)
    except Exception as e:
        return f"Error: {str(e)}"

# Create tools list
tools = [
    Tool(
        name="WebSearch",
        func=search_web,
        description="Search the internet for current information. Input should be a search query string."
    ),
    Tool(
        name="Calculator",
        func=calculate,
        description="Perform mathematical calculations. Input should be a mathematical expression."
    )
]

# Initialize LLM
llm = ChatOpenAI(model="gpt-4o", temperature=0)

# Get ReAct prompt from hub
prompt = hub.pull("hwchase17/react")

# Create agent
agent = create_react_agent(llm, tools, prompt)

# Create executor
agent_executor = AgentExecutor(
    agent=agent,
    tools=tools,    verbose=True,
    handle_parsing_errors=True,
    max_iterations=5
)

# Run agent
if __name__ == "__main__":
    result = agent_executor.invoke({
        "input": "What's the population of Tokyo in 2026 multiplied by 2?"
    })
    print("\nFinal Answer:", result["output"])
```

### **Output Example:**
```
> Entering new AgentExecutor chain...
I need to find the current population of Tokyo and then multiply it.

Action: WebSearch
Action Input: "Tokyo population 2026"

Observation: Title: Tokyo Population 2026
Snippet: Tokyo's population is estimated at 14.1 million in 2026...

Thought: Now I have the population, I need to multiply by 2.

Action: Calculator
Action Input: 14.1 * 2

Observation: 28.2

Thought: I now know the final answer.

Final Answer: The population of Tokyo in 2026 (approximately 14.1 million) multiplied by 2 is 28.2 million.
```

---

## Example 2: Agent with Memory (LangChain)

### **Conversation Agent with Context**

```python
from langchain.agents import AgentExecutor, create_openai_functions_agent
from langchain_openai import ChatOpenAI
from langchain.memory import ConversationBufferMemory
from langchain.prompts import ChatPromptTemplate, MessagesPlaceholder
from langchain.tools import Tool

# Define tools
def get_user_preference(user_id: str, preference_type: str) -> str:
    """Retrieve user preferences from a database (simulated)."""
    # In production, this would query a real database
    preferences = {
        "user123": {
            "language": "English",
            "timezone": "PST",
            "interests": ["AI", "Python", "Travel"]
        }
    }
    return str(preferences.get(user_id, {}).get(preference_type, "Not found"))

def save_user_note(user_id: str, note: str) -> str:
    """Save a note for the user."""
    # In production write to database
    print(f"Saving note for {user_id}: {note}")
    return "Note saved successfully"

tools = [
    Tool(
        name="GetUserPreference",
        func=get_user_preference,
        description="Get user preferences. Args: user_id (str), preference_type (str)"
    ),
    Tool(
        name="SaveNote",  
        func=save_user_note,
        description="Save a note for the user. Args: user_id (str), note (str)"
    )
]

# Create prompt with memory placeholder
prompt = ChatPromptTemplate.from_messages([
    ("system", "You are a helpful assistant with memory of past conversations."),
    MessagesPlaceholder(variable_name="chat_history"),
    ("human", "{input}"),
    MessagesPlaceholder(variable_name="agent_scratchpad"),
])

# Initialize LLM and memory
llm = ChatOpenAI(model="gpt-4o", temperature=0)
memory = ConversationBufferMemory(
    memory_key="chat_history",
    return_messages=True
)

# Create agent
agent = create_openai_functions_agent(llm, tools, prompt)

agent_executor = AgentExecutor(
    agent=agent,
    tools=tools,
    memory=memory,
    verbose=True,
    handle_parsing_errors=True
)

# Example conversation
if __name__ == "__main__":
    # First message
    response1 = agent_executor.invoke({
        "input": "My name is John and I love AI. Can you remember that?"
    })
    print("Response 1:", response1["output"])
    
    # Second message - tests memory
    response2 = agent_executor.invoke({
        "input": "What's my name and what do I love?"
    })
    print("Response 2:", response2["output"])
    
    # Third message - using tools
    response3 = agent_executor.invoke({
        "input": "Save a note that I want to learn about LangGraph"
    })
    print("Response 3:", response3["output"])
```

---

## Example 3: LangGraph Agent with State

### **Custom State-Based Agent**

```python
from typing import TypedDict, Annotated, Sequence
from langgraph.graph import Graph, StateGraph, END
from langgraph.prebuilt import ToolExecutor, ToolInvocation
from langchain_openai import ChatOpenAI
from langchain.tools import tool
import operator

# Define state
class AgentState(TypedDict):
    messages: Annotated[Sequence[str], operator.add]
    current_step: int
    task_complete: bool
    collected_info: dict

# Define tools
@tool
def research_topic(topic: str) -> str:
    """Research a topic and return information."""
    # Simulated research
    return f"Research results for {topic}: [Detailed information...]"

@tool  
def analyze_data(data: str) -> str:
    """Analyze data and return insights."""
    return f"Analysis of {data}: [Key insights...]"

@tool
def generate_report(info: dict) -> str:
    """Generate a final report from collected information."""
    return f"Report generated from: {info}"

tools = [research_topic, analyze_data, generate_report]
tool_executor = ToolExecutor(tools)

# Initialize LLM
llm = ChatOpenAI(model="gpt-4o", temperature=0).bind_tools(tools)

# Define nodes
def should_continue(state: AgentState) -> str:
    """Determine if we should continue or end."""
    if state["task_complete"]:
        return "end"
    if state["current_step"] >= 5:
        return "end"
    return "continue"

def call_model(state: AgentState) -> AgentState:
    """Call the LLM to decide next action."""
    messages = state["messages"]
    response = llm.invoke(messages)
    
    return {
        **state,
        "messages": [response],
        "current_step": state["current_step"] + 1
    }

def execute_tools(state: AgentState) -> AgentState:
    """Execute the tools that the LLM decided to use."""
    last_message = state["messages"][-1]
    
    # Check if there are tool calls
    if hasattr(last_message, "tool_calls") and last_message.tool_calls:
        tool_call = last_message.tool_calls[0]
        
        # Execute tool
        action = ToolInvocation(
            tool=tool_call["name"],
            tool_input=tool_call["args"]
        )
        response = tool_executor.invoke(action)
        
        # Update state
        return {
            **state,
            "messages": [f"Tool result: {response}"],
            "collected_info": {
                **state.get("collected_info", {}),
                tool_call["name"]: response
            }
        }
    
    return state

# Build graph
workflow = StateGraph(AgentState)

# Add nodes
workflow.add_node("agent", call_model)
workflow.add_node("tools", execute_tools)

# Set entry point
workflow.set_entry_point("agent")

# Add conditional edges
workflow.add_conditional_edges(
    "agent",
    should_continue,
    {
        "continue": "tools",
        "end": END
    }
)

workflow.add_edge("tools", "agent")

# Compile
app = workflow.compile()

# Run the agent
if __name__ == "__main__":
    initial_state = {
        "messages": ["Research AI agents and create a report"],
        "current_step": 0,
        "task_complete": False,
        "collected_info": {}
    }
    
    result = app.invoke(initial_state)
    print("Final State:", result)
```

---

## Example 4: CrewAI Multi-Agent System

### **Research and Writing Crew**

```python
from crewai import Agent, Task, Crew, Process
from crewai_tools import SerperDevTool, ScrapeWebsiteTool

# Initialize tools
search_tool = SerperDevTool()
scrape_tool = ScrapeWebsiteTool()

# Define agents
researcher = Agent(
    role='Senior Research Analyst',
    goal='Discover groundbreaking insights in {topic}',
    backstory="""
    You're a seasoned research analyst with a keen eye for detail.
    You excel at finding and synthesizing information from multiple sources.
    You always cite your sources and present data objectively.
    """,
    tools=[search_tool, scrape_tool],
    verbose=True,
    allow_delegation=False
)

writer = Agent(
    role='Tech Content Writer',
    goal='Create engaging and accurate content about {topic}',
    backstory="""
    You're an award-winning tech writer known for making complex topics
    accessible and engaging. You have a talent for storytelling while
    maintaining technical accuracy.
    """,
    verbose=True,
    allow_delegation=False
)

editor = Agent(
    role='Content Editor',
    goal='Ensure content is polished, accurate, and engaging',
    backstory="""
    You're a meticulous editor with years of experience in technical publishing.
    You ensure clarity, accuracy, and proper structure in all content.
    """,
    verbose=True,
    allow_delegation=False
)

# Define tasks
research_task = Task(
    description="""
    Research the topic: {topic}
    
    1. Search for the latest information  
    2. Identify 5 key insights
    3. Find credible sources  
    4. Document all findings with citations
    
    Provide a comprehensive research report.
    """,
    agent=researcher,
    expected_output="Detailed research report with citations"
)

writing_task = Task(
    description="""
    Using the research provided, write a comprehensive article about {topic}.
    
    Requirements:
    - 800-1000 words
    - Clear introduction, body, and conclusion
    - Engaging and accessible language
    - Include all important findings from research
    - Proper citations
    
    Focus on making it informative yet readable.
    """,
    agent=writer,
    expected_output="Complete article draft"
)

editing_task = Task(
    description="""
    Edit and polish the article.
    
    Check for:
    - Grammar and spelling
    - Clarity and flow
    - Technical accuracy
    - Proper structure
    - Citation format
    
    Provide the final, publication-ready version.
    """,
    agent=editor,
    expected_output="Polished final article",
    context=[research_task, writing_task]  # Has access to previous tasks
)

# Create crew
crew = Crew(
    agents=[researcher, writer, editor],
    tasks=[research_task, writing_task, editing_task],
    process=Process.sequential,  # Tasks executed in order
    verbose=2
)

# Execute
if __name__ == "__main__":
    result = crew.kickoff(inputs={'topic': 'AI Agents in 2026'})
    
    print("\n========== FINAL ARTICLE ==========\n")
    print(result)
```

---

## Example 5: Custom Tool Creation

### **Advanced Tool with Validation**

```python
from typing import Optional, Type
from pydantic import BaseModel, Field, validator
from langchain.tools import BaseTool

class WeatherInput(BaseModel):
    """Input for the weather  tool."""
    location: str = Field(description="City name, e.g., 'Tokyo' or 'New York'")
    unit: Optional[str] = Field(default="celsius", description="Temperature unit: 'celsius' or 'fahrenheit'")
    
    @validator('unit')
    def validate_unit(cls, v):
        if v.lower() not in ['celsius', 'fahrenheit']:
            raise ValueError("Unit must be 'celsius' or 'fahrenheit'")
        return v.lower()
    
    @validator('location')
    def validate_location(cls, v):
        if not v or len(v.strip()) == 0:
            raise ValueError("Location cannot be empty")
        return v.strip()

class WeatherTool(BaseTool):
    name = "get_weather"
    description = "Get current weather for a location. Use this when you need weather information."
    args_schema: Type[BaseModel] = WeatherInput
    
    def _run(self, location: str, unit: str = "celsius") -> str:
        """Get weather synchronously."""
        try:
            # In production, call real weather API
            # For demo, return simulated data
            temp = 22 if unit == "celsius" else 72
            
            return f"""
            Weather in {location}:
            Temperature: {temp}°{unit[0].upper()}
            Condition: Partly Cloudy
            Humidity: 65%
            Wind: 10 km/h
            """
        except Exception as e:
            return f"Error getting weather: {str(e)}"
    
    async def _arun(self, location: str, unit: str = "celsius") -> str:
        """Get weather asynchronously."""
        # Async implementation
        return self._run(location, unit)

# Usage with agent
from langchain.agents import AgentExecutor, create_openai_functions_agent
from langchain_openai import ChatOpenAI
from langchain.prompts import ChatPromptTemplate, MessagesPlaceholder

llm = ChatOpenAI(model="gpt-4o")
weather_tool = WeatherTool()

prompt = ChatPromptTemplate.from_messages([
    ("system", "You are a helpful assistant."),
    ("human", "{input}"),
    MessagesPlaceholder(variable_name="agent_scratchpad"),
])

agent = create_openai_functions_agent(llm, [weather_tool], prompt)
agent_executor = AgentExecutor(agent=agent, tools=[weather_tool], verbose=True)

if __name__ == "__main__":
    result = agent_executor.invoke({
        "input": "What's the weather like in Tokyo?"
    })
    print(result["output"])
```

---

## Example 6: Hierarchical Multi-Agent System

### **Manager-Worker Pattern with LangGraph**

```python
from typing import TypedDict, List
from langgraph.graph import StateGraph, END
from langchain_openai import ChatOpenAI
from langchain.prompts import ChatPromptTemplate

# Define state
class TeamState(TypedDict):
    task: str
    subtasks: List[dict]
    completed_subtasks: List[dict]
    final_result: str
    current_worker: str

# Create Workers
class Worker:
    def __init__(self, name: str, specialty: str):
        self.name = name
        self.specialty = specialty
        self.llm = ChatOpenAI(model="gpt-4o", temperature=0.7)
    
    def work(self, task: str) -> str:
        """Execute assigned task."""
        prompt = f"""
        You are a {self.specialty} specialist.
        Complete this task: {task}
        
        Provide detailed, high-quality output.
        """
        response = self.llm.invoke(prompt)
        return response.content

# Create Manager
class Manager:
    def __init__(self):
        self.llm = ChatOpenAI(model="gpt-4o", temperature=0)
        self.workers = {
            "researcher": Worker("researcher", "research and data gathering"),
            "analyzer": Worker("analyzer", "data analysis and insights"),
            "writer": Worker("writer", "content creation and writing")
        }
    
    def plan(self, task: str) -> List[dict]:
        """Break down task into subtasks."""
        prompt = f"""
        Break down this task into 3-5 subtasks: {task}
        
        For each subtask specify:
        1. Description
        2. Which worker: researcher, analyzer, or writer
        3. Expected output
        
        Return as a list of subtasks.
        """
        response = self.llm.invoke(prompt)
        
        # Parse response into subtasks
        # In production, use structured output
        subtasks = [
            {"id": 1, "description": "Research topic", "worker": "researcher"},
            {"id": 2, "description": "Analyze findings", "worker": "analyzer"},
            {"id": 3, "description": "Write report", "worker": "writer"}
        ]
        return subtasks
    
    def synthesize(self, results: List[dict]) -> str:
        """Combine worker outputs into final result."""
        combined = "\n\n".join([r["output"] for r in results])
        
        prompt = f"""
        Synthesize these outputs into a coherent final result:
        
        {combined}
        
        Create a comprehensive, well-structured final deliverable.
        """
        response = self.llm.invoke(prompt)
        return response.content

# Build workflow
def create_hierarchical_workflow():
    workflow = StateGraph(TeamState)
    manager = Manager()
    
    def planning_node(state: TeamState) -> TeamState:
        """Manager creates plan."""
        subtasks = manager.plan(state["task"])
        return {**state, "subtasks": subtasks, "completed_subtasks": []}
    
    def worker_node(state: TeamState) -> TeamState:
        """Workers execute their tasks."""
        subtasks = state["subtasks"]
        completed = state["completed_subtasks"]
        
        if len(completed) < len(subtasks):
            # Get next subtask
            current_subtask = subtasks[len(completed)]
            worker_name = current_subtask["worker"]
            worker = manager.workers[worker_name]
            
            # Execute
            result = worker.work(current_subtask["description"])
            
            # Store result
            completed.append({
                **current_subtask,
                "output": result
            })
            
            return {
                **state,
                "completed_subtasks": completed,
                "current_worker": worker_name
            }
        
        return state
    
    def synthesis_node(state: TeamState) -> TeamState:
        """Manager synthesizes results."""
        final_result = manager.synthesize(state["completed_subtasks"])
        return {**state, "final_result": final_result}
    
    def should_continue(state: TeamState) -> str:
        """Check if more work needed."""
        if len(state["completed_subtasks"]) >= len(state["subtasks"]):
            return "synthesize"
        return "work"
    
    # Add nodes
    workflow.add_node("plan", planning_node)
    workflow.add_node("work", worker_node)
    workflow.add_node("synthesize", synthesis_node)
    
    # Define flow
    workflow.set_entry_point("plan")
    workflow.add_edge("plan", "work")
    workflow.add_conditional_edges(
        "work",
        should_continue,
        {"work": "work", "synthesize": "synthesize"}
    )
    workflow.add_edge("synthesize", END)
    
    return workflow.compile()

# Run
if __name__ == "__main__":
    app = create_hierarchical_workflow()
    
    result = app.invoke({
        "task": "Create a comprehensive report on sustainable energy trends",
        "subtasks": [],
        "completed_subtasks": [],
        "final_result": "",
        "current_worker": ""
    })
    
    print("\n========== FINAL RESULT ==========\n")
    print(result["final_result"])
```

---

## Example 7: Agent with External Memory

### **Vector Store Memory Implementation**

```python
from langchain.agents import AgentExecutor, create_openai_functions_agent
from langchain_openai import ChatOpenAI, OpenAIEmbeddings
from langchain.vectorstores import Chroma
from langchain.memory import VectorStoreMemory
from langchain.schema import Document
from langchain.prompts import ChatPromptTemplate, MessagesPlaceholder

# Initialize vector store for memory
embeddings = OpenAIEmbeddings()
vectorstore = Chroma(
    collection_name="agent_memory",
    embedding_function=embeddings,
    persist_directory="./agent_memory_db"
)

# Create memory
memory = VectorStoreMemory(
    vectorstore=vectorstore,
    memory_key="history",
    return_docs=True,
    k=5  # Retrieve top 5 relevant memories
)

# Create agent with memory
llm = ChatOpenAI(model="gpt-4o")

prompt = ChatPromptTemplate.from_messages([
    ("system", """You are a helpful assistant with long-term memory.
    You remember past conversations and user preferences.
    
    Relevant memories:
    {history}
    """),
    ("human", "{input}"),
    MessagesPlaceholder(variable_name="agent_scratchpad"),
])

agent = create_openai_functions_agent(llm, [], prompt)
agent_executor = AgentExecutor(agent=agent, tools=[], memory=memory, verbose=True)

# Helper to add memories manually
def add_memory(text: str, metadata: dict = None):
    """Add a memory to the vector store."""
    doc = Document(page_content=text, metadata=metadata or {})
    vectorstore.add_documents([doc])

# Usage
if __name__ == "__main__":
    # Add some initial memories
    add_memory("User's name is Alice", {"type": "personal"})
    add_memory("Alice prefers Python over JavaScript", {"type": "preference"})
    add_memory("Alice is working on an AI project", {"type": "project"})
    
    # Query that should retrieve memories
    result = agent_executor.invoke({
        "input": "What programming language do I prefer?"
    })
    
    print(result["output"])
    
    # Add new memory based on conversation
    add_memory("Alice asked about programming languages on 2026-04-07")
```

---

## Example 8: Streaming Agent Responses

### **Real-time Streaming Implementation**

```python
from langchain.agents import AgentExecutor, create_openai_functions_agent
from langchain_openai import ChatOpenAI
from langchain.prompts import ChatPromptTemplate, MessagesPlaceholder
from langchain.callbacks.streaming_stdout import StreamingStdOutCallbackHandler
from langchain.callbacks.base import BaseCallbackHandler

class CustomStreamingHandler(BaseCallbackHandler):
    """Custom handler for streaming agent tokens."""
    
    def on_llm_new_token(self, token: str, **kwargs) -> None:
        """Handle new token."""
        print(token, end="", flush=True)
    
    def on_tool_start(self, serialized: dict, input_str: str, **kwargs) -> None:
        """Handle tool start."""
        print(f"\n[Using tool: {serialized.get('name')}]", flush=True)
    
    def on_tool_end(self, output: str, **kwargs) -> None:
        """Handle tool end."""
        print(f"\n[Tool completed]\n", flush=True)
    
    def on_agent_action(self, action, **kwargs) -> None:
        """Handle agent action."""
        print(f"\n[Action: {action.tool}]\n", flush=True)

# Create streaming LLM
llm = ChatOpenAI(
    model="gpt-4o",
    streaming=True,
    callbacks=[CustomStreamingHandler()]
)

prompt = ChatPromptTemplate.from_messages([
    ("system", "You are a helpful assistant."),
    ("human", "{input}"),
    MessagesPlaceholder(variable_name="agent_scratchpad"),
])

agent = create_openai_functions_agent(llm, [], prompt)
agent_executor = AgentExecutor(
    agent=agent,
    tools=[],
    verbose=False,  # We handle output via streaming
    callbacks=[CustomStreamingHandler()]
)

if __name__ == "__main__":
    print("Streaming response:\n")
    agent_executor.invoke({
        "input": "Tell me a short story about an AI agent."
    })
```

---

## Example 9: Error Handling & Recovery

### **Robust Agent with Error Handling**

```python
from langchain.agents import AgentExecutor, create_openai_functions_agent
from langchain_openai import ChatOpenAI
from langchain.tools import tool
from langchain.prompts import ChatPromptTemplate, MessagesPlaceholder
from typing import Optional
import time

class RateLimitError(Exception):
    pass

class ToolExecutionError(Exception):
    pass

@tool
def unreliable_api(query: str, fail_rate: float = 0.3) -> str:
    """An API that sometimes fails (for demonstration)."""
    import random
    
    if random.random() < fail_rate:
        raise ToolExecutionError("API temporarily unavailable")
    
    return f"Results for: {query}"

@tool
def fallback_api(query: str) -> str:
    """Backup API that always works."""
    return f"Fallback results for: {query}"

class RetryableAgentExecutor(AgentExecutor):
    """Agent executor with retry logic."""
    
    def __init__(self, *args, max_retries=3, **kwargs):
        super().__init__(*args, **kwargs)
        self.max_retries = max_retries
    
    def _call(self, inputs, **kwargs):
        """Override to add retry logic."""
        for attempt in range(self.max_retries):
            try:
                return super()._call(inputs, **kwargs)
            except ToolExecutionError as e:
                if attempt == self.max_retries - 1:
                    # Last attempt - try fallback
                    print(f"All retries failed, using fallback strategy")
                    # Modify input to use fallback tool
                    return self._fallback_strategy(inputs)
                
                wait_time = 2 ** attempt  # Exponential backoff
                print(f"Attempt{attempt + 1} failed: {e}. Retrying in {wait_time}s...")
                time.sleep(wait_time)
            except Exception as e:
                print(f"Unexpected error: {e}")
                return {"output": f"Error: {str(e)}"}
    
    def _fallback_strategy(self, inputs):
        """Execute fallback when main strategy fails."""
        # Implementation of fallback logic
        return {"output": "Executed fallback strategy"}

# Usage
llm = ChatOpenAI(model="gpt-4o")
tools = [unreliable_api, fallback_api]

prompt = ChatPromptTemplate.from_messages([
    ("system", """You are a helpful assistant.
    If the primary API fails, try the fallback API."""),
    ("human", "{input}"),
    MessagesPlaceholder(variable_name="agent_scratchpad"),
])

agent = create_openai_functions_agent(llm, tools, prompt)
agent_executor = RetryableAgentExecutor(
    agent=agent,
    tools=tools,
    verbose=True,
    max_retries=3
)

if __name__ == "__main__":
    result = agent_executor.invoke({
        "input": "Search for information about AI safety"
    })
    print(result["output"])
```

---

## Example 10: Testing Agents

### **Comprehensive Agent Testing**

```python
import pytest
from langchain.agents import AgentExecutor, create_openai_functions_agent
from langchain_openai import ChatOpenAI
from langchain.tools import tool
from langchain.prompts import ChatPromptTemplate, MessagesPlaceholder
from unittest.mock import Mock, patch

# Tool to test
@tool
def get_weather(location: str) -> str:
    """Get weather for a location."""
    # In tests, we can mock this
    return f"Weather in {location}: Sunny, 22°C"

# Create agent function
def create_weather_agent():
    llm = ChatOpenAI(model="gpt-4o", temperature=0)
    tools = [get_weather]
    
    prompt = ChatPromptTemplate.from_messages([
        ("system", "You are a weather assistant."),
        ("human", "{input}"),
        MessagesPlaceholder(variable_name="agent_scratchpad"),
    ])
    
    agent = create_openai_functions_agent(llm, tools, prompt)
    return AgentExecutor(agent=agent, tools=tools, verbose=False)

# Tests
class TestWeatherAgent:
    """Test suite for weather agent."""
    
    @pytest.fixture
    def agent(self):
        """Create agent for testing."""
        return create_weather_agent()
    
    def test_agent_initialization(self, agent):
        """Test that agent initializes correctly."""
        assert agent is not None
        assert len(agent.tools) == 1
        assert agent.tools[0].name == "get_weather"
    
    @patch('__main__.get_weather')
    def test_weather_query(self, mock_tool, agent):
        """Test weather query functionality."""
        # Mock the tool
        mock_tool.return_value = "Mocked weather data"
        
        # Run agent
        result = agent.invoke({"input": "What's the weather in Tokyo?"})
        
        # Assertions
        assert "output" in result
        assert len(result["output"]) > 0
    
    def test_invalid_location(self, agent):
        """Test handling of invalid locations."""
        result = agent.invoke({"input": "What's the weather in XYZ123?"})
        
        # Should still return a response
        assert "output" in result
    
    def test_agent_uses_tool(self, agent):
        """Test that agent actually calls the tool."""
        with patch.object(get_weather, 'invoke', return_value="Mocked") as mock:
            agent.invoke({"input": "Weather in Paris?"})
            # Verify tool was called
            assert mock.called
    
    def test_multiple_queries(self, agent):
        """Test agent handles multiple different queries."""
        queries = [
            "Weather in London?",
            "What's it like in New York?",
            "Tell me about Tokyo weather"
        ]
        
        for query in queries:
            result = agent.invoke({"input": query})
            assert "output" in result
            assert len(result["output"]) > 0

# Run tests
if __name__ == "__main__":
    pytest.main([__file__, "-v"])
```

---

## Production Best Practices

### **1. Configuration Management**

```python
from pydantic_settings import BaseSettings
from functools import lru_cache

class AgentSettings(BaseSettings):
    """Centralized configuration."""
    
    # LLM settings
    openai_api_key: str
    model_name: str = "gpt-4o"
    temperature: float = 0.0
    max_tokens: int = 4000
    
    # Agent settings
    max_iterations: int = 10
    timeout: int = 60
    verbose: bool = False
    
    # Monitoring
    langsmith_api_key: str | None = None
    enable_tracing: bool = True
    
    class Config:
        env_file = ".env"

@lru_cache()
def get_settings() -> AgentSettings:
    """Get cached settings."""
    return AgentSettings()

# Usage
settings = get_settings()
llm = ChatOpenAI(
    model=settings.model_name,
    temperature=settings.temperature,
    max_tokens=settings.max_tokens
)
```

### **2. Logging & Monitoring**

```python
import logging
from langchain.callbacks.base import BaseCallbackHandler

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('agent.log'),
        logging.StreamHandler()
    ]
)

logger = logging.getLogger(__name__)

class LoggingCallback(BaseCallbackHandler):
    """Custom logging callback."""
    
    def on_llm_start(self, serialized, prompts, **kwargs):
        logger.info(f"LLM started with prompts: {len(prompts)}")
    
    def on_llm_end(self, response, **kwargs):
        logger.info(f"LLM completed: {response.llm_output}")
    
    def on_tool_start(self, serialized, input_str, **kwargs):
        logger.info(f"Tool started: {serialized.get('name')} with input: {input_str}")
    
    def on_tool_end(self, output, **kwargs):
        logger.info(f"Tool completed with output length: {len(str(output))}")
    
    def on_chain_error(self, error, **kwargs):
        logger.error(f"Chain error: {error}")
    
    def on_tool_error(self, error, **kwargs):
        logger.error(f"Tool error: {error}")

# Usage
agent_executor = AgentExecutor(
    agent=agent,
    tools=tools,
    callbacks=[LoggingCallback()],
    verbose=True
)
```

### **3. Rate Limiting & Cost Control**

```python
from functools import wraps
import time
from collections import deque

class RateLimiter:
    """Token bucket rate limiter."""
    
    def __init__(self, calls_per_minute=60):
        self.calls_per_minute = calls_per_minute
        self.calls = deque()
    
    def __call__(self, func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            now = time.time()
            
            # Remove calls older than 1 minute
            while self.calls and self.calls[0] < now - 60:
                self.calls.popleft()
            
            # Check if we can make another call
            if len(self.calls) >= self.calls_per_minute:
                sleep_time = 60 - (now - self.calls[0])
                print(f"Rate limit reached, sleeping for {sleep_time:.2f}s")
                time.sleep(sleep_time)
                return wrapper(*args, **kwargs)
            
            # Make the call
            self.calls.append(now)
            return func(*args, **kwargs)
        
        return wrapper

# Usage
rate_limiter = RateLimiter(calls_per_minute=30)

@rate_limiter
def call_llm(prompt):
    # LLM call here
    pass
```

---

## Summary

**Key Takeaways:**

1. **Start simple** - Basic ReAct agent → Advanced multi-agent
2. **Use frameworks** - Don't reinvent the wheel
3. **Add memory** - Essential for context and personalization
4. **Handle errors** - Robust error handling is critical
5. **Test thoroughly** - Unit tests, integration tests, end-to-end
6. **Monitor production** - Logging, tracing, metrics
7. **Control costs** - Rate limiting, caching, monitoring

**Next Steps:**
1. Try each example
2. Modify for your use case
3. Add custom tools
4. Implement proper error handling
5. Add comprehensive tests
6. Deploy with monitoring
7. Iterate and improve

---

[Next: Agent Deployment and Hosting →](09-agent-deployment-hosting.md)

[← Back to Monitoring](07-agent-monitoring-observability.md)

[← Back to Agentic AI Index](README.md)
