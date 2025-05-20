rule snpeff_annotate_bcftools:
    input:
        vcf="output/variants_bcftools/{srr_id}.bcftools.vcf"
    output:
        vcf_annotated="output/annotated_bcftools/{srr_id}.annotated.vcf"
    params:
        genome="GRCh38.p13"
    conda:
        "envs/snpeff_java21.yml"
    shell:
        """
        mkdir -p output/annotated_bcftools
        java -Xmx4g -jar snpEff/snpEff.jar {params.genome} {input.vcf} > {output.vcf_annotated}
        """

rule snpsift_filter_bcftools:
    input:
        vcf_annotated="output/annotated_bcftools/{srr_id}.annotated.vcf"
    output:
        vcf_filtered="output/annotated_bcftools/{srr_id}.filtered.vcf"
    conda:
        "envs/snpeff_java21.yml"
    shell:
        """
        java -Xmx4g -jar snpEff/SnpSift.jar filter "(ANN[0].IMPACT = 'HIGH') | (ANN[0].IMPACT = 'MODERATE')" {input.vcf_annotated} > {output.vcf_filtered}
        """

rule summarize_variant_function:
    input:
        vcfs=expand("output/annotated_bcftools/{srr_id}.filtered.vcf", srr_id=SAMPLE_IDS)
    output:
        "output/annotated_bcftools/variant_function_counts.csv"
    shell:
        """
        echo "Sample,Annotation_Impact,Count" > {output}
        for f in {input.vcfs}; do
            SAMPLE=$(basename $f .filtered.vcf)
            grep -v '^#' $f | grep "ANN=" | \
            sed 's/.*ANN=//' | tr ',' '\n' | cut -d'|' -f3 | \
            sort | uniq -c | awk -v srr="$SAMPLE" '{{print srr","$2","$1}}' >> {output}
        done
        """
