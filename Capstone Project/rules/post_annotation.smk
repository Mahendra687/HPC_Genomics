rule snpsift_filter_high_moderate:
    input:
        vcf="output/annotated_variants/{srr_id}.annotated.vcf"
    output:
        vcf_filtered="output/annotated_variants/{srr_id}.filtered.vcf"
    params:
        expr="(ANN[].IMPACT = 'HIGH') | (ANN[].IMPACT = 'MODERATE')"  # Fixed quotes
    conda:
        "../envs/snpeff.yml"
    shell:
        """
        SnpSift filter "{params.expr}" {input.vcf} > {output.vcf_filtered}
        """

rule summarize_variant_impacts:
    input:
        expand("output/annotated_variants/{srr_id}.filtered.vcf", srr_id=SAMPLE_IDS)
    output:
        "output/summary/variant_impact_counts.csv"
    shell:
        """
        mkdir -p output/summary
        echo "Sample,IMPACT,Count" > {output}
        for vcf in {input}; do
            SAMPLE=$(basename "$vcf" .filtered.vcf)
            for impact in HIGH MODERATE LOW MODIFIER; do
                # Count using proper VCF annotation parsing
                COUNT=$(grep -v '^#' "$vcf" | \
                        grep "ANN=" | \
                        grep -c "|$impact|" || true)
                echo "$SAMPLE,$impact,$COUNT" >> {output}
            done
        done
        """

rule variant_annotation_report:
    input:
        csv = "output/summary/variant_impact_counts.csv",
        rmd = "scripts/variant_report.Rmd"
    output:
        html = "output/summary/variant_annotation_report.html",
        plot_dir = directory("output/summary/plots")
    conda:
        "../envs/r_env.yml"
    shell:
        """
        mkdir -p {output.plot_dir}
        Rscript scripts/plot_variant_impacts.R {input.csv} {output.html}
        """

