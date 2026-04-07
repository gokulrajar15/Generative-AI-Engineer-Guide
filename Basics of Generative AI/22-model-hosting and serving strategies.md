## Model Serving 

Model serving is the process of deploying a trained model to production, allowing it to handle inference requests from users or applications. This involves setting up infrastructure that can efficiently manage resources, scale with demand, and provide low-latency responses.

Tools and frameworks for serving LLMs:

### Inference Servers
- **vLLM**: High-throughput inference with PagedAttention
- **SGLang**: Structured generation language runtime
- **Triton Inference Server**: NVIDIA's multi-framework server
- **LitServe**: Lightning-fast model serving
- **TGI** (Text Generation Inference): Hugging Face's inference server
- **Ollama**: Local model deployment

### Key Features
- GPU optimization
- Request batching
- Multi-model support
- API endpoints
- Monitoring and logging


## Understanding Model Serving and Inference Strategies

Key concepts:
- **Batching**: Processing multiple requests together
- **KV Cache**: Caching key-value pairs for efficiency
- **Speculative decoding**: Faster generation with draft models
- **Continuous batching**: Dynamic request handling
- **Model parallelism**: Distributing models across GPUs
- **Tensor parallelism**: Splitting model layers
