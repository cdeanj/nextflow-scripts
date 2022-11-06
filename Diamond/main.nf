#!/usr/bin/env nextflow

params.help = ""
params.fastq = ""
params.threads = 1
params.output = ""
params.db = ""


threads = params.threads

if(params.help) {
    log.info ''
    log.info 'Diamond Pipeline'
    log.info ''
    log.info 'Usage: '
    log.info '    nextflow run . -profile template [options]'
    log.info ''
    log.info 'Script Options: '
    log.info '    --fastq		DIR	Path to FASTQ files'
    log.info '    --threads		INT	Number of threads to use'
    log.info '    --output		DIR	Directory to write output files'
    log.info '    --help		BOOL	Display help message'
    log.info ''

    return
}

reads = Channel
        .fromPath(params.fastq)
        .map { file -> tuple(file.baseName, file) }

process RunDiamond {
    errorStrategy 'ignore'

    tag { sample_id }

    publishDir "${params.output}/RunDiamond", mode: 'move'
	
    input:
	set sample_id, file(concatFastq) from reads

    output:
        set sample_id, file("${sample_id}.tsv")

    script:
    """
    diamond 				\
	blastx				\
	-p ${threads}			\
	--db ${params.db}		\
	-k 1				\
	-b 6				\
	-c 1				\
	-q ${concatFastq}		\
	--out ${sample_id}.tsv
    """
}
