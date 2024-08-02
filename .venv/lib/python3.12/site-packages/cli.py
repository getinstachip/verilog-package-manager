import typer

app = typer.Typer()

@app.command()
def install(lib: str):
    """Install a library."""
    typer.echo(f"Installing library: {lib}")

@app.command()
def uninstall(lib: str):
    """Uninstall a library."""
    typer.echo(f"Uninstalling library: {lib}")

if __name__ == "__main__":
    app()