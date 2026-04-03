# 2. Transformers and Other Architectures

Transformers are the core of modern generative AI. They replaced RNNs/LSTMs by using self-attention, enabling better long-range context and parallelization.

---

![Transformer Architecture](../assets/Basics_of_Generative_AI/02-transformers-architecture/transformer_architectures.webp)


## Transformer Architectures
Transformers architecture is based on the self-attention mechanism, allowing models to weigh the importance of different parts of the input data. The main architectures include: Encoder-only (e.g., BERT), Decoder-only (e.g., GPT, LLaMA, Mistral), and Encoder-Decoder (e.g., T5, BART). Newer architectures like Mamba, RWKV, MoE, and Hyena are emerging for improved efficiency and long-context handling.

References:
- [Attention Is All You Need](https://arxiv.org/abs/1706.03762)
- [The Illustrated Transformer](http://jalammar.github.io/illustrated-transformer/) <--- RECOMMENDED


## Key Ideas

- **Self-Attention**: Lets the model focus on all parts of a sequence.
- **Multi-Head Attention**: Multiple attention layers in parallel.
- **Positional Encoding**: Adds order info to tokens.
- **Feed-Forward Layers**: Non-linear transformations at each position.
- **Layer Normalization**: Stabilizes and speeds up training.

## Main Architectures

- **Encoder-only**: For understanding (e.g., BERT)
- **Decoder-only**: For generation (e.g., GPT, LLaMA, Mistral)
- **Encoder-Decoder**: For translation/summarization (e.g., T5, BART)

## Popular Variants

- **GPT**: Decoder-only, text generation
- **BERT**: Encoder-only, understanding
- **T5**: Encoder-decoder, text-to-text
- **LLaMA**: Efficient, open-source, decoder-only
- **Mistral**: Decoder-only, sliding window attention

## Newer Architectures

- **Mamba**: State space, efficient for long sequences
- **RWKV**: Combines RNN and Transformer
- **MoE**: Mixture of Experts, scalable
- **Hyena**: Uses convolutions for long context

## Attention Variants

- **Flash Attention**: Fast, memory-efficient
- **Sliding Window**: Local context, used in Mistral
- **Sparse Attention**: Reduces compute for long context

## Choosing an Architecture

- **Generation**: Decoder-only (GPT, LLaMA)
- **Understanding**: Encoder-only (BERT)
- **Translation/Summarization**: Encoder-decoder (T5)

## Tips

- Use efficient attention for speed
- Quantize for smaller/faster models
- Use model parallelism for large models


[← Previous](01-llms-embeddings-models.md) | [Next →](03-model-parameters.md)
[← Back to Index](README.md)
