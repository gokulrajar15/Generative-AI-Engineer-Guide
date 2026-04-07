# Structured Output Generation

Free-form text is fine for chatbots. But in real applications — pipelines, APIs, data extraction, agent tools — you need outputs you can reliably **parse, validate, and pass to the next step**. This guide covers how to make LLMs return structured data every time.

---

## The Problem with Unstructured Output

When you ask an LLM a question, it returns a string. That string might look like JSON, but it is not guaranteed to be valid, consistently formatted, or schema-compliant.

```python
# What you want:
{"name": "Gokul", "role": "ML Engineer", "skills": ["Python", "FastAPI"]}

# What the model might return without guidance:
"""
Sure! Here is the extracted information:

Name: Gokul
Role: ML Engineer
Skills: Python, FastAPI
"""
```

Structured output generation is about closing that gap — reliably.

---

## Strategy 1: Prompt-Level JSON Instructions

The simplest approach. Tell the model exactly what format to return, define the schema inside the prompt, and parse the response.

```python
from openai import OpenAI
import json, re

client = OpenAI(api_key="your_api_key")

def extract_candidate_info(resume_text: str) -> dict:
    prompt = f"""
Extract the following information from the resume below.

Return ONLY a valid JSON object. No explanation, no markdown, no backticks.

Schema:
{{
  "full_name": "<string>",
  "email": "<string>",
  "years_of_experience": <integer>,
  "skills": ["<string>"],
  "current_role": "<string or null>"
}}

Resume:
{resume_text}
"""
    response = client.chat.completions.create(
        model="gpt-5.4-mini",
        messages=[
            {"role": "system", "content": "You are a data extraction assistant. Always return valid JSON only."},
            {"role": "user",   "content": prompt}
        ],
        temperature=0   # deterministic output for extraction tasks
    )

    raw = response.choices[0].message.content
    cleaned = re.sub(r"```(?:json)?|```", "", raw).strip()
    return json.loads(cleaned)
```

**When to use it:** Quick extraction tasks, any provider, no extra dependencies.

**Limitation:** The model can still occasionally wrap output in markdown or add a preamble, so always clean and wrap in `try/except`.

---

## Strategy 2: JSON Mode (OpenAI)

OpenAI provides a `response_format` parameter that **enforces valid JSON at the API level**. The model will never return invalid JSON when this is set.

```python
response = client.chat.completions.create(
    model="gpt-5.4-mini",
    response_format={"type": "json_object"},   # enforced by the API
    messages=[
        {"role": "system", "content": "You are a data extractor. Always return JSON."},
        {"role": "user",   "content": f"Extract name, email, and skills from:\n{resume_text}"}
    ],
    temperature=0
)

data = json.loads(response.choices[0].message.content)
```

> **Note:** JSON mode guarantees valid JSON syntax, but it does not validate against a schema. The model decides the structure unless you define it in the prompt.

---

## Strategy 3: Schema Validation with Pydantic

Pydantic lets you define exactly what the output must look like — field names, types, optional fields, nested objects, and constraints. 

```python

from openai import OpenAI
from pydantic import BaseModel, Field

client = OpenAI()

class CalendarEvent(BaseModel):
    name: str = Field(..., description="The name of the event")  ## Giving descriptions helps the model understand the expected content
    date: str = Field(..., description="The date of the event in YYYY-MM-DD format")
    participants: list[str] = Field(..., description="List of participants attending the event")

response = client.responses.parse(
    model="gpt-5.4-mini",
    input=[
        {"role": "system", "content": "Extract the event information."},
        {
            "role": "user",
            "content": "Alice and Bob are going to a science fair on Friday.",
        },
    ],
    text_format=CalendarEvent,
)

event = response.output_parsed

print(event)

```


For nested structures, just define nested Pydantic models:

```python

from openai import OpenAI
from pydantic import BaseModel, Field

client = OpenAI()

class Step(BaseModel):
    explanation: str = Field(..., description="Explanation of the step")
    output: str = Field(..., description="The result of this step")

class MathReasoning(BaseModel):
    steps: list[Step] = Field(..., description="List of reasoning steps")
    final_answer: str = Field(..., description="The final answer to the problem")

response = client.responses.parse(
    model="gpt-4o-2024-08-06",
    input=[
        {
            "role": "system",
            "content": "You are a helpful math tutor. Guide the user through the solution step by step.",
        },
        {"role": "user", "content": "how can I solve 8x + 7 = -23"},
    ],
    text_format=MathReasoning,
)

math_reasoning = response.output_parsed

print(math_reasoning) 

```

*To know more about structured output generation refer openai documentation on [Structured Output Generation](https://developers.openai.com/api/docs/guides/structured-outputs).*

Note: Each model providers have their own way of handling structured output. Always check the documentation for your specific provider to see if they offer built-in support for structured formats or if you need to implement your own parsing logic.


**Next**: [Function Calling](09-function-calling.md)

[← Back to Index](README.md)
