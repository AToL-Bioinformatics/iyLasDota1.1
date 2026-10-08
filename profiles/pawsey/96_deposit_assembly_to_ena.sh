#!/bin/bash
#SBATCH --job-name=deposit_ascc_assembly_to_ena
#SBATCH --time=0-04
#SBATCH --cpus-per-task=2
#SBATCH --ntasks=1
#SBATCH --mem=8g
#SBATCH --output=logs/slurm/deposit_assembly_to_ena.%j.out
#SBATCH --error=logs/slurm/deposit_assembly_to_ena.%j.err

# Source snakemake environment
source profiles/pawsey/lib/snakemake_env.sh

# Setup and run
setup_snakemake
run_snakemake deposit_assembly_to_ena