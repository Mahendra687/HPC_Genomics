rule bcftools_mpileup:
    input:
        bam="output/aligned/{srr_id}.sorted.bam",
        ref="ref/genome.fa"
    output:
        bcf="output/bcftools/{srr_id}.pileup.bcf"
    conda: "../envs/bcftools.yml"
    shell:
        """
        mkdir -p output/bcftools
        bcftools mpileup -Ou -f {input.ref} {input.bam} > {output.bcf}
        """

rule bcftools_call:
    input:
        bcf="output/bcftools/{srr_id}.pileup.bcf"
    output:
        bcf="output/bcftools/{srr_id}.call.bcf"
    conda: "../envs/bcftools.yml"
    shell:
        """
        bcftools call -mv -Ou -o {output.bcf} {input.bcf}
        """

rule bcftools_norm:
    input:
        bcf="output/bcftools/{srr_id}.call.bcf",
        ref="ref/genome.fa"
    output:
        bcf="output/bcftools/{srr_id}.norm.bcf"
    conda: "../envs/bcftools.yml"
    shell:
        """
        bcftools norm -f {input.ref} -Ou -o {output.bcf} {input.bcf}
        """

rule bcftools_filter:
    input:
        bcf="output/bcftools/{srr_id}.norm.bcf"
    output:
        vcf="output/bcftools/{srr_id}.filtered.vcf.gz"
    conda: "../envs/bcftools.yml"
    shell:
        """
        bcftools view {input.bcf} | \
        bcftools filter -e 'QUAL<20 || DP<10' -Oz -o {output.vcf}
        tabix {output.vcf}
        """

rule bcftools_stats:
    input:
        vcf="output/bcftools/{srr_id}.filtered.vcf.gz"
    output:
        stats="output/bcftools/{srr_id}.stats.txt"
    conda: "../envs/bcftools.yml"
    shell:
        """
        bcftools stats {input.vcf} > {output.stats}
        """

rule plot_vcfstats:
    input:
        stats="output/bcftools/{srr_id}.stats.txt"
    output:
        plots=directory("output/bcftools/{srr_id}.plots")
    conda: "../envs/bcftools.yml"
    shell:
        """
        mkdir -p {output.plots}
        plot-vcfstats -t HTML {input.stats} -p {output.plots}
        """

