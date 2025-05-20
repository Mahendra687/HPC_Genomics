rule trim_reads:
    input:
        "data/{srr_id}.fastq.gz"
    output:
        fastq = "output/trimmed/{srr_id}_trimmed.fastq.gz",
        json = "output/trimmed/{srr_id}_fastp.json",
        html = "output/trimmed/{srr_id}_fastp.html"
    conda:
        "../envs/fastp.yml"
    shell:
        """
        fastp -i {input} -o {output.fastq} \
              --json {output.json} --html {output.html} \
              --trim_poly_g --cut_tail --cut_window_size 4 \
              --cut_mean_quality 20 --length_required 30 -w 4
        """
