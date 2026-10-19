#!/bin/bash
#SBATCH --job-name=draft_assembly_package
#SBATCH --time=0-04
#SBATCH --cpus-per-task=2
#SBATCH --ntasks=1
#SBATCH --mem=8g
#SBATCH --output=logs/slurm/draft_assembly_package.%j.out
#SBATCH --error=logs/slurm/draft_assembly_package.%j.err

# Source snakemake environment
source profiles/pawsey/lib/snakemake_env.sh

# Setup and run
setup_snakemake
run_snakemake draft_assembly_package