# Multimodal Vector Search

## Overview
Multimodal vector search enables retrieving and searching across different data types (text, images, audio, video) in a unified vector space. Essential for modern AI applications handling diverse content types.

---

## What is Multimodal Search?

**Traditional search**: Text queries → Text documents

**Multimodal search**: Any modality → Any modality

**Examples:**
- Text query → Find relevant images
- Image query → Find similar images or describing text
- Audio query → Find matching text or video
- Text → Video frames

---

## Multimodal Embedding Models

### **1. CLIP (Contrastive Language-Image Pre-training)**

Maps images and text to the same vector space.

```python
from transformers import CLIPProcessor, CLIPModel
from PIL import Image
import torch

# Load model
model = CLIPModel.from_pretrained("openai/clip-vit-base-patch32")
processor = CLIPProcessor.from_pretrained("openai/clip-vit-base-patch32")

def embed_image(image_path):
    """Convert image to embedding"""
    image = Image.open(image_path)
    inputs = processor(images=image, return_tensors="pt")
    
    with torch.no_grad():
        image_features = model.get_image_features(**inputs)
    
    return image_features.numpy()[0]

def embed_text_clip(text):
    """Convert text to embedding (CLIP)"""
    inputs = processor(text=[text], return_tensors="pt", padding=True)
    
    with torch.no_grad():
        text_features = model.get_text_features(**inputs)
    
    return text_features.numpy()[0]

# Text-to-image search
query = "a dog playing in the park"
query_embedding = embed_text_clip(query)

# Image-to-image search
query_image_embedding = embed_image("query_image.jpg")
```

---

### **2. SigLIP (Improved CLIP)**

Google's improved version of CLIP.

```python
from transformers import AutoProcessor, AutoModel

model = AutoModel.from_pretrained("google/siglip-base-patch16-224")
processor = AutoProcessor.from_pretrained("google/siglip-base-patch16-224")

def embed_with_siglip(image=None, text=None):
    if image and text:
        inputs = processor(images=image, text=text, return_tensors="pt")
    elif image:
        inputs = processor(images=image, return_tensors="pt")
    else:
        inputs = processor(text=text, return_tensors="pt")
    
    with torch.no_grad():
        outputs = model(**inputs)
    
    if image and not text:
        return outputs.image_embeds.numpy()[0]
    elif text and not image:
        return outputs.text_embeds.numpy()[0]
    else:
        return outputs.image_embeds, outputs.text_embeds
```

---

### **3. ImageBind (Meta)**

Unified embedding space for 6 modalities.

**Modalities:**
- Images
- Text
- Audio
- Depth
- Thermal
- IMU (motion)

```python
import imagebind from imagebind.models import imagebind_model
from imagebind.models.imagebind_model import ModalityType

# Load model
model = imagebind_model.imagebind_huge(pretrained=True)
model.eval()

def embed_multimodal(inputs):
    """
    inputs: dict with modality types as keys
    e.g., {ModalityType.TEXT: ["text"], ModalityType.VISION: [image_paths]}
    """
    with torch.no_grad():
        embeddings = model(inputs)
    
    return embeddings
```

---

### **4. BridgeTower**

Specialized for vision-language tasks.

```python
from transformers import BridgeTowerProcessor, BridgeTowerModel

model = BridgeTowerModel.from_pretrained("BridgeTower/bridgetower-large-itm-mlm")
processor = BridgeTowerProcessor.from_pretrained("BridgeTower/bridgetower-large-itm-mlm")

def embed_image_text_pair(image, text):
    inputs = processor(images=image, text=text, return_tensors="pt")
    
    with torch.no_grad():
        outputs = model(**inputs)
    
    return outputs.pooler_output.numpy()[0]
```

---

## Building a Multimodal RAG System

### **Complete Pipeline:**

```python
class MultimodalRAG:
    def __init__(self, clip_model, vector_index):
        self.clip_model = clip_model
        self.processor = CLIPProcessor.from_pretrained("openai/clip-vit-base-patch32")
        self.index = vector_index
    
    def index_image(self, image_path, metadata):
        """Add image to index"""
        # Embed image
        image = Image.open(image_path)
        embedding = self.embed_image(image)
        
        # Store in vector DB
        self.index.upsert([{
            'id': metadata['id'],
            'values': embedding.tolist(),
            'metadata': {
                **metadata,
                'type': 'image',
                'path': image_path
            }
        }])
    
    def index_text_with_image(self, text, image_path, metadata):
        """Index text-image pairs"""
        # You can either:
        # 1. Store image and text separately
        # 2. Combine their embeddings
        # 3. Use image embedding with text as metadata
        
        image_embedding = self.embed_image(Image.open(image_path))
        
        self.index.upsert([{
            'id': metadata['id'],
            'values': image_embedding.tolist(),
            'metadata': {
                **metadata,
                'type': 'text_image_pair',
                'text': text,
                'image_path': image_path
            }
        }])
    
    def search_with_text(self, query, top_k=5):
        """Search images/multimodal content with text"""
        query_embedding = self.embed_text(query)
        
        results = self.index.query(
            vector=query_embedding.tolist(),
            top_k=top_k,
            include_metadata=True
        )
        
        return results
    
    def search_with_image(self, image_path, top_k=5):
        """Search with image query"""
        query_embedding = self.embed_image(Image.open(image_path))
        
        results = self.index.query(
            vector=query_embedding.tolist(),
            top_k=top_k,
            include_metadata=True
        )
        
        return results
    
    def embed_image(self, image):
        inputs = self.processor(images=image, return_tensors="pt")
        with torch.no_grad():
            features = self.clip_model.get_image_features(**inputs)
        return features.numpy()[0]
    
    def embed_text(self, text):
        inputs = self.processor(text=[text], return_tensors="pt")
        with torch.no_grad():
            features = self.clip_model.get_text_features(**inputs)
        return features.numpy()[0]
```

---

## Use Cases

### **1. Visual Question Answering (VQA)**

```python
def visual_qa(image_path, question, multimodal_rag, llm):
    # Retrieve similar images or context
    results = multimodal_rag.search_with_image(image_path, top_k=3)
    
    # Create multimodal prompt
    prompt = f"""Image: [See attached]

Related context from database:
{format_multimodal_results(results)}

Question: {question}

Answer:"""
    
    # Generate answer (using vision-language model)
    answer = llm.generate(prompt, images=[image_path])
    
    return answer
```

---

### **2. Image-to-Text Generation with RAG**

```python
def describe_image_with_rag(image_path, multimodal_rag, llm):
    # Find similar images
    similar_images = multimodal_rag.search_with_image(image_path, top_k=5)
    
    # Extract descriptions from similar images
    context_descriptions = [
        result['metadata']['text'] 
        for result in similar_images 
        if 'text' in result['metadata']
    ]
    
    # Generate description using context
    prompt = f"""Generate a description for the attached image.

Similar images have been described as:
{chr(10).join(context_descriptions)}

Description:"""
    
    description = llm.generate(prompt, images=[image_path])
    return description
```

---

### **3. Product Search (E-commerce)**

```python
def product_search(query, multimodal_rag):
    # Support both text and image queries
    if is_image(query):
        results = multimodal_rag.search_with_image(query)
    else:
        results = multimodal_rag.search_with_text(query)
    
    # Format product results
    products = []
    for result in results:
        products.append({
            'id': result['metadata']['product_id'],
            'name': result['metadata']['name'],
            'image': result['metadata']['image_path'],
            'price': result['metadata']['price'],
            'similarity': result['score']
        })
    
    return products
```

---

### **4. Document Understanding (PDFs with Images)**

```python
from pdf2image import convert_from_path

def index_pdf_pages(pdf_path, multimodal_rag):
    """Index PDF pages as images + extracted text"""
    # Convert PDF to images
    images = convert_from_path(pdf_path)
    
    # Extract text (OCR or native)
    texts = extract_text_from_pdf(pdf_path)
    
    for i, (image, text) in enumerate(zip(images, texts)):
        # Save page image
        page_image_path = f"page_{i}.png"
        image.save(page_image_path)
        
        # Index with both image and text
        multimodal_rag.index_text_with_image(
            text=text,
            image_path=page_image_path,
            metadata={
                'id': f"{pdf_path}_page_{i}",
                'page_number': i,
                'document': pdf_path
            }
        )
```

---

## Advanced Techniques

### **1. Cross-Modal Retrieval**

```python
def cross_modal_retrieval(query, query_type, corpus_type, rag):
    """
    query_type: 'text' or 'image'
    corpus_type: 'text' or 'image' or 'both'
    """
    if query_type == 'text':
        query_emb = rag.embed_text(query)
    else:
        query_emb = rag.embed_image(Image.open(query))
    
    # Search across different modalities
    results = rag.index.query(
        vector=query_emb.tolist(),
        filter={'type': corpus_type} if corpus_type != 'both' else None,
        top_k=10
    )
    
    return results
```

---

### **2. Multimodal Fusion**

Combine embeddings from multiple modalities.

```python
def fuse_embeddings(text_emb, image_emb, strategy='concat'):
    """Combine text and image embeddings"""
    if strategy == 'concat':
        # Concatenate
        return np.concatenate([text_emb, image_emb])
    
    elif strategy == 'average':
        # Element-wise average
        return (text_emb + image_emb) / 2
    
    elif strategy == 'weighted':
        # Weighted combination
        alpha = 0.6  # Weight for text
        return alpha * text_emb + (1 - alpha) * image_emb
```

---

### **3. Late Interaction for Multimodal**

```python
def late_interaction_multimodal(query_text, query_image, documents):
    """Combine scores from different modalities"""
    
    # Compute text similarity
    text_emb = embed_text(query_text)
    text_scores = [cosine_similarity(text_emb, doc['text_emb']) 
                   for doc in documents]
    
    # Compute image similarity
    image_emb = embed_image(query_image)
    image_scores = [cosine_similarity(image_emb, doc['image_emb']) 
                    for doc in documents]
    
    # Combine scores
    combined_scores = [
        0.5 * text_score + 0.5 * image_score
        for text_score, image_score in zip(text_scores, image_scores)
    ]
    
    # Rank by combined score
    ranked_indices = np.argsort(combined_scores)[::-1]
    return [documents[i] for i in ranked_indices]
```

---

## Vector Databases for Multimodal

### **Weaviate Example:**

```python
import weaviate

client = weaviate.Client("http://localhost:8080")

# Create schema for multimodal data
class_obj = {
    "class": "MultimodalDocument",
    "vectorizer": "none",  # We provide our own embeddings
    "properties": [
        {"name": "text", "dataType": ["text"]},
        {"name": "imagePath", "dataType": ["string"]},
        {"name": "modality", "dataType": ["string"]},
    ]
}

client.schema.create_class(class_obj)

# Add multimodal document
client.data_object.create(
    data_object={
        "text": "A cute puppy playing",
        "imagePath": "/path/to/image.jpg",
        "modality": "text_image"
    },
    class_name="MultimodalDocument",
    vector=combined_embedding.tolist()
)
```

---

## ColPali: Vision Language Models for RAG

**ColPali** extends ColBERT to support document images directly.

```python
from colpali_engine import ColPaliModel, ColPaliProcessor

model = ColPaliModel.from_pretrained("colpali-model")
processor = ColPaliProcessor.from_pretrained("colpali-model")

def index_document_image(image_path):
    """Index document as image (no OCR needed!)"""
    image = Image.open(image_path)
    
    # ColPali creates multi-vector representation
    inputs = processor(images=image)
    embeddings = model(**inputs)
    
    return embeddings

def search_with_text(query, indexed_docs):
    """Search document images with text query"""
    query_inputs = processor(text=query)
    query_embeddings = model(**query_inputs)
    
    # Late interaction scoring
    scores = []
    for doc in indexed_docs:
        score = compute_late_interaction_score(query_embeddings, doc['embeddings'])
        scores.append(score)
    
    return scores
```

**Benefits:**
- No OCR needed
- Preserves layout
- Better than text-only RAG for visual documents

---

## Best Practices

1. **Choose appropriate models:**
   - CLIP: General image-text
   - SigLIP: Better zero-shot
   - ColPali: Document images
   - ImageBind: Multiple modalities

2. **Normalize embeddings:**
   ```python
   def normalize(embedding):
       return embedding / np.linalg.norm(embedding)
   ```

3. **Handle different aspect ratios:**
   - Resize images appropriately
   - Maintain aspect ratio
   - Use model's expected input size

4. **Metadata organization:**
   - Store modality type
   - Keep original file paths
   - Include dimensions/duration

5. **Hybrid search:**
   - Combine with text search
   - Use metadata filters
   - Apply reranking

---

## Next Steps
- Experiment with CLIP for your use case
- Build a multimodal search prototype
- Explore ColPali for document retrieval
- Implement cross-modal search
- Measure retrieval quality across modalities
