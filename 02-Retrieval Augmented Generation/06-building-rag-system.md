# Hands-on: Building a RAG System

## Overview

This hands-on guide walks you through building a complete RAG (Retrieval-Augmented Generation) system from scratch. We'll combine everything learned in the previous topics: vector search, embeddings, chunking strategies, and vector databases to create a production-ready RAG pipeline.

By the end of this tutorial, you'll have built:
- ✅ A document ingestion pipeline with intelligent chunking
- ✅ A vector database for semantic search
- ✅ A retrieval system with relevance scoring
- ✅ An LLM-powered generation component with citations
- ✅ A complete end-to-end RAG application

---

## Prerequisites

```bash
pip install langchain langchain-openai langchain-community
pip install chromadb sentence-transformers
pip install pypdf python-dotenv tiktoken
```

**Environment Setup:**
```python
# .env file
OPENAI_API_KEY=your_openai_api_key_here
```

---

## Part 1: Document Processing and Chunking

### Step 1: Load and Extract Documents

```python
import os
from pathlib import Path
from typing import List, Dict
from langchain.document_loaders import PyPDFLoader, TextLoader
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain.schema import Document
from dotenv import load_dotenv

load_dotenv()

class DocumentProcessor:
    """Handles document loading and preprocessing"""
    
    def __init__(self):
        self.supported_formats = {'.pdf', '.txt', '.md'}
    
    def load_documents(self, file_paths: List[str]) -> List[Document]:
        """Load documents from various file formats"""
        documents = []
        
        for file_path in file_paths:
            file_ext = Path(file_path).suffix.lower()
            
            if file_ext == '.pdf':
                loader = PyPDFLoader(file_path)
            elif file_ext in {'.txt', '.md'}:
                loader = TextLoader(file_path)
            else:
                print(f"Unsupported format: {file_ext}")
                continue
            
            docs = loader.load()
            # Add source metadata
            for doc in docs:
                doc.metadata['source'] = file_path
                doc.metadata['file_type'] = file_ext
            
            documents.extend(docs)
        
        print(f"✅ Loaded {len(documents)} documents")
        return documents
    
    def chunk_documents(
        self, 
        documents: List[Document],
        chunk_size: int = 1000,
        chunk_overlap: int = 200
    ) -> List[Document]:
        """Split documents into chunks with overlap"""
        
        text_splitter = RecursiveCharacterTextSplitter(
            chunk_size=chunk_size,
            chunk_overlap=chunk_overlap,
            length_function=len,
            separators=["\n\n", "\n", ". ", " ", ""]
        )
        
        chunks = text_splitter.split_documents(documents)
        
        # Add chunk metadata
        for i, chunk in enumerate(chunks):
            chunk.metadata['chunk_id'] = i
            chunk.metadata['chunk_size'] = len(chunk.page_content)
        
        print(f"✅ Created {len(chunks)} chunks")
        return chunks

# Example usage
processor = DocumentProcessor()
documents = processor.load_documents([
    'docs/handbook.pdf',
    'docs/policies.txt'
])
chunks = processor.chunk_documents(documents, chunk_size=1000, chunk_overlap=200)
```

---

## Part 2: Embedding and Vector Database

### Step 2: Create Embeddings and Index

```python
from langchain.embeddings import OpenAIEmbeddings
from langchain.vectorstores import Chroma
from langchain.embeddings import HuggingFaceEmbeddings
import chromadb

class VectorStoreManager:
    """Manages vector database operations"""
    
    def __init__(
        self, 
        collection_name: str = "rag_collection",
        persist_directory: str = "./chroma_db",
        embedding_model: str = "openai"  # or "sentence-transformers"
    ):
        self.collection_name = collection_name
        self.persist_directory = persist_directory
        
        # Choose embedding model
        if embedding_model == "openai":
            self.embeddings = OpenAIEmbeddings(
                model="text-embedding-3-small"
            )
        else:
            self.embeddings = HuggingFaceEmbeddings(
                model_name="sentence-transformers/all-MiniLM-L6-v2"
            )
        
        self.vectorstore = None
    
    def create_index(self, chunks: List[Document]):
        """Create vector index from document chunks"""
        
        self.vectorstore = Chroma.from_documents(
            documents=chunks,
            embedding=self.embeddings,
            collection_name=self.collection_name,
            persist_directory=self.persist_directory
        )
        
        self.vectorstore.persist()
        print(f"✅ Indexed {len(chunks)} chunks in vector database")
    
    def load_index(self):
        """Load existing vector index"""
        
        self.vectorstore = Chroma(
            collection_name=self.collection_name,
            embedding_function=self.embeddings,
            persist_directory=self.persist_directory
        )
        
        print(f"✅ Loaded existing vector database")
    
    def similarity_search(
        self, 
        query: str, 
        k: int = 4,
        filter_dict: Dict = None
    ) -> List[Document]:
        """Retrieve most similar chunks"""
        
        if filter_dict:
            results = self.vectorstore.similarity_search(
                query, 
                k=k, 
                filter=filter_dict
            )
        else:
            results = self.vectorstore.similarity_search(query, k=k)
        
        return results
    
    def similarity_search_with_score(
        self, 
        query: str, 
        k: int = 4
    ) -> List[tuple]:
        """Retrieve chunks with relevance scores"""
        
        results = self.vectorstore.similarity_search_with_score(query, k=k)
        return results

# Example usage
vector_manager = VectorStoreManager(
    collection_name="my_rag_app",
    embedding_model="openai"
)

# Index documents
vector_manager.create_index(chunks)

# Or load existing index
# vector_manager.load_index()
```

---

## Part 3: Retrieval Component

### Step 3: Implement Advanced Retrieval

```python
from typing import List, Tuple
from langchain.schema import Document

class Retriever:
    """Advanced retrieval with scoring and filtering"""
    
    def __init__(self, vector_manager: VectorStoreManager):
        self.vector_manager = vector_manager
        self.relevance_threshold = 0.7
    
    def retrieve(
        self, 
        query: str, 
        k: int = 4,
        filters: Dict = None,
        use_mmr: bool = False
    ) -> List[Document]:
        """Retrieve relevant documents with optional MMR"""
        
        if use_mmr:
            # Maximal Marginal Relevance for diversity
            results = self.vector_manager.vectorstore.max_marginal_relevance_search(
                query, 
                k=k,
                fetch_k=k*3
            )
        else:
            results = self.vector_manager.similarity_search(
                query, 
                k=k, 
                filter_dict=filters
            )
        
        return results
    
    def retrieve_with_scores(
        self, 
        query: str, 
        k: int = 6
    ) -> List[Tuple[Document, float]]:
        """Retrieve with relevance scores and filtering"""
        
        results = self.vector_manager.similarity_search_with_score(query, k=k)
        
        # Filter by relevance threshold
        filtered_results = [
            (doc, score) for doc, score in results 
            if score <= (1 - self.relevance_threshold)  # Lower is better in Chroma
        ]
        
        print(f"📊 Retrieved {len(filtered_results)}/{k} relevant chunks")
        return filtered_results
    
    def format_context(self, documents: List[Document]) -> str:
        """Format retrieved documents into context string"""
        
        context_parts = []
        for i, doc in enumerate(documents, 1):
            source = doc.metadata.get('source', 'Unknown')
            page = doc.metadata.get('page', 'N/A')
            
            context_parts.append(
                f"[Source {i}: {source}, Page {page}]\n{doc.page_content}\n"
            )
        
        return "\n---\n".join(context_parts)

# Example usage
retriever = Retriever(vector_manager)
query = "What is the company's vacation policy?"

# Simple retrieval
docs = retriever.retrieve(query, k=4)

# Retrieval with scores
docs_with_scores = retriever.retrieve_with_scores(query, k=4)
for doc, score in docs_with_scores:
    print(f"Score: {score:.3f} | {doc.page_content[:100]}...")

# Retrieval with MMR for diversity
diverse_docs = retriever.retrieve(query, k=4, use_mmr=True)
```

---

## Part 4: Generation Component

### Step 4: LLM-Powered Answer Generation

```python
from langchain.chat_models import ChatOpenAI
from langchain.prompts import ChatPromptTemplate
from langchain.schema.runnable import RunnablePassthrough
from langchain.schema.output_parser import StrOutputParser

class RAGGenerator:
    """Generates answers using retrieved context"""
    
    def __init__(
        self, 
        model_name: str = "gpt-4o-mini",
        temperature: float = 0.0
    ):
        self.llm = ChatOpenAI(
            model=model_name,
            temperature=temperature
        )
        
        self.prompt_template = ChatPromptTemplate.from_messages([
            ("system", """You are a helpful assistant that answers questions based on the provided context.

Rules:
1. Answer ONLY using information from the context
2. If the answer is not in the context, say "I don't have enough information to answer this question."
3. Always cite which source(s) you used (e.g., "According to Source 1...")
4. Be concise but complete
5. If multiple sources have conflicting information, mention both perspectives

Context:
{context}
"""),
            ("human", "{question}")
        ])
    
    def generate(
        self, 
        query: str, 
        context_documents: List[Document]
    ) -> str:
        """Generate answer from query and context"""
        
        # Format context
        retriever_obj = Retriever(None)  # Just for formatting
        context = retriever_obj.format_context(context_documents)
        
        # Create chain
        chain = (
            {"context": lambda x: context, "question": RunnablePassthrough()}
            | self.prompt_template
            | self.llm
            | StrOutputParser()
        )
        
        # Generate answer
        answer = chain.invoke(query)
        return answer
    
    def generate_with_citations(
        self, 
        query: str, 
        context_documents: List[Tuple[Document, float]]
    ) -> Dict:
        """Generate answer with detailed citations"""
        
        # Extract documents
        docs = [doc for doc, score in context_documents]
        
        # Generate answer
        answer = self.generate(query, docs)
        
        # Prepare citations
        citations = []
        for i, (doc, score) in enumerate(context_documents, 1):
            citations.append({
                'source_id': i,
                'source': doc.metadata.get('source', 'Unknown'),
                'page': doc.metadata.get('page', 'N/A'),
                'relevance_score': f"{score:.3f}",
                'snippet': doc.page_content[:200]
            })
        
        return {
            'answer': answer,
            'citations': citations,
            'num_sources': len(citations)
        }

# Example usage
generator = RAGGenerator(model_name="gpt-4o-mini", temperature=0)

# Simple generation
answer = generator.generate(query, docs)
print(f"Answer: {answer}")

# Generation with citations
result = generator.generate_with_citations(query, docs_with_scores)
print(f"\n📝 Answer:\n{result['answer']}")
print(f"\n📚 Sources used: {result['num_sources']}")
for citation in result['citations']:
    print(f"  - {citation['source']} (Page {citation['page']}) - Score: {citation['relevance_score']}")
```

---

## Part 5: Complete RAG Pipeline

### Step 5: End-to-End RAG System

```python
class RAGSystem:
    """Complete RAG system integrating all components"""
    
    def __init__(
        self,
        collection_name: str = "rag_system",
        embedding_model: str = "openai",
        llm_model: str = "gpt-4o-mini"
    ):
        self.processor = DocumentProcessor()
        self.vector_manager = VectorStoreManager(
            collection_name=collection_name,
            embedding_model=embedding_model
        )
        self.retriever = Retriever(self.vector_manager)
        self.generator = RAGGenerator(model_name=llm_model)
        
        self.indexed = False
    
    def index_documents(
        self, 
        file_paths: List[str],
        chunk_size: int = 1000,
        chunk_overlap: int = 200
    ):
        """Index documents into vector database"""
        
        print("📄 Loading documents...")
        documents = self.processor.load_documents(file_paths)
        
        print("✂️  Chunking documents...")
        chunks = self.processor.chunk_documents(
            documents, 
            chunk_size=chunk_size,
            chunk_overlap=chunk_overlap
        )
        
        print("🔍 Creating vector index...")
        self.vector_manager.create_index(chunks)
        
        self.indexed = True
        print("✅ Indexing complete!")
    
    def load_existing_index(self):
        """Load previously created index"""
        self.vector_manager.load_index()
        self.indexed = True
    
    def query(
        self, 
        question: str,
        k: int = 4,
        use_mmr: bool = False,
        return_sources: bool = True
    ) -> Dict:
        """Query the RAG system"""
        
        if not self.indexed:
            raise ValueError("No index loaded. Call index_documents() or load_existing_index() first.")
        
        print(f"\n🔍 Searching for: {question}")
        
        # Retrieve relevant documents
        docs_with_scores = self.retriever.retrieve_with_scores(question, k=k*2)
        
        if not docs_with_scores:
            return {
                'answer': "I couldn't find any relevant information to answer this question.",
                'sources': [],
                'num_sources': 0
            }
        
        # Take top k after scoring
        top_docs = docs_with_scores[:k]
        
        # Generate answer
        result = self.generator.generate_with_citations(question, top_docs)
        
        return result
    
    def chat(self):
        """Interactive chat interface"""
        
        if not self.indexed:
            print("❌ No index loaded. Please index documents first.")
            return
        
        print("\n💬 RAG Chat Interface (type 'exit' to quit)")
        print("=" * 60)
        
        while True:
            question = input("\nYou: ").strip()
            
            if question.lower() in ['exit', 'quit', 'q']:
                print("Goodbye!")
                break
            
            if not question:
                continue
            
            result = self.query(question, k=4)
            
            print(f"\n🤖 Assistant: {result['answer']}")
            
            if result['citations']:
                print(f"\n📚 Sources ({result['num_sources']}):")
                for cite in result['citations']:
                    print(f"  [{cite['source_id']}] {cite['source']} (Page {cite['page']}) - Relevance: {cite['relevance_score']}")

# Example: Complete RAG workflow
def main():
    # Initialize RAG system
    rag = RAGSystem(
        collection_name="company_docs",
        embedding_model="openai",
        llm_model="gpt-4o-mini"
    )
    
    # Option 1: Index new documents
    file_paths = [
        'docs/employee_handbook.pdf',
        'docs/company_policies.pdf',
        'docs/benefits_guide.pdf'
    ]
    rag.index_documents(file_paths, chunk_size=1000, chunk_overlap=200)
    
    # Option 2: Load existing index
    # rag.load_existing_index()
    
    # Single query
    result = rag.query("What is the vacation policy?", k=4)
    print(f"\n📝 Answer:\n{result['answer']}")
    print(f"\n📚 Used {result['num_sources']} sources")
    
    # Interactive chat
    rag.chat()

if __name__ == "__main__":
    main()
```

---

## Part 6: Advanced Features

### Multi-Query Retrieval

```python
from langchain.retrievers import MultiQueryRetriever
from langchain.prompts import PromptTemplate

class AdvancedRAG(RAGSystem):
    """RAG with advanced retrieval strategies"""
    
    def multi_query_retrieve(self, question: str, k: int = 4) -> List[Document]:
        """Generate multiple query variations for better retrieval"""
        
        llm = ChatOpenAI(model="gpt-4o-mini", temperature=0.3)
        
        prompt = PromptTemplate(
            input_variables=["question"],
            template="""You are an AI assistant helping to improve search queries.
Generate 3 different versions of the following question to retrieve relevant documents:

Original question: {question}

Generate 3 alternative questions:
1."""
        )
        
        # Generate query variations
        variations = llm.invoke(prompt.format(question=question))
        queries = [question] + variations.content.split('\n')
        
        # Retrieve for each query
        all_docs = []
        for q in queries[:4]:  # Use top 4 variations
            docs = self.retriever.retrieve(q.strip(), k=k//2)
            all_docs.extend(docs)
        
        # Deduplicate
        seen = set()
        unique_docs = []
        for doc in all_docs:
            content_hash = hash(doc.page_content)
            if content_hash not in seen:
                seen.add(content_hash)
                unique_docs.append(doc)
        
        return unique_docs[:k]

# Usage
advanced_rag = AdvancedRAG(collection_name="advanced_rag")
advanced_rag.load_existing_index()
docs = advanced_rag.multi_query_retrieve("vacation policy", k=4)
```

### Streaming Responses

```python
from langchain.callbacks.streaming_stdout import StreamingStdOutCallbackHandler

class StreamingRAG(RAGSystem):
    """RAG with streaming responses"""
    
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        
        # Reinitialize generator with streaming
        self.generator.llm = ChatOpenAI(
            model=self.generator.llm.model_name,
            temperature=0,
            streaming=True,
            callbacks=[StreamingStdOutCallbackHandler()]
        )
    
    def stream_query(self, question: str, k: int = 4):
        """Stream answer as it's generated"""
        
        docs_with_scores = self.retriever.retrieve_with_scores(question, k=k)
        
        if not docs_with_scores:
            print("No relevant documents found.")
            return
        
        print(f"\n🤖 Assistant: ", end='', flush=True)
        
        # This will stream to stdout via callback
        result = self.generator.generate_with_citations(
            question, 
            docs_with_scores[:k]
        )
        
        return result

# Usage
streaming_rag = StreamingRAG(collection_name="streaming_rag")
streaming_rag.load_existing_index()
streaming_rag.stream_query("What are the health benefits?", k=4)
```

---

## Testing Your RAG System

### Evaluation Script

```python
def evaluate_rag(rag_system: RAGSystem, test_cases: List[Dict]):
    """Evaluate RAG system on test cases"""
    
    results = []
    
    for i, test in enumerate(test_cases, 1):
        question = test['question']
        expected_keywords = test.get('expected_keywords', [])
        
        print(f"\n{'='*60}")
        print(f"Test {i}/{len(test_cases)}: {question}")
        
        result = rag_system.query(question, k=4)
        answer = result['answer']
        
        # Check if expected keywords are present
        found_keywords = [kw for kw in expected_keywords if kw.lower() in answer.lower()]
        keyword_score = len(found_keywords) / len(expected_keywords) if expected_keywords else 1.0
        
        results.append({
            'question': question,
            'answer': answer,
            'num_sources': result['num_sources'],
            'keyword_score': keyword_score,
            'found_keywords': found_keywords
        })
        
        print(f"Answer: {answer[:200]}...")
        print(f"Sources used: {result['num_sources']}")
        print(f"Keyword match: {keyword_score*100:.1f}% ({len(found_keywords)}/{len(expected_keywords)})")
    
    # Summary
    avg_sources = sum(r['num_sources'] for r in results) / len(results)
    avg_keyword_score = sum(r['keyword_score'] for r in results) / len(results)
    
    print(f"\n{'='*60}")
    print(f"📊 Evaluation Summary:")
    print(f"  Average sources per answer: {avg_sources:.1f}")
    print(f"  Average keyword match: {avg_keyword_score*100:.1f}%")
    
    return results

# Test cases
test_cases = [
    {
        'question': 'What is the vacation policy?',
        'expected_keywords': ['days', 'vacation', 'annual']
    },
    {
        'question': 'How do I submit expense reports?',
        'expected_keywords': ['expense', 'submit', 'approval']
    },
    {
        'question': 'What health insurance options are available?',
        'expected_keywords': ['health', 'insurance', 'plan']
    }
]

# Run evaluation
rag = RAGSystem(collection_name="test_rag")
rag.load_existing_index()
results = evaluate_rag(rag, test_cases)
```

---

## Best Practices

### 1. **Chunking Strategy**
```python
# For technical docs: smaller chunks
chunks = processor.chunk_documents(docs, chunk_size=500, chunk_overlap=100)

# For narrative content: larger chunks
chunks = processor.chunk_documents(docs, chunk_size=1500, chunk_overlap=200)

# For structured data: semantic chunking
# Use custom splitters based on document structure
```

### 2. **Embedding Model Selection**
- **OpenAI** (`text-embedding-3-small`): Fast, high quality, costs $0.02/1M tokens
- **Sentence Transformers** (`all-MiniLM-L6-v2`): Free, local, good for MVP
- **BGE** (`BAAI/bge-large-en-v1.5`): State-of-the-art open source

### 3. **Retrieval Optimization**
```python
# Use MMR for diverse results
docs = retriever.retrieve(query, k=4, use_mmr=True)

# Filter by metadata
docs = vector_manager.similarity_search(
    query, 
    k=10, 
    filter_dict={'source': 'handbook.pdf'}
)

# Adjust k based on query complexity
k = 6 if len(query.split()) > 10 else 4
```

### 4. **Prompt Engineering**
- Include system instructions for citation format
- Set temperature to 0 for factual answers
- Add examples of good answers in few-shot prompts

### 5. **Error Handling**
```python
try:
    result = rag.query(question, k=4)
except Exception as e:
    result = {
        'answer': f"An error occurred: {str(e)}",
        'sources': [],
        'num_sources': 0
    }
```

---

## Performance Optimization

### Caching

```python
from functools import lru_cache
import hashlib

class CachedRAG(RAGSystem):
    """RAG with query caching"""
    
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.cache = {}
    
    def _hash_query(self, query: str) -> str:
        return hashlib.md5(query.lower().encode()).hexdigest()
    
    def query(self, question: str, k: int = 4, **kwargs) -> Dict:
        """Query with caching"""
        
        cache_key = self._hash_query(question)
        
        if cache_key in self.cache:
            print("💾 Using cached result")
            return self.cache[cache_key]
        
        result = super().query(question, k=k, **kwargs)
        self.cache[cache_key] = result
        
        return result
```

### Batch Processing

```python
def batch_index(rag: RAGSystem, file_paths: List[str], batch_size: int = 10):
    """Index documents in batches"""
    
    for i in range(0, len(file_paths), batch_size):
        batch = file_paths[i:i+batch_size]
        print(f"Processing batch {i//batch_size + 1}/{(len(file_paths)-1)//batch_size + 1}")
        rag.index_documents(batch)
```

---

## Next Steps

Now that you've built a complete RAG system, explore these advanced topics:

1. **[Document Extraction](07-document-extraction.md)** - Handle complex document formats
2. **[OCR Extraction](08-ocr-document-extraction.md)** - Process scanned documents
3. **[Advanced Retrieval](10-retrieval-strategies.md)** - Multi-query, HyDE, parent document retrieval
4. **[Reranking](11-reranker-models.md)** - Improve precision with cross-encoders
5. **[Evaluation](14-evaluation-metrics.md)** - Measure and optimize your RAG system

---

## Common Issues & Solutions

**Issue**: Answers are generic/hallucinated  
**Solution**: Increase k, improve chunking, add stricter prompts

**Issue**: Retrieval is slow  
**Solution**: Use smaller embedding model, implement caching, reduce index size

**Issue**: Answers miss key information  
**Solution**: Use MMR, try multi-query retrieval, adjust chunk size

**Issue**: Citations are incorrect  
**Solution**: Improve metadata tracking, use better prompt instructions

---

**Congratulations!** 🎉 You've built a production-ready RAG system. This foundation can be extended with advanced features like reranking, multi-modal search, and agentic RAG patterns.

[← Previous: Vector Databases](05-vector-databases.md) | [Next: Document Extraction →](07-document-extraction.md)
