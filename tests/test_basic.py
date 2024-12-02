import pytest

from tests import use_file, run_task
from functools import partial


# Test basic Miniwdl run functionality

@pytest.fixture
def wdl():
    return "https://raw.githubusercontent.com/openwdl/learn-wdl/refs/heads/master/1_script_examples/1_hello_worlds/1_hello/hello.wdl"

@pytest.fixture
def hello():
    h = type('', (), {})()
    h.name = "WriteGreeting"
    return h

@pytest.fixture()
def run(wdl):
    return partial(run_task, wdl)

@pytest.fixture
def raw():
    yield from use_file("test/compression/example.raw")

def test_use_file(raw):
    from pathlib import Path
    assert Path(raw).is_file()

def test_hello(run, hello, outputs):
    outputs.update(run(hello, {}))
    assert outputs["WriteGreeting.output_greeting"].strip() == "Hello World"

