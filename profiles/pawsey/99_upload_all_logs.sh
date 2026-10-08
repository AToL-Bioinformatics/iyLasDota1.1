#!/bin/bash
#SBATCH --job-name=upload_logs
#SBATCH --time=0-01
#SBATCH --cpus-per-task=2
#SBATCH --ntasks=1
#SBATCH --mem=8g

# Source snakemake environment
source profiles/pawsey/lib/snakemake_env.sh

# Setup and run
setup_snakemake
run_snakemake upload_all_logs

# remove the flagfile so we can run this rule again
flagfiles=(
	.assembly_stats.upload_all_logs.done
	.git_logs.upload_all_logs.done
	.logs.upload_all_logs.done
	.qc_stats.upload_all_logs.done
	.receipts.upload_all_logs.done
	.status_updates.upload_all_logs.done
)

for flagfile in ${flagfiles[@]}; do
	if [[ -f ${flagfile} ]]; then
		rm ${flagfile}
	fi
done
