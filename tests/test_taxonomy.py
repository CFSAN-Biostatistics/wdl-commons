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

def test_parse_kraken2(wdl, tasks, run, outputs):
    inputs = {
        "ver": "Kraken version 2.0.9-beta",
        "kraken2_results": [
"  0.26	13	13	U	0	unclassified",
" 99.74	4968	53	R	1	root",
" 98.33	4898	0	D	10239	  Viruses",
" 98.33	4898	0	D1	439488	    ssRNA viruses",
" 98.33	4898	0	D2	35278	      ssRNA positive-strand viruses, no DNA stage",
" 98.33	4898	0	F	11989	        Leviviridae",
" 98.33	4898	0	G	11990	          Levivirus",
" 98.31	4897	4897	S	329852	            Escherichia virus MS2",
"  0.02	1	1	S	329853	            Escherichia virus BZ13",
"  0.34	17	0	R1	131567	  cellular organisms",
"  0.24	12	1	D	2	    Bacteria",
"  0.22	11	1	P	1224	      Proteobacteria",
"  0.20	10	5	C	1236	        Gammaproteobacteria",
"  0.10	5	3	O	91347	          Enterobacterales",
"  0.04	2	2	F	543	            Enterobacteriaceae",
"  0.10	5	0	D	2759	    Eukaryota",
"  0.10	5	0	D1	33154	      Opisthokonta",
"  0.10	5	0	K	33208	        Metazoa",
"  0.10	5	0	K1	6072	          Eumetazoa",
"  0.10	5	0	K2	33213	            Bilateria",
"  0.10	5	0	K3	33511	              Deuterostomia",
"  0.10	5	0	P	7711	                Chordata",
"  0.10	5	0	P1	89593	                  Craniata",
"  0.10	5	0	P2	7742	                    Vertebrata",
"  0.10	5	0	P3	7776	                      Gnathostomata",
"  0.10	5	0	P4	117570	                        Teleostomi",
"  0.10	5	0	P5	117571	                          Euteleostomi",
"  0.10	5	0	P6	8287	                            Sarcopterygii",
"  0.10	5	0	P7	1338369	                              Dipnotetrapodomorpha",
"  0.10	5	0	P8	32523	                                Tetrapoda",
"  0.10	5	0	P9	32524	                                  Amniota",
"  0.10	5	0	C	40674	                                    Mammalia",
"  0.10	5	0	C1	32525	                                      Theria",
"  0.10	5	0	C2	9347	                                        Eutheria",
"  0.10	5	0	C3	1437010	                                          Boreoeutheria",
"  0.10	5	0	C4	314146	                                            Euarchontoglires",
"  0.10	5	0	O	9443	                                              Primates",
"  0.10	5	0	O1	376913	                                                Haplorrhini",
"  0.10	5	0	O2	314293	                                                  Simiiformes",
"  0.10	5	0	O3	9526	                                                    Catarrhini",
"  0.10	5	0	O4	314295	                                                      Hominoidea",
"  0.10	5	0	F	9604	                                                        Hominidae",
"  0.10	5	0	F1	207598	                                                          Homininae",
"  0.10	5	0	G	9605	                                                            Homo",
"  0.10	5	5	S	9606	                                                              Homo sapiens"
        ]
    }
    outputs.update(run(tasks.parse_kraken2, inputs))
    assert len(outputs["parse_kraken2.predictions"]) == 3
    assert outputs["parse_kraken2.predictions"][0]["tool"]["version"] == "v. 2.0.9-beta"
    assert outputs["parse_kraken2.predictions"][0]["confidence"] == 98.31