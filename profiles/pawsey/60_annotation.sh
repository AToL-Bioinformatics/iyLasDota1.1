#!/bin/bash
#SBATCH --job-name=annotation
#SBATCH --time=1-00
#SBATCH --cpus-per-task=2
#SBATCH --ntasks=1
#SBATCH --mem=8g
#SBATCH --output=logs/slurm/annotation.%j.out
#SBATCH --error=logs/slurm/annotation.%j.err

# Source snakemake environment
source profiles/pawsey/lib/snakemake_env.sh

# Setup and run
setup_snakemake

# check this here because it's annotation-specific (for now)
export GPU_ACCOUNT="${PAWSEY_PROJECT:?PAWSEY_PROJECT must be set for Annotation}-gpu"

# Use a second profile for Tiberius. This requires Snakemake 9.27.0. From that
# version, profile instances specified later take precedence over earlier
# instances, wherever the same top-level entries occur in multiple profiles,
# i.e. providing the GPU profile second means we can override the
# singularity-args and submit cmd. See
# https://snakemake.readthedocs.io/en/stable/executing/cli.html#using-multiple-global-profiles
XDG_CACHE_HOME="$(mktemp -d)" \
	snakemake \
	--profile profiles/pawsey \
	--profile profiles/pawsey_gpu \
	tiberius

# This target runs QC, uploads etc. with the standard command.
if [ $? -eq 0 ]; then
	run_snakemake post_annotation
fi
