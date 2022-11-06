#!/usr/bin/env nextflow

params.help = ""
params.read_pairs = ""
params.threads = 1
params.output = ""
params.db = "" // path to metaphlan marker-gene database


threads = params.threads

if(params.help) {
    log.info ''
    log.info 'Metaphlan3 Pipeline'
    log.info ''
    log.info 'Usage: '
    log.info '    nextflow run . -profile template [options]'
    log.info ''
    log.info 'Script Options: '
    log.info '    --reads_pairs		DIR	Path to FASTQ files'
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

process RunMetaphlan3 {
    errorStrategy 'ignore'

    tag { sample_id }

    publishDir "${params.output}/RunMetaphlan3", mode: 'move'
	
    input:
        set sample_id, file(forward), file(reverse) from reads

    output:
        set sample_id, file("${sample_id}.bz2")
	set sample_id, file("${sample_id}.metagenome.txt") 

    script:
    """
    metaphlan 				\
	${forward},${reverse}           \
	--input_type fastq 		\
	--bowtie2out ${sample_id}.bz2 	\
	--add_viruses 			\
	--nproc ${threads}		\
	--bowtie2db ${params.db}	\
	-o ${sample_id}.metagenome.txt

    metaphlan ${sample_id}.bz2 --nproc 5 --input_type bowtie2out --add_viruses -o ${sample_id}.metagenome.txt
    """
}

