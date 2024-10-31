import pytest
import tempfile
import requests

def use_file(partial_path, name="file"):
    def file():
        __name__ = name
        with tempfile.NamedTemporaryFile() as f:
            f.write(requests.get(f"https://raw.githubusercontent.com/CFSAN-Biostatistics/data-commons/{partial_path}").content)
            yield f.name
    def decorator(func):
        return pytest.mark.usefixtures(file)(func)
    return decorator