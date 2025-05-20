import os
import re  # Added import for regex escaping

# Define absolute paths
ENVS_DIR = os.path.expanduser("~/envs")
SNPEFF_DIR = os.path.expanduser("~/snpEff")

# Chromosome mapping for RefSeq to chr names
CHR_MAP = {
    "NC_000001.11": "chr1",
    "NC_000002.12": "chr2",
    "NC_000003.12": "chr3",
    "NC_000004.12": "chr4",
    "NC_000005.10": "chr5",
    "NC_000006.12": "chr6",
    "NC_000007.14": "chr7",
    "NC_000008.11": "chr8",
    "NC_000009.12": "chr9",
    "NC_000010.11": "chr10",
    "NC_000011.10": "chr11",
    "NC_000012.12": "chr12",
    "NC_000013.11": "chr13",
    "NC_000014.9": "chr14",
    "NC_000015.10": "chr15",
    "NC_000016.10": "chr16",
    "NC_000017.11": "chr17",
    "NC_000018.10": "chr18",
    "NC_000019.10": "chr19",
    "NC_000020.11": "chr20",
    "NC_000021.9": "chr21",
    "NC_000022.11": "chr22",
    "NC_000023.11": "chrX",
    "NC_000024.10": "chrY",
    "NC_012920.1": "chrM"
}

rule annotate_bcftools_snpeff:
    input:
        vcf="output/variants_bcftools/{srr_id}.bcftools.vcf"
    output:
        vcf_annotated="output/annotated_bcftools/{srr_id}.bcftools.GRCh38p13.annotated.vcf"
    conda:
        os.path.join(ENVS_DIR, "snpeff_java21.yml")
    params:
        config=os.path.join(SNPEFF_DIR, "snpEff.config"),
        data_dir=os.path.join(SNPEFF_DIR, "data"),
        snpeff_jar=os.path.join(SNPEFF_DIR, "snpEff.jar"),
        # Use regex escape for chromosome names
        chr_map="; ".join([f"s/{re.escape(k)}/{v}/g" for k,v in CHR_MAP.items()])
    log:
        "logs/snpeff/{srr_id}.log"
    shell:
        """
        mkdir -p output/annotated_bcftools logs/snpeff
        sed '{params.chr_map}' {input.vcf} > tmp_renamed.vcf
        java -Xmx4g -jar {params.snpeff_jar} \
            -c {params.config} \
            -dataDir {params.data_dir} \
            GRCh38.p13 tmp_renamed.vcf > {output.vcf_annotated} 2> {log}
        rm tmp_renamed.vcf
        """

rule filter_snpeff_bcftools:
    input:
        vcf_annotated="output/annotated_bcftools/{srr_id}.bcftools.GRCh38p13.annotated.vcf"
    output:
        vcf_filtered="output/annotated_bcftools/{srr_id}.bcftools.GRCh38p13.filtered.vcf"
    conda:
        os.path.join(ENVS_DIR, "snpeff_java21.yml")
    params:
        snpsift_jar=os.path.join(SNPEFF_DIR, "SnpSift.jar")
    shell:
        """
        java -Xmx4g -jar {params.snpsift_jar} \
            filter 'exists(ANN) && !ANN.contains("ERROR_CHROMOSOME_NOT_FOUND")' \
            {input.vcf_annotated} > {output.vcf_filtered}
        """

rule summarize_bcftools_variant_impacts:
    input:
        vcf_files=expand("output/annotated_bcftools/{srr_id}.bcftools.GRCh38p13.filtered.vcf", srr_id=SAMPLE_IDS)
    output:
        summary="output/annotated_bcftools/variant_function_counts.csv"
    shell:
        r"""
        mkdir -p output/annotated_bcftools
        echo "Sample,Function,Impact,Count" > {output.summary}
        for f in {input.vcf_files}; do
            sample=$(basename "$f" .bcftools.GRCh38p13.filtered.vcf)
            if [ ! -s "$f" ]; then
                echo "Warning: Empty file $f" >&2
                continue
            fi
            {{
                grep -v "^#" "$f" | grep "ANN=" || true
            }} | sed 's/.*ANN=//' | tr ',' '\n' \
            | awk -F'|' 'NF >=4 {{print $2,$3}}' \
            | while read func impact; do
                [[ -z "$func" || -z "$impact" ]] && continue
                echo "$sample,$func,$impact"
            done | sort | uniq -c \
            | while read count line; do
                echo "$line,$count"
            done >> {output.summary}
        done
        """
