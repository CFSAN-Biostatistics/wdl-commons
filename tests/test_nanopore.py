import pytest
import miniwdl

@pytest.fixture
def wdl():
	return miniwdl.Workflow.load("$$name.wdl")

def test_basecall(wdl):
	assert False
	

def test_assemble(wdl):
	assert False