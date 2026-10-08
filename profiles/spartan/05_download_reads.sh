#!/bin/bash
#SBATCH --job-name=download_reads
#SBATCH --time=0-12
#SBATCH --cpus-per-task=2
#SBATCH --ntasks=1
#SBATCH --mem=8g
#SBATCH --output=logs/slurm/download_reads.%j.out
#SBATCH --error=logs/slurm/download_reads.%j.err

# Source snakemake environment
source profiles/spartan/lib/snakemake_env.sh

# Setup and run
setup_snakemake
run_snakemake download_reads
