## Transformers and Other Architectures

Transformers are the core architecture behind modern generative models. They utilize attention mechanisms to process and generate text, enabling them to capture long-range dependencies and context effectively. The Transformer architecture, proposed in the paper "Attention is All You Need" by Vaswani et al. in 2017, has become the foundation for most large language models (LLMs) and other generative AI models.

![Transformer Architecture](../assets/Basics_of_Generative_AI/02-transformers-architecture/transformer.png)

### Key Components of Transformer Architecture

#### 1. Input Processing
- **Tokenization**: Converts text into tokens (subwords, words, or characters) that can be processed by the model. Different tokenizers include BPE (Byte Pair Encoding), WordPiece, and SentencePiece.

Note: You'll learn more about tokenization in the upcoming section on [Tokenization and Embeddings](03-tokenizers.md). This is very important for cost optimization and performance.

- **Embedding Layer**: Transforms tokens into dense vector representations (typically 512-4096 dimensions) that capture semantic meaning.
- **Positional Encoding**: Adds information about the position of tokens in the sequence using sinusoidal functions or learned embeddings, enabling the model to understand word order.

#### 2. Self-Attention Mechanism
- **Multi-Head Attention**: The core innovation of transformers. It allows the model to focus on different parts of the input simultaneously by:
  - Computing Query (Q), Key (K), and Value (V) matrices from the input
  - Calculating attention scores using scaled dot-product attention: `Attention(Q, K, V) = softmax(QK^T / √d_k)V`
  - Using multiple attention heads (typically 8-96 heads) to capture different types of relationships
  - Concatenating and projecting the outputs from all heads
- **Self-Attention**: Each token attends to all other tokens in the sequence, enabling the model to capture dependencies regardless of distance.
- **Masked Self-Attention**: Used in decoder layers to prevent attending to future tokens during autoregressive generation.
- **Cross-Attention**: Used in encoder-decoder models to allow the decoder to attend to encoder outputs.

#### 3. Processing Layers
- **Feedforward Neural Networks (FFN)**: Applied to each position independently, typically consisting of two linear transformations with a non-linear activation (GELU or ReLU) in between. Usually expands dimensionality by 4x (e.g., 768 → 3072 → 768).
- **Layer Normalization**: Normalizes activations across features for each token, stabilizing training and enabling deeper models.
- **Residual Connections**: Skip connections around each sub-layer that help gradients flow during backpropagation and allow training very deep networks (up to 100+ layers).
- **Dropout**: Applied for regularization to prevent overfitting during training.

#### 4. Transformer Variants

**Encoder-Only Models** (e.g., BERT, RoBERTa, ALBERT)
- Use bidirectional attention (can see entire context)
- Best for understanding tasks: classification, sentiment analysis, named entity recognition
- Apply masked language modeling during training

**Decoder-Only Models** (e.g., GPT-3/4, LLaMA, Mistral, Gemini)
- Use causal/masked attention (can only see previous tokens)
- Best for generation tasks: text completion, chatbots, code generation
- Apply autoregressive language modeling during training
- Most modern LLMs use this architecture

**Encoder-Decoder Models** (e.g., T5, BART, Flan-T5)
- Combine both encoder and decoder with cross-attention
- Best for sequence-to-sequence tasks: translation, summarization, question answering
- Encoder processes input, decoder generates output while attending to encoder states

### Training Techniques
- **Pre-training**: Models are trained on massive text corpora to learn language patterns and world knowledge
- **Fine-tuning**: Pre-trained models are adapted to specific tasks with smaller, task-specific datasets
- **Instruction Tuning**: Training on instruction-response pairs to follow human instructions better
- **RLHF (Reinforcement Learning from Human Feedback)**: Aligning model outputs with human preferences

You'll know more about training techniques in the upcoming section on [Training and Fine-tuning](20-training-generativeai-models.md).

### Key Innovations and Optimizations
- **Flash Attention**: Optimized attention computation that reduces memory usage and increases speed
- **Grouped Query Attention (GQA)**: Shares key-value heads across query heads to reduce memory and computation
- **Multi-Query Attention (MQA)**: Uses single key-value head for all query heads
- **Rotary Position Embeddings (RoPE)**: Encodes position information by rotating token embeddings
- **ALiBi (Attention with Linear Biases)**: Alternative positional encoding method that generalizes better to longer sequences
- **Sliding Window Attention**: Limits attention to a local window for efficiency with long sequences


### References
- [Transformers playlist on YouTube](https://www.youtube.com/playlist?list=PLUfbC589u-FSwnqsvTHXVcgmLg8UnbIy3) - Highly recommended for understanding the architecture in depth
- [The Illustrated Transformer](http://jalammar.github.io/illustrated-transformer/) - A visual and intuitive explanation of how transformers work
- [Attention is All You Need](https://arxiv.org/abs/1706.03762) - The original paper that introduced transformers (recommended for deeper understanding)

### Simulation of Transformer Architecture
[Simulate Transformer Architecture](https://poloclub.github.io/transformer-explainer/) - An interactive tool to visualize and understand how transformers process input and generate output.


---

## Alternative and Emerging Architectures

While transformers dominate the generative AI landscape, researchers continue to explore alternative architectures that address specific limitations such as computational complexity, memory requirements, and efficiency with long sequences.

1. Mixture of Experts (MoE) - Instead of using all model parameters for every input, MoE models route each input to a subset of "expert" networks, significantly improving efficiency.
2. State Space Models (SSMs) - Mamba Combines the parallelizable training of transformers with the efficient inference of recurrent models.
3. RWKV (Receptance Weighted Key Value) - A novel RNN-like architecture that combines linear attention with recurrent processing.
4. Diffusion-Based Architectures - Generate outputs by iteratively denoising random noise through learned diffusion processes.
5. Retentive Networks (RetNet) - Designed as the "successor to transformers" with retention mechanism replacing attention.
6. Hyena and Long Convolution Models - Use implicitly parameterized long convolutions instead of attention.
7. Hybrid Architectures - Many recent models combine multiple architectural approaches:

![Types of Architectures](../assets/Basics_of_Generative_AI/02-transformers-architecture/transformer_architectures.webp)

The field continues to evolve rapidly, with new architectures emerging that challenge transformer dominance, particularly for specific use cases like extremely long sequences, real-time applications, and resource-constrained environments. 


Reference:
- [Different Architectures in Latest Models](https://sebastianraschka.com/llm-architecture-gallery/) - A comprehensive overview of the architectures used in recent models, including MoE, SSM, RWKV, and more. Must-read for understanding the diversity of approaches in modern generative AI.

---

*Checkout the tokenization techniques used in these architectures in the next section.*


[<- Previous: Introduction to LLM's](01-introduction-to-llms.md) | [Next: Tokenization and It's Types→](03-tokenizers.md)


[← Back to Index](README.md)


## Checkout mathmatical details of transformer architecture if you're curious:


---

### Step-by-Step Transformer Workflow (Visual Example)

Let's trace how the input **"Hello World"** flows through a transformer architecture with concrete numerical examples.

---

#### 📥 STEP 1: INPUT TEXT
```
┌─────────────────────────────────────────────────────────────────┐
│                        INPUT TEXT                               │
│                      "Hello World"                              │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
```

---

#### 🔤 STEP 2: TOKENIZATION
```
┌─────────────────────────────────────────────────────────────────┐
│                       TOKENIZATION                              │
│         Split text into tokens (subwords/words)                 │
├─────────────────────────────────────────────────────────────────┤
│  "Hello World"  →  ["Hello", "World"]                           │
│                                                                 │
│  Token IDs:         [15496, 2159]                               │
│                     (from vocabulary lookup)                    │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
```

---

#### 📊 STEP 3: TOKEN EMBEDDINGS
```
┌─────────────────────────────────────────────────────────────────┐
│                    TOKEN EMBEDDINGS                             │
│      Convert token IDs to dense vectors (d_model = 4)           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Token "Hello" [15496] → [ 0.423, -0.206, -0.984,  0.242]       │
│  Token "World" [2159]  → [-0.156,  0.891,  0.334, -0.521]       │
│                                                                 │
│  Embedding Matrix E (shape: 2 × 4):                             │
│  ┌                                        ┐                     │
│  │  0.423   -0.206   -0.984    0.242      │  ← "Hello"          │
│  │ -0.156    0.891    0.334   -0.521      │  ← "World"          │
│  └                                        ┘                     │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
```

---

#### 📍 STEP 4: POSITIONAL ENCODING
```
┌─────────────────────────────────────────────────────────────────┐
│                   POSITIONAL ENCODING                           │
│         Add position information to embeddings                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Position 0 (Hello): [ 0.000,  1.000,  0.000,  1.000]           │
│  Position 1 (World): [ 0.841,  0.540,  0.010,  0.999]           │
│                                                                 │
│  Formula: PE(pos,2i) = sin(pos/10000^(2i/d_model))              │
│           PE(pos,2i+1) = cos(pos/10000^(2i/d_model))            │
│                                                                 │
│  Input = Embedding + Positional Encoding:                       │
│  ┌                                        ┐                     │
│  │  0.423   0.794   -0.984    1.242       │  ← Position 0       │
│  │  0.685   1.431    0.344    0.478       │  ← Position 1       │
│  └                                        ┘                     │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
```

---

### 🔵 ENCODER ARCHITECTURE WORKFLOW

```
┌═══════════════════════════════════════════════════════════════════════════════┐
║                              ENCODER BLOCK                                    ║
║                        (Repeated N times, e.g., N=6)                          ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║   ┌───────────────────────────────────────────────────────────────────────┐   ║
║   │                    MULTI-HEAD SELF-ATTENTION                          │   ║
║   │                                                                       │   ║
║   │   Input X (shape: 2 × 4):                                             │   ║
║   │   ┌                                    ┐                              │   ║
║   │   │  0.423   0.794   -0.984    1.242   │                              │   ║
║   │   │  0.685   1.431    0.344    0.478   │                              │   ║
║   │   └                                    ┘                              │   ║
║   │                                                                       │   ║
║   │   ─────────────── STEP 5: LINEAR PROJECTIONS ───────────────          │   ║
║   │                                                                       │   ║
║   │   Weight Matrices (learned parameters):                               │   ║
║   │                                                                       │   ║
║   │   Wq (Query):      Wk (Key):        Wv (Value):                       │   ║
║   │   ┌          ┐     ┌          ┐     ┌          ┐                      │   ║
║   │   │ 0.1  0.2 │     │ 0.3  0.1 │     │ 0.2  0.4 │                      │   ║
║   │   │ 0.3  0.1 │     │ 0.2  0.4 │     │ 0.1  0.3 │                      │   ║
║   │   │ 0.2  0.4 │     │ 0.1  0.2 │     │ 0.3  0.1 │                      │   ║
║   │   │ 0.1  0.3 │     │ 0.4  0.3 │     │ 0.2  0.2 │                      │   ║
║   │   └          ┘     └          ┘     └          ┘                      │   ║
║   │                                                                       │   ║
║   │   Compute Q, K, V:                                                    │   ║
║   │   Q = X × Wq    K = X × Wk    V = X × Wv                              │   ║
║   │                                                                       │   ║
║   │   Query (Q):       Key (K):         Value (V):                        │   ║
║   │   ┌          ┐     ┌          ┐     ┌          ┐                      │   ║
║   │   │ 0.12 0.45│     │ 0.28 0.52│     │ 0.31 0.42│  ← "Hello"           │   ║
║   │   │ 0.38 0.67│     │ 0.41 0.38│     │ 0.29 0.58│  ← "World"           │   ║
║   │   └          ┘     └          ┘     └          ┘                      │   ║
║   │                                                                       │   ║
║   │   ─────────────── STEP 6: ATTENTION SCORES ───────────────            │   ║
║   │                                                                       │   ║
║   │   Attention(Q, K, V) = softmax(Q × K^T / √d_k) × V                    │   ║
║   │                                                                       │   ║
║   │   1. Q × K^T (dot product):                                           │   ║
║   │      ┌              ┐                                                 │   ║
║   │      │ 0.268  0.220 │  ← How much "Hello" attends to each token       │   ║
║   │      │ 0.453  0.409 │  ← How much "World" attends to each token       │   ║
║   │      └              ┘                                                 │   ║
║   │              ↓                                                        │   ║
║   │   2. Scale by √d_k (√2 ≈ 1.414):                                      │   ║
║   │      ┌              ┐                                                 │   ║
║   │      │ 0.190  0.156 │                                                 │   ║
║   │      │ 0.320  0.289 │                                                 │   ║
║   │      └              ┘                                                 │   ║
║   │              ↓                                                        │   ║
║   │   3. Softmax (normalize rows):                                        │   ║
║   │      ┌              ┐                                                 │   ║
║   │      │ 0.508  0.492 │  ← Attention weights for "Hello"                │   ║
║   │      │ 0.508  0.492 │  ← Attention weights for "World"                │   ║
║   │      └              ┘                                                 │   ║
║   │              ↓                                                        │   ║
║   │   4. Multiply by V:                                                   │   ║
║   │      ┌              ┐                                                 │   ║
║   │      │ 0.300  0.500 │  ← Contextualized "Hello"                       │   ║
║   │      │ 0.300  0.500 │  ← Contextualized "World"                       │   ║
║   │      └              ┘                                                 │   ║
║   │                                                                       │   ║
║   └───────────────────────────────────────────────────────────────────────┘   ║
║                              │                                                ║
║                              ▼                                                ║
║   ┌───────────────────────────────────────────────────────────────────────┐   ║
║   │                 STEP 7: ADD & LAYER NORM                              │   ║
║   │                                                                       │   ║
║   │   Residual Connection: Output = LayerNorm(X + Attention(X))           │   ║
║   │                                                                       │   ║
║   │   ┌                    ┐     ┌              ┐     ┌                ┐  │   ║
║   │   │ 0.423  0.794  ... │  +  │ 0.300  0.500 │  →  │ Normalized     │   │   ║
║   │   │ 0.685  1.431  ... │     │ 0.300  0.500 │     │ Output         │   │   ║
║   │   └                    ┘     └              ┘     └                ┘  │   ║
║   └───────────────────────────────────────────────────────────────────────┘   ║
║                              │                                                ║
║                              ▼                                                ║
║   ┌───────────────────────────────────────────────────────────────────────┐   ║
║   │              STEP 8: FEED-FORWARD NETWORK (FFN)                       │   ║
║   │                                                                       │   ║
║   │   FFN(x) = GELU(x × W1 + b1) × W2 + b2                                │   ║
║   │                                                                       │   ║
║   │   ┌────────┐     ┌────────────────┐     ┌────────┐                    │   ║
║   │   │ d=4    │ →   │ d=16 (expand)  │ →   │ d=4    │                    │   ║
║   │   │ Input  │     │ Hidden + GELU  │     │ Output │                    │   ║
║   │   └────────┘     └────────────────┘     └────────┘                    │   ║
║   │                                                                       │   ║
║   │Example: [0.3, 0.5, 0.2, 0.1] → [...16 dims...] → [0.4, 0.6, 0.3, 0.2] │   ║
║   └───────────────────────────────────────────────────────────────────────┘   ║
║                              │                                                ║
║                              ▼                                                ║
║   ┌───────────────────────────────────────────────────────────────────────┐   ║
║   │                 STEP 9: ADD & LAYER NORM                              │   ║
║   │                                                                       │   ║
║   │   Output = LayerNorm(X + FFN(X))                                      │   ║
║   │                                                                       │   ║
║   │   Final Encoder Output (shape: 2 × 4):                                │   ║
║   │   ┌                                    ┐                              │   ║
║   │   │  0.512   0.234   -0.123    0.891   │  ← Contextualized "Hello"    │   ║
║   │   │  0.234   0.567    0.456   -0.234   │  ← Contextualized "World"    │   ║
║   │   └                                    ┘                              │   ║
║   └───────────────────────────────────────────────────────────────────────┘   ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
                              │
                              │ Encoder Output passed to Decoder
                              ▼
```

---

### 🟢 DECODER ARCHITECTURE WORKFLOW

```
┌═══════════════════════════════════════════════════════════════════════════════┐
║                              DECODER BLOCK                                    ║
║                        (Repeated N times, e.g., N=6)                          ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║   Input: Previously generated tokens + Encoder output                         ║
║   Target: "Bonjour" (for translation task)                                    ║
║                                                                               ║
║   ┌───────────────────────────────────────────────────────────────────────┐   ║
║   │            STEP 10: MASKED SELF-ATTENTION                             │   ║
║   │                                                                       │   ║
║   │   Prevents looking at future tokens during generation                 │   ║
║   │                                                                       │   ║
║   │   Attention Mask (lower triangular):                                  │   ║
║   │   ┌                    ┐                                              │   ║
║   │   │  1    -∞   -∞  -∞  │  ← Token 1 sees only itself                  │   ║
║   │   │  1     1   -∞  -∞  │  ← Token 2 sees tokens 1-2                   │   ║
║   │   │  1     1    1  -∞  │  ← Token 3 sees tokens 1-3                   │   ║
║   │   │  1     1    1   1  │  ← Token 4 sees all tokens                   │   ║
║   │   └                    ┘                                              │   ║
║   │                                                                       │   ║
║   │   After softmax, -∞ becomes 0 (no attention to future)                │   ║
║   │   ┌                    ┐                                              │   ║
║   │   │ 1.00  0.00  0.00  0.00 │                                          │   ║
║   │   │ 0.52  0.48  0.00  0.00 │                                          │   ║
║   │   │ 0.35  0.33  0.32  0.00 │                                          │   ║
║   │   │ 0.26  0.25  0.25  0.24 │                                          │   ║
║   │   └                    ┘                                              │   ║
║   └───────────────────────────────────────────────────────────────────────┘   ║
║                              │                                                ║
║                              ▼                                                ║
║   ┌───────────────────────────────────────────────────────────────────────┐   ║
║   │                    ADD & LAYER NORM                                   │   ║
║   └───────────────────────────────────────────────────────────────────────┘   ║
║                              │                                                ║
║                              ▼                                                ║
║   ┌───────────────────────────────────────────────────────────────────────┐   ║
║   │            STEP 11: CROSS-ATTENTION                                   │   ║
║   │         (Encoder-Decoder Attention)                                   │   ║
║   │                                                                       │   ║
║   │   Q = from Decoder (what we're generating)                            │   ║
║   │   K, V = from Encoder output (source context)                         │   ║
║   │                                                                       │   ║
║   │   ┌─────────────┐         ┌─────────────┐                             │   ║
║   │   │   DECODER   │         │   ENCODER   │                             │   ║
║   │   │   Output    │         │   Output    │                             │   ║
║   │   │      │      │         │    │   │    │                             │   ║
║   │   │      ▼      │         │    ▼   ▼    │                             │   ║
║   │   │      Q      │         │    K   V    │                             │   ║
║   │   └──────┬──────┘         └────┬───┬────┘                             │   ║
║   │          │                     │   │                                  │   ║
║   │          └─────────┬───────────┘   │                                  │   ║
║   │                    ▼               │                                  │   ║
║   │              ┌───────────┐         │                                  │   ║
║   │              │  Q × K^T  │←────────┘                                  │   ║
║   │              │  Softmax  │                                            │   ║
║   │              │   × V     │                                            │   ║
║   │              └───────────┘                                            │   ║
║   │                    │                                                  │   ║
║   │   Allows decoder to "look at" relevant parts of input                 │   ║
║   │   Example: When generating "Bonjour", attend to "Hello"               │   ║
║   └───────────────────────────────────────────────────────────────────────┘   ║
║                              │                                                ║
║                              ▼                                                ║
║   ┌───────────────────────────────────────────────────────────────────────┐   ║
║   │                    ADD & LAYER NORM                                   │   ║
║   └───────────────────────────────────────────────────────────────────────┘   ║
║                              │                                                ║
║                              ▼                                                ║
║   ┌───────────────────────────────────────────────────────────────────────┐   ║
║   │              STEP 12: FEED-FORWARD NETWORK                            │   ║
║   │                                                                       │   ║
║   │   Same structure as encoder FFN                                       │   ║
║   │   FFN(x) = GELU(x × W1 + b1) × W2 + b2                                │   ║
║   └───────────────────────────────────────────────────────────────────────┘   ║
║                              │                                                ║
║                              ▼                                                ║
║   ┌───────────────────────────────────────────────────────────────────────┐   ║
║   │                    ADD & LAYER NORM                                   │   ║
║   └───────────────────────────────────────────────────────────────────────┘   ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
                              │
                              ▼
```

---

### 📤 STEP 13: OUTPUT GENERATION

```
┌═══════════════════════════════════════════════════════════════════════════════┐
║                           OUTPUT LAYER                                        ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║                                                                               ║
║   ┌───────────────────────────────────────────────────────────────────────┐   ║
║   │                    LINEAR PROJECTION                                  │   ║
║   │                                                                       │   ║
║   │   Decoder Output (d_model=4) → Vocabulary Size (e.g., 50,000)         │   ║
║   │                                                                       │   ║
║   │   ┌────────┐              ┌────────────────────┐                      │   ║
║   │   │ [0.5,  │    Linear    │ [2.1, -0.3, 1.5,   │                      │   ║
║   │   │  0.3,  │  ─────────►  │  0.8, -1.2, 3.2,   │  (50,000 logits)     │   ║
║   │   │  0.2,  │   Projection │  ...               │                      │   ║
║   │   │  0.1]  │              │  0.4, 1.1]         │                      │   ║
║   │   └────────┘              └────────────────────┘                      │   ║
║   └───────────────────────────────────────────────────────────────────────┘   ║
║                              │                                                ║
║                              ▼                                                ║
║   ┌───────────────────────────────────────────────────────────────────────┐   ║
║   │                       SOFTMAX                                         │   ║
║   │                                                                       │   ║
║   │   Convert logits to probabilities:                                    │   ║
║   │                                                                       │   ║
║   │   Token Probabilities:                                                │   ║
║   │   ┌─────────────────────────────────────────────────────────┐         │   ║
║   │   │  "Bonjour": 0.42  ◄── Highest probability               │         │   ║
║   │   │  "Salut":   0.18                                        │         │   ║
║   │   │  "Hello":   0.12                                        │         │   ║
║   │   │  "Hi":      0.08                                        │         │   ║
║   │   │  "Ciao":    0.05                                        │         │   ║
║   │   │  ...                                                    │         │   ║
║   │   │  (50,000 tokens with probabilities summing to 1.0)      │         │   ║
║   │   └─────────────────────────────────────────────────────────┘         │   ║
║   └───────────────────────────────────────────────────────────────────────┘   ║
║                              │                                                ║
║                              ▼                                                ║
║   ┌───────────────────────────────────────────────────────────────────────┐   ║
║   │                    TOKEN SELECTION                                    │   ║
║   │                                                                       │   ║
║   │   Sampling Strategies:                                                │   ║
║   │   • Greedy: Always pick highest probability → "Bonjour"               │   ║
║   │   • Top-k: Sample from top k tokens                                   │   ║
║   │   • Top-p (Nucleus): Sample from tokens with cumulative prob < p      │   ║
║   │   • Temperature: Scale logits before softmax (higher = more random)   │   ║
║   │                                                                       │   ║
║   │   Selected Token: "Bonjour" → Token ID: 23456                         │   ║
║   └───────────────────────────────────────────────────────────────────────┘   ║
║                              │                                                ║
║                              ▼                                                ║
║   ┌───────────────────────────────────────────────────────────────────────┐   ║
║   │                 AUTOREGRESSIVE LOOP                                   │   ║
║   │                                                                       │   ║
║   │   Generated token fed back as input for next iteration:               │   ║
║   │                                                                       │   ║
║   │   Iteration 1: [<SOS>]           → "Bonjour"                          │   ║
║   │   Iteration 2: [<SOS>, Bonjour]  → "Monde"                            │   ║
║   │   Iteration 3: [<SOS>, Bonjour, Monde] → "<EOS>"                      │   ║
║   │                                                                       │   ║
║   │   Final Output: "Bonjour Monde"                                       │   ║
║   └───────────────────────────────────────────────────────────────────────┘   ║
║                                                                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
```

---

### 🔄 COMPLETE FLOW SUMMARY

```
┌────────────────────────────────────────────────────────────────────────────────┐
│                        TRANSFORMER COMPLETE FLOW                               │
├────────────────────────────────────────────────────────────────────────────────┤
│                                                                                │
│   INPUT: "Hello World"                                                         │
│            │                                                                   │
│            ▼                                                                   │
│   ┌─────────────────┐                                                          │
│   │  1. Tokenize    │  →  [15496, 2159]                                        │
│   └────────┬────────┘                                                          │
│            ▼                                                                   │
│   ┌─────────────────┐                                                          │
│   │  2. Embed       │  →  [[0.42, -0.21, ...], [-0.16, 0.89, ...]]             │
│   └────────┬────────┘                                                          │
│            ▼                                                                   │
│   ┌─────────────────┐                                                          │
│   │  3. Add Pos Enc │  →  [[0.42, 0.79, ...], [0.68, 1.43, ...]]               │
│   └────────┬────────┘                                                          │
│            ▼                                                                   │
│   ╔═════════════════════════════════════════════════════════════════════╗      │
│   ║                         ENCODER (×N)                                ║      │
│   ║  ┌─────────────┐  ┌──────────┐  ┌─────────┐  ┌──────────┐           ║      │
│   ║  │ Self-Attn   │→ │ Add&Norm │→ │   FFN   │→ │ Add&Norm │           ║      │
│   ║  │ (Q,K,V all  │  │          │  │         │  │          │           ║      │
│   ║  │ from input) │  │          │  │         │  │          │           ║      │
│   ║  └─────────────┘  └──────────┘  └─────────┘  └──────────┘           ║      │
│   ╚══════════════════════════════╦══════════════════════════════════════╝      │
│                                  ║                                             │
│                                  ║ Encoder Output                              │
│                                  ▼                                             │
│   ╔═════════════════════════════════════════════════════════════════════╗      │
│   ║                         DECODER (×N)                                ║      │
│   ║  ┌─────────────┐  ┌──────────┐  ┌─────────────┐  ┌──────────┐       ║      │
│   ║  │ Masked      │→ │ Add&Norm │→ │ Cross-Attn  │→ │ Add&Norm │→      ║      │
│   ║  │ Self-Attn   │  │          │  │ (Q from dec,│  │          │       ║      │
│   ║  │             │  │          │  │ K,V from enc│  │          │       ║      │
│   ║  └─────────────┘  └──────────┘  └─────────────┘  └──────────┘       ║      │
│   ║                                                                     ║      │
│   ║            ┌─────────┐  ┌──────────┐                                ║      │
│   ║        →   │   FFN   │→ │ Add&Norm │                                ║      │
│   ║            └─────────┘  └──────────┘                                ║      │
│   ╚══════════════════════════════╦══════════════════════════════════════╝      │
│                                  ║                                             │
│                                  ▼                                             │
│   ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐                │
│   │  Linear Layer   │→ │     Softmax     │→ │  Token Select   │                │
│   │  (to vocab size)│  │ (probabilities) │  │  (sampling)     │                │
│   └─────────────────┘  └─────────────────┘  └────────┬────────┘                │
│                                                      │                         │
│                                                      ▼                         │
│   OUTPUT: "Bonjour Monde"                                                      │
│                                                                                │
└────────────────────────────────────────────────────────────────────────────────┘
```

---

### Key Dimensions Reference Table

| Component | Typical Values | Example (Small) |
|-----------|----------------|-----------------|
| Vocabulary Size | 30K - 100K tokens | 50,000 |
| d_model (embedding dim) | 512 - 4096 | 768 |
| Number of Heads | 8 - 96 | 12 |
| d_k (head dimension) | 64 - 128 | 64 |
| FFN hidden dim | 4× d_model | 3072 |
| Number of Layers (N) | 6 - 96 | 12 |
| Max Sequence Length | 512 - 128K | 2048 |

---