import pytest
import WDL

from tests import use_file, run_task

@pytest.fixture
def wdl():
	return WDL.load("nanopore.wdl")

@pytest.fixture()
def tasks(wdl):
    return {task.name: task for task in wdl.tasks}

@pytest.fixture
def run():
    return partial(run_task, "nanopore.wdl")

def test_basecall(tasks):
	assert False
	

def test_assemble(tasks):
	assert False