import typer
import requests
import os
import random
import string
from urllib.parse import urlparse
from push_to_db import embed_library_from_repo, create_index
from elasticsearch import Elasticsearch
import shutil

# verilog install [lib_name]
# verilog add [REPO_URL] as [lib_name]

app = typer.Typer()

def download_item(api_url, item, current_dir):
    if item['type'] == 'file' and item['name'].endswith('.v'):
        file_url = item['download_url']
        file_name = item['name']
        file_path = os.path.join(current_dir, file_name)
        
        # Download the file content
        file_response = requests.get(file_url)
        if file_response.status_code == 200:
            with open(file_path, 'wb') as f:
                f.write(file_response.content)
            typer.echo(f"Downloaded: {file_path}")
        else:
            typer.echo(f"Failed to download: {file_path}")
    elif item['type'] == 'dir':
        # Create subdirectory
        subdir = os.path.join(current_dir, item['name'])
        os.makedirs(subdir, exist_ok=True)
        
        # Fetch contents of subdirectory
        subdir_url = f"{api_url}/{item['path']}"
        subdir_response = requests.get(subdir_url)
        if subdir_response.status_code == 200:
            subdir_contents = subdir_response.json()
            for subitem in subdir_contents:
                download_item(api_url, subitem, subdir)
        else:
            typer.echo(f"Failed to fetch contents of: {subdir}")

@app.command()
def install(lib: str):
    """Install a library."""
    es_client = Elasticsearch(
        "https://69bc680d7967407080cd9090e3c12a25.us-central1.gcp.cloud.es.io:443",
        api_key="UWdUV0M1RUJjd1F5SmpPNHRJVlU6Ui1tenFqaUFReFc5d0k2ODJSVnBldw=="
    )

    # Search for documents in the specified library
    response = es_client.search(
        index=lib,
        body={
            "query": {"match_all": {}},
            "size": 10000  # Adjust the size as needed
        }
    )

    # Create a base directory for the library
    base_dir = os.path.join("lib", lib)
    os.makedirs(base_dir, exist_ok=True)

    # Download each document
    for doc in response['hits']['hits']:
        doc_source = doc['_source']
        file_name = doc_source['name']
        chunk_id = doc_source['chunk_id']
        code = doc_source['code']

        # Create a subdirectory for each file within the base directory
        file_dir = os.path.join(base_dir, file_name)
        os.makedirs(file_dir, exist_ok=True)

        # Write the code chunk to a file
        chunk_file_path = os.path.join(file_dir, f"{file_name}_chunk_{chunk_id}.v")
        with open(chunk_file_path, 'w') as f:
            f.write(code)

        typer.echo(f"Downloaded: {chunk_file_path}")
    typer.echo(f"Successfully installed library: {lib}")

@app.command()
def load(repo: str):
    """Load a library from a repository."""
    # Extract the owner and repo name from the URL
    parsed_url = urlparse(repo)
    path_parts = parsed_url.path.strip('/').split('/')
    owner, repo_name = path_parts[0], path_parts[1]

    es_client = Elasticsearch(
        "https://69bc680d7967407080cd9090e3c12a25.us-central1.gcp.cloud.es.io:443",
        api_key="UWdUV0M1RUJjd1F5SmpPNHRJVlU6Ui1tenFqaUFReFc5d0k2ODJSVnBldw=="
    )
    mapping = {
        "mappings": {
            "properties": {
                "name": {"type": "keyword"},
                "code": {"type": "text"},
                "embedding": {
                    "type": "dense_vector",
                    "dims": 1536,
                    "index": True,
                    "similarity": "cosine"
                }
            }
        }
    }

    with typer.progressbar(length=1, label="Creating index") as progress:
        create_index(es_client, repo_name, mapping)
        progress.update(1)
    embed_library_from_repo(owner, repo_name, es_client)

    typer.echo(f"Loaded {repo_name} into Instachip successfully.")


@app.command()
def uninstall(lib: str):
    """Uninstall a library."""
    lib_dir = os.path.join("lib", lib)
    if os.path.exists(lib_dir) and os.path.isdir(lib_dir):
        shutil.rmtree(lib_dir)
        typer.echo(f"Removed directory: {lib_dir}")
    else:
        typer.echo(f"Directory {lib_dir} does not exist.")
    typer.echo(f"Uninstalling library: {lib}")

if __name__ == "__main__":
    app()