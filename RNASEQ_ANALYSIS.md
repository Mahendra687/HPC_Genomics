RNA-Seq Analysis Environment Setup

```bash
# Step 1: Install Miniconda3
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
# Run the Installer:Execute the installer and follow the prompts:
bash Miniconda3-latest-Linux-x86_64.sh
# Activate Conda:After installation, reload your shell to enable Conda:
source ~/.bashrc
# Verify Installation:Check the Conda version to confirm successful installation:
conda --version
# Step 2: Create the RNA_ANALYSIS Environment
conda create -n RNA_ANALYSIS python=3.10
# Activate the Environment: Activate the RNA_ANALYSIS environment:
conda activate RNA_ANALYSIS
# Step 3: Install Mamba
conda install -y -c conda-forge mamba
# Verify Installation:Check the mamba version:
mamba --version
# Step 4: Install Snakemake
mamba install -y -c bioconda snakemake
# Verify Installation:Check the snakemake version:
snakemake --version

PERFECT:)
```
