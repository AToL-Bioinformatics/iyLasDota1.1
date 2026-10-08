#!/bin/bash

set -euxo pipefail

# Dependencies
module load GCCcore/13.3.0
module load Python/3.12.3

unset SBATCH_EXPORT

source profiles/spartan/lib/common.sh
set_project_dir

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
DATASET_ID="$(grep "dataset_id" config/manifest.yaml | head -n1 | cut -d' ' -f2 | sed "s/\"//g")"
ASSEMBLY_VERSION="$(grep "assembly_version" config/manifest.yaml | head -n1 | cut -d' ' -f2 | sed "s/\"//g")"

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
