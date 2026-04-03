# 6. Prompting Best Practices and Strategies

Effective prompt engineering techniques for better LLM outputs.

---

## Core Principles

### 1. Be Clear and Specific
```
❌ "Write about AI"
✅ "Write a 200-word explanation of how neural networks work, targeting beginners"
```

### 2. Provide Context
```
❌ "Translate this: Bonjour"
✅ "Translate this French greeting to English: Bonjour"
```

### 3. Use Examples (Few-Shot Learning)
```
Classify the sentiment of these reviews:

Review: "This product is amazing!" → Positive
Review: "Terrible experience, would not recommend." → Negative
Review: "It's okay, nothing special." → Neutral
Review: "Best purchase I've made this year!" → [Model completes]
```

---

## Advanced Techniques

### Chain-of-Thought Prompting
```
Instead of: "What is 15% of 80?"

Use: "What is 15% of 80? Let's think step by step:
1. Convert percentage to decimal
2. Multiply by the number
3. State the answer"
```

### Role-Based Prompting
```
"You are an expert Python developer with 10 years of experience.
Review this code and suggest improvements..."
```

### System Messages Optimization
```python
system_message = """You are a helpful customer service agent.
- Always be polite and professional
- Provide concise answers (2-3 sentences)
- If you don't know, say so and offer to escalate
- Never make up information"""
```

---

## 📚 Further Reading
- [OpenAI Prompt Engineering Guide](https://platform.openai.com/docs/guides/prompt-engineering)
- [Anthropic Prompt Library](https://docs.anthropic.com/claude/prompt-library)

---

**Previous**: [← Hands-on Practice](05-hands-on-practice.md)  
**Next**: [Context Management →](07-context-management.md)

[← Back to Index](README.md)
