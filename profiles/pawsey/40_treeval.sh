#!/bin/bash -l
#SBATCH --job-name=treeval
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=4g
#SBATCH --time=1-00
#SBATCH --output=logs/slurm/treeval.%j.out
#SBATCH --error=logs/slurm/treeval.%j.err

# Source nextflow environment
source profiles/pawsey/lib/nextflow_env.sh

# Pipeline configuration
PIPELINE="treeval"
PIPELINE_VERSION="1.4.5"
SAMPLE_ID="$(get_sample_id)"

# Setup nextflow
setup_nextflow "${PIPELINE}" "${PIPELINE_VERSION}" "25.10.4"

# format yaml file
if [ ! -f "config/treeval.yaml" ]; then
        envsubst <config/treeval.yaml.sample >config/treeval.yaml
fi

# Pipeline parameters
PIPELINE_PARAMS=(
        "--input" "config/treeval.yaml"
        "--outdir" "results/${PIPELINE}/${SAMPLE_ID}"
        "--mode" "RAPID_TOL"
        "--run_hires"
        "--split_telomere"
        "-profile" "singularity,pawsey,treeval"
        "-r" "${PIPELINE_VERSION}"
        "-c" "profiles/pawsey/pawsey.config"
)

# Run pipeline
run_nextflow "sanger-tol/${PIPELINE}" PIPELINE_PARAMS
