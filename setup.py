from setuptools import setup

setup(
    name="verilog",
    version="0.1",
    py_modules=["cli", "push_to_db"],
    install_requires=["typer[all]", "python-dotenv"],
    entry_points={
        "console_scripts": [
            "verilog=cli:app",
        ],
    },
    include_package_data=True,
    package_data={
        '': ['.env'],
    }
)