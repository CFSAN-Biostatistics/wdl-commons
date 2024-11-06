# Tests for the identify WDL library

import pytest
import WDL
import WDL.Value

from functools import partial

from tests import use_file, run_task

@pytest.fixture
def wdl():
    return WDL.load("identify.wdl")

@pytest.fixture()
def tasks(wdl):
    o = type('', (), {})()
    for task in wdl.tasks:
        setattr(o, task.name, task)
    return o

@pytest.fixture
def run():
    return partial(run_task, "identify.wdl")


@pytest.fixture
def bam():
    yield from use_file("test/identify/example.bam")

@pytest.fixture
def fasta():
    yield from use_file("test/identify/example.fasta")

@pytest.fixture
def fastq():
    yield from use_file("test/identify/example.fastq")

@pytest.fixture
def outputs():
    return {}

@pytest.mark.xfail
def test_coercion_to_tool(structs):
    result = WDL.Value.from_json(structs['Tool'], dict(name="test", version="0.0.0"))
    assert result.name == "test"
    assert result.version == "0.0.0"

def test_identify_bam(run, bam, tasks, outputs):
    inputs = {
        "file": bam,
    }
    outputs.update(run(tasks.bam, inputs))
    assert outputs["bam.name"] == "EXAMPLE"

def test_identify_fasta(run, fasta, tasks, outputs):
    inputs = {
        "file": fasta,
    }
    outputs.update(run(tasks.fasta, inputs))
    assert outputs["fasta.name"] == "EXAMPLE"

def test_identify_fastq(run, fastq, tasks, outputs):
    inputs = {
        "file": fastq,
    }
    outputs.update(run(tasks.fastq, inputs))
    assert outputs["fastq.name"] == "EXAMPLE"