# 19. Model Hosting and Inference

Tools and frameworks for serving LLMs in production.

---

## Inference Servers

### vLLM
High-throughput inference with PagedAttention.

```bash
# Install
pip install vllm

# Serve model
python -m vllm.entrypoints.openai.api_server \
    --model meta-llama/Llama-2-7b-hf \
    --port 8000
```

### SGLang
Structured generation language runtime for efficient inference.

### Triton Inference Server
NVIDIA's multi-framework server supporting TensorFlow, PyTorch, ONNX.

### LitServe
Lightning-fast model serving from Lightning AI.

```python
import litserve as ls

class SimpleLitAPI(ls.LitAPI):
    def setup(self, device):
        self.model = load_model()
    
    def predict(self, x):
        return self.model(x)

server = ls.LitServer(SimpleLitAPI())
server.run(port=8000)
```

### TGI (Text Generation Inference)
Hugging Face's optimized inference server.

```bash
docker run --gpus all --shm-size 1g -p 8080:80 \
    ghcr.io/huggingface/text-generation-inference:latest \
    --model-id meta-llama/Llama-2-7b-hf
```

### Ollama
Local model deployment made easy.

```bash
# Install and run
ollama run llama2

# API usage
curl http://localhost:11434/api/generate -d '{
  "model": "llama2",
  "prompt": "Why is the sky blue?"
}'
```

---

## Key Features

✅ GPU optimization  
✅ Request batching  
✅ Multi-model support  
✅ REST API endpoints  
✅ Monitoring and logging  
✅ Auto-scaling capabilities

---

## Deployment Checklist

- [ ] Choose appropriate instance type (GPU/CPU)
- [ ] Implement health checks
- [ ] Set up monitoring (Prometheus, Grafana)
- [ ] Configure auto-scaling
- [ ] Implement rate limiting
- [ ] Set up logging
- [ ] Add authentication
- [ ] Test load handling
- [ ] Document API endpoints

---

**Previous**: [← Serving Strategies](18-serving-strategies.md)

[← Back to Index](README.md) | [← Back to Main Guide](../README.md)
