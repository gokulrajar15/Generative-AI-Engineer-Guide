# 17. Quantization

Techniques for optimizing LLMs and reducing model size.

---

## Quantization Techniques

### INT8 Quantization
8-bit integer precision - balanced quality and size reduction.

### INT4 Quantization
4-bit precision - aggressive size reduction with minimal quality loss.

### GPTQ
Post-training quantization method for large language models.

### AWQ (Activation-aware Weight Quantization)
Preserves important weights for better performance.

### GGUF
Efficient format for CPU inference, used by llama.cpp.

---

## Benefits

✅ Reduced memory footprint (2-8x smaller)  
✅ Faster inference  
✅ Lower deployment costs  
✅ Minimal accuracy loss (typically <5%)

---

## Example: Using Quantized Models

```python
from transformers import AutoModelForCausalLM, AutoTokenizer

# Load 4-bit quantized model
model = AutoModelForCausalLM.from_pretrained(
    "model-name",
    load_in_4bit=True,
    device_map="auto"
)

tokenizer = AutoTokenizer.from_pretrained("model-name")
```

📚 [Read more about quantization](https://cast.ai/blog/demystifying-quantizations-llms/)

---

**Previous**: [← Leaderboards](16-leaderboards.md)  
**Next**: [Serving Strategies →](18-serving-strategies.md)

[← Back to Index](README.md)
