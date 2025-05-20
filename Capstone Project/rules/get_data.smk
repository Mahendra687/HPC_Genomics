rule prefetch_sra:
    output:
        "data/sra/{srr_id}/{srr_id}.sra"
    conda:
        "../envs/get_data.yml"
    shell:
        """
        prefetch {wildcards.srr_id} -O data/sra/
        """

rule extract_fastq:
    input:
        "data/sra/{srr_id}/{srr_id}.sra"
    output:
        "data/{srr_id}.fastq.gz"
    conda:
        "../envs/get_data.yml"
    shell:
        """
        fasterq-dump {input} -O data/tmp_{wildcards.srr_id}/
        gzip data/tmp_{wildcards.srr_id}/{wildcards.srr_id}.fastq
        mv data/tmp_{wildcards.srr_id}/{wildcards.srr_id}.fastq.gz {output}
        rm -r data/tmp_{wildcards.srr_id}
        """
