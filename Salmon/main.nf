#!/usr/bin/env nextflow

params.help = ""
params.read_pairs = ""
params.threads = 1
params.output = ""
params.index = "" // path to Salmon index

threads = params.threads
index = params.index

if(params.help) {
    log.info ''
    log.info 'Salmon Pipeline'
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

process RunQC {
    errorStrategy 'ignore'

    tag { sample_id }

    publishDir "${params.output}/Quant", mode: 'move', pattern: '*.sf'
	
    input:
        set sample_id, file(forward), file(reverse) from reads

    output:
        set sample_id, file("${sample_id}.quant.sf")

    """
    salmon quant -i ${index} -l A \
        -1 ${forward} \
        -2 ${reverse} \
        -p ${threads} \
        --validateMappings \
        -o quants/${sample_id}_quant

    mv quants/${sample_id}_quant/quant.sf ${sample_id}.quant.sf   
    """
}
