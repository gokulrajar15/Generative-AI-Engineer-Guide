# Document Extraction Techniques

## Overview
Document extraction is the process of converting various document formats (PDF, DOCX, HTML, etc.) into clean text or structured data for RAG systems. Quality extraction is critical for downstream retrieval and generation.

---

## Why Document Extraction Matters

**Challenges:**
- Multiple file formats (PDF, DOCX, HTML, TXT, etc.)
- Complex layouts (multi-column, tables, images)
- Embedded images and charts
- Formatting preservation vs. clean text
- Metadata extraction

**Goals:**
- Extract accurate text content
- Preserve document structure when needed
- Handle tables and lists properly
- Extract metadata (author, date, title)
- Maintain performance at scale

---

## Common Document Formats

### 1. **Plain Text (.txt)**
- Simplest format
- Direct reading, minimal processing
- No formatting information

### 2. **PDF (.pdf)**
- Most common business document format
- Can be text-based or image-based (scanned)
- Complex layouts, fonts, embedded objects

### 3. **Microsoft Word (.docx, .doc)**
- Structured XML format (.docx)
- Binary format (.doc)
- Rich formatting, styles, tables

### 4. **HTML/Web Pages**
- Markup-based structure
- Navigation elements, scripts
- Need cleaning and extraction

### 5. **Markdown (.md)**
- Plain text with formatting markers
- Easy to parse
- Popular in technical documentation

### 6. **Spreadsheets (.xlsx, .csv)**
- Tabular data
- Multiple sheets
- Formulas and formatting

### 7. **Presentations (.pptx)**
- Slide-based content
- Text, images, speaker notes

---

## Extraction Libraries and Tools

### **1. PyPDF2 / pypdf**

Basic PDF text extraction.

```python
from pypdf import PdfReader

def extract_pdf_pypdf(file_path):
    reader = PdfReader(file_path)
    text = ""
    
    for page in reader.pages:
        text += page.extract_text() + "\n\n"
    
    # Extract metadata
    metadata = {
        'title': reader.metadata.title,
        'author': reader.metadata.author,
        'pages': len(reader.pages)
    }
    
    return text, metadata
```

**Pros:**
- Pure Python, no dependencies
- Simple API
- Good for basic PDFs

**Cons:**
- Poor with complex layouts
- Struggles with scanned PDFs
- No table extraction

---

### **2. PyMuPDF (fitz)**

More advanced PDF extraction.

```python
import fitz  # PyMuPDF

def extract_pdf_pymupdf(file_path):
    doc = fitz.open(file_path)
    text = ""
    
    for page_num, page in enumerate(doc):
        text += f"--- Page {page_num + 1} ---\n"
        text += page.get_text() + "\n\n"
    
    # Extract images
    images = []
    for page in doc:
        for img in page.get_images():
            images.append(img)
    
    metadata = doc.metadata
    doc.close()
    
    return text, metadata, images
```

**Pros:**
- Fast and efficient
- Better layout handling
- Image extraction
- Table detection

**Cons:**
- C dependency
- More complex setup

---

### **3. pdfplumber**

Excellent for tables and structured data.

```python
import pdfplumber

def extract_pdf_with_tables(file_path):
    text = ""
    tables = []
    
    with pdfplumber.open(file_path) as pdf:
        for page in pdf.pages:
            # Extract text
            text += page.extract_text() + "\n\n"
            
            # Extract tables
            page_tables = page.extract_tables()
            if page_tables:
                tables.extend(page_tables)
    
    return text, tables
```

**Pros:**
- Excellent table extraction
- Layout-aware
- Good documentation

**Cons:**
- Slower than PyMuPDF
- Python only

---

### **4. python-docx**

Microsoft Word document extraction.

```python
from docx import Document

def extract_docx(file_path):
    doc = Document(file_path)
    
    # Extract paragraphs
    text = "\n\n".join([para.text for para in doc.paragraphs])
    
    # Extract tables
    tables = []
    for table in doc.tables:
        table_data = []
        for row in table.rows:
            table_data.append([cell.text for cell in row.cells])
        tables.append(table_data)
    
    # Extract metadata
    metadata = {
        'author': doc.core_properties.author,
        'title': doc.core_properties.title,
        'created': doc.core_properties.created
    }
    
    return text, tables, metadata
```

---

### **5. BeautifulSoup**

HTML/Web content extraction.

```python
from bs4 import BeautifulSoup
import requests

def extract_html(url):
    response = requests.get(url)
    soup = BeautifulSoup(response.content, 'html.parser')
    
    # Remove script and style elements
    for script in soup(["script", "style", "nav", "footer"]):
        script.decompose()
    
    # Extract main content
    main_content = soup.find('main') or soup.find('article') or soup.body
    text = main_content.get_text(separator='\n', strip=True)
    
    # Extract metadata
    metadata = {
        'title': soup.title.string if soup.title else None,
        'description': soup.find('meta', attrs={'name': 'description'}),
        'url': url
    }
    
    return text, metadata
```

---

### **6. Unstructured**

Unified library for multiple formats.

```python
from unstructured.partition.auto import partition

def extract_any_document(file_path):
    # Automatically detects file type
    elements = partition(filename=file_path)
    
    text = "\n\n".join([str(el) for el in elements])
    
    # Elements have types: Title, NarrativeText, Table, etc.
    structured = {
        'titles': [el.text for el in elements if el.category == 'Title'],
        'tables': [el.text for el in elements if el.category == 'Table'],
        'text': [el.text for el in elements if el.category == 'NarrativeText']
    }
    
    return text, structured
```

**Pros:**
- Handles many formats
- Good structure detection
- Integration with RAG frameworks

**Cons:**
- Heavier dependency
- Can be slower

---

### **7. Apache Tika**

Java-based universal document parser.

```python
from tika import parser

def extract_with_tika(file_path):
    parsed = parser.from_file(file_path)
    
    text = parsed['content']
    metadata = parsed['metadata']
    
    return text, metadata
```

**Pros:**
- Supports 1000+ file formats
- Robust and mature
- Good for enterprise

**Cons:**
- Requires Java
- Heavier setup

---

## Best Practices

### **1. Format Detection**

```python
import mimetypes
import pathlib

def detect_format(file_path):
    # By extension
    suffix = pathlib.Path(file_path).suffix.lower()
    
    # By MIME type
    mime_type, _ = mimetypes.guess_type(file_path)
    
    return suffix, mime_type
```

### **2. Robust Error Handling**

```python
def safe_extract(file_path):
    try:
        if file_path.endswith('.pdf'):
            return extract_pdf(file_path)
        elif file_path.endswith('.docx'):
            return extract_docx(file_path)
        # ... other formats
    except Exception as e:
        print(f"Error extracting {file_path}: {e}")
        return None, None
```

### **3. Text Cleaning**

```python
import re

def clean_extracted_text(text):
    # Remove extra whitespace
    text = re.sub(r'\s+', ' ', text)
    
    # Remove special characters
    text = re.sub(r'[^\w\s\.\,\!\?\-]', '', text)
    
    # Normalize line breaks
    text = re.sub(r'\n{3,}', '\n\n', text)
    
    return text.strip()
```

### **4. Preserve Structure**

```python
def extract_with_structure(file_path):
    sections = []
    current_section = {'title': None, 'content': ''}
    
    # Extract with structure markers
    # Group by headers, sections, etc.
    
    return sections
```

### **5. Handle Large Files**

```python
def extract_large_pdf_streaming(file_path, chunk_size=10):
    """Process large PDF in chunks"""
    reader = PdfReader(file_path)
    
    for i in range(0, len(reader.pages), chunk_size):
        chunk_pages = reader.pages[i:i+chunk_size]
        chunk_text = "".join([p.extract_text() for p in chunk_pages])
        yield chunk_text
```

---

## Advanced Techniques

### **1. Layout-Aware Extraction**

```python
import pdfplumber

def extract_with_layout(file_path):
    with pdfplumber.open(file_path) as pdf:
        for page in pdf.pages:
            # Get layout information
            layout = page.layout
            
            # Extract by regions
            for obj in page.objects.get('char', []):
                # Process with position info
                x, y, text = obj['x0'], obj['y0'], obj['text']
```

### **2. Multi-Column Detection**

```python
def detect_columns(page):
    # Analyze text positions
    # Group by columns
    # Extract column by column
    pass
```

### **3. Table Structure Preservation**

```python
import pandas as pd

def tables_to_markdown(tables):
    markdown_tables = []
    for table in tables:
        df = pd.DataFrame(table[1:], columns=table[0])
        markdown_tables.append(df.to_markdown())
    return markdown_tables
```

---

## Metadata Extraction

```python
def extract_comprehensive_metadata(file_path):
    metadata = {
        'filename': pathlib.Path(file_path).name,
        'file_size': pathlib.Path(file_path).stat().st_size,
        'created_date': None,
        'modified_date': None,
        'author': None,
        'title': None,
        'page_count': None,
        'language': None
    }
    
    # Format-specific metadata extraction
    # ...
    
    return metadata
```

---

## Selecting the Right Tool

| Format | Recommended Tool | Alternative |
|--------|-----------------|-------------|
| PDF (simple) | PyMuPDF | pypdf |
| PDF (tables) | pdfplumber | Camelot |
| PDF (scanned) | OCR tools | See next chapter |
| DOCX | python-docx | Unstructured |
| HTML | BeautifulSoup | Trafilatura |
| Any format | Unstructured | Apache Tika |
| Tables only | Camelot, Tabula | pdfplumber |

---

## Hands-On Example: Complete Pipeline

```python
class DocumentExtractor:
    def __init__(self):
        self.extractors = {
            '.pdf': self.extract_pdf,
            '.docx': self.extract_docx,
            '.html': self.extract_html,
            '.txt': self.extract_txt
        }
    
    def extract(self, file_path):
        suffix = pathlib.Path(file_path).suffix.lower()
        extractor = self.extractors.get(suffix)
        
        if not extractor:
            raise ValueError(f"Unsupported format: {suffix}")
        
        return extractor(file_path)
    
    def extract_pdf(self, file_path):
        # Implementation
        pass
    
    def extract_docx(self, file_path):
        # Implementation
        pass
    
    # ... other extractors

# Usage
extractor = DocumentExtractor()
text, metadata = extractor.extract("document.pdf")
```

---

## Next Steps
- Learn about OCR for scanned documents
- Implement batch processing for large document sets
- Integrate with RAG pipeline
- Explore multimodal extraction techniques
