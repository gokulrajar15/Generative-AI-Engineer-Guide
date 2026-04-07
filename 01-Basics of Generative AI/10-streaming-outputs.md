# Streaming Outputs

LLM's generate a response token by token. so far, we've been waiting for the entire response to be generated before we can access it. But what if we want to access the response as it's being generated? This is where streaming outputs come in.

With streaming, you can access each token as soon as it's generated, allowing for real-time processing, faster response times, and the ability to handle long outputs without waiting for the entire response to be ready.

You may experience this while using ChatGPT or Claude or other chat interfaces, where the response appears to be "typing out" in real time. This is streaming in action.


Let 's see how to use streaming outputs with the OpenAI API.

```python
from openai import OpenAI
client = OpenAI()

stream = client.responses.create(
    model="gpt-5.4-mini",
    input=[
        {
            "role": "user",
            "content": "Say 'double bubble bath' ten times fast.",
        },
    ],
    stream=True,
)

for event in stream:
    print(event)

```

This will print each token as it's generated. You can also access metadata about the response, such as the token ID, logprobs, and more.

To know more about streaming outputs, check out the 

[OpenAI API documentation](https://developers.openai.com/api/docs/guides/streaming-responses).
[Claude API documentation](https://platform.claude.com/docs/en/build-with-claude/streaming)


**Next**: [Real-time APIs](11-realtime-apis.md)

[← Back to Index](README.md)
