rule fastqc:
    input:
        "data/{srr_id}.fastq.gz"
    output:
        html = "output/fastqc/{srr_id}_fastqc.html",
        zip = "output/fastqc/{srr_id}_fastqc.zip"
    conda:
        "../envs/qc.yml"
    shell:
        """
        fastqc {input} --outdir output/fastqc
        """

rule multiqc:
    input:
        expand("output/fastqc/{srr_id}_fastqc.zip", srr_id=SAMPLE_IDS)
    output:
        "output/fastqc/multiqc_report.html"
    conda:
        "../envs/qc.yml"
    shell:
        """
        multiqc output/fastqc --outdir output/fastqc
        """
rule multiqc_fastp:
    input:
        expand("output/trimmed/{srr_id}_fastp.json", srr_id=SAMPLE_IDS)
    output:
        "output/trimmed/multiqc_report.html"
    conda:
        "../envs/qc.yml"
    shell:
        """
        multiqc output/trimmed --outdir output/trimmed
        """

