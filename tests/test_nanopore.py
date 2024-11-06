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