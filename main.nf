#!/usr/bin/env nextflow

log.info ""
log.info "SRR Download "
log.info "======================"
log.info "input      : ${params.input}"
log.info "resultsDir : ${params.resultsDir}"
log.info "sample     : ${params.sample}"
log.info "======================"
log.info ""

Channel
    .fromPath( params.input )
    .splitCsv(sep: '\t', header: true)
    .map { it.Run_s }
    .set { srrFiles }


process fetch {

    tag { srr }

    publishDir path: "${params.resultsDir}/reads",
               mode: 'copy',
               saveAs: { filename -> filename.replaceFirst(/_pass/, '') }

    input:
    val(srr) from srrFiles

    output:
    file('*.fastq.gz') into fetchedFiles

    script:
    flag_sample = params.sample ? "-X ${params.sample}" : ''

    """
    fastq-dump \
        ${flag_sample} \
        --gzip \
        --skip-technical  \
        --readids \
        --read-filter pass \
        --dumpbase \
        --split-files \
        --clip \
        ${srr}
    """
}
