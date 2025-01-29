# FastQC Array Job Script

This is a SLURM batch script to run FastQC on multiple samples using an array job.

## Script Overview

- **Job name**: fastqc_array_job
- **Output file**: `output_%A_%a.txt` (includes the array job ID and task ID)
- **Error file**: `error_%A_%a.txt`
- **Partition**: `cpu_student`
- **Array**: 2 tasks for 2 samples (range: 0-1)
- **CPUs per task**: 1
- **Memory per task**: 2GB
- **Max runtime**: 30 minutes

## SLURM Batch Script

```bash
#!/bin/bash
#SBATCH --job-name=fastqc_array_job    # Job name
#SBATCH --output=output_%A_%a.txt      # Output file (%A = array job ID, %a = task ID)
#SBATCH --error=error_%A_%a.txt        # Error file
#SBATCH --partition=cpu_student        # Partition/queue
#SBATCH --array=0-1                    # Array range (2 tasks for 2 samples)
#SBATCH --ntasks=1                     # Number of tasks per array job
#SBATCH --cpus-per-task=1              # CPUs per task
#SBATCH --mem=2G                       # Memory per task
#SBATCH --time=00:30:00                # Max runtime (30 minutes)

# Load the FastQC module
module load FastQCv0.12.1

# Move to the project directory
cd ~/project

# Extract sample name from the text file samples.txt
samplename=$(sed -n -e "$((SLURM_ARRAY_TASK_ID + 1))p" samples/samples.txt)

# Create output directory if it does not exist
mkdir -p results/fastqc_results_Jan2025

# Run FastQC on the corresponding sample
fastqc dataset/${samplename}.fastq --outdir=results/fastqc_results_Jan2025

```

```bash

#To submit the job as follows:
sbatch script.sh
#And verify job status using:
squeue -u $USER
#Check Output Logs: Once the job completes, check the output and error logs:
ls -l output_1428_*.txt   # Output logs  
ls -l error_1428_*.txt    # Error logs (if any)
#Check If FastQC Completed Successfully: After the jobs 14282_0 and 14282_1 finish, check the output:
ls -l ~/project/results/fastqc_results_Jan2025/
#Check Output & Error Logs:
cat output_14282_0.txt   # Log for first sample
cat output_14282_1.txt   # Log for second sample
cat error_14282_0.txt    # Check for any errors
cat error_14282_1.txt
```
