#!/usr/bin/env nextflow

params.help = ""
params.read_pairs = ""
params.threads = 1
params.output = ""
params.gene = ""
params.gene_index = ""

gene = file(params.gene)

threads = params.threads

if(params.help) {
    log.info ''
    log.info 'Mapping Pipeline'
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

if( !params.gene_index ) {
    process BuildIndex {
        publishDir "${params.output}/BuildIndex", mode: "copy"

        tag { gene.baseName }

        input:
            file(gene)

        output:
            file '*' into (gene_index)

        """
        bwa index ${gene}
        """
    }
}

process RunMapping {
    errorStrategy 'ignore'

    tag { sample_id }

    publishDir "${params.output}/RunMapping", mode: 'copy', pattern: '*.bam'
	
    input:
        set sample_id, file(forward), file(reverse) from reads
        file index from gene_index
        file gene

    output:
        set sample_id, file("${sample_id}.sorted.bam") into (bams)

    """
    bwa mem ${gene} ${forward} ${reverse} -t ${threads} > ${sample_id}.sam
    samtools view -bS ${sample_id}.sam | samtools sort - ${sample_id}.sorted
    """
}

process RunFlagStat {
    errorStrategy 'ignore'

    publishDir "${params.output}/RunFlagStat", mode: 'copy', pattern: '*.txt'
    
    tag { sample_id }

    input:
        set sample_id, file(bam) from bams

    output:
        set sample_id, file("${sample_id}.flagstat.txt") into (flagstat)

    """
    samtools flagstat ${bam} > ${sample_id}.flagstat.txt
    """
}
