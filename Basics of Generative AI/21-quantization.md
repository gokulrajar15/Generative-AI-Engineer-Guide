## Quantization

Techniques for optimizing LLMs and reducing model size:
- **Bits and bytes**: Reducing precision from 16-bit to 8-bit or 4-bit
- **GPTQ**: Post-training quantization
- **AWQ**: Activation-aware Weight Quantization
- **GGUF**: Efficient format for CPU inference
- **TurboQuant**: Compression method that achieves a high reduction in model size with zero accuracy loss, ideal for supporting both key-value (KV) cache compression and vector search.

**Benefits**:
- Reduced memory footprint
- Faster inference
- Lower deployment costs
- Minimal accuracy loss

📚 [Read more about quantization](https://cast.ai/blog/demystifying-quantizations-llms/)
