# File: scripts/run_deseq2_analysis.py

import pandas as pd
from pydeseq2.dds import DeseqDataSet
from pydeseq2.ds import DeseqStats

# === Load counts matrix ===
counts_df = pd.read_csv(snakemake.input.counts, sep="\t", index_col=0)

# === Remove summary rows ===
counts_df = counts_df[~counts_df.index.str.startswith("__")]

# === Metadata (real sample annotations) ===
df = pd.DataFrame({
    'SRR_ID': ["SRR087416", "SRR085471", "SRR085473", "SRR085474", "SRR085726", "SRR085725"],
    'Sample': [
        "Alzheimer's whole brain",
        "Normal brain, temporal lobe",
        "Alzheimer's brain, temporal lobe",
        "Normal brain, frontal lobe",
        "Alzheimer's brain, frontal lobe",
        "Normal whole brain"
    ]
})
df["condition"] = df["Sample"].apply(lambda x: "AD" if "Alzheimer" in x else "Normal")
df = df.set_index("SRR_ID")
df = df.loc[counts_df.columns]  # align metadata order

# === Run DESeq2 ===
dds = DeseqDataSet(
    counts=counts_df.T,
    clinical=df,
    design_factors="condition",
    ref_level="Normal"
)
dds.deseq2()

# === Statistics ===
stat_res = DeseqStats(dds)
stat_res.summary()

# === Export results ===
stat_res.results_df.sort_values("padj").to_csv(snakemake.output.results)
dds.norm_counts.to_csv(snakemake.output.norm_counts)
