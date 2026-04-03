# 4. Understanding and Hands-on Experience with Tokenizers

How text is converted to tokens that AI models can process.

---

## Overview

Tokenizers are the bridge between human-readable text and the numerical format that AI models understand. Mastering tokenization is crucial for efficient and effective use of LLMs.

---

## What is Tokenization?

**Tokenization** is the process of breaking down text into smaller units called "tokens" that the model can process.

### Why Tokenization Matters

1. **Models work with numbers**, not text
2. **Token limits** determine how much text you can process
3. **Costs are calculated** per token
4. **Performance depends** on efficient tokenization

---

## Common Tokenization Strategies

### 1. Byte-Pair Encoding (BPE)

**How it works**:
- Starts with individual characters
- Iteratively merges most frequent pairs
- Creates vocabulary of subword units

**Used by**:
- GPT models
- RoBERTa
- BART

**Example**:
```
Text: "tokenization"
Tokens: ["token", "ization"]
or: ["token", "iz", "ation"]
```

**Advantages**:
- Efficient for common words
- Handles rare words well
- Reduces vocabulary size

### 2. WordPiece

**How it works**:
- Similar to BPE
- Uses likelihood-based merging
- Adds "##" prefix to subwords

**Used by**:
- BERT
- DistilBERT
- Electra

**Example**:
```
Text: "unhappiness"
Tokens: ["un", "##happiness"]
or: ["un", "##hap", "##pi", "##ness"]
```

### 3. SentencePiece

**How it works**:
- Language-agnostic
- Treats text as raw stream
- No pre-tokenization needed

**Used by**:
- T5
- ALBERT
- XLNet
- LLaMA

**Advantages**:
- Works for any language
- No need for language-specific rules
- Handles spaces as tokens

### 4. Unigram Language Model

**How it works**:
- Probabilistic approach
- Starts with large vocabulary
- Removes tokens to optimize likelihood

**Used by**:
- Some multilingual models
- SentencePiece implementations

---

## Practical Examples

### Token Count Variations

```
Text: "Hello, world!"

GPT-2/GPT-3:
["Hello", ",", " world", "!"] = 4 tokens

GPT-4:
["Hello", ",", " world", "!"] = 4 tokens

BERT:
["Hello", ",", "world", "!"] = 4 tokens
```

### Why Token Counts Differ

```
Text: "The cat sat on the mat."

GPT tokenizer: ["The", " cat", " sat", " on", " the", " mat", "."] = 7 tokens
BERT tokenizer: ["the", "cat", "sat", "on", "the", "mat", "."] = 7 tokens
(Note: BERT lowercases by default)
```

---

## Token Limits and Optimization

### Understanding Token Budgets

**Model Context Windows**:
```
GPT-3.5: 4,096 tokens
GPT-4: 8,192 tokens (or 32K/128K variants)
Claude 3: Up to 200,000 tokens
Gemini 1.5: Up to 2,000,000 tokens
```

**Token Budget Breakdown**:
```
Total Context = System Prompt + User Messages + Assistant Messages + Output

Example for 4K context:
- System prompt: 200 tokens
- Conversation history: 1,500 tokens
- Current user message: 300 tokens
- Available for response: 2,096 tokens
```

### Token Optimization Strategies

#### 1. Use Concise Prompts
```python
# Inefficient (125 tokens)
prompt = """
I would like you to please help me by providing a detailed 
explanation of how to implement a function in Python that 
can calculate the factorial of a number using recursion.
"""

# Efficient (15 tokens)
prompt = "Write a Python function to calculate factorial using recursion."
```

#### 2. Remove Redundancy
```python
# Before (30 tokens)
"The model should respond with a JSON object. The JSON object 
should contain the following fields: name, age, and address."

# After (18 tokens)
"Respond with JSON containing: name, age, address."
```

#### 3. Use Abbreviations (when appropriate)
```python
# Before: "approximately" (3 tokens)
# After: "approx." (2 tokens)

# Before: "for example" (2 tokens)
# After: "e.g." (1 token)
```

---

## Hands-on Practice

### Using OpenAI's Tokenizer

```python
import tiktoken

# Load tokenizer for GPT-4
encoding = tiktoken.encoding_for_model("gpt-4")

# Tokenize text
text = "Hello, how are you doing today?"
tokens = encoding.encode(text)
print(f"Tokens: {tokens}")
print(f"Token count: {len(tokens)}")

# Decode tokens back to text
decoded = encoding.decode(tokens)
print(f"Decoded: {decoded}")

# Count tokens before API call
def count_tokens(text, model="gpt-4"):
    encoding = tiktoken.encoding_for_model(model)
    return len(encoding.encode(text))

token_count = count_tokens("Your prompt here")
print(f"This prompt uses {token_count} tokens")
```

### Using Hugging Face Tokenizers

```python
from transformers import AutoTokenizer

# Load tokenizer
tokenizer = AutoTokenizer.from_pretrained("gpt2")

# Tokenize
text = "Artificial Intelligence is transforming the world."
tokens = tokenizer.tokenize(text)
print(f"Tokens: {tokens}")

# Encode (text to IDs)
input_ids = tokenizer.encode(text)
print(f"Token IDs: {input_ids}")

# Decode (IDs back to text)
decoded = tokenizer.decode(input_ids)
print(f"Decoded: {decoded}")

# Get token count
token_count = len(tokenizer.encode(text))
print(f"Token count: {token_count}")
```

### Special Tokens

```python
# Special tokens in different models
tokenizer = AutoTokenizer.from_pretrained("gpt2")

print(f"BOS token: {tokenizer.bos_token}")  # Beginning of sequence
print(f"EOS token: {tokenizer.eos_token}")  # End of sequence
print(f"PAD token: {tokenizer.pad_token}")  # Padding
print(f"UNK token: {tokenizer.unk_token}")  # Unknown

# These tokens count toward your limit!
```

---

## Common Tokenization Challenges

### 1. Unicode and Special Characters

```python
# Some characters use multiple tokens
text1 = "café"  # May be 2-3 tokens depending on encoding
text2 = "cafe"  # Likely 1-2 tokens

# Emojis can be expensive!
text3 = "😀"  # Can be 2-4 tokens
```

### 2. Code Tokenization

```python
# Code often uses more tokens than natural language
code = "def hello_world():\n    print('Hello, world!')"
# This might be 15-20 tokens depending on the tokenizer

# Tip: Minimize whitespace and comments when token-limited
```

### 3. Multilingual Text

```python
# Different languages have different token efficiencies
english = "Hello"  # 1 token
spanish = "Hola"   # 1 token
japanese = "こんにちは"  # 3-5 tokens
chinese = "你好"  # 2-3 tokens
```

---

## Best Practices

### 1. Always Count Tokens Before API Calls
```python
def estimate_cost(text, model="gpt-4"):
    token_count = count_tokens(text, model)
    cost_per_1k = 0.03  # Example rate
    estimated_cost = (token_count / 1000) * cost_per_1k
    return token_count, estimated_cost
```

### 2. Implement Token Budgets in Your Apps
```python
MAX_TOKENS = 4000
RESERVED_FOR_SYSTEM = 200
RESERVED_FOR_OUTPUT = 500

available_for_conversation = MAX_TOKENS - RESERVED_FOR_SYSTEM - RESERVED_FOR_OUTPUT

if count_tokens(conversation_history) > available_for_conversation:
    # Truncate or summarize
    pass
```

### 3. Use Chunking for Long Documents
```python
def chunk_text(text, max_tokens=500, model="gpt-4"):
    encoding = tiktoken.encoding_for_model(model)
    tokens = encoding.encode(text)
    
    chunks = []
    for i in range(0, len(tokens), max_tokens):
        chunk = tokens[i:i + max_tokens]
        chunks.append(encoding.decode(chunk))
    
    return chunks
```

### 4. Monitor Token Usage
```python
# Track token usage for cost management
def track_usage(prompt, response, model="gpt-4"):
    prompt_tokens = count_tokens(prompt, model)
    response_tokens = count_tokens(response, model)
    total_tokens = prompt_tokens + response_tokens
    
    print(f"Prompt: {prompt_tokens} tokens")
    print(f"Response: {response_tokens} tokens")
    print(f"Total: {total_tokens} tokens")
    
    return total_tokens
```

---

## Tools and Resources

### Online Tokenizers
- [OpenAI Tokenizer](https://platform.openai.com/tokenizer)
- [Hugging Face Tokenizer Playground](https://huggingface.co/spaces/Xenova/the-tokenizer-playground)
- [TikToken Web](https://tiktokenizer.vercel.app/)

### Python Libraries
```bash
pip install tiktoken  # OpenAI tokenizers
pip install transformers  # Hugging Face tokenizers
pip install sentencepiece  # SentencePiece tokenizer
```

---

## 📚 Further Reading

- [OpenAI Tokenizer Documentation](https://github.com/openai/tiktoken)
- [Hugging Face Tokenizers](https://huggingface.co/docs/tokenizers/)
- [Understanding Tokenization in NLP](https://huggingface.co/learn/nlp-course/chapter2/4)

---

**Previous**: [← Model Parameters](03-model-parameters.md)  
**Next**: [Hands-on Practice with APIs →](05-hands-on-practice.md)

[← Back to Index](README.md)
