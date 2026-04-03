# 8. Structured Output Generation

Producing structured data like JSON from LLMs.

---

## Using JSON Mode (OpenAI)

```python
from openai import OpenAI

client = OpenAI()

response = client.chat.completions.create(
    model="gpt-4-turbo-preview",
    response_format={"type": "json_object"},
    messages=[
        {"role": "system", "content": "You are a helpful assistant designed to output JSON."},
        {"role": "user", "content": "Extract: Name is John, age is 30, city is NYC"}
    ]
)

import json
data = json.loads(response.choices[0].message.content)
print(data)
```

## Using Pydantic for Schema Validation

```python
from pydantic import BaseModel
from openai import OpenAI

class Person(BaseModel):
    name: str
    age: int
    city: str

client = OpenAI()

completion = client.beta.chat.completions.parse(
    model="gpt-4o-2024-08-06",
    messages=[
        {"role": "user", "content": "Extract: Name is John, age is 30, city is NYC"}
    ],
    response_format=Person,
)

person = completion.choices[0].message.parsed
print(f"{person.name}, {person.age}, {person.city}")
```

---

**Previous**: [← Context Management](07-context-management.md)  
**Next**: [Function Calling →](09-function-calling.md)

[← Back to Index](README.md)
