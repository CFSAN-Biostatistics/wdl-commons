# Tests for the resistance WDL library

import pytest
import WDL

from functools import partial

from tests import use_file, run_task

@pytest.fixture
def wdl():
    return WDL.load("resistance.wdl")

@pytest.fixture()
def tasks(wdl):
    o = type('', (), {})()
    for task in wdl.tasks:
        setattr(o, task.name, task)
    return o

@pytest.fixture
def run():
    return partial(run_task, "resistance.wdl")


def test_parse_resfinder(tasks, run, outputs):
    inputs = {
        "resfinder_results": [
"Resistance gene	Identity	Alignment Length/Gene Length	Coverage	Position in reference	Contig	Position in contig	Phenotype	Accession no.",
"blaOXA-193	99.87	774/774	100.0	1..774	Contig_17_116.474	33449..34222	Unknown Beta-lactam	CP013032",
"blaOXA-61	99.87	774/774	100.0	1..774	Contig_17_116.474	33449..34222	Amoxicillin, Amoxicillin+Clavulanic acid, Ampicillin, Ampicillin+Clavulanic acid	AY587956",
"blaOXA-489	99.87	774/774	100.0	1..774	Contig_17_116.474	33449..34222	Unknown Beta-lactam	CP013733",
"blaOXA-453	99.87	774/774	100.0	1..774	Contig_17_116.474	33449..34222	Unknown Beta-lactam	KR061507",
"blaOXA-452	99.87	774/774	100.0	1..774	Contig_17_116.474	33449..34222	Unknown Beta-lactam	KR061505",
"blaOXA-451	99.87	774/774	100.0	1..774	Contig_17_116.474	33449..34222	Unknown Beta-lactam	KR061504",
"blaOXA-450	99.87	774/774	100.0	1..774	Contig_17_116.474	33449..34222	Unknown Beta-lactam	KR061502",
"tet(O)	100.00	1920/1920	100.0	1..1920	Contig_1_168.009_Circ [topology=circular]	27131..29050	Doxycycline, Tetracycline, Minocycline	M18896"
        ]
    }
    outputs.update(run(tasks.parse_resfinder, inputs))
    assert len(outputs["parse_resfinder.resistanceGenes"]) == 8
    assert outputs["parse_resfinder.resistanceGenes"][0]["gene"] == "blaOXA-193"