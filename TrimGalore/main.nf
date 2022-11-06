#!/usr/bin/env nextflow

params.help = ""
params.read_pairs = ""
params.output = ""

params.threads = 4
params.max_n = 0
params.length = 50
params.quality = 25
params.stringency = 4

threads = params.threads
max_n = params.max_n
length = params.length
quality = params.quality
stringency = params.stringency


if(params.help) {
    log.info ''
    log.info 'TrimGalore Pipeline'
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

process RunQC {
    errorStrategy 'ignore'

    tag { sample_id }

    publishDir "${params.output}/RunQC", mode: 'move',
        saveAs: { filename ->
            if(filename.indexOf(".gz") > 0) "Paired/$filename"
            else if(filename.indexOf(".txt") > 0) "Log/$filename"
            else {}
        }
	
    input:
        set sample_id, file(forward), file(reverse) from reads

    output:
        file("*.fq.gz")
        file("*.txt")

    script:
    """
    trim_galore \
	-j ${threads} \
	--max_n ${max_n} \
	--length ${length} \
	--nextera \
	--quality ${quality} \
	--paired ${forward} ${reverse} \
	--stringency ${stringency} \
	--dont_gzip \
	--trim1 \
	--phred33

    pigz --fast *.fq	
    """
}
