#!/bin/bash
# Nextflow environment setup for Pawsey

# Source common setup
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

# Setup nextflow environment
# Usage: setup_nextflow <pipeline_name> <pipeline_version> [nextflow_version]
setup_nextflow() {
    local pipeline_name="${1:?Pipeline name required}"
    local pipeline_version="${2:?Pipeline version required}"
    local nextflow_version="${3:-25.10.4}"
    local base_dir="${4:-results}"

    # Set up singularity first
    setup_singularity

    # Define nextflow directory structure
    local nextflow_dir_relative="${base_dir}/${pipeline_name}/nextflow/${nextflow_version}/${pipeline_version}"
    mkdir -p "${nextflow_dir_relative}/logs"
    local nextflow_dir="$(readlink -f ${nextflow_dir_relative})"

    # Download nextflow if not present
    if [ ! -f "${nextflow_dir}/nextflow" ]; then
        wget \
            -O "${nextflow_dir}/nextflow" \
            "https://github.com/nextflow-io/nextflow/releases/download/v${nextflow_version}/nextflow"
        chmod 755 "${nextflow_dir}/nextflow"
    fi

    # Configure nextflow environment
    export PATH="${nextflow_dir}:${PATH}"
    printf "nextflow: %s\n" "$(readlink -f "$(which nextflow)")"

    export NXF_HOME="$(readlink -f "${nextflow_dir}/home")"
    export NXF_CACHE_DIR="$(readlink -f "${nextflow_dir}/cache")"
    export NXF_WORK="$(readlink -f "${nextflow_dir}/work")"
    export NXF_LINEAGE="$(readlink -f "${nextflow_dir}/lineage")"
    export NXF_TMPDIR="$(readlink -f "${nextflow_dir}/tmp")"
    mkdir -p "${NXF_TMPDIR}"

    export NXF_APPTAINER_CACHEDIR="${SINGULARITY_CACHEDIR}/library"
    export NXF_SINGULARITY_CACHEDIR="${SINGULARITY_CACHEDIR}/library"

    # Export for use by caller
    export NEXTFLOW_DIR="${nextflow_dir}"
    export NEXTFLOW_VERSION="${nextflow_version}"
}

# Run a nextflow pipeline
# Usage: run_nextflow <pipeline_repo> <params_array_name>
run_nextflow() {
    local pipeline_repo="${1:?Pipeline repository required}"
    local -n params_ref="${2:?Pipeline params array name required}"

    nextflow \
        -log "${NEXTFLOW_DIR}/logs/nextflow-${SLURM_JOB_ID:-$(date +%Y%m%d%H%M%S)}.log" \
        run \
        "${pipeline_repo}" \
        "${params_ref[@]}" \
        -resume
}
