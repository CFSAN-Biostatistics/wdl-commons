# Tests for the taxonomy WDL library

import pytest
import WDL
import WDL.Value

from functools import partial

from tests import use_file, run_task

@pytest.fixture
def wdl():
    return WDL.load("taxonomy.wdl")

@pytest.fixture()
def tasks(wdl):
    o = type('', (), {})()
    for task in wdl.tasks:
        setattr(o, task.name, task)
    return o

@pytest.fixture
def run():
    return partial(run_task, "taxonomy.wdl")

schemes = """achromobacter aeromonas aactinomycetemcomitans vibrio neisseria efaecalis geotrichum kaerogenes shaemolyticus bsubtilis oralstrep edwardsiella cbotulinum shewanella mycobacteria_2 sdysgalactiae bcereus sgallolyticus cfreundii hparasuis schromogenes wolbachia cmaltaromaticum campylobacter_nonjejuni_6 hinfluenzae mgallisepticum vvulnificus ppentosaceus magalactiae streptomyces mcaseolyticus campylobacter_nonjejuni_2 vparahaemolyticus klebsiella campylobacter_nonjejuni_5 sbsec csepticum brachyspira_5 mhyopneumoniae lsalivarius tenacibaculum blicheniformis_14 pmultocida_2 borrelia sthermophilus brachyspira smaltophilia ureaplasma llactis_phage sinorhizobium pgingivalis pmultocida manserisalpingitidis fpsychrophilum bordetella_3 leptospira_2 bcc ssuis campylobacter_nonjejuni brachyspira_2 ecoli_achtman_4 cronobacter vcholerae_2 bfragilis spyogenes mcatarrhalis_achtman_6 kingella hsuis orhinotracheale mbovis_2 mhyorhinis mhaemolytica campylobacter_nonjejuni_7 koxytoca bpseudomallei abaumannii_2 cdifficile mplutonius mgallisepticum_2 brucella ranatipestifer ecoli mcanis brachyspira_4 arcobacter bwashoensis abaumannii otsutsugamushi tpallidum scanis hcinaedi paeruginosa campylobacter_nonjejuni_3 mabscessus gallibacterium campylobacter_nonjejuni_9 plarvae sagalactiae msynoviae rhodococcus cperfringens xfastidiosa aphagocytophilum bhenselae listeria_2 ypseudotuberculosis_achtman_3 saureus efaecium miowae liberibacter pputida staphlugdunensis pdamselae pfluorescens campylobacter psalmonis helicobacter spneumoniae leptospira_3 mpneumoniae streptothermophilus bbacilliformis vcholerae shominis senterica_achtman_2 vtapetis taylorella spseudintermedius chlamydiales campylobacter_nonjejuni_8 diphtheria_3 yruckeri brachyspira_3 mflocculare leptospira dnodosus pacnes_3 campylobacter_nonjejuni_4 szooepidemicus ecloacae suberis sepidermidis mhominis_3 msciuri""".split()

# def test_hello(run, tasks):
#     task = tasks["hello"]
#     inputs = {}
#     outputs = run(task, inputs)
#     assert outputs["salutation"] == "Hello, world!"

@pytest.fixture
def Subsubspecies(structs):
    return structs["Subsubspecies"]

@pytest.fixture
def Organism(structs):
    return structs["Organism"]

@pytest.fixture
def Prediction(structs):
    return structs["Prediction"]

@pytest.mark.xfail
def test_coercion_to_Subsubspecies(Subsubspecies):
    assert WDL.Value.from_json(Subsubspecies, {"name":"test", "rank:":"test"}).name == "test"

@pytest.mark.xfail
def test_coercion_to_Organism(Organism):
    assert WDL.Value.from_json(Organism, {"name":"test", "genus":"test", "species":"test", "subspecies":"test", "subsubspecies":{"name":"test", "rank":"test"}}).name == "test"

@pytest.mark.xfail
def test_coercion_to_Prediction(Prediction):
    assert WDL.Value.from_json(Prediction, dict(
        tool=dict(name="test", version="0.0.0"),
        organism=dict(name="test", genus="test", species="test", subspecies="test", subsubspecies=dict(name="test", rank="test")),
        confidence=0.0,
        scheme="test",
        alleles=["1", "2", "3"]
        )
    ).scheme == "test"



@pytest.mark.parametrize("scheme", schemes)
def test_parse_mlst(wdl, tasks, run, scheme, outputs):
    inputs = {
        "mlst_results":[
                "TEST",
                scheme,
                f"{scheme[:4]}1",
                f"{scheme[:4]}2",
                f"{scheme[:4]}3"
        ]
    }
    outputs.update(run(tasks.parse_mlst, inputs))
    # assert len(outputs["parse_mlst.predictions"]) == 1
    assert outputs["parse_mlst.prediction"]["scheme"] == scheme

def test_parse_seqsero2(wdl, tasks, run, outputs):
    inputs = {
        "seqsero2_results": [
            "TEST",
            "TEST",
            "TEST",
            "4",
            "r",
            "1,2",
            "Salmonella TEST subsp. TEST (TEST)",
            "4r1,2"
            "TESTLEBERG"
            "Note:", "This is a test"
        ]
    }
    outputs.update(run(tasks.parse_seqsero2, inputs))
    assert outputs["parse_seqsero2.prediction"]["organism"]["genus"] == "Salmonella"