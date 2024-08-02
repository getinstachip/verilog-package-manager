from setuptools import setup

setup(
    name="verilog",
    version="0.1",
    py_modules=["cli"],
    install_requires=["typer[all]"],
    entry_points={
        "console_scripts": [
            "verilog=cli:app",
        ],
    },
)