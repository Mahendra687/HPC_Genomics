```bash
#!/bin/bash
#SBATCH -J rna-seq
#SBATCH -N 1
#SBATCH --cpus-per-task=8
#SBATCH --mem=120G
#SBATCH --time=24:00:00
#SBATCH --partition=gpu_scholar
#SBATCH --output=logs/snakemake_run.out
#SBATCH --error=logs/snakemake_run.err

module load mamba
source activate RNA_ANALYSIS

snakemake --use-conda --cores 4 --conda-frontend mamba -p
```

### Run the job
```bash
sbatch run_snake.slurm
```
