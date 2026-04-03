# 12. LLM Fine-tuning (Hands-on)

Complete understanding of model customization.

---

## Pre-training
- Training models from scratch
- Data preparation and curation
- Requires massive computational resources

## Fine-tuning Techniques

### PEFT (Parameter-Efficient Fine-Tuning)
Updates only a small subset of model parameters.

### LoRA (Low-Rank Adaptation)
```python
from peft import LoraConfig, get_peft_model
from transformers import AutoModelForCausalLM

model = AutoModelForCausalLM.from_pretrained("base-model")

lora_config = LoraConfig(
    r=8,  # Rank
    lora_alpha=32,
    target_modules=["q_proj", "v_proj"],
    lora_dropout=0.05,
    bias="none"
)

model = get_peft_model(model, lora_config)
```

### QLoRA (Quantized LoRA)
LoRA with 4-bit quantization for reduced memory usage.

## Model Alignment

### RLHF (Reinforcement Learning from Human Feedback)
1. Supervised fine-tuning
2. Train reward model
3. Optimize policy with RL

### DPO (Direct Preference Optimization)
Simpler alternative to RLHF, trains directly on preference data.

### PPO (Proximal Policy Optimization)
RL algorithm used in RLHF training.

---

**Previous**: [← Real-time APIs](11-realtime-apis.md)  
**Next**: [LLM Benchmarks →](13-benchmarks.md)

[← Back to Index](README.md)
