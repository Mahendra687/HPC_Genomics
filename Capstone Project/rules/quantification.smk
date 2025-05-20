rule download_gtf:
    output:
        "ref/genome.gtf.gz"
    shell:
        """
        wget -O {output} https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/001/405/GCF_000001405.40_GRCh38.p14/GCF_000001405.40_GRCh38.p14_genomic.gtf.gz
        """

rule featurecounts_quant:
    input:
        gtf="ref/genome.gtf.gz",
        bam="output/aligned/{srr_id}.sorted.bam"
    output:
        counts="output/counts/{srr_id}.counts.txt"
    threads: 4
    conda:
        "../envs/featurecounts.yml"
    shell:
        """
        mkdir -p output/counts
        featureCounts -T {threads} -a {input.gtf} -o {output.counts} {input.bam}
        """

rule merge_counts:
    input:
        expand("output/counts/{srr_id}.counts.txt", srr_id=SAMPLE_IDS)
    output:
        "output/counts/merged_counts.txt"
    conda:
        "../envs/python.yml"
    shell:
        """
        python scripts/merge_counts.py {output}
        """
