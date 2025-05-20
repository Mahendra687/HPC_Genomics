# STAR Index Creation Rule
rule star_index:
    input:
        genome_fasta="ref/genome.fa",
        fai="ref/genome.fa.fai",
        dict="ref/genome.dict"
    output:
        index_dir=directory("ref/star_index")
    threads: 4
    conda:
        "../envs/star.yml"
    shell:
        """
        STAR --runMode genomeGenerate \
             --genomeDir {output.index_dir} \
             --genomeFastaFiles {input.genome_fasta} \
             --runThreadN {threads}
        """

# STAR Alignment Rule
rule star_align:
    input:
        index_dir="ref/star_index",
        trimmed_reads="output/trimmed/{srr_id}_trimmed.fastq.gz"
    output:
        bam="output/aligned/{srr_id}.unsorted.bam"
    threads: 4
    conda:
        "../envs/star.yml"
    shell:
        """
        STAR --genomeDir {input.index_dir} \
             --readFilesIn {input.trimmed_reads} \
             --readFilesCommand zcat \
             --runThreadN {threads} \
             --outSAMtype BAM Unsorted \
             --limitBAMsortRAM 5000000000 \
             --outBAMsortingThreadN 2 \
             --outFileNamePrefix output/aligned/{wildcards.srr_id}_

        mv output/aligned/{wildcards.srr_id}_Aligned.out.bam {output.bam}
        """

# BAM Sorting and Indexing Rule
rule sort_index_bam:
    input:
        "output/aligned/{srr_id}.unsorted.bam"
    output:
        sorted="output/aligned/{srr_id}.sorted.bam",
        bai="output/aligned/{srr_id}.sorted.bam.bai"
    conda:
        "../envs/samtools.yml"
    shell:
        """
        samtools sort -@ 4 -m 2G {input} -o {output.sorted}
        samtools index {output.sorted}
        """

# Add Read Groups Rule (no internal indexing)
rule add_read_groups:
    input:
        bam="output/aligned/{srr_id}.sorted.bam",
        bai="output/aligned/{srr_id}.sorted.bam.bai"
    output:
        bam="output/aligned/{srr_id}.rg.bam"
    conda:
        "../envs/picard.yml"
    shell:
        """
        picard AddOrReplaceReadGroups \
            I={input.bam} \
            O={output.bam} \
            RGID={wildcards.srr_id} \
            RGLB=lib1 \
            RGPL=ILLUMINA \
            RGPU=unit1 \
            RGSM={wildcards.srr_id} \
            VALIDATION_STRINGENCY=SILENT
        """

# Explicit BAM Indexing Rule for RG BAM
rule index_rg_bam:
    input:
        "output/aligned/{srr_id}.rg.bam"
    output:
        "output/aligned/{srr_id}.rg.bam.bai"
    conda:
        "../envs/samtools.yml"
    shell:
        """
        samtools index {input}
        """

# GATK Variant Calling Rule
rule gatk_variant_calling:
    input:
        bam="output/aligned/{srr_id}.rg.bam",
        bai="output/aligned/{srr_id}.rg.bam.bai",
        ref="ref/genome.fa",
        fai="ref/genome.fa.fai",
        dict="ref/genome.dict"
    output:
        vcf="output/variants/{srr_id}.vcf"
    conda:
        "../envs/gatk.yml"
    shell:
        """
        gatk HaplotypeCaller \
            -R {input.ref} \
            -I {input.bam} \
            -O {output.vcf} \
            --dont-use-soft-clipped-bases \
            --standard-min-confidence-threshold-for-calling 20
        """
