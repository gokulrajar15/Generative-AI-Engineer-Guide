# 3. Model Parameters and Key Terms

Understanding key generation parameters for controlling LLM outputs.

---

## Overview

Model parameters control how Large Language Models generate text. Mastering these parameters is essential for getting the desired output from AI models.

---

## Core Generation Parameters

### 1. Temperature

**Controls randomness in output generation**

- **Range**: 0.0 to 2.0 (typically)
- **Default**: Usually 0.7 or 1.0

**How it works**:
- Lower temperature (0.0 - 0.3): More deterministic, focused, conservative
- Medium temperature (0.4 - 0.9): Balanced creativity and coherence
- Higher temperature (1.0 - 2.0): More random, creative, unpredictable

**Use cases**:
```
Temperature 0.0-0.3: Code generation, factual Q&A, data extraction
Temperature 0.5-0.7: General chatbots, customer service
Temperature 0.8-1.2: Creative writing, brainstorming, story generation
Temperature 1.5-2.0: Experimental, highly creative outputs
```

### 2. Top-k

**Limits sampling to the k most likely next tokens**

- **Range**: 1 to vocabulary size
- **Default**: Often 40-50

**How it works**:
- At each step, only considers the top k most probable tokens
- Reduces low-probability tokens from consideration
- Prevents nonsensical outputs

**Examples**:
```
Top-k = 1: Always picks the most likely token (greedy decoding)
Top-k = 10: Chooses from 10 most likely tokens
Top-k = 50: More diversity while maintaining quality
```

### 3. Top-p (Nucleus Sampling)

**Samples from tokens whose cumulative probability exceeds p**

- **Range**: 0.0 to 1.0
- **Default**: Often 0.9 or 0.95

**How it works**:
- Dynamically adjusts the number of tokens considered
- Includes tokens until cumulative probability reaches p
- More adaptive than top-k

**Examples**:
```
Top-p = 0.1: Very focused, limited token choices
Top-p = 0.5: Balanced selection
Top-p = 0.9: Broader token selection
Top-p = 1.0: Considers all tokens (no filtering)
```

**Combining Top-k and Top-p**:
- Can be used together
- Applies both filters sequentially
- Provides fine-grained control

---

## Context and Length Parameters

### 4. Context Window

**Maximum number of tokens the model can process at once**

**Common context windows**:
- GPT-3.5: 4,096 tokens (~3,000 words)
- GPT-4: 8,192 or 32,768 tokens
- GPT-4 Turbo: 128,000 tokens
- Claude 3: 200,000 tokens
- Gemini 1.5 Pro: 2,000,000 tokens

**Implications**:
- Longer context = better understanding of long documents
- Longer context = higher latency and cost
- Need context management strategies for very long conversations

### 5. Max Tokens (Max Length)

**Maximum number of tokens in the generated output**

- **Range**: 1 to model's maximum
- **Purpose**: Controls response length and cost

**Considerations**:
```
Short responses (50-100 tokens): Quick answers, summaries
Medium responses (200-500 tokens): Explanations, emails
Long responses (1000+ tokens): Articles, detailed analyses
```

**Note**: If max tokens is reached, response may be cut off mid-sentence.

---

## Repetition Control

### 6. Frequency Penalty

**Reduces likelihood of tokens based on how often they appear**

- **Range**: -2.0 to 2.0
- **Default**: 0.0 (no penalty)

**How it works**:
- Positive values: Discourage repetition
- Negative values: Encourage repetition
- Applied based on token frequency in current output

**Use cases**:
```
0.0: No penalty (default behavior)
0.3-0.6: Mild reduction in repetition
0.7-1.0: Strong reduction, more diverse vocabulary
1.0-2.0: Very strong penalty, may affect coherence
```

### 7. Presence Penalty

**Reduces likelihood of tokens that have already appeared**

- **Range**: -2.0 to 2.0
- **Default**: 0.0 (no penalty)

**How it works**:
- Penalizes tokens based on whether they've appeared (not how many times)
- Encourages new topics and ideas
- Single occurrence triggers penalty

**Difference from Frequency Penalty**:
- Frequency: Penalizes based on count
- Presence: Binary - penalizes if appeared at all

---

## Advanced Parameters

### 8. Logit Bias

**Manually adjusts probability of specific tokens**

- **Range**: -100 to 100 per token
- **Purpose**: Force inclusion/exclusion of words

**Use cases**:
- Preventing specific words (set to -100)
- Encouraging technical terms
- Controlling output format

### 9. Stop Sequences

**Tokens or strings that halt generation**

**Examples**:
```python
stop_sequences = ["\n\n", "END", "###"]
```

**Use cases**:
- Controlling response boundaries
- Structured output generation
- Preventing runaway generation

### 10. N (Number of Completions)

**Number of alternative completions to generate**

- **Default**: 1
- **Use**: Compare multiple outputs, select best

**Note**: Multiplies API costs by N

---

## Parameter Combinations for Common Use Cases

### Factual Q&A / Code Generation
```
temperature: 0.0-0.2
top_p: 0.1
max_tokens: 500-1000
frequency_penalty: 0.0
presence_penalty: 0.0
```

### Creative Writing
```
temperature: 0.8-1.2
top_p: 0.9
max_tokens: 1000-2000
frequency_penalty: 0.3-0.6
presence_penalty: 0.2-0.4
```

### Conversational AI
```
temperature: 0.7
top_p: 0.9
max_tokens: 150-300
frequency_penalty: 0.3
presence_penalty: 0.1
```

### Brainstorming / Ideation
```
temperature: 1.0-1.5
top_p: 0.95
max_tokens: 500-1000
frequency_penalty: 0.5-1.0
presence_penalty: 0.5-1.0
```

---

## Best Practices

### 1. Start with Defaults
- Use recommended defaults for your use case
- Adjust based on results

### 2. Temperature vs Top-p
- Temperature affects probability distribution globally
- Top-p is more dynamic and adaptive
- Use one or both based on needs

### 3. Iterate and Test
- Test different parameters with same prompt
- Observe quality vs creativity trade-off
- Document what works for your use case

### 4. Monitor Costs
- Longer max_tokens = higher costs
- Multiple completions (N > 1) multiply costs
- Balance quality and budget

### 5. Context Window Management
- Don't exceed model's context limit
- Implement summarization for long conversations
- Use sliding window or truncation strategies

---

## 📚 Further Reading

- [OpenAI API Parameters](https://platform.openai.com/docs/api-reference/chat/create)
- [Anthropic Claude Parameters](https://docs.anthropic.com/claude/reference/complete_post)
- [Temperature in LLMs Explained](https://lukesalamone.github.io/posts/what-is-temperature/)

---

**Previous**: [← Transformers and Architecture](02-transformers-architecture.md)  
**Next**: [Understanding Tokenizers →](04-tokenizers.md)

[← Back to Index](README.md)
