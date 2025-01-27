process FGBIO_GROUPREADSBYUMI {
    tag "$meta.id"
    label 'process_low'

    conda (params.enable_conda ? "bioconda::fgbio=1.4.0" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/fgbio:1.4.0--hdfd78af_0' :
        'quay.io/biocontainers/fgbio:1.4.0--hdfd78af_0' }"

    input:
    tuple val(meta), path(taggedbam)
    val(strategy)

    output:
    tuple val(meta), path("*_umi-grouped.bam")  , emit: bam
    tuple val(meta), path("*_umi_histogram.txt"), emit: histogram
    path "versions.yml"                         , emit: versions

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    mkdir tmp

    fgbio \\
        --tmp-dir=${PWD}/tmp \\
        GroupReadsByUmi \\
        -s $strategy \\
        $args \\
        -i $taggedbam \\
        -o ${prefix}_umi-grouped.bam \\
        -f ${prefix}_umi_histogram.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        fgbio: \$( echo \$(fgbio --version 2>&1 | tr -d '[:cntrl:]' ) | sed -e 's/^.*Version: //;s/\\[.*\$//')
    END_VERSIONS
    """
}
