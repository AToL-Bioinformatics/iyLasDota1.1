#!/bin/bash -l
#SBATCH --job-name=ascc
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=4g
#SBATCH --time=1-00
#SBATCH --output=logs/slurm/ascc.%j.out
#SBATCH --error=logs/slurm/ascc.%j.err

# Source nextflow environment
source profiles/pawsey/lib/nextflow_env.sh

# Pipeline configuration
PIPELINE="ascc"
PIPELINE_VERSION="0.5.3"
SAMPLE_ID="$(get_sample_id)"

# Setup nextflow
setup_nextflow "${PIPELINE}" "${PIPELINE_VERSION}" "25.04.8"

# format samplesheet
if [ ! -f "config/ascc_samplesheet.csv" ]; then
        envsubst <config/ascc_samplesheet.csv.sample >config/ascc_samplesheet.csv
fi

# format yaml file
if [ ! -f "config/ascc.yaml" ]; then
        envsubst <config/ascc.yaml.sample >config/ascc.yaml
fi

# Pipeline parameters
PIPELINE_PARAMS=(
        "--input" "config/ascc_samplesheet.csv"
        "--outdir" "results/${PIPELINE}/${SAMPLE_ID}"
        "--fcs_gx_database_path" "$(readlink -f resources/staging/fcsgx)"
        "--busco_lineages_folder" "$(readlink -f resources/staging/busco)"
        "--diamond_uniprot_database_path" "$(readlink -f resources/staging/diamond_uniprot_database/reference_proteomes.dmnd)"
        "--nt_database_path" "$(readlink -f resources/staging/nt_database)"
        "-profile" "singularity,pawsey,ascc"
        "-params-file" "config/ascc.yaml"
        "-r" "${PIPELINE_VERSION}"
        "-c" "profiles/pawsey/pawsey.config"
        "-c" "profiles/pawsey/ascc.params.config"
)

# Run pipeline
run_nextflow "sanger-tol/${PIPELINE}" PIPELINE_PARAMS
