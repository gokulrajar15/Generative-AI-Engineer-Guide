# 10. Streaming Outputs

Live response streaming for better user experience.

---

## Streaming Text (OpenAI)

```python
from openai import OpenAI

client = OpenAI()

stream = client.chat.completions.create(
    model="gpt-4",
    messages=[{"role": "user", "content": "Write a short story"}],
    stream=True
)

for chunk in stream:
    if chunk.choices[0].delta.content:
        print(chunk.choices[0].delta.content, end="")
```

## Streaming with Anthropic Claude

```python
from anthropic import Anthropic

client = Anthropic()

with client.messages.stream(
    model="claude-3-opus-20240229",
    max_tokens=1024,
    messages=[{"role": "user", "content": "Write a short story"}]
) as stream:
    for text in stream.text_stream:
        print(text, end="", flush=True)
```

---

**Previous**: [← Function Calling](09-function-calling.md)  
**Next**: [Real-time APIs →](11-realtime-apis.md)

[← Back to Index](README.md)
