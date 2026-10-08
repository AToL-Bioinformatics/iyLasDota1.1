#!/bin/bash
#SBATCH --job-name=post_ascc
#SBATCH --time=0-02
#SBATCH --cpus-per-task=2
#SBATCH --ntasks=1
#SBATCH --mem=8g
#SBATCH --output=logs/slurm/post_ascc.%j.out
#SBATCH --error=logs/slurm/post_ascc.%j.err

# Source snakemake environment
source profiles/pawsey/lib/snakemake_env.sh

# Setup and run
setup_snakemake
run_snakemake post_ascc
