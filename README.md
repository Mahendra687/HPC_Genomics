### Assignment SLURM SCRIPT
```bash
#!/bin/bash
#SBATCH --job-name=RNA_Array                # Job name
#SBATCH --output=logs_job_%A_%a.out         # Output file (%A = array job ID, %a = task ID)
#SBATCH --error=logs_job_%A_%a.err          # Error file
#SBATCH --partition=cpu_scholar             # Partition/queue
#SBATCH --array=1-876                       # Array range (adjust based on the number of samples)
#SBATCH --ntasks=1                          # Number of tasks per array job
#SBATCH --cpus-per-task=2                   # CPUs per task
#SBATCH --mem=8G                            # Memory per task
#SBATCH --time=01:00:00                     # Max runtime (1 hour)
#SBATCH --mail-type=END,FAIL                # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=mahendras948@gmail.com  # Replace with your email

# Load Conda manually (fixes Conda activation issue)
eval "$(conda shell.bash hook)"
conda activate rna-seq

# Check Conda environment
echo "Active Conda Environment: $(conda info --envs | grep '*')"

# Define directories
DATA_DIR=~/assignment1/Mahindra/raw_data
REF_DIR=~/assignment1/Mahindra/ref
OUTPUT_DIR=~/assignment1/Mahindra/output
QC_DIR=$OUTPUT_DIR/QC
mkdir -p $OUTPUT_DIR/logs $QC_DIR

# Get sample names
SAMPLES=($(ls $DATA_DIR | awk -F'-' '{print $1}' | sort | uniq))
SAMPLE_NAME=${SAMPLES[$SLURM_ARRAY_TASK_ID - 1]}

# Define file names
R1="$DATA_DIR/${SAMPLE_NAME}-R1.fastq.gz"
R2="$DATA_DIR/${SAMPLE_NAME}-R2.fastq.gz"
OUT_DIR="$OUTPUT_DIR/$SAMPLE_NAME"
mkdir -p $OUT_DIR

echo "Processing sample: $SAMPLE_NAME"

# Step 1: Quality Control
fastqc -t 4 $R1 $R2 -o $QC_DIR

# Step 2: Trimming
TRIMMED_R1="$OUT_DIR/${SAMPLE_NAME}_trimmed_R1.fastq.gz"
TRIMMED_R2="$OUT_DIR/${SAMPLE_NAME}_trimmed_R2.fastq.gz"
trimmomatic PE -threads 4 $R1 $R2 $TRIMMED_R1 /dev/null $TRIMMED_R2 /dev/null SLIDINGWINDOW:4:20 MINLEN:36

# Step 3: Expression Quantification using Salmon
if [[ "$SAMPLE_NAME" == GRZ_* ]]; then
    REF="$REF_DIR/GRZ.fasta"
else
    REF="$REF_DIR/MZM.fasta"
fi

salmon quant -i $REF -l A -1 $TRIMMED_R1 -2 $TRIMMED_R2 -p 4 --validateMappings -o $OUT_DIR/salmon_output

# Step 4: MultiQC Report (Only Runs Once at the End)
if [[ $SLURM_ARRAY_TASK_ID -eq 1 ]]; then
    sleep 120
    multiqc $QC_DIR -o $OUTPUT_DIR/multiqc_report
    echo "MultiQC report generated!"
fi

echo "Sample $SAMPLE_NAME processing complete!"
```

### Installation of Micromamba, Snakemake, FastQC and MultiQC using Conda/Miniconda

**Package Installation**

* **`conda install micromamba -c conda-forge`**: Installs the `micromamba` package from the `conda-forge` channel using `conda`.
* **`micromamba install -n snakemake  -c conda-forge -c bioconda snakemake-minimal`**: Installs the `snakemake-minimal` package into a new environment named `snakemake` using `micromamba`, pulling from both the `conda-forge` and `bioconda` channels.
* **`micromamba create -n snakemake -c conda-forge -c bioconda snakemake-minimal`**: Creates a new conda environment named `snakemake` and installs the `snakemake-minimal` package using `micromamba` (this was necessary because the previous `install` command failed as the environment didn't exist).
* **`micromamba create -n fastqc bioconda::fastqc`**: Creates a new conda environment named `fastqc` and installs the `fastqc` package from the `bioconda` channel using `micromamba`.
* **`micromamba install multiqc -c conda-forge -c bioconda`**: Installs the `multiqc` package into the currently active environment using `micromamba`.


**Environment Management**

* **`conda activate snakemake`**:  Activates the `snakemake` conda environment. However, in this case, it seems the environment didn't exist yet.
* **`conda activate fastqc`**:  Activates the `fastqc` conda environment (also didn't exist in this case).
* **`micromamba activate snakemake`**: Activates the `snakemake` conda environment managed by `micromamba`.
* **`micromamba activate fastqc`**: Activates the `fastqc` conda environment managed by `micromamba`.
* **`conda deactivate`**: Deactivates the currently active conda environment.
* **`eval "$(micromamba shell hook --shell bash)"`**: Initializes the current bash shell for use with `micromamba`.
* **`micromamba shell init --shell bash --root-prefix=~/.local/share/mamba`**:  Configures `micromamba` to automatically manage environments in future bash sessions.
* **`source ~/.bashrc`**: Reloads the `~/.bashrc` file to apply the `micromamba` initialization.

### `SLURM` Array Job to Run Trimmomatic-0.39
```bash
#!/bin/bash
#SBATCH --job-name=trimmomatic_array_job  # Job name
#SBATCH --output=trimmomatic_job_%A_%a.out  # Output file (%A = array job ID, %a = task ID)
#SBATCH --error=trimmomatic_job_%A_%a.err   # Error file
#SBATCH --partition=gpu_scholar             # Partition/queue
#SBATCH --array=0-1                         # Array range (adjust based on the number of samples)
#SBATCH --ntasks=1                          # Number of tasks per array job
#SBATCH --cpus-per-task=2                   # CPUs per task
#SBATCH --mem=2G                            # Memory per task
#SBATCH --time=01:00:00                     # Max runtime (1 hour)
#SBATCH --mail-type=END,FAIL                # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=mahendras948@gmail.com  # Replace with your email

# Load the Trimmomatic module
module load Trimmomatic-0.39

# Define the path to the Trimmomatic JAR file
TRIMMOMATIC_JAR="/dgxa_home/shared_software/Trimmomatic-0.39/trimmomatic-0.39.jar"

# Define input and output directories
INPUT_DIR="/dgxb_home/se24plsc006/project/dataset"
OUTPUT_DIR="/dgxb_home/se24plsc006/project/results/trim_out"

# Create the output directory if it doesn't exist
mkdir -p $OUTPUT_DIR

# Extract sample name from the text file samples.txt
SAMPLENAME=$(sed -n "$((SLURM_ARRAY_TASK_ID + 1)) p" /dgxb_home/se24plsc006/project/samples/samples.txt)

# Define input files
INPUT_1="${INPUT_DIR}/${SAMPLENAME}_1.fastq"
INPUT_2="${INPUT_DIR}/${SAMPLENAME}_2.fastq"

# Define output files
OUTPUT_1="${OUTPUT_DIR}/${SAMPLENAME}_1_trimmed.fastq"
OUTPUT_2="${OUTPUT_DIR}/${SAMPLENAME}_2_trimmed.fastq"
OUTPUT_1_UNPAIRED="${OUTPUT_DIR}/${SAMPLENAME}_1_unpaired.fastq"
OUTPUT_2_UNPAIRED="${OUTPUT_DIR}/${SAMPLENAME}_2_unpaired.fastq"

# Run Trimmomatic
java -jar $TRIMMOMATIC_JAR PE \
    -threads $SLURM_CPUS_PER_TASK \
    $INPUT_1 $INPUT_2 \
    $OUTPUT_1 $OUTPUT_1_UNPAIRED \
    $OUTPUT_2 $OUTPUT_2_UNPAIRED \
    ILLUMINACLIP:TruSeq3-PE.fa:2:30:10 \
    LEADING:3 \
    TRAILING:3 \
    SLIDINGWINDOW:4:15 \
    MINLEN:36

# Check if the job was successful
if [ $? -eq 0 ]; then
    echo "Trimmomatic completed successfully for $SAMPLENAME."
else
    echo "Trimmomatic failed for $SAMPLENAME."
    exit 1
fi

```

### `SLURM` Script to Run Trimmomatic-0.39
```bash
#!/bin/bash
#SBATCH --job-name=trimmomatic_job       # Job name
#SBATCH --output=trimmomatic_job_%j.out  # Standard output and error log
#SBATCH --error=trimmomatic_job_%j.err   # Error log
#SBATCH --ntasks=1                       # Number of tasks (processes)
#SBATCH --cpus-per-task=2                # Number of CPU cores per task
#SBATCH --mem=2G                         # Memory per node
#SBATCH --time=01:00:00                  # Time limit hrs:min:sec
#SBATCH --partition=gpu_scholar       # Replace with your partition name
#SBATCH --mail-type=END,FAIL             # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=mahendras948@gmail.com # Replace with your email

# Load the Trimmomatic module
module load Trimmomatic-0.39

# Define the path to the Trimmomatic JAR file
TRIMMOMATIC_JAR="/dgxa_home/shared_software/Trimmomatic-0.39/trimmomatic-0.39.jar"

# Define input and output directories
INPUT_DIR="/dgxb_home/se24plsc006/project/dataset"
OUTPUT_DIR="/dgxb_home/se24plsc006/project/results/trim_out"

# Create the output directory if it doesn't exist
mkdir -p $OUTPUT_DIR

# Define input files
INPUT_1="$INPUT_DIR/SRR32066794_1.fastq"
INPUT_2="$INPUT_DIR/SRR32066794_2.fastq"

# Define output files
OUTPUT_1="$OUTPUT_DIR/SRR32066794_1_trimmed.fastq"
OUTPUT_2="$OUTPUT_DIR/SRR32066794_2_trimmed.fastq"
OUTPUT_1_UNPAIRED="$OUTPUT_DIR/SRR32066794_1_unpaired.fastq"
OUTPUT_2_UNPAIRED="$OUTPUT_DIR/SRR32066794_2_unpaired.fastq"

# Run Trimmomatic
java -jar $TRIMMOMATIC_JAR PE \
    -threads 4 \
    $INPUT_1 $INPUT_2 \
    $OUTPUT_1 $OUTPUT_1_UNPAIRED \
    $OUTPUT_2 $OUTPUT_2_UNPAIRED \
    ILLUMINACLIP:TruSeq3-PE.fa:2:30:10 \
    LEADING:3 \
    TRAILING:3 \
    SLIDINGWINDOW:4:15 \
    MINLEN:36

# Check if the job was successful
if [ $? -eq 0 ]; then
    echo "Trimmomatic completed successfully."
else
    echo "Trimmomatic failed."
    exit 1
fi
```
### Run the Script:
```bash
chmod +x tri.sh
./tri.sh
```
### Submit the job to SLURM:
```bash
sbatch trimmomatic_job.sh
```
### Check Job Completion/Failure Logs Since the jobs aren't listed, they likely completed or failed. Check their output and error logs:
```bash
squeue
squeue -u USER
ls -l /dgxb_home/se24plsc006/project/results/trim_ou
cat trimmomatic_job_14331.err
cat trimmomatic_job_14331.out
```
### Directory Structure
```bash
/dgxb_home/se24plsc006/project/
├── dataset/
│   ├── SRR32066794_1.fastq
│   ├── SRR32066794_2.fastq
├── results/
│   └── trim_out/
├── samples/
│   └── samples.txt
├── script/
│   └── trimmomatic_array_job.sh
```
### Getting information about Trimmomatic directory
```bash
module show Trimmomatic-0.39
find /dgxa_home/shared_software/Trimmomatic-0.39 -name "*.jar"
```
### FastQC Array Job Script

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
