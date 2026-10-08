#!/bin/bash
#SBATCH --job-name=broker_raw_reads_to_ena
#SBATCH --time=0-04
#SBATCH --cpus-per-task=2
#SBATCH --ntasks=1
#SBATCH --mem=8g
#SBATCH --output=logs/slurm/broker_raw_reads_to_ena.%j.out
#SBATCH --error=logs/slurm/broker_raw_reads_to_ena.%j.err

# Source snakemake environment
source profiles/pawsey/lib/snakemake_env.sh

# Setup and run
setup_snakemake
run_snakemake broker_raw_reads_to_ena