#!/bin/bash
#SBATCH --job-name=all_assembly_stats
#SBATCH --time=0-02
#SBATCH --cpus-per-task=2
#SBATCH --ntasks=1
#SBATCH --mem=8g
#SBATCH --output=logs/slurm/all_assembly_stats.%j.out
#SBATCH --error=logs/slurm/all_assembly_stats.%j.err

# Source snakemake environment
source profiles/pawsey/lib/snakemake_env.sh

# Setup and run
setup_snakemake
run_snakemake all_assembly_stats 
run_snakemake calculate_depth