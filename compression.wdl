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

task fromgz {

    input {
        File in
    }

    command <<<
        gzip -cd ~{in}
    >>>

    output {
        File out = stdout()
    }

    parameter_meta {
        in: "File in GZIP format."
    }

    runtime {
        container: "ubuntu:focal"
        cpu: 1
        memory: "1024 MB"
    }
}


task togz {

    input {
        File in
    }

    command <<<
        gzip -c ~{in}
    >>>

    output {
        File out = stdout()
    }

    parameter_meta {
        in: "A file to compress."
    }

    runtime {
        container: "ubuntu:focal"
        cpu: 1
        memory: "1024 MB"
    }
}

task fromzstd {

    input {
        File in
    }

    command <<<
        zstd -d ~{in} -c
    >>>

    output {
        File out = stdout()
    }

    parameter_meta {
        in: "File in ZSTD format."
    }

    runtime {
        container: "biocontainers/zstd:v1.3.8dfsg-3-deb_cv1"
        cpu: 1
        memory: "1024 MB"
    }
}

task tozstd {

    input {
        File in
        Int compression = 15
    }

    command <<<
        zstd -~{compression} ~{in} -c
    >>>

    output {
        File out = stdout()
    }

    parameter_meta {
        in: "A file to compress."
        compression: "Compression level (1-19)."
    }

    runtime {
        container: "biocontainers/zstd:v1.3.8dfsg-3-deb_cv1"
        cpu: 8
        memory: "1024 MB"
    }
}

task untar {

    input {
        File in
        String flags = "xavf"
    }

    command <<<
        tar -~{flags} ~{in} -C ./out
    >>>

    output {
        Array[File] files = glob("./out/*")
    }

    parameter_meta {
        in: "File in TAR format."
        flags: "tar flags."
    }

    runtime {
        container: "ubuntu:focal"
        cpu: 1
        memory: "1024 MB"
    }

}

task tar {
    input {
        Array[File]+ files
        String flags = "czvf"
        String name = "archive"
        String suffix = "tar.gz"
    }

    command <<<
        tar -~{flags} ~{name}.~{suffix} ~{sep(' ', files)}
    >>>

    output {
        File archive = "~{name}.~{suffix}"
    }

    parameter_meta {
        files: "Files to archive."
        flags: "tar flags."
        name: "Name of the archive."
        suffix: "Archive suffix."
    }

    runtime {
        container: "ubuntu:focal"
        cpu: 1
        memory: "1024 MB"
    }
}