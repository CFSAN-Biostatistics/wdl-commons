# FDA-HFP DSDI Nanopore WDL Library
# Common nanopore tasks for biosurveillance of foodborne pathogens.
# Author: Justin Payne <justin.payne@fda.hhs.gov>

version 1.2

task basecall {
    File fast5
    File config

    command <<<
        guppy_basecaller -i ~{fast5} -c ~{config}
    >>>

    output {
        Array[File] fastqs = "${fast5}.fastq"
    }
    runtime {
        docker: "ontresearch/guppy:5.0.11"
        cpu: 8
        memory: "32 GB"
    }
    
}

task assemble {
    File fastq
    File config

    command <<<
        flye --nano-raw ~{fastq} --config ~{config}
    >>>

    output {
        File assembly = "${fastq}.assembly.fasta"
    }
    runtime {
        docker: "staphb/flye:2.8"
        cpu: 16
        memory: "64 GB"
    }
}