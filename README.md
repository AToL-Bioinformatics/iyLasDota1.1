# iyLasDota1.1

This repository contains the workflows that were used to assemble the genome
iyLasDota1.1 for *Lasioglossum dotatum*.

The repo was produced automatically from boilerplate code at
[AToL-Bioinformatics/genome-launcher-workflow](https://github.com/AToL-Bioinformatics/genome-launcher-workflow).

### Assembly data

<details>

<summary>Click to view YAML</summary>

```yaml
assembly_id: c752cbcd-6761-4490-b245-5db3e2f91cbf
assembly_version: 1
augustus_dataset_name: tiberius_model_cfg:insecta.yaml
busco_odb10_dataset_name: hymenoptera
busco_odb12_dataset_name: apoidea
dataset_id: iyLasDota1
genetic_code_id: 1
hic_motif: GATC,GANTC,CTNAG,TTAA
mitochondrial_genetic_code_id: 5
mitohifi_reference_species: Seladonia aeraria
ncbi_class: Insecta
oatk_hmm_name: hymenoptera
read_files:
- base_url: https://downloads-qcif.bioplatforms.com/bpa/ipm_staging/pacbio-hifi/BPAOPS-2190/20260818_IPM_AGRF_CAGRF26030155_m84073_260807_062841_s3/
  data_type: PACBIO_SMRT
  name: bpa-ipm-pacbio-hifi-606323-m84073_260807_062841_s3
  single_end:
  - md5sum: f1150f30e9e2e13044ba281bcb3bef94
    url: https://data.bioplatforms.com/dataset/bpa-ipm-pacbio-hifi-606323-m84073_260807_062841_s3/resource/f1150f30e9e2e13044ba281bcb3bef94/download/606323_IPM_AGRF_m84073_260807_062841_s3.ccs.bam
- base_url: https://downloads-qcif.bioplatforms.com/bpa/ipm_staging/illumina-shortread/BPAOPS-2127/20260630_IPM_BRF_WO24051_SC2149464-SC3/
  data_type: Hi-C
  name: bpa-ipm-illumina-shortread-606323-sc2149464-sc3
  r1:
  - lane_number: L001
    md5sum: 879653aad306da35175ac6a231c2ab61
    url: https://data.bioplatforms.com/dataset/bpa-ipm-illumina-shortread-606323-sc2149464-sc3/resource/879653aad306da35175ac6a231c2ab61/download/606323_IPM_BRF_SC2149464-SC3_CAGCAATA-ATTAGGAG_S1_L001_R1_001.fastq.gz
  r2:
  - lane_number: L001
    md5sum: 062822533d721bb0e39eaf298f3b03d8
    url: https://data.bioplatforms.com/dataset/bpa-ipm-illumina-shortread-606323-sc2149464-sc3/resource/062822533d721bb0e39eaf298f3b03d8/download/606323_IPM_BRF_SC2149464-SC3_CAGCAATA-ATTAGGAG_S1_L001_R2_001.fastq.gz
scientific_name: Lasioglossum dotatum
taxon_id: 1039396

```

</details>

## Overview

The assembly process has three main steps:

1. Assembly with
   [sanger-tol/genomeassembly](https://github.com/sanger-tol/genomeassembly/)
2. Decontamination with [sanger-tol/ascc](https://github.com/sanger-tol/ascc/)
3. Preparation of curation materials with
   [sanger-tol/treeval](https://github.com/sanger-tol/treeval/), if there are
   Hi-C reads.

The config files for these steps are in the [config](./config) directory.

The sanger-tol workflows are plumbed together by the [included Snakemake
worfklow](./workflow/Snakefile).

## Running the assembly

### Setting up

Clone this repo to the HPC where it will be run.

A profile will be needed to configure the job scheduler on the HPC. Profiles
for [Setonix](./profiles/pawsey) and [Spartan (partial)](./profiles/spartan)
are included. A profile for [local testing](./profiles/local) is also included.

<details>

<summary>More information about the profile</summary>

#### The profile needs at least the following files:

- Snakemake [**job config**](./profiles/pawsey/config.v9+.yaml) and [**workflow
  config**](./profiles/pawsey/workflow.config.yaml): configure the jobs from the
  genome-launcher-workflow.
- [**nextflow config**](./profiles/pawsey/pawsey.config): configure the
  processes from the Sanger-Tol pipelines
- [**ascc.params.config**](./profiles/pawsey/ascc.params.config): the [YAML
  params
  file](https://pipelines.tol.sanger.ac.uk/ascc/0.6.0/usage#running-the-pipeline)
  for ASCC (not shared with the other pipelines).

</details>

### Steps

1. Download the reads and run the QC scripts using the genome-launcher-workflow
   target `pre_genomeassembly`.
2. Run the `genomeassembly` workflow. See the [example 20_genomeassembly.sh
   script](profiles/pawsey/20_genomeassembly.sh).
3. Stage the ASCC reference data using the genome-launcher-workflow target
   `post_genomeassembly`.
4. Run the `ascc` workflow. See the [example 30_ascc.sh
   script](profiles/pawsey/30_ascc.sh).
5. Convert the ASCC output for TreeVal using the genome-launcher-workflow
   target `post_ascc`.
6. If Hi-C is available, run the `treeval` workflow. See the [example
   40_treeval.sh submission script](profiles/pawsey/40_treeval.sh).
7. Run the `post_treeval` target to upload the results to object storage. The
   `post_*` targets all upload the output of the preceding pipeline to object
   storage.
8. **Optional**: curate the genome manually using
   [PretextView](https://github.com/sanger-tol/PretextView). Add the AGP file
   that is output by PretextView and a list of any contigs or scaffolds to
   remove to the repository on GitHub. The files must be named as follows:
   - `curation/{dataset_id}_{assembly_version}_normal_curated_v1.pretext.agp_1`
   - `curation/{dataset_id}.{assembly_version}_scaffolds_to_remove.txt`
9. Once the files from step 8 have been added, pull the updates and run the
   `post_curation` target to split the haplotypes.
10. **Optional**: use the `all_assembly_stats` target to run `seqkit stats
    -all` on the list of expected assembly outputs.
11. **Optional**: use the `upload_all_logs` target to backup all the log files
    to object store.

<details>

<summary>Worked example</summary>

#### Run this assembly on Setonix:

> [!IMPORTANT]
>
> The pull command requires a Personal Access Token with read access to code
> and metadata.

1. Pull the repo:
   1. `git init . `
   2. `git remote add origin https://github.com/AToL-Bioinformatics/iyLasDota1.1.git`
   3. `git pull origin main`
2. Set up the directory structure: `bash profiles/pawsey/00_preflight.sh`
3. Run the workflow steps:
   1. `sbatch profiles/pawsey/10_pre_genomeassembly.sh`
   2. `sbatch profiles/pawsey/20_genomeassembly.sh`
   3. `sbatch profiles/pawsey/25_post_genomeassembly.sh`
   4. `sbatch profiles/pawsey/30_ascc.sh`
   5. `sbatch profiles/pawsey/35_post_ascc.sh`
   6. `sbatch profiles/pawsey/40_treeval.sh`
   7. `sbatch profiles/pawsey/45_post_treeval.sh`
4. Curate manually, add the curation files to the repo, and update the repo:
   1. `git pull origin main`
   2. `sbatch profiles/pawsey/55_post_curation.sh`
5. Generate assembly stats:
   1. `sbatch profiles/pawsey/98_all_assembly_stats.sh`
6. Backup the logs:
   1. `sbatch profiles/pawsey/99_upload_all_logs.sh`

</details>