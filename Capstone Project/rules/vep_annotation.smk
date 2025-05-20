rule annotate_variants_vep:
    input:
        vcf = "output/variants/{srr_id}.vcf",
        # Add reference genome as it's needed for accurate annotation
        fasta = "ref/genome.fa"
    output:
        annotated_vcf = "output/annotated_variants/{srr_id}.vep.vcf"
    conda:
        "../envs/vep.yml"
    threads: 4
    shell:
        """
        mkdir -p output/annotated_variants
        vep \
            --input_file {input.vcf} \
            --output_file {output.annotated_vcf} \
            --vcf \
            --offline \
            --cache \
            --dir_cache /dgxb_home/se24plsc006/.vep \  # Explicit cache location
            --fasta {input.fasta} \  # Reference genome
            --species homo_sapiens \
            --assembly GRCh38 \
            --no_stats \
            --fork {threads}
        """
