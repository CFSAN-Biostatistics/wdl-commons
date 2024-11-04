# Tests for the compression WDL library

from tests import use_file, run_task

import pytest
import WDL

from hypothesis import given, strategies

from functools import partial


@pytest.fixture
def wdl():
    return WDL.load("compression.wdl")

@pytest.fixture()
def tasks(wdl):
    o = type('', (), {})()
    for task in wdl.tasks:
        setattr(o, task.name, task)
    return o

@pytest.fixture
def run():
    return partial(run_task, "compression.wdl")

@pytest.fixture
def gz():
    yield from use_file("test/compression/example.gz")

@pytest.fixture
def raw():
    yield from use_file("test/compression/example.raw")

@pytest.fixture
def outputs():
    return {}


def test_fromgz(run, gz, raw, tasks, outputs):
    inputs = {
        "in": gz,
    }
    outputs.update(run(tasks.fromgz, inputs))
    assert outputs["fromgz.out"] == open(raw, "rt").read()

def test_togz(run, raw, gz, tasks, outputs):
    inputs = {
        "in": raw,
    }
    outputs.update(run(tasks.togz, inputs))
    assert outputs["togz.out"][8:] == open(gz, "rb").read()[8:] # skip the timestamp

@pytest.fixture
def zstd(request):
    yield from use_file(f"test/compression/example.{request.param}.zst")

@pytest.fixture
def cl(request):
    return request.param

@pytest.mark.parametrize("zstd", [1, 8, 15], indirect=True)
def test_fromzstd(run, zstd, raw, tasks, outputs):
    inputs = {
        "in": zstd,
    }
    outputs.update(run(tasks.fromzstd, inputs))
    assert outputs["fromzstd.out"] == open(raw, "rt").read()

@pytest.mark.parametrize("zstd, cl", [(1,1),  (8,8), (15,15)], indirect=True)
def test_tozstd(run, raw, zstd, cl, tasks, outputs):
    inputs = {
        "in": raw,
        "compression": cl
    }
    outputs.update(run(tasks.tozstd, inputs))
    assert outputs["tozstd.out"] == open(zstd, "rb").read()

@pytest.fixture
def tar():
    yield from use_file("test/compression/example.tar.gz")

def test_tar(run, raw, tar, tasks, outputs):
    inputs = {
        "files": raw,
    }
    outputs.update(run(tasks.tar, inputs))
    assert outputs["tar.archive"] == open(tar, "rb").read()


def test_untar(run, tar, raw, tasks, outputs):
    inputs = {
        "in": tar,
    }
    outputs.update(run(tasks.untar, inputs))
    assert open(outputs["tar.files"][0]).read() == open(raw, "rt").read()