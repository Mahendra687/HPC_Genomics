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

## `SLURM` Batch Script

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
### Write a script to run `FastQC` from the Project directory:
```bash
#!/bin/bash
#SBATCH --job-name=fastqc_analysis         # Job name
#SBATCH --output=output_%j.txt             # Standard output log (%j = Job ID)
#SBATCH --error=error_%j.txt               # Standard error log
#SBATCH --partition=gpu_scholar            # Partition/queue name
#SBATCH --nodes=1                          # Number of nodes
#SBATCH --ntasks=1                         # Number of tasks
#SBATCH --cpus-per-task=4                  # CPUs per task
#SBATCH --mem=4G                           # Memory per node
#SBATCH --time=01:00:00                    # Time limit
#SBATCH --mail-user=user@email.com         # User email for notifications
#SBATCH --mail-type=END,FAIL               # Notify on job end/fail

# Load the FastQC module
module load FastQCv0.12.1

# Define directories
INPUT_DIR=/dgxb_home/se24plsc006/project/dataset
OUTPUT_DIR=/dgxb_home/se24plsc006/project/results/output

# Create the output directory if it doesn't exist
mkdir -p $OUTPUT_DIR

# Run FastQC on the input files
echo "Running FastQC on input files from $INPUT_DIR..."
fastqc -o $OUTPUT_DIR $INPUT_DIR/SRR32066794_1.fastq $INPUT_DIR/SRR32066794_2.fastq

# Verify that output files are created
if [[ -f "$OUTPUT_DIR/SRR32066794_1_fastqc.zip" && -f "$OUTPUT_DIR/SRR32066794_2_fastqc.zip" ]]; then
  echo "FastQC analysis completed successfully. Output files are located in $OUTPUT_DIR."
else
  echo "Error: FastQC output files not found in $OUTPUT_DIR."
  exit 1
fi
```

### Write a script to run `FastQC` from input directory:

```bash
#!/bin/bash
#SBATCH --job-name=fastqc_analysis         # Job name
#SBATCH --output=output_%j.txt             # Standard output log (%j = Job ID)
#SBATCH --error=error_%j.txt               # Standard error log
#SBATCH --partition=gpu_scholar            # Partition/queue name
#SBATCH --nodes=1                          # Number of nodes
#SBATCH --ntasks=1                         # Number of tasks
#SBATCH --cpus-per-task=4                  # CPUs per task
#SBATCH --mem=4G                           # Memory per node
#SBATCH --time=01:00:00                    # Time limit
#SBATCH --mail-user=user@email.com         # User email for notifications
#SBATCH --mail-type=END,FAIL               # Notify on job end/fail

# Load the FastQC module
module load FastQCv0.12.1

# Define directories
INPUT_DIR=/dgxb_home/se24plsc006/dataset
OUTPUT_DIR=/dgxb_home/se24plsc006/output

# Create the output directory if it doesn't exist
mkdir -p $OUTPUT_DIR

# Run FastQC on the input files
echo "Running FastQC on input files from $INPUT_DIR..."
fastqc -o $OUTPUT_DIR $INPUT_DIR/SRR32066794_1.fastq $INPUT_DIR/SRR32066794_2.fastq

# Verify that output files are created
if [[ -f "$OUTPUT_DIR/SRR32066794_1_fastqc.zip" && -f "$OUTPUT_DIR/SRR32066794_2_fastqc.zip" ]]; then
  echo "FastQC analysis completed successfully. Output files are located in $OUTPUT_DIR."
else
  echo "Error: FastQC output files not found in $OUTPUT_DIR."
  exit 1
fi
```
### Write a script to run `FastQC` -help:

```bash
#!/bin/bash
#SBATCH --job-name=fastqc_help             # Job name
#SBATCH --output=fastqc_help_output.txt    # Output file
#SBATCH --error=fastqc_help_error.txt      # Error file
#SBATCH --partition=cpu_scholar           # Partition name
#SBATCH --nodes=1                         # Number of nodes
#SBATCH --ntasks=1                        # Number of tasks
#SBATCH --time=00:05:00                   # Time limit

# Load the required module
module load fastqc

# Print the help information for FastQC
fastqc --help
```

### Job Submission:
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
