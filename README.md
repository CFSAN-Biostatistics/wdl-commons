# FDA-HFP Division of Surveillance & Data Integration WDL Library

## Collection of utility WDL modules from the FDA Human Foods Program (CFSAN) DSDI Signal Detection and Bioinformatics branch.

---

## Importing

Typically you will import the tasks defined here into your own WDL workflows:

`import https://github.com/CFSAN-Biostatistics/wdl-modules/raw/main/nanopore.wdl" as nanopore`

and then use them in workflows:

`call nanopore.assemble { fastq:my_reads }`

WDL runners will collect these files as imports; there's not a reason to clone the repository unless you'd like to develop and submit additional tasks to the libraries. If that's something you'd like to do, please see [CONTRIBUTING.rst](CONTRIBUTING) to get started.

## Usage

`$ make help`

