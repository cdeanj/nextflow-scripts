#!/usr/bin/env nextflow

params.help = ""
params.read_pairs = ""
params.threads = 1
params.output = ""
params.trimmomatic = "" // path to Trimmomatic jar file
trimmomatic = params.trimmomatic
params.adapters = "$baseDir/adapters/adapters.fa"
adapters = params.adapters

params.leading = "3"
params.trailing = "3"
leading = params.leading
trailing = params.trailing
params.slidingwindow = "4:25"
slidingwindow = params.slidingwindow
params.minlen = 50
minlen = params.minlen

threads = params.threads

if(params.help) {
    log.info ''
    log.info 'Trimmomatic Pipeline'
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

    publishDir "${params.output}/RunQC", mode: 'copy', pattern: '*.fastq',
        saveAs: { filename ->
            if(filename.indexOf("P.fastq") > 0) "Paired/$filename"
            else if(filename.indexOf("U.fastq") > 0) "Unpaired/$filename"
            else if(filename.indexOf(".log") > 0) "Log/$filename"
            else {}
        }
	
    input:
        set sample_id, file(forward), file(reverse) from reads

    output:
        set sample_id, file("${sample_id}.1P.fastq"), file("${sample_id}.2P.fastq") into (paired_fastq)
        set sample_id, file("${sample_id}.1U.fastq"), file("${sample_id}.2U.fastq") into (unpaired_fastq)
        file("${sample_id}.trimmomatic.stats.log") into (trimmomatic_stats)

    """
    java -jar ${trimmomatic}/trimmomatic-0.38.jar \
      PE \
      -threads ${threads} \
      $forward $reverse -baseout ${sample_id} \
      ILLUMINACLIP:${adapters}:2:30:10:8:TRUE \
      LEADING:${leading} \
      TRAILING:${trailing} \
      SLIDINGWINDOW:${slidingwindow} \
      MINLEN:${minlen} \
      2> ${sample_id}.trimmomatic.stats.log

    mv ${sample_id}_1P ${sample_id}.1P.fastq
    mv ${sample_id}_2P ${sample_id}.2P.fastq
    mv ${sample_id}_1U ${sample_id}.1U.fastq
    mv ${sample_id}_2U ${sample_id}.2U.fastq
    """
}
