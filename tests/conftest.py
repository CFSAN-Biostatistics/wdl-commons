import pytest

@pytest.fixture
def outputs():
    return {}

@pytest.fixture
def structs(wdl):
    return {t.name.value:t.value for t in wdl.struct_typedefs}