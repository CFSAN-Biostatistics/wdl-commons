import pytest
import WDL

from functools import partial

from tests import use_file, run_task

@pytest.fixture
def wdl():
	return WDL.load("nanopore.wdl")

@pytest.fixture()
def tasks(wdl):
    o = type('', (), {})()
    for task in wdl.tasks:
        setattr(o, task.name, task)
    return o

@pytest.fixture
def run():
    return partial(run_task, "nanopore.wdl")

def test_basecall(tasks):
	assert False
	

def test_assemble(tasks):
	assert False
      
@pytest.fixture
def header():
    yield from use_file("test/nanopore/header.fq")

def test_get_header(header, tasks, run, outputs):
    inputs = dict(
        fastq = header
    )
    outputs.update(run(tasks.get_header, inputs))
    assert outputs["get_header.header"]["runid"] == "56609027e57d2aaa97a6d5b0a8557d8b67018231"