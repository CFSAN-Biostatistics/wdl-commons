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

version 1.1

task interleave {
    input {
        File forward
        File reverse
    }

    command <<<
        paste ~{forward} ~{reverse} | paste - - - - | awk -v OFS="\n" -v FS="\t" '{print($1,$3,$5,$7,$2,$4,$6,$8)}' > reads
    >>>

    output {
        File reads = "reads"
    }

    runtime {
        container: "ubuntu:xenial"
        cpu: 1
        memory: "1024 MB"
    }
}

task deinterleave {
    input {
        File reads
    }

    command <<<
        cat ~{reads} | paste - - - - - - - -  | tee >(cut -f 1-4 | tr "\t" "\n" > forward ) | cut -f 5-8 | tr "\t" "\n" > reverse
    >>>

    output {
        File forward = "forward"
        File reverse = "reverse"
    }

    runtime {
        container: "ubuntu:xenial"
        cpu: 1
        memory: "1024 MB"
    }
}