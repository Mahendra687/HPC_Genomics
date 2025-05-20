rule index_reference:
    input:
        "ref/genome.fa"
    output:
        faidx="ref/genome.fa.fai",
        dict="ref/genome.dict"
    conda:
        "../envs/gatk.yml"  # Use GATK environment instead of samtools
    shell:
        """
        samtools faidx {input}
        gatk --java-options "-Xmx4G" CreateSequenceDictionary \
            -R {input} \
            -O {output.dict}
        """
