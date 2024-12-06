# FDA-HFP DSDI Nanopore WDL Library
# Common nanopore tasks for biosurveillance of foodborne pathogens.
# Author: Justin Payne <justin.payne@fda.hhs.gov>

version 1.0


# @1e130ab1-9668-4222-affa-45d539b1aedb 
# runid=56609027e57d2aaa97a6d5b0a8557d8b67018231 
# read=6584 
# ch=56 
# start_time=2024-06-20T13:48:45.004322-04:00 
# flow_cell_id=FAX48016 
# protocol_group_id=FAX48016_4 
# sample_id=FAX48016_4 
# barcode=barcode02 
# barcode_alias=barcode02 
# parent_read_id=1e130ab1-9668-4222-affa-45d539b1aedb 
# basecall_model_version_id=dna_r10.4.1_e8.2_400bps_hac@v4.3.0

struct Header {
    String readid
    String runid
    String read
    String channel
    String start_time
    String flow_cell_id
    String protocol_group_id
    String sample_id
    String barcode
    String barcode_alias
    String parent_read_id
    String basecall_model_version_id
}

task get_header {
    input {
        File fastq
    }

    command <<<
        head -n 1 ~{fastq} | cut -d " " -f 1- | jq -nR 'input as $L | {readid: ($L | split(" ")[0]), runid: ($L | split(" ")[1]  | split("=")[1]), read: ($L | split(" ")[2] | split("=")[1]), channel: ($L | split(" ")[3] | split("=")[1]), start_time: ($L | split(" ")[4] | split("=")[1]), flow_cell_id: ($L | split(" ")[5] | split("=")[1]), protocol_group_id: ($L | split(" ")[6] | split("=")[1]), sample_id: ($L | split(" ")[7] | split("=")[1]), barcode: ($L | split(" ")[8] | split("=")[1]), barcode_alias: ($L | split(" ")[9] | split("=")[1]), parent_read_id: ($L | split(" ")[10] | split("=")[1]), basecall_model_version_id: ($L | split(" ")[11] | split("=")[1])}'
    >>>

    output {
        Header header = read_json(stdout())
    }

    runtime {
        docker: "poulti/ubuntu-with-utils"
    }

}

# docker run \
#     --gpus 1 \
#     -v $PWD:$PWD \
#     nanoporetech/dorado \
#     dorado basecaller "/models/dna_r10.4.1_e8.2_400bps_hac@v3.5.2" $PWD/fast5/ \
# > output.sam

task dorado_basecall {
    input {
        File pod5
        String kit
        String model = "/models/dna_r10.4.1_e8.2_400bps_hac@v3.5.2"
    }

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
        model: "Path to the basecalling model."
    }

    runtime {
        docker: "nanoporetech/dorado"
        cpu: 1
        gpu: true
    }
}

task guppy_basecall {
    input {
        File fast5
        File? config
    }

    command <<<
        guppy_basecaller -i ~{fast5} ~{"-c " + config}
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
    input {
        File fastq
        File? config
    }

    command <<<
        flye --nano-raw ~{fastq} ~{"--config " + config}
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