#!/bin/bash

set -euxo pipefail

# preflight.sh from profiles/pawsey is specific to Pawsey. It uses the
# environment variables provided by Pawsey to set up the virtual environment
# and input/output directories. A similar setup will be required to run the
# genome launcher in other environments.

# Dependencies
module load python/3.11.6
unset SBATCH_EXPORT

# Array of directories we need for the workflows.
# TODO: If we deploy these direct from GitHub, we will also need to link the
# .git directory to scratch.
scratch_directories=(
    ".snakemake"
    "logs"
    "resources"
    "results"
    "venv"
)

# get the assembly name from the manifest
DATASET_ID="$(jq -r '.dataset_id' config/manifest.json)"
ASSEMBLY_VERSION="$(jq -r '.assembly_version' config/manifest.json)"

ASSEMBLY_ID="${DATASET_ID}.${ASSEMBLY_VERSION}"
ASSEMBLY_BASE="${MYSCRATCH}/${ASSEMBLY_ID}"

printf "ASSEMBLY_BASE: %s\n" "${ASSEMBLY_BASE}" 1>&2
printf "ASSEMBLY_ID  : %s\n" "${ASSEMBLY_ID}" 1>&2

# create the directory strucure
for dir in ${scratch_directories[@]}; do
    mypath="${ASSEMBLY_BASE}/${dir}"
    mkdir -p "${mypath}"
    ln -sf "${mypath}" "${PWD}/"
done

# set up the virtual environment
if [[ ! -f venv/bin/activate ]]; then
    python3 -m venv "${ASSEMBLY_BASE}/venv"
    source venv/bin/activate
    python3 -m pip install --upgrade pip setuptools wheel
    python3 -m pip install -r config/requirements.txt
else
    source venv/bin/activate
fi

# check for snakemake
if ! command -v snakemake >/dev/null 2>&1; then
    printf "snakemake not installed" 1>&2
    exit 1
else
    printf "running snakemake version %s\n" "$(snakemake --version)" 1>&2
fi
