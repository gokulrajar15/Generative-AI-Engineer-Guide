# 11. Real-time APIs

Working with voice-to-voice and real-time systems.

---

## OpenAI Real-time API

The OpenAI Real-time API enables low-latency, multi-modal conversations with voice-to-voice capabilities.

### Key Features
- Speech input and output
- Function calling in real-time
- Low latency (~300ms)
- WebSocket-based communication

### Basic Example

```python
import asyncio
import websockets
import json

async def realtime_session():
    url = "wss://api.openai.com/v1/realtime?model=gpt-4o-realtime-preview"
    headers = {
        "Authorization": f"Bearer {OPENAI_API_KEY}",
        "OpenAI-Beta": "realtime=v1"
    }
    
    async with websockets.connect(url, additional_headers=headers) as ws:
        # Configure session
        await ws.send(json.dumps({
            "type": "session.update",
            "session": {
                "modalities": ["text", "audio"],
                "instructions": "You are a helpful assistant.",
                "voice": "alloy"
            }
        }))
        
        # Send message
        await ws.send(json.dumps({
            "type": "conversation.item.create",
            "item": {
                "type": "message",
                "role": "user",
                "content": [{"type": "input_text", "text": "Hello!"}]
            }
        }))
        
        # Receive responses
        async for message in ws:
            data = json.loads(message)
            print(data)
```

---

**Previous**: [← Streaming Outputs](10-streaming-outputs.md)  
**Next**: [LLM Fine-tuning →](12-fine-tuning.md)

[← Back to Index](README.md)
