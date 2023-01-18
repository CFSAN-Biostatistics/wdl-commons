version 1.0

# This project constitutes a work of the United States Government and is not
# subject to domestic copyright protection under 17 USC § 105. No Rights Are 
# Reserved.

# This program is distributed in the hope that it will be useful. Responsibility
# for the use of the system and interpretation of documentation and results lies
# solely with the user. In no event shall FDA be liable for direct, indirect,
# special, incidental, or consequential damages resulting from the use, misuse,
# or inability to use the system and accompanying documentation. Third parties'
# use of or acknowledgment of the system does not in any way represent that
# FDA endorses such third parties or expresses any opinion with respect to their
# statements. 

# This program is free software: you can redistribute it and/or modify it.

task fastq {

    input {
        File file
    }

    command <<< 
        set -e
        gunzip -c ~{file} | head -n 1 | cut -d@ -f2- |cut -d. -f1 
    >>>

    output {
        String name = read_string(stdout())
    }

    parameter_meta {
        file: "Reads file in FASTQ format."
    }

    runtime {
        container: "ubuntu:xenial"
        cpu: 1
        memory: "1024 MB"
    }
}

task fasta {

    input {
        File file
    }

    command <<< 
        set -e
        cat ~{file} | head -n 1 | cut -d'>' -f2
    >>>

    output {
        String name = read_string(stdout())
    }

    parameter_meta {
        file: "Reads file in FASTA format."
    }

    runtime {
        container: "ubuntu:xenial"
        cpu: 1
        memory: "1024 MB"
    }


}