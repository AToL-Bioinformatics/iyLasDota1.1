#!/bin/bash
#SBATCH --job-name=post_genomeassembly
#SBATCH --time=0-04
#SBATCH --cpus-per-task=2
#SBATCH --ntasks=1
#SBATCH --mem=8g
#SBATCH --output=logs/slurm/post_genomeassembly.%j.out
#SBATCH --error=logs/slurm/post_genomeassembly.%j.err

# Source snakemake environment
source profiles/pawsey/lib/snakemake_env.sh

# Setup and run
setup_snakemake
run_snakemake post_genomeassembly
