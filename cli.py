import typer

# verilog install [lib_name]
# verilog add [lib_name] from [REPO_URL]

app = typer.Typer()

@app.command()
def install(lib: str):
    """Install a library."""
    typer.echo(f"Installing library: {lib}")

@app.command()
def add(lib: str, repo: str):
    """Add a library from a repository."""
    typer.echo(f"Adding library: {lib} from {repo}")

@app.command()
def uninstall(lib: str):
    """Uninstall a library."""
    typer.echo(f"Uninstalling library: {lib}")

if __name__ == "__main__":
    app()