# OCR-Based Document Extraction

## Overview
Optical Character Recognition (OCR) converts images and scanned documents into machine-readable text. Essential for processing scanned PDFs, images, and handwritten documents in RAG systems.

---

## What is OCR?

**Definition:** Technology that recognizes text within digital images and converts it to machine-encoded text.

**Use cases:**
- Scanned documents and PDFs
- Images containing text
- Screenshots
- Historical documents
- Handwritten notes
- Forms and receipts

---

## When to Use OCR

**Text-based PDFs vs. Scanned PDFs:**

```python
import fitz  # PyMuPDF

def is_scanned_pdf(file_path):
    """Check if PDF needs OCR"""
    doc = fitz.open(file_path)
    
    for page in doc:
        text = page.get_text().strip()
        if len(text) > 50:  # Has extractable text
            return False
    
    return True  # Likely scanned
```

**Indicators you need OCR:**
- PDF has no selectable text
- Document is an image file (JPG, PNG)
- Poor text extraction quality
- Scanned books or papers

---

## OCR Tools and Libraries

### **1. Tesseract OCR**

Open-source, most popular OCR engine.

**Installation:**
```bash
# Windows
# Download from: https://github.com/UB-Mannheim/tesseract/wiki

# Linux
sudo apt-get install tesseract-ocr

# Mac
brew install tesseract
```

**Basic Usage:**
```python
import pytesseract
from PIL import Image

def extract_text_tesseract(image_path):
    # Load image
    image = Image.open(image_path)
    
    # Extract text
    text = pytesseract.image_to_string(image)
    
    return text

# With language specification
text = pytesseract.image_to_string(image, lang='eng')

# Get detailed data
data = pytesseract.image_to_data(image, output_type=pytesseract.Output.DICT)
```

**Pros:**
- Free and open source
- Supports 100+ languages
- Good accuracy for printed text
- Active development

**Cons:**
- Slower than commercial solutions
- Requires preprocessing for best results
- Struggles with handwriting
- No built-in layout analysis

---

### **2. EasyOCR**

Deep learning-based OCR with simple API.

**Installation:**
```bash
pip install easyocr
```

**Usage:**
```python
import easyocr

# Initialize reader (downloads models on first use)
reader = easyocr.Reader(['en'])  # Specify languages

def extract_text_easyocr(image_path):
    # Extract text
    results = reader.readtext(image_path)
    
    # Results include: (bbox, text, confidence)
    text = "\n".join([res[1] for res in results])
    
    return text, results

# Multilingual
reader_multi = easyocr.Reader(['en', 'es', 'fr'])
results = reader_multi.readtext('multilingual.jpg')
```

**Pros:**
- Very easy to use
- Good accuracy
- Supports 80+ languages
- GPU acceleration

**Cons:**
- Larger model downloads
- Requires GPU for speed
- Less customization

---

### **3. PaddleOCR**

High-performance OCR from Baidu.

**Installation:**
```bash
pip install paddlepaddle paddleocr
```

**Usage:**
```python
from paddleocr import PaddleOCR

# Initialize
ocr = PaddleOCR(use_angle_cls=True, lang='en')

def extract_text_paddle(image_path):
    results = ocr.ocr(image_path, cls=True)
    
    # Extract text
    text = "\n".join([line[1][0] for line in results[0]])
    
    return text, results
```

**Pros:**
- Very fast
- Excellent accuracy
- Layout analysis included
- Rotation detection

**Cons:**
- Chinese-focused (but supports many languages)
- Learning curve
- Dependencies

---

### **4. Google Cloud Vision API**

Commercial cloud-based OCR.

```python
from google.cloud import vision

client = vision.ImageAnnotatorClient()

def extract_text_google_vision(image_path):
    with open(image_path, 'rb') as image_file:
        content = image_file.read()
    
    image = vision.Image(content=content)
    response = client.text_detection(image=image)
    texts = response.text_annotations
    
    if texts:
        return texts[0].description
    
    return ""
```

**Pros:**
- Extremely high accuracy
- Handles complex layouts
- Many languages
- Handwriting support

**Cons:**
- Costs money
- Requires internet
- Privacy concerns

---

### **5. Azure Computer Vision**

Microsoft's OCR service.

```python
from azure.cognitiveservices.vision.computervision import ComputerVisionClient
from msrest.authentication import CognitiveServicesCredentials

client = ComputerVisionClient(endpoint, CognitiveServicesCredentials(key))

def extract_text_azure(image_url):
    # For Read API
    read_response = client.read(image_url, raw=True)
    operation_id = read_response.headers["Operation-Location"].split("/")[-1]
    
    # Wait for result
    while True:
        result = client.get_read_result(operation_id)
        if result.status not in ['notStarted', 'running']:
            break
    
    # Extract text
    text = ""
    if result.status == 'succeeded':
        for page in result.analyze_result.read_results:
            for line in page.lines:
                text += line.text + "\n"
    
    return text
```

---

### **6. AWS Textract**

Amazon's document analysis service.

```python
import boto3

textract = boto3.client('textract')

def extract_text_textract(image_bytes):
    response = textract.detect_document_text(
        Document={'Bytes': image_bytes}
    )
    
    # Extract text
    text = ""
    for item in response['Blocks']:
        if item['BlockType'] == 'LINE':
            text += item['Text'] + "\n"
    
    return text

# For tables
def extract_tables_textract(image_bytes):
    response = textract.analyze_document(
        Document={'Bytes': image_bytes},
        FeatureTypes=['TABLES']
    )
    
    # Parse table structure
    # ...
```

**Pros:**
- Excellent table extraction
- Form detection
- High accuracy
- Layout analysis

---

## OCR for PDFs

### **PDF with OCR (pdf2image + Tesseract):**

```python
from pdf2image import convert_from_path
import pytesseract

def ocr_pdf(pdf_path):
    # Convert PDF pages to images
    images = convert_from_path(pdf_path)
    
    full_text = ""
    for i, image in enumerate(images):
        print(f"Processing page {i+1}...")
        text = pytesseract.image_to_string(image)
        full_text += f"\n\n--- Page {i+1} ---\n\n{text}"
    
    return full_text
```

### **OCRmyPDF:**

```bash
# Install
pip install ocrmypdf

# Add OCR layer to PDF
ocrmypdf input.pdf output.pdf

# With language
ocrmypdf -l eng+fra input.pdf output.pdf
```

```python
import ocrmypdf

def add_ocr_layer(input_pdf, output_pdf):
    ocrmypdf.ocr(
        input_pdf,
        output_pdf,
        deskew=True,
        rotate_pages=True,
        remove_background=True
    )
```

---

## Image Preprocessing for Better OCR

### **1. Grayscale Conversion**

```python
from PIL import Image

def to_grayscale(image_path):
    image = Image.open(image_path)
    gray_image = image.convert('L')
    return gray_image
```

### **2. Thresholding**

```python
import cv2

def apply_threshold(image_path):
    img = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE)
    
    # Binary threshold
    _, thresh = cv2.threshold(img, 127, 255, cv2.THRESH_BINARY)
    
    # Adaptive threshold (better for varying lighting)
    adaptive = cv2.adaptiveThreshold(
        img, 255, 
        cv2.ADAPTIVE_THRESH_GAUSSIAN_C, 
        cv2.THRESH_BINARY, 11, 2
    )
    
    return adaptive
```

### **3. Noise Removal**

```python
def remove_noise(image):
    return cv2.medianBlur(image, 5)
```

### **4. Deskewing**

```python
import numpy as np

def deskew(image):
    coords = np.column_stack(np.where(image > 0))
    angle = cv2.minAreaRect(coords)[-1]
    
    if angle < -45:
        angle = -(90 + angle)
    else:
        angle = -angle
    
    (h, w) = image.shape[:2]
    center = (w // 2, h // 2)
    M = cv2.getRotationMatrix2D(center, angle, 1.0)
    rotated = cv2.warpAffine(
        image, M, (w, h),
        flags=cv2.INTER_CUBIC,
        borderMode=cv2.BORDER_REPLICATE
    )
    
    return rotated
```

### **5. Border Removal**

```python
def remove_borders(image):
    contours, _ = cv2.findContours(image, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    largest_contour = max(contours, key=cv2.contourArea)
    x, y, w, h = cv2.boundingRect(largest_contour)
    cropped = image[y:y+h, x:x+w]
    return cropped
```

### **Complete Preprocessing Pipeline:**

```python
def preprocess_for_ocr(image_path):
    # Read image
    img = cv2.imread(image_path)
    
    # Convert to gray
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    
    # Remove noise
    denoised = cv2.medianBlur(gray, 3)
    
    # Threshold
    thresh = cv2.threshold(denoised, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)[1]
    
    # Deskew
    deskewed = deskew(thresh)
    
    return deskewed
```

---

## Best Practices

### **1. Choose the Right Tool:**
- **Quick prototype**: EasyOCR
- **Best free option**: Tesseract with preprocessing
- **Production/accuracy**: Cloud APIs (Google, Azure, AWS)
- **Tables & forms**: AWS Textract
- **Speed**: PaddleOCR

### **2. Optimize Images:**
- **Resolution**: 300 DPI minimum
- **Format**: PNG or TIFF (lossless)
- **Size**: Not too large (impacts speed)
- **Contrast**: Clear text on background

### **3. Handle Errors:**

```python
def safe_ocr(image_path, fallback=True):
    try:
        # Try primary OCR
        text = extract_text_easyocr(image_path)
        if len(text.strip()) < 10 and fallback:
            # Try alternative
            text = extract_text_tesseract(image_path)
        return text
    except Exception as e:
        print(f"OCR failed: {e}")
        return ""
```

### **4. Post-Processing:**

```python
import re

def clean_ocr_text(text):
    # Remove common OCR errors
    text = text.replace('|', 'I')  # Common mistake
    text = text.replace('0', 'O')  # In words
    
    # Remove extra whitespace
    text = re.sub(r'\s+', ' ', text)
    
    # Fix line breaks
    text = re.sub(r'\n{3,}', '\n\n', text)
    
    return text.strip()
```

### **5. Confidence Scores:**

```python
def ocr_with_confidence(image_path, min_confidence=60):
    reader = easyocr.Reader(['en'])
    results = reader.readtext(image_path)
    
    # Filter by confidence
    high_confidence = [
        (text, conf) for (_, text, conf) in results 
        if conf * 100 >= min_confidence
    ]
    
    return high_confidence
```

---

## Layout Analysis

### **Detect Text Regions:**

```python
from PIL import Image
import pytesseract

def detect_text_regions(image_path):
    image = Image.open(image_path)
    
    # Get bounding boxes
    data = pytesseract.image_to_data(image, output_type=pytesseract.Output.DICT)
    
    regions = []
    for i, text in enumerate(data['text']):
        if text.strip():
            regions.append({
                'text': text,
                'confidence': data['conf'][i],
                'bbox': (
                    data['left'][i],
                    data['top'][i],
                    data['width'][i],
                    data['height'][i]
                )
            })
    
    return regions
```

---

## Handling Different Document Types

### **1. Invoices/Receipts:**
- Use specialized models (DocTR, LayoutLM)
- Template matching
- Key-value pair extraction

### **2. Forms:**
- AWS Textract Forms
- Checkbox detection
- Field extraction

### **3. Tables:**
- Table detection models
- Structure preservation
- Cell-by-cell extraction

### **4. Handwriting:**
- Google Vision API
- Azure Read API
- Specialized models

---

## Performance Optimization

```python
import concurrent.futures

def batch_ocr(image_paths, max_workers=4):
    """Process multiple images in parallel"""
    with concurrent.futures.ThreadPoolExecutor(max_workers=max_workers) as executor:
        results = list(executor.map(extract_text_easyocr, image_paths))
    return results
```

---

## Integration with RAG

```python
class OCRDocumentProcessor:
    def __init__(self):
        self.reader = easyocr.Reader(['en'])
    
    def process_document(self, file_path):
        # Detect if OCR is needed
        if self.needs_ocr(file_path):
            text = self.ocr_extract(file_path)
        else:
            text = self.direct_extract(file_path)
        
        # Clean and chunk
        text = clean_ocr_text(text)
        chunks = self.chunk_text(text)
        
        return chunks
    
    def needs_ocr(self, file_path):
        # Implementation
        pass
    
    def ocr_extract(self, file_path):
        # Implementation
        pass
```

---

## Next Steps
- Experiment with different OCR engines on your documents
- Implement preprocessing pipeline
- Integrate with vector database
- Learn about document-specific models (LayoutLM, DocTR)
