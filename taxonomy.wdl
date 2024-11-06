# FDA-HFP DSDI taxonomy WDL Library
# Author: Justin Payne <justin.payne@fda.hhs.gov>

version 1.1

import "identify.wdl" as identify

struct Subsubspecies {
    String name
    String rank
}

struct Organism {
    String? name
    String genus
    String? species
    String? subspecies
    Subsubspecies? subsubspecies
}

struct Prediction {
    Tool? tool
    Organism organism
    Float? confidence
    String? scheme
    Array[String]? alleles
    String? comment
}



task mlst {
    input {
        File fasta
    }

    command <<<
        mlst --version 2>&1> ver
        mlst ~{fasta}
    >>>

    output {
        String ver = read_string("ver")
        Array[String] result = read_tsv(stdout())[0]
    }

    runtime {
        container: "staphb/mlst:latest"
        cpu: 1
        memory: "512 MB"
    }

    parameter_meta {
        fasta: "Assembly in FASTA format, optionally compressed."
    }
}

task mlst_singleton {
    input {
        Array[File] fastas
    }

    command <<<
        mlst --version 2>&1> ver
        mlst ~{sep(' ', fastas)}
    >>>

    output {
        String ver = read_string("ver")
        Array[Array[String]] result = read_tsv(stdout())
    }

    runtime {
        container: "staphb/mlst:latest"
        cpu: 1
        memory: "512 MB"
    }

    parameter_meta {
        fasta: "Assemblies in FASTA format, optionally compressed."
    }
}

# Miniwdl can't coerce to a Map of a struct

task parse_mlst {
    input {
        String ver = "MLST unrecorded version"
        Array[String] mlst_results
    }

    command <<<
        python <<CODE
import json
import csv

mlst_schemes = {
    "achromobacter":("Achromobacter",None),
    "aeromonas":("Aeromonas",None),
    "aactinomycetemcomitans":("Aggregatibacter","actinomycetemcomitans"),
    "vibrio":("Vibrio",None),
    "neisseria":("Neisseria",None),
    "efaecalis":("Enterococcus","faecalis"),
    "geotrichum":("Geotrichum",None),
    "kaerogenes":("Klebsiella","aerogenes"),
    "shaemolyticus":("Staphylococcus","haemolyticus"),
    "bsubtilis":("Bacillus","subtilis"),
    "oralstrep":("Streptococcus",None),
    "edwardsiella":("Edwardsiella",None),
    "cbotulinum":("Clostridium","botulinum"),
    "shewanella":("Shewanella",None),
    "mycobacteria_2":("Mycobacteria",None),
    "sdysgalactiae":("Streptococcus","dysgalactiae"),
    "bcereus":("Bacillus","cereus"),
    "sgallolyticus":("Streptococcus","gallolyticus"),
    "cfreundii":("Citrobacter","freundii"),
    "hparasuis":("Haemophilus","parasuis"),
    "schromogenes":("Staphylococcus","chromogenes"),
    "wolbachia":("Wolbachia",None),
    "cmaltaromaticum":("Carnobacterium","maltaromaticum"),
    "campylobacter_nonjejuni_6":("Campylobacter",None),
    "hinfluenzae":("Haemophilus","influenzae"),
    "mgallisepticum":("Mycoplasma","gallisepticum"),
    "vvulnificus":("Vibrio","vulnificus"),
    "ppentosaceus":("Pediococcus","pentosaceus"),
    "magalactiae":("Mycoplasma","agalactiae"),
    "streptomyces":("Streptomyces",None),
    "mcaseolyticus":("Macrococcus","caseolyticu"),
    "campylobacter_nonjejuni_2":("Campylobacter",None),
    "vparahaemolyticus":("Vibrio","parahaemolyticus"),
    "klebsiella":("Klebsiella",None),
    "campylobacter_nonjejuni_5":("Campylobacter",None),
    "sbsec":("Streptococcus",None),
    "csepticum":("Clostridium","septicum"),
    "brachyspira_5":("Brachyspira",None),
    "mhyopneumoniae":("Mycoplasma","hyopneumoniae"),
    "lsalivarius":("Ligilactobacillus","salivarius"),
    "tenacibaculum":("Tenacibaculum",None),
    "blicheniformis_14":("Bacillus","licheniformis"),
    "pmultocida_2":("Pasteurella","multocida"),
    "borrelia":("Borrelia",None),
    "sthermophilus":("Streptococcus","thermophilus"),
    "brachyspira":("Brachyspira",None),
    "smaltophilia":("Stenotrophomonas","maltophilia"),
    "ureaplasma":("Ureaplasma",None),
    "llactis_phage":("Sk1virus","Lactococcus virus"),
    "sinorhizobium":("Ensifer","meliloti"),
    "pgingivalis":("Porphyromonas","gingivalis"),
    "pmultocida":("Pasteurella","multocida"),
    "manserisalpingitidis":("Manseri","salpingitidis"),
    "fpsychrophilum":("Flavobacterium","psychrophilum"),
    "bordetella_3":("Bordetella",None),
    "leptospira_2":("Leptospira",None),
    "bcc":("Burkholderia","cepacia"),
    "ssuis":("Streptococcus","suis"),
    "campylobacter_nonjejuni":("Campylobacter",None),
    "brachyspira_2":("Brachyspira",None),
    "ecoli_achtman_4":("Escherichia","coli"),
    "cronobacter":("Cronobacter",None),
    "vcholerae_2":("Vibrio","cholerae"),
    "bfragilis":("Bacteroides","fragilis"),
    "spyogenes":("Streptococcus","pyogenes"),
    "mcatarrhalis_achtman_6":("Moraxella","catarrhalis"),
    "kingella":("Kingella",None),
    "hsuis":("Helicobacter","suis"),
    "orhinotracheale":("Ornithobacterium","rhinotracheale"),
    "mbovis_2":("Mycoplasma","bovis"),
    "mhyorhinis":("Mycoplasma","hyorhinis"),
    "mhaemolytica":("Mannheimia","haemolytica"),
    "campylobacter_nonjejuni_7":("Campylobacter",None),
    "koxytoca":("Klebsiella","oxytoca"),
    "bpseudomallei":("Burkholderia","pseudomallei"),
    "abaumannii_2":("Acinetobacter"," baumannii"),
    "cdifficile":("Clostridioides","difficile"),
    "mplutonius":("Melissococcus","plutonius"),
    "mgallisepticum_2":("Mycoplasma","gallisepticum"),
    "brucella":("Brucella",None),
    "ranatipestifer":("Riemerella","anatipestifer"),
    "ecoli":("Escherichia","coli"),
    "mcanis":("Macrococcus","canis"),
    "brachyspira_4":("Brachyspira",None),
    "arcobacter":("Arcobacter",None),
    "bwashoensis":("Bartonella","washoensis"),
    "abaumannii":("Acinetobacter"," baumannii"),
    "otsutsugamushi":("Orientia","tsutsugamushi"),
    "tpallidum":("Treponema","pallidum"),
    "scanis":("Streptococcus","canis"),
    "hcinaedi":("Helicobacter","cinaedi"),
    "paeruginosa":("Pseudomonas","aeruginosa"),
    "campylobacter_nonjejuni_3":("Campylobacter",None),
    "mabscessus":("Mycobacteroides","abcessus complex"),
    "gallibacterium":("Gallibacterium",None),
    "campylobacter_nonjejuni_9":("Campylobacter",None),
    "plarvae":("Paenibacillus","larvae"),
    "sagalactiae":("Streptococcus","agalactiae"),
    "msynoviae":("Mycoplasma","synoviae"),
    "rhodococcus":("Rhodococcus",None),
    "cperfringens":("Clostridium","perfringens"),
    "xfastidiosa":("Xylella","fastidiosa"),
    "aphagocytophilum":("Anaplasma","phagocytophilum"),
    "bhenselae":("Bartonella","henselae"),
    "listeria_2":("Listeria",None),
    "ypseudotuberculosis_achtman_3":("Yersinia","pseudotuberculosis"),
    "saureus":("Staphylococcus","aureus"),
    "efaecium":("Enterococcus","faecium"),
    "miowae":("Mycoplasma","iowae"),
    "liberibacter":("Liberibacter",None),
    "pputida":("Pseudomonas","putida"),
    "staphlugdunensis":("Staphylococcus","lugdunensis"),
    "pdamselae":("Photobacterium","damselae"),
    "pfluorescens":("Pseudomonas","fluorescens"),
    "campylobacter":("Campylobacter",None),
    "psalmonis":("Piscirickettsia","salmonis"),
    "helicobacter":("Helicobacter",None),
    "spneumoniae":("Streptococcus","pneumoniae"),
    "leptospira_3":("Leptospira",None),
    "mpneumoniae":("Mycoplasma","pneumoniae"),
    "streptothermophilus":("Streptococcus","thermophilus"),
    "bbacilliformis":("Bartonella","bacilliformis"),
    "vcholerae":("Vibrio","cholerae"),
    "shominis":("Staphylococcus","hominis"),
    "senterica_achtman_2":("Salmonella","enterica"),
    "vtapetis":("Vibrio","tapetis"),
    "taylorella":("Taylorella",None),
    "spseudintermedius":("Staphylococcus","pseudintermedius"),
    "chlamydiales":("Chlamydiales",None),
    "campylobacter_nonjejuni_8":("Campylobacter",None),
    "diphtheria_3":("Corynebacterium","diphtheriae"),
    "yruckeri":("Yersinia","ruckeri"),
    "brachyspira_3":("Brachyspira",None),
    "mflocculare":("Mycoplasma","flocculare"),
    "leptospira":("Leptospira",None),
    "dnodosus":("Dichelobacter","nodosus"),
    "pacnes_3":("Propionibacterium","acnes"),
    "campylobacter_nonjejuni_4":("Campylobacter",None),
    "szooepidemicus":("Streptococcus","zooepidemicus"),
    "ecloacae":("Enterobacter","cloacae"),
    "suberis":("Streptococcus","uberis"),
    "sepidermidis":("Staphylococcus","epidermidis"),
    "mhominis_3":("Staphylococcus","hominis"),
    "msciuri":("Mammaliicoccus","sciuri"),
}

def get_name_from_scheme(scheme):
    genus = mlst_schemes[scheme][0]
    species = mlst_schemes[scheme][1]
    name = " ".join([genus, species or "spp."])
    return_dict = dict(
        name=name,
        genus=genus,
    )
    if species:
        return_dict["species"] = species
    return return_dict


with open("~{write_lines(mlst_results)}", "r") as f:
    fname, scheme, *alleles = (l.strip() for l in f.readlines())
    print(json.dumps(
        dict(
            tool=dict(
                name="mlst",
                version=" ".join("~{ver}".split(" ")[1:])
            ),
            organism=get_name_from_scheme(scheme),
            alleles=alleles,
            scheme=scheme
        )
    ))
CODE
    >>>

    output {
        Prediction prediction = read_json(stdout())
    }

    runtime {
        container: "python:3.12"
        cpu: 1
        memory: "512 MB"
    }
}

task seqsero2 {
    input {
        Array[File] files
        Int mode = 2
    }

    command <<<
        SeqSero2_package.py --version 2>&1> ver
        SeqSero2_package.py -m k -t ~{mode} -i ~{sep(' ', files)} -o /out -s
    >>>

    output {
        Array[String] results = read_tsv("/out/Seqsero_result.txt")[0]
        String ver = read_string("ver")
    }

    runtime {
        container: "staphb/seqsero2:latest"
        cpu: 1
        memory: "512 MB"
    }

    parameter_meta {
        fasta: "Reads or assembly file or files."
    }
}

task parse_seqsero2 {
    # Sample name	
    # Output directory	
    # Input files	
    # O antigen prediction	
    # H1 antigen prediction(fliC)	
    # H2 antigen prediction(fljB)	
    # Predicted identification	
    # Predicted antigenic profile	
    # Predicted serotype	
    # Potential inter-serotype contamination	
    # Note
    # Salmonella enterica subspecies enterica (subspecies I)
    input {
        Array[String] seqsero2_results
        String ver = "SeqSero2 unrecorded version"
    }

    command <<<
        python <<CODE
import json
with open("~{write_lines(seqsero2_results)}", "r") as f:
    _, _, _, o, h1, h2, pred, prof, serotype, *notes = (l.strip() for l in f.readlines())
    genus, species, _, subspecies, *_ = pred.split()
    print(json.dumps(
        dict(
            tool=dict(
                name="SeqSero2",
                version=" ".join("~{ver}".split()[1:])
            ),
            organism=dict(
                name=f"{genus} {species} subsp. {subspecies} serovar {serotype}",
                genus=genus,
                species=species,
                subspecies=subspecies,
                subsubspecies=dict(
                    name=serotype,
                    rank="serovar"
                ),
                scheme="White-Kauffmann-Le Minor",
                alleles=[f"rfb({o})", f"fliC({h1})", f"fljB({h2})"],
                comment=" ".join(notes) or None
            )
        )
    ))
CODE
    >>>

    output {
        Prediction prediction = read_json(stdout())
    }

    runtime {
        container: "python:3.12"
        cpu: 1
        memory: "512 MB"
    }
}