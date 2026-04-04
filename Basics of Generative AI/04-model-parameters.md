## Model Parameters and Key Terms

Parameters are the variables that control the behavior of a model during training and inference. They determine how the model processes input data and generates output. Understanding these parameters is crucial for fine-tuning model performance and achieving desired results.

---

## Interactive Parameter Playground

<style>
  .playground { padding: 1rem 0; font-family: var(--font-sans); }
  .param-row { display: flex; align-items: center; gap: 12px; margin-bottom: 14px; }
  .param-label { min-width: 130px; font-size: 13px; color: var(--color-text-secondary); }
  .param-value { min-width: 40px; font-size: 13px; font-weight: 500; color: var(--color-text-primary); text-align: right; }
  .param-desc { font-size: 12px; color: var(--color-text-tertiary); margin-left: 2px; }
  .section-title { font-size: 11px; font-weight: 500; letter-spacing: .06em; color: var(--color-text-tertiary); text-transform: uppercase; margin: 1.5rem 0 .75rem; border-bottom: 0.5px solid var(--color-border-tertiary); padding-bottom: .4rem; }
  .card { background: var(--color-background-primary); border: 0.5px solid var(--color-border-tertiary); border-radius: var(--border-radius-lg); padding: 1rem 1.25rem; margin-top: 1.25rem; }
  .badge { display: inline-block; font-size: 11px; padding: 2px 8px; border-radius: var(--border-radius-md); font-weight: 500; margin-right: 6px; }
  .badge-blue  { background: #E6F1FB; color: #0C447C; }
  .badge-amber { background: #FAEEDA; color: #633806; }
  .badge-red   { background: #FCEBEB; color: #791F1F; }
  .badge-teal  { background: #E1F5EE; color: #085041; }
  .badge-gray  { background: #F1EFE8; color: #2C2C2A; }
  .insight-row { display: flex; align-items: flex-start; gap: 8px; margin-bottom: 8px; font-size: 13px; }
  .insight-row .dot { width: 8px; height: 8px; border-radius: 50%; margin-top: 5px; flex-shrink: 0; }
  code { font-family: var(--font-mono); font-size: 12px; background: var(--color-background-secondary); padding: 1px 5px; border-radius: 4px; }
  .tip-box { background: var(--color-background-secondary); border-left: 2px solid #378ADD; border-radius: 0; padding: .75rem 1rem; font-size: 13px; color: var(--color-text-secondary); margin-top: 1rem; }
</style>

<div class="playground">
  <p style="font-size:14px; color:var(--color-text-secondary); margin-bottom:1rem;">Adjust each parameter and see a live summary of what your config produces.</p>

  <div class="section-title">Core sampling</div>

  <div class="param-row">
    <span class="param-label">Temperature</span>
    <input type="range" min="0" max="2" step="0.05" value="0.7" id="temp" style="flex:1;" oninput="update()">
    <span class="param-value" id="temp-v">0.70</span>
  </div>
  <div class="param-desc" style="margin-bottom:10px; font-size:12px; color:var(--color-text-tertiary); padding-left:142px;">0 = deterministic &nbsp;|&nbsp; 1 = balanced &nbsp;|&nbsp; 2 = very random</div>

  <div class="param-row">
    <span class="param-label">Top-p</span>
    <input type="range" min="0" max="1" step="0.01" value="0.9" id="topp" style="flex:1;" oninput="update()">
    <span class="param-value" id="topp-v">0.90</span>
  </div>
  <div class="param-desc" style="margin-bottom:10px; font-size:12px; color:var(--color-text-tertiary); padding-left:142px;">Nucleus: sample from tokens summing to this probability mass</div>

  <div class="param-row">
    <span class="param-label">Top-k</span>
    <input type="range" min="1" max="200" step="1" value="40" id="topk" style="flex:1;" oninput="update()">
    <span class="param-value" id="topk-v">40</span>
  </div>
  <div class="param-desc" style="margin-bottom:10px; font-size:12px; color:var(--color-text-tertiary); padding-left:142px;">Hard cap: only consider the top k tokens each step</div>

  <div class="section-title">Output control</div>

  <div class="param-row">
    <span class="param-label">Max tokens</span>
    <input type="range" min="50" max="4096" step="50" value="512" id="maxtok" style="flex:1;" oninput="update()">
    <span class="param-value" id="maxtok-v">512</span>
  </div>

  <div class="param-row">
    <span class="param-label">Freq penalty</span>
    <input type="range" min="-2" max="2" step="0.1" value="0" id="freqp" style="flex:1;" oninput="update()">
    <span class="param-value" id="freqp-v">0.0</span>
  </div>
  <div class="param-desc" style="margin-bottom:10px; font-size:12px; color:var(--color-text-tertiary); padding-left:142px;">Penalises tokens proportional to how often they've appeared</div>

  <div class="param-row">
    <span class="param-label">Presence penalty</span>
    <input type="range" min="-2" max="2" step="0.1" value="0" id="presp" style="flex:1;" oninput="update()">
    <span class="param-value" id="presp-v">0.0</span>
  </div>
  <div class="param-desc" style="margin-bottom:10px; font-size:12px; color:var(--color-text-tertiary); padding-left:142px;">Penalises any token that has appeared at all (topic diversity)</div>

  <div class="card" id="summary-card">
    <div id="summary-content"></div>
  </div>

  <div class="tip-box" id="tip-box"></div>
</div>

<script>
function update() {
  const temp   = parseFloat(document.getElementById('temp').value);
  const topp   = parseFloat(document.getElementById('topp').value);
  const topk   = parseInt(document.getElementById('topk').value);
  const maxtok = parseInt(document.getElementById('maxtok').value);
  const freqp  = parseFloat(document.getElementById('freqp').value);
  const presp  = parseFloat(document.getElementById('presp').value);

  document.getElementById('temp-v').textContent   = temp.toFixed(2);
  document.getElementById('topp-v').textContent   = topp.toFixed(2);
  document.getElementById('topk-v').textContent   = topk;
  document.getElementById('maxtok-v').textContent = maxtok;
  document.getElementById('freqp-v').textContent  = freqp.toFixed(1);
  document.getElementById('presp-v').textContent  = presp.toFixed(1);

  let creativity, creativityColor;
  if (temp < 0.3)       { creativity = 'Very focused';   creativityColor = 'badge-blue'; }
  else if (temp < 0.7)  { creativity = 'Focused';        creativityColor = 'badge-teal'; }
  else if (temp < 1.1)  { creativity = 'Balanced';       creativityColor = 'badge-gray'; }
  else if (temp < 1.5)  { creativity = 'Creative';       creativityColor = 'badge-amber'; }
  else                  { creativity = 'Very random';    creativityColor = 'badge-red'; }

  let poolDesc;
  if (topp <= 0.3)      poolDesc = 'very tight nucleus (conservative)';
  else if (topp <= 0.7) poolDesc = 'moderate nucleus';
  else if (topp <= 0.95)poolDesc = 'broad nucleus';
  else                  poolDesc = 'full vocabulary';

  let topkDesc;
  if (topk === 1)       topkDesc = 'greedy — always picks the #1 token';
  else if (topk <= 10)  topkDesc = 'very narrow candidate list';
  else if (topk <= 50)  topkDesc = 'moderate candidate list';
  else if (topk <= 100) topkDesc = 'wide candidate list';
  else                  topkDesc = 'very wide candidate list';

  let lengthDesc;
  if (maxtok <= 100)      lengthDesc = 'one-liner or snippet';
  else if (maxtok <= 300) lengthDesc = 'short paragraph';
  else if (maxtok <= 800) lengthDesc = 'medium response';
  else if (maxtok <= 2000)lengthDesc = 'long response / essay';
  else                    lengthDesc = 'very long / document-length';

  let repDesc = '';
  if (freqp > 0.5 || presp > 0.5) repDesc = 'strong anti-repetition';
  else if (freqp > 0 || presp > 0) repDesc = 'mild anti-repetition';
  else if (freqp < 0 || presp < 0) repDesc = 'repetition allowed / encouraged';
  else repDesc = 'no repetition penalty';

  const html = `
    <div style="display:flex;gap:8px;flex-wrap:wrap;margin-bottom:12px;">
      <span class="badge ${creativityColor}">${creativity}</span>
      <span class="badge badge-gray">${lengthDesc}</span>
      <span class="badge badge-gray">${repDesc}</span>
    </div>
    <div class="insight-row"><div class="dot" style="background:#378ADD;"></div><div><b>Sampling</b>: temp <code>${temp.toFixed(2)}</code> + top-p <code>${topp.toFixed(2)}</code> → ${poolDesc}</div></div>
    <div class="insight-row"><div class="dot" style="background:#1D9E75;"></div><div><b>Top-k</b>: <code>${topk}</code> — ${topkDesc}</div></div>
    <div class="insight-row"><div class="dot" style="background:#BA7517;"></div><div><b>Max tokens</b>: <code>${maxtok}</code> — ${lengthDesc}</div></div>
    <div class="insight-row"><div class="dot" style="background:#A32D2D;"></div><div><b>Penalties</b>: freq <code>${freqp.toFixed(1)}</code>, presence <code>${presp.toFixed(1)}</code> — ${repDesc}</div></div>
  `;
  document.getElementById('summary-content').innerHTML = html;

  let tip = '';
  if (temp > 1.0 && topp < 0.5) tip = '⚠ High temp + low top-p can conflict — the nucleus cuts most creative options before temperature can spread probability.';
  else if (temp === 0 && topk > 1) tip = 'With temp=0 (greedy), top-k and top-p have no effect — the model always picks the single highest-probability token.';
  else if (topk === 1) tip = 'top-k=1 is greedy decoding. Temperature and top-p are irrelevant here.';
  else if (temp < 0.3 && topp > 0.9 && topk > 100) tip = '💡 Good for: code generation, factual Q&A, structured output — low entropy, wide but focused pool.';
  else if (temp >= 0.7 && temp <= 1.0 && topp >= 0.8) tip = '💡 Good for: chat, summarisation, general writing — balanced and natural.';
  else if (temp > 1.2) tip = '💡 Good for: brainstorming, poetry, creative fiction — but validate outputs; hallucination risk rises.';
  else tip = '💡 Tip: for most production use cases, temp 0.5–0.8 + top-p 0.9 + top-k 40–50 is a safe starting point.';

  document.getElementById('tip-box').textContent = tip;
}
update();
</script>

---

## Python Code Example

```python
from openai import OpenAI

client = OpenAI(api_key="your_api_key")

response = client.chat.completions.create(
    model="gpt-4o-mini",

    messages=[
        {"role": "system", "content": "You are a helpful assistant."},
        {"role": "user",   "content": "Write a short poem about the sea."}
    ],

    temperature=0.7,        # 0 = deterministic, 2 = very random
    top_p=0.9,              # nucleus sampling: consider tokens covering 90% prob mass
    # top_k not exposed in OpenAI API (used in Anthropic, Google, Mistral, etc.)

    max_tokens=200,         # hard cap on response length
    frequency_penalty=0.3,  # reduce word repetition (-2 to 2)
    presence_penalty=0.2,   # encourage topic diversity (-2 to 2)

    stop=["\n\n", "END"],   # stop generating at these sequences
    seed=42,                # for reproducibility
    n=1,                    # how many completions to generate
)

print(response.choices[0].message.content)
```

---

## Detailed Parameter Explanations

### 1. Model
- The specific language model to use (e.g., "gpt-4o", "claude-3", "gemini-pro")
- Different models have different capabilities, context window sizes, and cost structures 
- Always check the model documentation for supported parameters and best practices

### 2. Messages

Messages are the input format for chat-based models, consisting of a list of dictionaries with "role" and "content". Common roles include:

- **system**: Instructions or context for the model (e.g., "You are a helpful assistant.")
- **user**: The user's input or query
- **assistant**: The model's previous responses (used for multi-turn conversations)

You'll learn more about crafting effective messages and prompts in the upcoming sections on [Prompt Engineering](06-prompt-strategies.md) and [Context Management](07-context-management.md).


### 3. Temperature
**Range**: 0.0 to 2.0 (typical range: 0.0 to 1.0)

**What it does**: Controls randomness in the output by scaling the logits (pre-softmax scores) before sampling.

**How it works**:
- **Temperature = 0**: Deterministic (always picks highest probability token) - greedy decoding
- **Temperature < 1**: Makes the model more confident, sharper probability distribution
- **Temperature = 1**: Uses the model's raw probabilities as-is
- **Temperature > 1**: Flattens the distribution, making lower-probability tokens more likely

**Use cases**:
- **0.0 - 0.3**: Code generation, math problems, factual Q&A, structured data extraction
- **0.5 - 0.8**: General chatbots, customer support, professional writing
- **0.8 - 1.2**: Creative writing, brainstorming, diverse responses
- **1.5 - 2.0**: Experimental, highly creative fiction, poetry (risk of incoherence)

**Python example**:
```python
# Deterministic output for code generation
response = client.chat.completions.create(
    model="gpt-4o",
    messages=[{"role": "user", "content": "Write a Python function to reverse a string"}],
    temperature=0.0
)

# Creative output for storytelling
response = client.chat.completions.create(
    model="gpt-4o",
    messages=[{"role": "user", "content": "Write a creative story opening"}],
    temperature=1.2
)
```

---

### 5. Top-p (Nucleus Sampling)
**Range**: 0.0 to 1.0

**What it does**: Samples from the smallest set of tokens whose cumulative probability exceeds the threshold p.

**How it works**:
1. Sort tokens by probability (highest to lowest)
2. Keep adding tokens until cumulative probability ≥ p
3. Sample only from this subset
4. Dynamically adjusts vocabulary size based on confidence

**Use cases**:
- **0.1 - 0.5**: Very focused, conservative responses
- **0.7 - 0.9**: Balanced, most common setting
- **0.95 - 1.0**: More diverse vocabulary, exploratory

**Interaction with temperature**:
- Apply temperature FIRST (scales logits)
- Then apply top-p (filters tokens)
- Most APIs use both together

**Python example**:
```python
# Conservative, focused response
response = client.chat.completions.create(
    model="gpt-4o",
    messages=[{"role": "user", "content": "Explain quantum computing"}],
    temperature=0.5,
    top_p=0.7
)

# More diverse vocabulary
response = client.chat.completions.create(
    model="gpt-4o",
    messages=[{"role": "user", "content": "Describe a sunset"}],
    temperature=0.9,
    top_p=0.95
)
```

---

### 4. Top-k
**Range**: 1 to vocabulary_size (typically 1 to 100)

**What it does**: Limits sampling to the k most likely tokens at each step.

**How it works**:
1. Sort tokens by probability
2. Keep only the top k tokens
3. Renormalize probabilities
4. Sample from this fixed-size subset

**Comparison with top-p**:
- **Top-k**: Fixed number of candidates
- **Top-p**: Dynamic number based on probability mass
- Top-p is generally preferred in modern systems

**Use cases**:
- **k = 1**: Greedy decoding (deterministic)
- **k = 10-20**: Very focused, conservative
- **k = 40-50**: Balanced (common default)
- **k = 100+**: More exploratory

**Python example** (using providers that support it):
```python
# Anthropic example
import anthropic

client = anthropic.Anthropic(api_key="your_api_key")

response = client.messages.create(
    model="claude-3-5-sonnet-20241022",
    max_tokens=200,
    temperature=0.7,
    top_k=40,
    top_p=0.9,
    messages=[{"role": "user", "content": "Explain machine learning"}]
)

# Google example
import google.generativeai as genai

genai.configure(api_key="your_api_key")
model = genai.GenerativeModel('gemini-pro')

response = model.generate_content(
    "Explain neural networks",
    generation_config=genai.types.GenerationConfig(
        temperature=0.8,
        top_k=50,
        top_p=0.95,
    )
)
```

---

### 6. Max Tokens
**Range**: 1 to model's context window

**What it does**: Sets the maximum number of tokens the model can generate.

**Important notes**:
- Does NOT guarantee this many tokens (model may finish early)
- Includes ALL output tokens, not just the visible text
- Different from context window (which includes input + output)

**Typical values**:
- **50-100**: Short answers, snippets
- **200-500**: Paragraphs, explanations
- **1000-2000**: Articles, essays
- **4000+**: Long-form content, documentation

**Cost consideration**: You're charged for tokens generated, so set appropriately.

**Python example**:
```python
# Short, concise response
response = client.chat.completions.create(
    model="gpt-4o-mini",
    messages=[{"role": "user", "content": "What is Python?"}],
    max_tokens=100
)

# Long-form essay
response = client.chat.completions.create(
    model="gpt-4o",
    messages=[{"role": "user", "content": "Write a detailed guide on REST APIs"}],
    max_tokens=2000
)
```

---

### 7. Frequency Penalty
**Range**: -2.0 to 2.0 (OpenAI), typically 0.0 to 2.0

**What it does**: Penalizes tokens proportionally to how often they've already appeared.

**Formula**: `penalty = frequency_penalty × (token_count / total_tokens)`

**How it works**:
- Positive values (0 to 2): Discourage repetition
- Higher counts → stronger penalty
- Proportional to frequency of occurrence

**Use cases**:
- **0.0**: No penalty (default)
- **0.3-0.6**: Mild reduction in repetition
- **0.8-1.0**: Strong anti-repetition for varied writing
- **1.5-2.0**: Maximum diversity (can hurt coherence)

**Python example**:
```python
# Encourage varied vocabulary in creative writing
response = client.chat.completions.create(
    model="gpt-4o",
    messages=[{"role": "user", "content": "Write a product description"}],
    frequency_penalty=0.5
)

# Generate code (repetition is often needed)
response = client.chat.completions.create(
    model="gpt-4o",
    messages=[{"role": "user", "content": "Write a class with multiple methods"}],
    frequency_penalty=0.0  # Don't penalize repeated keywords
)
```

---

### 8. Presence Penalty
**Range**: -2.0 to 2.0 (OpenAI), typically 0.0 to 2.0

**What it does**: Penalizes tokens based on whether they've appeared at all (binary, not frequency-based).

**Formula**: `penalty = presence_penalty × (1 if token appeared else 0)`

**Difference from frequency penalty**:
- **Frequency**: Stronger penalty for tokens used multiple times
- **Presence**: Same penalty whether token used once or 100 times
- **Presence**: Better for encouraging topic diversity

**Use cases**:
- **0.0**: No penalty (default)
- **0.3-0.6**: Encourage covering different topics/aspects
- **0.8-1.2**: Strong push for novel content
- **1.5-2.0**: Maximum topic diversity

**Python example**:
```python
# Encourage exploring multiple perspectives
response = client.chat.completions.create(
    model="gpt-4o",
    messages=[{"role": "user", "content": "Discuss benefits of exercise"}],
    presence_penalty=0.6  # Cover different types of benefits
)

# Combine both penalties for maximum variety
response = client.chat.completions.create(
    model="gpt-4o",
    messages=[{"role": "user", "content": "Brainstorm startup ideas"}],
    frequency_penalty=0.5,
    presence_penalty=0.6
)
```

---

### 9. Stop Sequences
**Type**: String or array of strings

**What it does**: Tells the model to stop generating when it encounters any of these sequences.

**Use cases**:
- Control output format
- Prevent unwanted continuation
- Enforce structure

**Python example**:
```python
# Stop at double newline (paragraph break)
response = client.chat.completions.create(
    model="gpt-4o-mini",
    messages=[{"role": "user", "content": "Write a paragraph about AI"}],
    stop=["\n\n"]
)

# Stop at custom markers
response = client.chat.completions.create(
    model="gpt-4o",
    messages=[{"role": "user", "content": "Generate JSON data"}],
    stop=["}", "END"]
)

# Multiple stop sequences
response = client.chat.completions.create(
    model="gpt-4o",
    messages=[{"role": "user", "content": "List 3 items"}],
    stop=["4.", "\n\n"]  # Stop after 3 items
)
```

---

### 10. Seed (Deterministic Outputs)
**Type**: Integer

**What it does**: Attempts to make outputs deterministic by fixing the random seed.

**Important notes**:
- Must combine with `temperature=0` for true determinism
- Not all providers support this
- System-level changes can still affect outputs
- Beta feature in most APIs

**Use cases**:
- Testing and debugging
- Reproducible experiments
- A/B testing prompts

**Python example**:
```python
# Reproducible output
response = client.chat.completions.create(
    model="gpt-4o",
    messages=[{"role": "user", "content": "Generate a random story"}],
    seed=42,
    temperature=0  # Important for determinism
)

# Running multiple times with same seed gives same output
for i in range(3):
    response = client.chat.completions.create(
        model="gpt-4o",
        messages=[{"role": "user", "content": "Pick a number"}],
        seed=12345,
        temperature=0
    )
    print(response.choices[0].message.content)  # Same each time
```

---

### 11. N (Number of Completions)
**Type**: Integer (typically 1-10)

**What it does**: Generate multiple independent completions for the same prompt.

**Important notes**:
- Each completion counts toward your token usage
- Returned in `choices` array
- Useful for comparing alternatives

**Python example**:
```python
# Generate multiple alternatives
response = client.chat.completions.create(
    model="gpt-4o",
    messages=[{"role": "user", "content": "Write a slogan for a coffee shop"}],
    n=3,
    temperature=0.9
)

# Access all completions
for i, choice in enumerate(response.choices):
    print(f"Option {i + 1}: {choice.message.content}")

# Output:
# Option 1: "Brew-tiful Mornings Start Here"
# Option 2: "Sip, Savor, Repeat"
# Option 3: "Where Every Cup Tells a Story"
```

---

## Best Practices and Common Configurations

### Configuration Presets

#### 1. **Code Generation**
```python
{
    "temperature": 0.0,
    "top_p": 0.95,
    "max_tokens": 1000,
    "frequency_penalty": 0.0,
    "presence_penalty": 0.0
}
```
*Why*: Deterministic, focused, allows necessary repetition of keywords

#### 2. **Chatbot / Customer Support**
```python
{
    "temperature": 0.7,
    "top_p": 0.9,
    "max_tokens": 500,
    "frequency_penalty": 0.3,
    "presence_penalty": 0.1
}
```
*Why*: Balanced, natural, slight variety to avoid robotic responses

#### 3. **Creative Writing**
```python
{
    "temperature": 1.0,
    "top_p": 0.95,
    "max_tokens": 2000,
    "frequency_penalty": 0.5,
    "presence_penalty": 0.5
}
```
*Why*: More random, diverse vocabulary, explores different topics

#### 4. **Data Extraction / Classification**
```python
{
    "temperature": 0.0,
    "top_p": 1.0,
    "max_tokens": 100,
    "frequency_penalty": 0.0,
    "presence_penalty": 0.0
}
```
*Why*: Deterministic, consistent, short outputs

#### 5. **Brainstorming / Ideation**
```python
{
    "temperature": 1.2,
    "top_p": 0.95,
    "max_tokens": 1500,
    "frequency_penalty": 0.7,
    "presence_penalty": 0.6
}
```
*Why*: High creativity, strong encouragement for diverse ideas


## References and Further Reading

- [OpenAI API Documentation - Chat Completions](https://platform.openai.com/docs/api-reference/chat)
- [Anthropic Claude API Documentation](https://platform.claude.com/docs/en/api/messages/create)


*Do a experimentation with different parameter settings to see how they affect the output. Adjusting these parameters is key to tailoring the model's behavior to your specific use case.*

**Next**: [Hands-On Practice](05-hands-on-practice.md)

[← Back to Index](README.md)
