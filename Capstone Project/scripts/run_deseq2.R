args <- commandArgs(trailingOnly=TRUE)
counts_file <- args[1]
metadata_file <- args[2]
output_file <- args[3]

library(DESeq2)

# Load data
counts <- read.table(counts_file, header=TRUE, row.names=1, sep="\t", check.names=FALSE)
metadata <- read.csv(metadata_file, row.names=1)

# Ensure columns in counts match metadata rows
counts <- counts[, rownames(metadata)]

# Create DESeq2 dataset
dds <- DESeqDataSetFromMatrix(countData = counts,
                              colData = metadata,
                              design = ~ condition)  # Adjust to your actual condition column

# Run DESeq2
dds <- DESeq(dds)
res <- results(dds)

# Write results
write.csv(as.data.frame(res), file=output_file)
