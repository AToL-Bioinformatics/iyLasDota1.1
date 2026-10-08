#!/bin/bash -l
#SBATCH --job-name=genomeassembly
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=4g
#SBATCH --time=1-00
#SBATCH --output=logs/slurm/genomeassembly.%j.out
#SBATCH --error=logs/slurm/genomeassembly.%j.err

# Source nextflow environment
source profiles/pawsey/lib/nextflow_env.sh

# Pipeline configuration
PIPELINE="genomeassembly"
PIPELINE_VERSION="e651801"
SAMPLE_ID="$(get_sample_id)"

# Setup nextflow
setup_nextflow "${PIPELINE}" "${PIPELINE_VERSION}" "25.10.4"

# The genomeassembly pipeline uses Nextflow secrets for the NCBI API
if [ -z "${NCBI_API_KEY}" ]; then
        printf "Set the NCBI_API_KEY variable" 1>&2
        exit 1
else
        nextflow secrets set NCBI_API_KEY "${NCBI_API_KEY}"
fi

# Generate data config if needed
if [ ! -f "config/genomeassembly.data.yaml" ]; then
        envsubst <config/genomeassembly.data.yaml.sample >config/genomeassembly.data.yaml
fi

# Pipeline parameters
PIPELINE_PARAMS=(
        "--genomic_data" "config/genomeassembly.data.yaml"
        "--assembly_specs" "config/genomeassembly.spec.yaml"
        "--busco_lineage_directory" "$(readlink -f resources/staging/busco)"
        "--outdir" "results/${PIPELINE}/${SAMPLE_ID}"
        "-profile" "singularity,pawsey,genomeassembly"
        "-r" "${PIPELINE_VERSION}"
        "-c" "profiles/pawsey/pawsey.config"
)

# Run pipeline
run_nextflow "sanger-tol/${PIPELINE}" PIPELINE_PARAMS
