#!/usr/bin/env nextflow

params.help = ""
params.read_pairs = ""
params.threads = 1
params.output = ""
params.background = "" // path to kraken2 database

threads = params.threads

if(params.help) {
    log.info ''
    log.info 'Kraken2 Pipeline'
    log.info ''
    log.info 'Usage: '
    log.info '    nextflow run . -profile template [options]'
    log.info ''
    log.info 'Script Options: '
    log.info '    --read_pairs		DIR	Path to FASTQ files'
    log.info '    --threads		INT	Number of threads to use'
    log.info '    --output		DIR	Directory to write output files'
    log.info '    --help		BOOL	Display help message'
    log.info ''

    return
}

Channel
    .fromFilePairs(params.read_pairs, flat: true)
    .ifEmpty { exit 1, "Read pairs could not be found: ${params.read_pairs}" }
    .into { reads }

process RunKraken {
    errorStrategy 'ignore'

    tag { sample_id }

    publishDir "${params.output}/Kraken2", mode: 'move'
	
    input:
        set sample_id, file(forward), file(reverse) from reads

    output:
        set sample_id, file("${sample_id}_C_1.fq.gz"), file("${sample_id}_C_2.fq.gz")
	set sample_id, file("${sample_id}_U_1.fq.gz"), file("${sample_id}_U_2.fq.gz")
	set sample_id, file("${sample_id}.report.txt")

    """
    kraken2 --db ${params.background} \
	--use-names \
	--paired \
	--classified-out ${sample_id}_C#.fq \
	--unclassified-out ${sample_id}_U#.fq ${forward} ${reverse} \
	--threads ${threads} \
	--report ${sample_id}.report.txt

    pigz --fast -p ${threads} *.fq
    """
}
