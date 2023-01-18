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

task calculateN50 {

    input {
        File assembly
    }

    command <<<
        seqtk comp ~{assembly} | cut -f 2 | sort -rn | awk '{ sum += $0; print $0, sum }' | tac | awk 'NR==1 { halftot=$2/2 } lastsize>halftot && $2<halftot { print $1 } { lastsize=$2 }'
    >>>

    output {
        Int n50 = read_int(stdout())
    }

    runtime {
        container: "staphb/seqtk:latest"
        cpu: 1
        memory: "512 MB"
    }

    parameter_meta {
        assembly: "Assembly in FASTA format."
    }
}