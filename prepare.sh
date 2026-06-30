#!/usr/bin/env bash

set -e
set -o pipefail

ot_version="25.12"
if [[ -z "$1" ]] ; then
    echo "Using default Open Targets version: $ot_version" >&2
else
    ot_version="$1"
    echo "Using Open Targets version: $ot_version" >&2
fi

data_dir="data"
script_dir="$(dirname $0)"


echo "Check for neo4j.pass..." >&2
if [[ ! -f neo4j.pass ]] ; then
    echo "WARNING: file 'neo4j.pass' is missing." >&2
    # exit 1
fi
echo "neo4j — OK" >&2


if [[ -d $script_dir/.venv ]] ; then
    echo "Environment already existing, if you want to upgrade it, either:" >&2
    echo "- remove the '.venv' directory and run 'prepare.sh' again," >&2
    echo "- or run 'uv sync' manually." >&2
else
    echo "Install environment..." >&2
    uv sync --no-upgrade
    echo "Sync — OK" >&2
fi


echo "Download data:" >&2
mkdir -p data
cd data
rsync_cmd="rsync --ignore-existing -rpltvz --delete"

echo " │ Open Targets..." >&2

echo " | | Open Targets : Target..." >&2
$rsync_cmd rsync.ebi.ac.uk::pub/databases/opentargets/platform/${ot_version}/output/target .
echo " │ │  └OK" >&2

echo " | | Open Targets : Drug-Mechanism..." >&2
$rsync_cmd rsync.ebi.ac.uk::pub/databases/opentargets/platform/${ot_version}/output/drug_mechanism_of_action .
echo " │ │  └OK" >&2

echo " | | Open Targets : Drug-Molecule..." >&2
$rsync_cmd rsync.ebi.ac.uk::pub/databases/opentargets/platform/${ot_version}/output/drug_molecule .
echo " │ │  └OK" >&2


echo " │ OmniPath Networks..." >&2
mkdir -p omnipath_networks
cd omnipath_networks
wget https://archive.omnipathdb.org/omnipath_webservice_interactions__latest.tsv.gz
gunzip omnipath_webservice_interactions__latest.tsv.gz # <-- This extracts the .gz
cd ..
echo " │  └OK" >&2

echo " | SIGNOR..." >&2
mkdir -p signor
cd signor

echo " | | Downloading SIGNOR TSV..." >&2
# Pulling the complete Human dataset directly from the GET endpoint
wget -qO signor_db.tsv "https://signor.uniroma2.it/API/getHumanData.php"

echo " | | Filtering SIGNOR data (Protein-Protein only)..." >&2
# Running your pandas filter directly from Bash
uv run python -c "
import pandas as pd

# Files are downloaded into the current 'data/signor' directory
file_path = 'signor_db.tsv' 
df = pd.read_csv(file_path, sep='\t')

# Filter for protein-protein interactions
df_filtered = df.loc[(df['TYPEA'] == 'protein') & (df['TYPEB'] == 'protein')]

# Export the filtered dataframe
df_filtered.to_csv('Signor_filtered.tsv', sep='\t', index=False)
"
cd ..
echo " | └OK" >&2


echo " | Human Protein Atlas..." >&2
mkdir -p hpa
cd hpa
wget https://www.proteinatlas.org/download/tsv/rna_tissue_consensus.tsv.zip

if command -v python3 &> /dev/null; then
    python3 -m zipfile -e rna_tissue_consensus.tsv.zip .
elif command -v jar &> /dev/null; then
    jar xf rna_tissue_consensus.tsv.zip
else
    echo "Error: Could not extract zip. Neither python3 nor jar are available." >&2
    exit 1
fi


cd ..
echo " | └OK" >&2


echo " | Gene Symbol to Ensembl ID" >&2
mkdir -p HGNC
cd HGNC
wget https://storage.googleapis.com/public-download-files/hgnc/tsv/tsv/hgnc_complete_set.txt
cd ..
echo " | └OK" >&2

echo " | OK" >&2

echo "Everything is OK, you can now call: ./makeKG.sh." >&2

