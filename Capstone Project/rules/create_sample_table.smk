rule create_sample_table:
    output:
        "config/sample_metadata.csv"
    conda:
        "../envs/sample_table.yml"
    script:
        "../scripts/create_sample_table.py"
