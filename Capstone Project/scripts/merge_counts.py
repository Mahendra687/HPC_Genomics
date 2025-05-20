import pandas as pd
import glob
import sys

output_file = sys.argv[1]
files = glob.glob("output/counts/*.counts.txt")

dfs = []
for file in files:
    df = pd.read_csv(file, sep="\t", comment='#', skiprows=1, index_col=0)
    dfs.append(df.iloc[:, 5])  # column with read counts
merged = pd.concat(dfs, axis=1)
merged.columns = [f.split("/")[-1].split(".")[0] for f in files]
merged.to_csv(output_file, sep="\t")

