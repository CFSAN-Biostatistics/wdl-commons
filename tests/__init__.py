import pytest
import tempfile
import requests
from pathlib import Path

def use_file(partial_path, name="file"):
    def file():
        __name__ = name
        with tempfile.NamedTemporaryFile() as f:
            try:
                f.write(requests.get(f"https://raw.githubusercontent.com/CFSAN-Biostatistics/data-commons/{partial_path}").content)
                yield f.name
            except requests.HTTPError:
                yield Path(__file__).parent / partial_path
    def decorator(func):
        return pytest.mark.usefixtures(file)(func)
    return decorator