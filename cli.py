import typer
import requests
import os
import random
import string
from urllib.parse import urlparse

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
    typer.echo(f"Installing library: {lib}")

@app.command()
def load(repo: str):
    """Load a library from a repository."""
    # Extract the owner and repo name from the URL
    parsed_url = urlparse(repo)
    path_parts = parsed_url.path.strip('/').split('/')
    owner, repo_name = path_parts[0], path_parts[1]

    # Construct the API URL
    api_url = f"https://api.github.com/repos/{owner}/{repo_name}/contents"

    # Send a GET request to the GitHub API
    response = requests.get(api_url)
    
    if response.status_code == 200:
        contents = response.json()
        
        # Create a directory for the library
        # random_suffix = ''.join(random.choices(string.ascii_lowercase + string.digits, k=6))
        # lib_dir = f"{repo_name}_{random_suffix}"
        lib_dir = repo_name
        os.makedirs(lib_dir, exist_ok=True)
        
        # Download each file
        for item in contents:
            download_item(api_url, item, lib_dir)
        
        typer.echo(f"Repository contents downloaded to directory: {lib_dir}")
    else:
        typer.echo("Failed to fetch repository contents")

@app.command()
def uninstall(lib: str):
    """Uninstall a library."""
    typer.echo(f"Uninstalling library: {lib}")

if __name__ == "__main__":
    app()