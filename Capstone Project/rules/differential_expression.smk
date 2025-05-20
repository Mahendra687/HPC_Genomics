# File: rules/differential_expression.smk

rule run_deseq2_analysis:
    input:
        counts="output/counts/merged_counts.txt"
    output:
        results="output/deseq2_results.csv",
        norm_counts="output/normalized_counts.csv"
    conda:
        "../envs/python.yml"
    script:
        "scripts/run_deseq2_analysis.py"

