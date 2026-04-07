# Graph Databases for RAG

## Overview
Graph databases store data as nodes and relationships, enabling powerful traversal and context-aware retrieval. GraphRAG combines traditional vector search with graph-based knowledge representation for enhanced reasoning.

---

## Why Graph Databases for RAG?

**Limitations of vector-only RAG:**
- No explicit relationships between entities
- Difficult multi-hop reasoning
- Limited context about connections
- Misses indirect relevance

**Graph advantages:**
- Explicit relationships (who, what, when, where)
- Multi-hop traversal
- Context propagation
- Better for complex queries

---

## Graph Database Fundamentals

### **Basic Concepts:**

```
Nodes (Entities):
- Person(name: "Alice")
- Company(name: "TechCorp")
- Document(title: "AI Report")

Edges (Relationships):
- Alice --[WORKS_AT]--> TechCorp
- Alice --[AUTHORED]--> Document
- Document --[ABOUT]--> Topic

Properties:
- Nodes and edges can have properties
- e.g., WORKS_AT {since: "2020", role: "Engineer"}
```

---

## Popular Graph Databases

### **1. Neo4j**

Most popular graph database.

**Installation:**
```bash
# Docker
docker run -p 7474:7474 -p 7687:7687 neo4j
```

**Basic Usage:**
```python
from neo4j import GraphDatabase

class Neo4jConnection:
    def __init__(self, uri, user, password):
        self.driver = GraphDatabase.driver(uri, auth=(user, password))
    
    def close(self):
        self.driver.close()
    
    def create_person(self, name):
        with self.driver.session() as session:
            session.run(
                "CREATE (p:Person {name: $name})",
                name=name
            )
    
    def create_relationship(self, person1, person2, relationship):
        with self.driver.session() as session:
            query = f"""
            MATCH (p1:Person {{name: $person1}})
            MATCH (p2:Person {{name: $person2}})
            CREATE (p1)-[r:{relationship}]->(p2)
            RETURN r
            """
            session.run(query, person1=person1, person2=person2)
    
    def find_paths(self, start, end, max_hops=3):
        with self.driver.session() as session:
            query = """
            MATCH path = (start:Person {name: $start})-[*1..%d]-(end:Person {name: $end})
            RETURN path
            """ % max_hops
            
            result = session.run(query, start=start, end=end)
            return [record["path"] for record in result]

# Usage
neo4j = Neo4jConnection("bolt://localhost:7687", "neo4j", "password")

# Create nodes
neo4j.create_person("Alice")
neo4j.create_person("Bob")

# Create relationship
neo4j.create_relationship("Alice", "Bob", "KNOWS")
```

---

### **2. Amazon Neptune**

AWS managed graph database.

```python
from gremlin_python.driver import client, serializer

# Connect to Neptune
neptune_client = client.Client(
    'wss://your-neptune-endpoint:8182/gremlin',
    'g',
    message_serializer=serializer.GraphSONSerializersV2d0()
)

# Add vertex
neptune_client.submit(
    "g.addV('person').property('name', 'Alice')"
).all().result()

# Add edge
neptune_client.submit(
    """
    g.V().has('person', 'name', 'Alice').as('a')
     .V().has('person', 'name', 'Bob').as('b')
     .addE('knows').from('a').to('b')
    """
).all().result()
```

---

### **3. ArangoDB**

Multi-model database (document + graph).

```python
from arango import ArangoClient

# Connect
client = ArangoClient(hosts='http://localhost:8529')
db = client.db('_system', username='root', password='')

# Create graph
graph = db.create_graph('social')

# Create collections
persons = graph.create_vertex_collection('persons')
knows = graph.create_edge_definition(
    edge_collection='knows',
    from_vertex_collections=['persons'],
    to_vertex_collections=['persons']
)

# Add vertices
persons.insert({'_key': 'alice', 'name': 'Alice'})
persons.insert({'_key': 'bob', 'name': 'Bob'})

# Add edge
knows.insert({
    '_from': 'persons/alice',
    '_to': 'persons/bob',
    'type': 'friend'
})

# Traverse
result = db.aql.execute(
    """
    FOR v, e, p IN 1..3 OUTBOUND 'persons/alice' knows
    RETURN {vertex: v, edge: e, path: p}
    """
)
```

---

## GraphRAG Architecture

### **Combining Vector + Graph:**

```python
class GraphRAG:
    def __init__(self, vector_db, graph_db, embedding_model, llm):
        self.vector_db = vector_db
        self.graph_db = graph_db
        self.embed_model = embedding_model
        self.llm = llm
    
    def index_document(self, document):
        # 1. Extract entities and relationships
        entities, relationships = self.extract_knowledge(document)
        
        # 2. Add to graph
        for entity in entities:
            self.graph_db.add_node(entity)
        
        for rel in relationships:
            self.graph_db.add_edge(rel['source'], rel['target'], rel['type'])
        
        # 3. Create vector embedding
        embedding = self.embed_model.encode(document['text'])
        
        # 4. Store embedding with graph reference
        self.vector_db.insert({
            'id': document['id'],
            'embedding': embedding,
            'entity_ids': [e['id'] for e in entities]
        })
    
    def query(self, question):
        # 1. Vector search for relevant documents
        query_embedding = self.embed_model.encode(question)
        vector_results = self.vector_db.search(query_embedding, top_k=5)
        
        # 2. Extract entities from question
        question_entities = self.extract_entities(question)
        
        # 3. Graph traversal to find related entities
        graph_context = []
        for entity in question_entities:
            subgraph = self.graph_db.get_neighborhood(entity, hops=2)
            graph_context.append(subgraph)
        
        # 4. Combine vector and graph results
        combined_context = self.merge_contexts(vector_results, graph_context)
        
        # 5. Generate answer
        answer = self.llm.generate(question, combined_context)
        
        return answer
    
    def extract_knowledge(self, document):
        """Extract entities and relationships using LLM"""
        prompt = f"""Extract entities and relationships from this text:

Text: {document['text']}

Return as JSON:
{{
  "entities": [{{"id": "...", "type": "...", "name": "..."}}],
  "relationships": [{{"source": "...", "target": "...", "type": "..."}}]
}}

Output:"""
        
        response = self.llm.generate(prompt)
        knowledge = json.loads(response)
        
        return knowledge['entities'], knowledge['relationships']
    
    def extract_entities(self, text):
        """Extract entities from text"""
        prompt = f"Extract key entities from: {text}\nEntities:"
        response = self.llm.generate(prompt)
        return response.strip().split(', ')
```

---

## Knowledge Graph Construction

### **1. Entity Extraction:**

```python
def extract_entities_ner(text):
    """Using NER for entity extraction"""
    import spacy
    
    nlp = spacy.load("en_core_web_sm")
    doc = nlp(text)
    
    entities = []
    for ent in doc.ents:
        entities.append({
            'text': ent.text,
            'label': ent.label_,
            'start': ent.start_char,
            'end': ent.end_char
        })
    
    return entities
```

---

### **2. Relationship Extraction:**

```python
def extract_relationships(text, entities):
    """Extract relationships between entities"""
    from openai import OpenAI
    
    client = OpenAI()
    
    prompt = f"""Given this text and entities, extract relationships:

Text: {text}

Entities: {', '.join([e['text'] for e in entities])}

Extract relationships in format: (Entity1, Relationship, Entity2)

Relationships:"""
    
    response = client.chat.completions.create(
        model="gpt-4",
        messages=[{"role": "user", "content": prompt}]
    )
    
    # Parse relationships
    relationships = []
    for line in response.choices[0].message.content.strip().split('\n'):
        # Parse "(Entity1, Relationship, Entity2)"
        if line.strip():
            relationships.append(parse_relationship(line))
    
    return relationships
```

---

### **3. Building Knowledge Graph:**

```python
class KnowledgeGraphBuilder:
    def __init__(self, graph_db):
        self.graph_db = graph_db
    
    def build_from_documents(self, documents):
        """Build KG from document corpus"""
        for doc in documents:
            # Extract entities
            entities = extract_entities_ner(doc['text'])
            
            # Extract relationships
            relationships = extract_relationships(doc['text'], entities)
            
            # Add to graph
            for entity in entities:
                self.graph_db.add_node(
                    id=entity['text'],
                    type=entity['label'],
                    source_doc=doc['id']
                )
            
            for rel in relationships:
                self.graph_db.add_edge(
                    source=rel['source'],
                    target=rel['target'],
                    type=rel['relationship'],
                    source_doc=doc['id']
                )
    
    def enrich_with_external_kg(self, external_kg):
        """Merge with Wikidata, DBpedia, etc."""
        # Entity linking
        for node in self.graph_db.get_all_nodes():
            # Link to external KG
            external_entity = external_kg.find_entity(node['id'])
            if external_entity:
                # Add linked entity info
                self.graph_db.update_node(
                    node['id'],
                    external_id=external_entity['id'],
                    additional_properties=external_entity['properties']
                )
```

---

## Graph-Based Retrieval

### **1. Subgraph Retrieval:**

```python
def retrieve_subgraph(question, graph_db):
    """Get relevant subgraph for question"""
    # Extract entities from question
    entities = extract_entities_ner(question)
    
    # Find subgraph around these entities
    subgraph = {
        'nodes': [],
        'edges': []
    }
    
    for entity in entities:
        # Get entity node
        node = graph_db.find_node(entity['text'])
        if node:
            # Get neighbors (1-2 hops)
            neighbors = graph_db.get_neighbors(node['id'], max_hops=2)
            
            subgraph['nodes'].extend(neighbors['nodes'])
            subgraph['edges'].extend(neighbors['edges'])
    
    # Deduplicate
    subgraph['nodes'] = list({n['id']: n for n in subgraph['nodes']}.values())
    subgraph['edges'] = list({e['id']: e for e in subgraph['edges']}.values())
    
    return subgraph
```

---

### **2. Path Finding:**

```python
def find_reasoning_paths(start_entity, end_entity, graph_db, max_hops=3):
    """Find paths connecting two entities"""
    paths = graph_db.find_shortest_paths(
        start=start_entity,
        end=end_entity,
        max_length=max_hops
    )
    
    # Convert to natural language
    path_descriptions = []
    for path in paths:
        desc = describe_path(path)
        path_descriptions.append(desc)
    
    return path_descriptions

def describe_path(path):
    """Convert graph path to text"""
    description = path['nodes'][0]['name']
    
    for i, edge in enumerate(path['edges']):
        description += f" {edge['type']} {path['nodes'][i+1]['name']}"
    
    return description
```

---

### **3. Community Detection:**

```python
def detect_communities(graph_db):
    """Find clusters of related entities"""
    # Use algorithm like Louvain
    communities = graph_db.run_louvain()
    
    return communities

def retrieve_by_community(question, graph_db):
    """Retrieve entire relevant communities"""
    # Find relevant entities
    entities = extract_entities_ner(question)
    
    # Get their communities
    communities = []
    for entity in entities:
        community = graph_db.get_community(entity['text'])
        if community:
            communities.append(community)
    
    return communities
```

---

## Hybrid Vector + Graph Search

```python
class HybridVectorGraphRAG:
    def __init__(self, vector_db, graph_db):
        self.vector_db = vector_db
        self.graph_db = graph_db
    
    def retrieve(self, query, top_k=5):
        # 1. Vector search
        vector_results = self.vector_db.search(query, top_k=top_k*2)
        
        # 2. Extract entities from top results
        entity_candidates = set()
        for result in vector_results[:top_k]:
            entities = extract_entities_ner(result['text'])
            entity_candidates.update([e['text'] for e in entities])
        
        # 3. Graph expansion
        expanded_results = []
        for entity in entity_candidates:
            # Get connected documents via graph
            connected = self.graph_db.get_documents_for_entity(entity)
            expanded_results.extend(connected)
        
        # 4. Re-rank combined results
        all_results = vector_results + expanded_results
        reranked = self.rerank(query, all_results)
        
        return reranked[:top_k]
```

---

## Microsoft GraphRAG

Implementation based on recent research.

```python
class MicrosoftGraphRAG:
    """
    Based on: "From Local to Global: A Graph RAG Approach" (Microsoft, 2024)
    """
    
    def build_hierarchical_communities(self, documents):
        # 1. Build entity graph
        entity_graph = self.build_entity_graph(documents)
        
        # 2. Detect communities at multiple levels
        communities = self.detect_hierarchical_communities(entity_graph)
        
        # 3. Generate community summaries
        for community in communities:
            community['summary'] = self.generate_community_summary(community)
        
        return communities
    
    def query_global(self, question):
        """Answer using global community summaries"""
        # Use high-level community summaries
        relevant_communities = self.find_relevant_communities(question)
        
        context = "\n\n".join([c['summary'] for c in relevant_communities])
        
        answer = self.llm.generate(question, context)
        return answer
    
    def query_local(self, question):
        """Answer using local entity subgraphs"""
        # Extract entities from question
        entities = self.extract_entities(question)
        
        # Get local subgraphs
        subgraphs = [self.get_local_subgraph(e) for e in entities]
        
        # Generate from subgraphs
        answer = self.llm.generate(question, subgraphs)
        return answer
```

---

## Best Practices

1. **Use graphs for:**
   - Multi-hop reasoning
   - Complex relationships
   - Structured domains

2. **Combine with vectors:**
   - Vector for semantic search
   - Graph for relationship traversal

3. **Entity linking:**
   - Disambiguate entities
   - Link to external KGs

4. **Keep graphs manageable:**
   - Prune irrelevant edges
   - Focus on key relationships

5. **Update incrementally:**
   - Add new entities/relationships
   - Version control graph state

---

## Tools and Libraries

- **Neo4j**: Most popular, great tooling
- **LangChain Neo4j**: Integration with LangChain
- **LlamaIndex Knowledge Graph**: Built-in support
- **Wikidata/DBpedia**: External knowledge graphs
- **Rebel, OpenIE**: Relationship extraction

---

## Next Steps
- Set up a graph database (Neo4j)
- Extract entities from your documents
- Build a knowledge graph
- Implement hybrid vector + graph retrieval
- Experiment with Microsoft GraphRAG approach
- Evaluate improvement over pure vector search
