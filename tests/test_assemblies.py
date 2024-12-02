# Tests for the assemblies WDL library

import pytest
import WDL

from functools import partial

from tests import use_file, run_task

@pytest.fixture
def wdl():
    return WDL.load("assemblies.wdl")

@pytest.fixture()
def tasks(wdl):
    o = type('', (), {})()
    for task in wdl.tasks:
        setattr(o, task.name, task)
    return o

@pytest.fixture
def run():
    return partial(run_task, "assemblies.wdl")

@pytest.fixture
def fasta():
    yield from use_file("test/assemblies/example.fasta")

def test_calculateN50(fasta, run, tasks, outputs):
    inputs = {
        "assembly":fasta
    }
    outputs.update(run(tasks.calculateN50, inputs))
    assert outputs["calculateN50.n50"] == 193697