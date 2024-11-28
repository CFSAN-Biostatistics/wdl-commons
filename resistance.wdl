# FDA-HFP DSDI resistance WDL Library
# Author: Justin Payne <justin.payne@fda.hhs.gov>

version 1.1

import "identify.wdl" as identify

struct AlignmentCoordinate {
    String? contig
    Int ref_start
    Int ref_end
    Int? gene_length
    Int? contig_start
    Int? contig_end
    Int? alignment_length
}

struct ResistanceGene {
    Tool tool
    String gene
    Float? identity
    Int? alignmentLength
    Int? geneLength
    Float? coverage
    AlignmentCoordinate? coordinates
    String phenotype
    String accession
}

task resfinder {

    input {
        Array[File] fastqs
        File? fasta
        Boolean? nanopore
        String? species
    }

    command <<<
        python -m resfinder --version 2>&1 > ver
        python -m resfinder -acq ~{if defined(nanopore) then "--nanopore" else ""} ~{if defined(species) then "-s " + "\"" + species + "\"" else ""} ~{if defined(fasta) then "-ifa " + fasta else "-ifq " + sep(" ", fastqs)} -j /out/resfinder.json -o /out/
    >>>

    output {
        String version = read_string("ver")
        Array[String] results = read_tsv("/out/ResFinder_results_tab.txt")
    }

    runtime {
        docker: "genomicepidemiology/resfinder:latest"
    }

}

task parse_resfinder {

    input {
        Array[String] resfinder_results
        String ver = "unspecified version"
    }

    command <<<
        python <<CODE
import json
import csv

ver = "~{ver}"

tool = dict(
    name='ResFinder',
    version=f"{'.v ' if ver != 'unspecified version' else ''}{ver}"
)

with open("~{write_lines(resfinder_results)}", 'r') as f:
    reader = csv.DictReader(f, delimiter='\t')
    genes = []
    for row in reader:
        gene = row['Resistance gene']
        identity = float(row['Identity'])
        alignment_length, gene_length = map(int, row['Alignment Length/Gene Length'].split('/'))
        coverage = float(row['Coverage'])
        contig = row['Contig']
        ref_start, ref_end = map(int, row['Position in reference'].split('..'))
        contig_start, contig_end = map(int, row['Position in contig'].split('..'))
        phenotype = row['Phenotype']
        accession = row['Accession no.']
        genes.append({
            'tool': tool,
            'gene': gene,
            'identity': identity,
            'alignmentLength': alignment_length,
            'geneLength': gene_length,
            'coverage': coverage,
            'coordinates': {
                'contig': contig,
                'ref_start': ref_start,
                'ref_end': ref_end,
                'contig_start': contig_start,
                'contig_end': contig_end,
                'alignment_length': contig_end - contig_start
            },
            'phenotype': phenotype,
            'accession': accession
        })

print(json.dumps(genes))

CODE
    >>>

    output {
        Array[ResistanceGene] resistanceGenes = read_json(stdout())
    }

    runtime {
        docker: "python:3.12"
    }

}