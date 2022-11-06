#!/usr/bin/env nextflow

params.help = ""
params.fastq = ""
params.threads = 1
params.output = ""

params.nucleotide = ""  // path to Chocophlan database
params.protein = ""     // path to uniref database

threads = params.threads

if(params.help) {
    log.info ''
    log.info 'Humann3 Pipeline'
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

process RunHumann3 {
    errorStrategy 'ignore'

    tag { sample_id }

    publishDir "${params.output}/Humann3", mode: 'move',
        saveAs: { filename ->
            if(filename.indexOf("genefamilies.tsv") > 0) "GeneFamilies/$filename"
            else if(filename.indexOf("pathabundance.tsv") > 0) "PathAbundance/$filename"
	    else if(filename.indexOf("pathcoverage.tsv") > 0) "PathCoverage/$filename"
	    else if(filename.indexOf(".log") > 0) "Logs/$filename"
            else if(filename.indexOf("metaphlan_bugs_list.tsv") > 0) "Microbes/$filename"
            else {}
        }

	
    input:
        set sample_id, file(concatFastq) from reads

    output:
        set sample_id, file("*_genefamilies.tsv")
	set sample_id, file("*_pathabundance.tsv")
	set sample_id, file("*_pathcoverage.tsv")
	set sample_id, file("*.log")
	set sample_id, file("*_metaphlan_bugs_list.tsv")

    """
    humann3 								\
	--input ${concatFastq}						\
	--output "."							\
	--memory-use maximum						\
	--prescreen-threshold 0.01					\
	--nucleotide-database ${params.nucleotide}			\
	--protein-database ${params.protein}				\
	--threads ${threads}

    mv */*.log .
    mv */*_metaphlan_bugs_list.tsv .   
    """
}
