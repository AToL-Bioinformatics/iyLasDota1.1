#!/bin/bash
#SBATCH --job-name=pre_genomeassembly
#SBATCH --time=0-12
#SBATCH --cpus-per-task=2
#SBATCH --ntasks=1
#SBATCH --mem=8g
#SBATCH --output=logs/slurm/pre_genomeassembly.%j.out
#SBATCH --error=logs/slurm/pre_genomeassembly.%j.err

# Source snakemake environment
source profiles/pawsey/lib/snakemake_env.sh

# Setup and run
setup_snakemake
run_snakemake pre_genomeassembly
