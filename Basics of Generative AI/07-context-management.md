# 7. Context Management

Strategies for managing context windows in long conversations.

---

## Key Strategies

### 1. Rolling Window
Keep only the most recent N messages in context.

```python
MAX_MESSAGES = 10

conversation_history = conversation_history[-MAX_MESSAGES:]
```

### 2. Recursive Summarization
Periodically summarize older messages.

```python
if len(messages) > threshold:
    summary = summarize_messages(messages[:threshold])
    messages = [summary] + messages[threshold:]
```

### 3. Selective Retention
Keep important messages, remove less relevant ones.

```python
# Keep: system message, recent messages, pinned important messages
context = [system_msg] + important_msgs + recent_msgs[-5:]
```

---

## Best Practices

1. **Monitor token usage** in each request
2. **Implement summarization** for long conversations
3. **Use external storage** for conversation history
4. **Test different strategies** for your use case

---

**Previous**: [← Prompting Strategies](06-prompting-strategies.md)  
**Next**: [Structured Output →](08-structured-output.md)

[← Back to Index](README.md)
