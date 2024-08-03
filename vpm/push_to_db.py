from typing import List, Dict, Union, Any
from openai import OpenAI
from pathlib import Path
from dotenv import load_dotenv
import os
from elasticsearch import Elasticsearch
import json
import requests
import typer

load_dotenv()
# oai = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))
oai = OpenAI(api_key="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")

def generate_embedding(code_snippet: str) -> List[float]:
    response = oai.embeddings.create(
        input=code_snippet,
    model="text-embedding-ada-002")
    return response.data[0].embedding
  
def chunk_code(code: str, chunk_size: int = 1000, overlap: int = 100) -> List[str]:
    chunks = []
    start = 0
    while start < len(code):
        end = start + chunk_size
        chunk = code[start:end]
        chunks.append(chunk)
        start = end - overlap
    return chunks

def embed_library(fpath: str) -> List[Dict[str, Union[str, List[float]]]]:
    documents = []
    doc_id = 0
    for file_path in Path(fpath).glob("*.v"):
        with open(file_path, "r") as f:
            module_code = f.read()
            file_name = file_path.name
            chunks = chunk_code(module_code)
            for chunk_idx, chunk in enumerate(chunks):
                doc = {
                    "name": file_name,
                    "chunk_id": chunk_idx,
                    "code": chunk,
                    "embedding": generate_embedding(chunk)
                }
                documents.extend([
                    {
                        "index": {
                            "_index": "ee272",
                            "_id": doc_id
                        }
                    },
                    doc
                ])
                doc_id += 1
    return documents

def process_item(api_url: str, repo_name: str, item: Dict[str, Any], es_client: Elasticsearch, doc_id: int) -> int:
    if item['type'] == 'file' and item['name'].endswith('.v'):
        file_url = item['download_url']
        file_name = item['name']
        file_response = requests.get(file_url)
        if file_response.status_code == 200:
            module_code = file_response.text
            chunks = chunk_code(module_code)
            for chunk_idx, chunk in enumerate(chunks):
                doc = {
                    "name": file_name,
                    "chunk_id": chunk_idx,
                    "code": chunk,
                    "embedding": generate_embedding(chunk)
                }
                with typer.progressbar(length=1, label=f"Loading {file_name}") as progress:
                    try:
                        es_client.index(index=repo_name, id=doc_id, body=doc)
                    except Exception as e:
                        if "version_conflict_engine_exception" in str(e):
                            es_client.update(index=repo_name, id=doc_id, body={"doc": doc})
                    progress.update(1)
                doc_id += 1
        else:
            pass
    elif item['type'] == 'dir':
        # Fetch contents of subdirectory
        subdir_url = f"{api_url}/{item['path']}"
        subdir_response = requests.get(subdir_url)
        if subdir_response.status_code == 200:
            subdir_contents = subdir_response.json()
            for subitem in subdir_contents:
                doc_id = process_item(api_url, repo_name, subitem, es_client, doc_id)
        else:
            # print(f"Failed to fetch contents of: {subdir_url}")
            pass
    return doc_id

def embed_library_from_repo(owner: str, repo_name: str, es_client: Elasticsearch) -> List[Dict[str, Union[str, List[float]]]]:
    documents = []
    doc_id = 0

    api_url = f"https://api.github.com/repos/{owner}/{repo_name}/contents"
    response = requests.get(api_url)    
    if response.status_code == 200:
        contents = response.json()
        for item in contents:
            doc_id = process_item(api_url, repo_name, item, es_client, doc_id)
    else:
        # print("Failed to fetch repository contents")
        pass

    return documents


def create_index(client: Elasticsearch, index_name: str, mapping: Dict[str, Any]) -> None:
    try:
        client.indices.create(index=index_name, body=mapping)
        # print(f"Index '{index_name}' created successfully with the specified mapping")
    except Exception as e:
        if "resource_already_exists_exception" in str(e):
            # print(f"Index '{index_name}' already exists. Updating mapping...")
            try:
                client.indices.put_mapping(index=index_name, body=mapping["mappings"])
                # print(f"Mapping updated successfully for index '{index_name}'")
            except Exception as update_error:
                # print(f"Error updating mapping: {str(update_error)}")
                pass
        else:
            # print(f"Error creating index: {str(e)}")
            pass

def delete_index(client: Elasticsearch, index_name: str) -> None:
    try:
        client.indices.delete(index=index_name)
        # print(f"Index '{index_name}' deleted successfully")
    except Exception as e:
        # print(f"Error deleting index '{index_name}': {str(e)}")
        pass


def insert_documents(client: Elasticsearch, index_name: str, embedded_documents: List[Dict]) -> None:
    for i in range(0, len(embedded_documents), 2):
        doc_id = embedded_documents[i]['index']['_id']
        doc_body = embedded_documents[i + 1]
        
        try:
            if not client.exists(index=index_name, id=doc_id):
                response = client.index(
                    index=index_name,
                    id=doc_id,
                    body=doc_body
                )
                # print(f"Document {doc_id} added successfully")
            else:
                response = client.update(
                    index=index_name,
                    id=doc_id,
                    body={"doc": doc_body}
                )
                # print(f"Document {doc_id} updated successfully")
        except Exception as e:
            # print(f"Error processing document {doc_id}: {str(e)}")
            pass

def get_all_documents(client: Elasticsearch, index_name: str, size: int = 10000) -> List[Dict]:
    try:
        response = client.search(
            index=index_name,
            body={
                "query": {"match_all": {}},
                "size": size
            }
        )
        
        documents = []
        for hit in response['hits']['hits']:
            documents.append({
                'id': hit['_id'],
                'name': hit['_source']['name'],
                'code': hit['_source']['code'],
                'embedding': hit['_source']['embedding']
            })
        
        # print(f"Retrieved {len(documents)} documents from index '{index_name}'")
        return documents
    except Exception as e:
        # print(f"Error retrieving documents from index '{index_name}': {str(e)}")
        return []


def vector_search(client: Elasticsearch, index_name: str, query_vector: List[float], top_k: int = 5) -> List[Dict]:
    search_query = {
        "size": top_k,
        "query": {
            "script_score": {
                "query": {"match_all": {}},
                "script": {
                    "source": "cosineSimilarity(params.query_vector, 'embedding') + 1.0",
                    "params": {"query_vector": query_vector}
                }
            }
        }
    }
    
    try:
        response = client.search(index=index_name, body=search_query)
        results = []
        for hit in response['hits']['hits']:
            results.append({
                'id': hit['_id'],
                'score': hit['_score'],
                'name': hit['_source']['name'],
                'code': hit['_source']['code']
            })
        return results
    except Exception as e:
        # print(f"Error performing vector search: {str(e)}")
        return []

