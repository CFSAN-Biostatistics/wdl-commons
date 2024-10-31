# FDA-HFP DSDI Nanopore WDL Library
# Common nanopore tasks for biosurveillance of foodborne pathogens.
# Author: Justin Payne <justin.payne@fda.hhs.gov>

version 1.2


# docker run \
#     --gpus 1 \
#     -v $PWD:$PWD \
#     nanoporetech/dorado \
#     dorado basecaller "/models/dna_r10.4.1_e8.2_400bps_hac@v3.5.2" $PWD/fast5/ \
# > output.sam

task dorado_basecall {
    File pod5
    String kit
    String model = "/models/dna_r10.4.1_e8.2_400bps_hac@v3.5.2"

    command <<<
        dorado basecaller ~{model} ~{pod5} --kit-name ~{kit} > calls.bam
        dorado demux --output-dir /output --no-classify calls.bam
    >>>

    output {
        Array[File] bams = glob("/output/*.bam")
    }

    parameter_meta {
        pod5: "Path to a Pod5 file."
        kit: "Name of the sequencing kit used."
    }

    runtime {
        docker: "nanoporetech/dorado"
        cpu: 1
        gpu: 1
    }
}

task guppy_basecall {
    File fast5
    File config

    command <<<
        guppy_basecaller -i ~{fast5} -c ~{config}
    >>>

    output {
        Array[File] fastqs = glob("*.fastq")
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