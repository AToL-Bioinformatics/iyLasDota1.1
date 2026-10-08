#!/bin/bash
# Common setup for all Pawsey jobs

set -eux

# Unset SBATCH_EXPORT to prevent environment leakage
unset SBATCH_EXPORT

# Spartan uses per-project storage, see
# https://dashboard.hpc.unimelb.edu.au/data_management/#scratch-directories
set_project_dir() {
    if [ -z "${PROJECTID:-}" ]; then
        printf "The PROJECTID variable is required" 1>&2
        exit 1
    fi
    export MYSCRATCH="/data/scratch/projects/${PROJECTID}"
}

# Singularity/Apptainer setup
setup_singularity() {
    module load Apptainer/1.4.4

    if [ -z "${SINGULARITY_CACHEDIR:-}" ]; then
        printf "The SINGULARITY_CACHEDIR variable is required" 1>&2
        exit 1
    fi
    export APPTAINER_CACHEDIR="${SINGULARITY_CACHEDIR}"
    printf "APPTAINER_CACHEDIR: %s\n" "${APPTAINER_CACHEDIR}" 1>&2

}

# Get sample/dataset ID from manifest or directory
# FIXME - use yaml_manifest for this
get_sample_id() {
    if [ -f "config/manifest.yaml" ]; then
        local dataset_id assembly_version
        dataset_id="$(grep "dataset_id" config/manifest.yaml | head -n1 | cut -d' ' -f2 | sed 's/"//g')"
        assembly_version="$(grep "assembly_version" config/manifest.yaml | head -n1 | cut -d' ' -f2 | sed 's/"//g')"
        printf "%s.%s" "${dataset_id}" "${assembly_version}"
    else
        basename "$(dirname "$(readlink -f venv)")"
    fi
}
