# Rule to download and build the snpEff database for GRCh38.105
rule download_snpeff_db:
    output:
        "ref/snpeff_data/GRCh38.105/snpEffectPredictor.bin"
    conda:
        "../envs/snpeff.yml"
    shell:
        """
        mkdir -p ref/snpeff_data
        snpEff -download -dataDir ref/snpeff_data GRCh38.105
        test -f {output} || exit 1
        """

# Rule to annotate VCF files using snpEff
rule annotate_variants:
    input:
        vcf = "output/variants/{srr_id}.vcf",
        db = "ref/snpeff_data/GRCh38.105/snpEffectPredictor.bin"
    output:
        annotated_vcf = "output/annotated_variants/{srr_id}.annotated.vcf"
    conda:
        "../envs/snpeff.yml"
    resources:
        mem_mb = 32768  # 32 GB per job
    shell:
        """
        export JAVA_TOOL_OPTIONS="-Xmx24g -Xms8g -XX:ParallelGCThreads=2"
        snpEff -c ref/snpeff_data/snpEff.config \
               -dataDir ref/snpeff_data \
               GRCh38.105 {input.vcf} > {output.annotated_vcf}
        """
