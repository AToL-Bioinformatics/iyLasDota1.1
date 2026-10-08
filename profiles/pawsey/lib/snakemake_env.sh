#!/bin/bash
# Snakemake environment setup for Pawsey

# Source common setup
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

# Setup snakemake environment
setup_snakemake() {
	module load python/3.11.6

	# Activate virtual environment
	if [ ! -f "venv/bin/activate" ]; then
		printf "Virtual environment not found. Run 00_preflight.sh first." 1>&2
		exit 1
	fi
	source venv/bin/activate

	# Load singularity after venv
	setup_singularity

	# Rclone/S3 configuration
	export RCLONE_CONFIG_UPLOAD_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}"
	export RCLONE_CONFIG_UPLOAD_ENDPOINT="https://projects.pawsey.org.au"
	export RCLONE_CONFIG_UPLOAD_PROVIDER="Ceph"
	export RCLONE_CONFIG_UPLOAD_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}"
	export RCLONE_CONFIG_UPLOAD_TYPE="s3"

	export RCLONE_S3_ACCESS_KEY_ID="${RCLONE_CONFIG_UPLOAD_ACCESS_KEY_ID}"
	export RCLONE_S3_ENDPOINT="${RCLONE_CONFIG_UPLOAD_ENDPOINT}"
	export RCLONE_S3_PROVIDER="${RCLONE_CONFIG_UPLOAD_PROVIDER}"
	export RCLONE_S3_SECRET_ACCESS_KEY="${RCLONE_CONFIG_UPLOAD_SECRET_ACCESS_KEY}"

	# Webin access
	export WEBIN_USER="${WEBIN_USER}"
	export WEBIN_PASS="${WEBIN_PASS}"

	# Canopy access
	export CANOPY_BASE_URL="${CANOPY_BASE_URL}"
	export CANOPY_USERNAME="${CANOPY_USERNAME}"
	export CANOPY_PASSWORD="${CANOPY_PASSWORD}"

}

# Run snakemake with standard options
run_snakemake() {
	local target="${1:?Snakemake target required}"

	# Workaround for snakemake caching issue
	XDG_CACHE_HOME="$(mktemp -d)" \
		snakemake --profile profiles/pawsey "${target}"
}
