# Tests for the taxonomy WDL library
#
import pytest
import miniwdl
#
pytest.fixture
def wdl():
return miniwdl.Workflow.load("taxonomy.wdl")
#
def test_hello(wf):
task = wdl.tasks["hello"]
inputs = {}
outputs = wdl.invoke(task, inputs)
assert outputs["salutation"] == "Hello, world!"
