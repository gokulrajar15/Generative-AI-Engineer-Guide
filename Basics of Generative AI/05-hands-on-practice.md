# 5. Hands-on Practice with Text Generation, Vision, TTS, STT, and Embeddings

Practical experience using OpenAI, Google Gemini, Groq, and other providers.

---

## Overview

This section provides hands-on examples for working with various AI APIs and capabilities.

---

## Setup and Prerequisites

### Installing Required Libraries

```bash
# OpenAI
pip install openai

# Google Gemini
pip install google-generativeai

# Anthropic Claude
pip install anthropic

# Groq
pip install groq

# For audio processing
pip install pydub soundfile

# For image processing
pip install pillow requests
```

### API Keys Setup

```python
import os
from dotenv import load_dotenv

load_dotenv()

OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
GOOGLE_API_KEY = os.getenv("GOOGLE_API_KEY")
ANTHROPIC_API_KEY = os.getenv("ANTHROPIC_API_KEY")
GROQ_API_KEY = os.getenv("GROQ_API_KEY")
```

---

## Text Generation

### OpenAI GPT

```python
from openai import OpenAI

client = OpenAI(api_key=OPENAI_API_KEY)

# Basic text generation
response = client.chat.completions.create(
    model="gpt-4",
    messages=[
        {"role": "system", "content": "You are a helpful assistant."},
        {"role": "user", "content": "Explain quantum computing in simple terms."}
    ],
    temperature=0.7,
    max_tokens=500
)

print(response.choices[0].message.content)
```

### Google Gemini

```python
import google.generativeai as genai

genai.configure(api_key=GOOGLE_API_KEY)

model = genai.GenerativeModel('gemini-pro')

response = model.generate_content(
    "Explain quantum computing in simple terms.",
    generation_config=genai.types.GenerationConfig(
        temperature=0.7,
        max_output_tokens=500,
    )
)

print(response.text)
```

### Anthropic Claude

```python
from anthropic import Anthropic

client = Anthropic(api_key=ANTHROPIC_API_KEY)

response = client.messages.create(
    model="claude-3-opus-20240229",
    max_tokens=500,
    messages=[
        {"role": "user", "content": "Explain quantum computing in simple terms."}
    ]
)

print(response.content[0].text)
`````

### Groq (Fast Inference)

```python
from groq import Groq

client = Groq(api_key=GROQ_API_KEY)

response = client.chat.completions.create(
    model="mixtral-8x7b-32768",
    messages=[
        {"role": "user", "content": "Explain quantum computing in simple terms."}
    ],
    temperature=0.7,
    max_tokens=500
)

print(response.choices[0].message.content)
```

---

## Vision (Image Understanding)

### OpenAI GPT-4 Vision

```python
from openai import OpenAI
import base64

client = OpenAI(api_key=OPENAI_API_KEY)

# From URL
response = client.chat.completions.create(
    model="gpt-4-vision-preview",
    messages=[
        {
            "role": "user",
            "content": [
                {"type": "text", "text": "What's in this image?"},
                {
                    "type": "image_url",
                    "image_url": {
                        "url": "https://example.com/image.jpg"
                    }
                }
            ]
        }
    ],
    max_tokens=300
)

print(response.choices[0].message.content)

# From local file
def encode_image(image_path):
    with open(image_path, "rb") as image_file:
        return base64.b64encode(image_file.read()).decode('utf-8')

base64_image = encode_image("path/to/image.jpg")

response = client.chat.completions.create(
    model="gpt-4-vision-preview",
    messages=[
        {
            "role": "user",
            "content": [
                {"type": "text", "text": "Describe this image in detail."},
                {
                    "type": "image_url",
                    "image_url": {
                        "url": f"data:image/jpeg;base64,{base64_image}"
                    }
                }
            ]
        }
    ]
)
```

### Google Gemini Vision

```python
import google.generativeai as genai
from PIL import Image

genai.configure(api_key=GOOGLE_API_KEY)

model = genai.GenerativeModel('gemini-pro-vision')

# From local file
image = Image.open('path/to/image.jpg')

response = model.generate_content([
    "Describe this image in detail.",
    image
])

print(response.text)
```

---

## Text-to-Speech (TTS)

### OpenAI TTS

```python
from openai import OpenAI
from pathlib import Path

client = OpenAI(api_key=OPENAI_API_KEY)

# Generate speech
response = client.audio.speech.create(
    model="tts-1",  # or "tts-1-hd" for higher quality
    voice="alloy",  # alloy, echo, fable, onyx, nova, shimmer
    input="Hello! This is a test of text to speech conversion."
)

# Save to file
speech_file_path = Path("output.mp3")
response.stream_to_file(speech_file_path)

print(f"Audio saved to {speech_file_path}")
```

### Google TTS

```python
from google.cloud import texttospeech

client = texttospeech.TextToSpeechClient()

synthesis_input = texttospeech.SynthesisInput(
    text="Hello! This is a test of text to speech conversion."
)

voice = texttospeech.VoiceSelectionParams(
    language_code="en-US",
    ssml_gender=texttospeech.SsmlVoiceGender.NEUTRAL
)

audio_config = texttospeech.AudioConfig(
    audio_encoding=texttospeech.AudioEncoding.MP3
)

response = client.synthesize_speech(
    input=synthesis_input,
    voice=voice,
    audio_config=audio_config
)

with open("output.mp3", "wb") as out:
    out.write(response.audio_content)
```

---

## Speech-to-Text (STT)

### OpenAI Whisper

```python
from openai import OpenAI

client = OpenAI(api_key=OPENAI_API_KEY)

# Transcribe audio
with open("audio.mp3", "rb") as audio_file:
    transcript = client.audio.transcriptions.create(
        model="whisper-1",
        file=audio_file,
        response_format="text"
    )

print(transcript)

# With timestamps (verbose JSON)
with open("audio.mp3", "rb") as audio_file:
    transcript = client.audio.transcriptions.create(
        model="whisper-1",
        file=audio_file,
        response_format="verbose_json",
        timestamp_granularities=["word"]
    )

print(transcript.text)
for word in transcript.words:
    print(f"{word.word}: {word.start}s - {word.end}s")

# Translation (to English)
with open("audio_spanish.mp3", "rb") as audio_file:
    translation = client.audio.translations.create(
        model="whisper-1",
        file=audio_file
    )

print(translation.text)
```

---

## Embeddings

### OpenAI Embeddings

```python
from openai import OpenAI
import numpy as np

client = OpenAI(api_key=OPENAI_API_KEY)

# Generate embeddings
def get_embedding(text, model="text-embedding-3-small"):
    text = text.replace("\n", " ")
    response = client.embeddings.create(input=[text], model=model)
    return response.data[0].embedding

# Single text
embedding = get_embedding("This is a test sentence.")
print(f"Embedding dimension: {len(embedding)}")

# Batch embeddings
texts = [
    "Artificial intelligence is transforming industries.",
    "Machine learning enables computers to learn from data.",
    "Deep learning uses neural networks with multiple layers."
]

embeddings = []
for text in texts:
    embedding = get_embedding(text)
    embeddings.append(embedding)

# Calculate similarity
def cosine_similarity(a, b):
    return np.dot(a, b) / (np.linalg.norm(a) * np.linalg.norm(b))

similarity = cosine_similarity(embeddings[0], embeddings[1])
print(f"Similarity between text 1 and 2: {similarity:.4f}")
```

### Google Embeddings

```python
import google.generativeai as genai

genai.configure(api_key=GOOGLE_API_KEY)

# Generate embedding
result = genai.embed_content(
    model="models/embedding-001",
    content="This is a test sentence.",
    task_type="retrieval_document"
)

embedding = result['embedding']
print(f"Embedding dimension: {len(embedding)}")
```

### Cohere Embeddings

```python
import cohere

co = cohere.Client(api_key=COHERE_API_KEY)

# Generate embeddings
texts = [
    "Artificial intelligence is transforming industries.",
    "Machine learning enables computers to learn from data."
]

response = co.embed(
    texts=texts,
    model='embed-english-v3.0',
    input_type='search_document'
)

embeddings = response.embeddings
print(f"Number of embeddings: {len(embeddings)}")
print(f"Embedding dimension: {len(embeddings[0])}")
```

---

## Practical Examples

### Document Q&A with Embeddings

```python
from openai import OpenAI
import numpy as np

client = OpenAI(api_key=OPENAI_API_KEY)

# Sample documents
documents = [
    "Python is a high-level programming language.",
    "JavaScript is primarily used for web development.",
    "Machine learning is a subset of artificial intelligence.",
    "Neural networks are inspired by the human brain."
]

# Create embeddings for documents
doc_embeddings = []
for doc in documents:
    embedding = get_embedding(doc)
    doc_embeddings.append(embedding)

# User query
query = "What language is used for AI?"
query_embedding = get_embedding(query)

# Find most similar document
similarities = [
    cosine_similarity(query_embedding, doc_emb) 
    for doc_emb in doc_embeddings
]

most_similar_idx = np.argmax(similarities)
print(f"Most relevant document: {documents[most_similar_idx]}")
print(f"Similarity score: {similarities[most_similar_idx]:.4f}")
```

### Image Description and TTS

```python
from openai import OpenAI
from pathlib import Path

client = OpenAI(api_key=OPENAI_API_KEY)

# 1. Analyze image
response = client.chat.completions.create(
    model="gpt-4-vision-preview",
    messages=[
        {
            "role": "user",
            "content": [
                {"type": "text", "text": "Describe this image briefly."},
                {
                    "type": "image_url",
                    "image_url": {"url": "https://example.com/image.jpg"}
                }
            ]
        }
    ]
)

description = response.choices[0].message.content

# 2. Convert description to speech
speech_response = client.audio.speech.create(
    model="tts-1",
    voice="nova",
    input=description
)

speech_response.stream_to_file("image_description.mp3")
print("Image described and converted to speech!")
```

---

## 📚 Further Reading

- [OpenAI API Documentation](https://platform.openai.com/docs)
- [Google AI Documentation](https://ai.google.dev/docs)
- [Anthropic Claude Docs](https://docs.anthropic.com)
- [Groq Documentation](https://console.groq.com/docs)

---

**Previous**: [← Understanding Tokenizers](04-tokenizers.md)  
**Next**: [Prompting Best Practices →](06-prompting-strategies.md)

[← Back to Index](README.md)
