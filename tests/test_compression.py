# Tests for the compression WDL library

from tests import use_file

import pytest
import miniwdl

from hypothesis import given, strategies


@pytest.fixture
def wdl():
    return miniwdl.Workflow.load("compression.wdl")

@use_file("test/compression/example.gz", "src")
@use_file("test/compression/example.raw", "raw")
def test_fromgz(wdl, src, raw):
    inputs = {
        "in": src,
    }
    outputs = wdl.invoke("fromgz", inputs)
    assert outputs["out"].read() == open(raw, "rb").read()

@use_file("test/compression/example.raw", "raw")
@use_file("test/compression/example.gz", "out")
def test_togz(wdl, raw, out):
    inputs = {
        "in": raw,
    }
    outputs = wdl.invoke("togz", inputs)
    assert outputs["out"].read() == open(out, "rb").read()

# This is how I want these tests to work
@given(
    strategies.one_of(
        strategies.only(use_file("test/compression/example.1.zstd", "src"), 1),
        strategies.only(use_file("test/compression/example.8.zstd", "src"), 8),
        strategies.only(use_file("test/compression/example.15.zstd", "src"), 15)
    )
)
@use_file("test/compression/example.raw", "raw")
def test_fromzstd(wdl, src, cl, raw):
    inputs = {
        "in": src,
        "compression_level": cl
    }
    outputs = wdl.invoke("fromzstd", inputs)
    assert outputs["out"].read() == open(raw, "rb").read()

@given(
    strategies.one_of(
        strategies.only(use_file("test/compression/example.1.zstd", "out"), 1),
        strategies.only(use_file("test/compression/example.8.zstd", "out"), 8),
        strategies.only(use_file("test/compression/example.15.zstd", "out"), 15)
    )
)
@use_file("test/compression/example.raw", "raw")
def test_tozstd(wdl, raw, cl, out):
    inputs = {
        "in": raw,
        "compression_level": cl
    }
    outputs = wdl.invoke("tozstd", inputs)
    assert outputs["out"].read() == open(out, "rb").read()


@use_file("test/compression/example.raw", "raw")
@use_file("test/compression/example.tar.gz", "out")
def test_tar(wdl, raw, out):
    inputs = {
        "in": raw,
    }
    outputs = wdl.invoke("tar", inputs)
    assert outputs["archive"].read() == open(out, "rb").read()

@use_file("test/compression/example.tar.gz", "src")
@use_file("test/compression/example.raw", "raw")
def test_untar(wdl, src, raw):
    inputs = {
        "in": src,
    }
    outputs = wdl.invoke("untar", inputs)
    assert outputs["files"][0].read() == open(raw, "rb").read()