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
download https://archive.omnipathdb.org/omnipath_webservice_interactions__latest.tsv.gz
cd ..
echo " │  └OK" >&2


echo " | Gene Symbol to Ensembl ID" >&2
mkdir -p HGNC
cd HGNC
wget https://storage.googleapis.com/public-download-files/hgnc/tsv/tsv/hgnc_complete_set.txt
cd ..
echo " | └OK" >&2

echo " | OK" >&2

echo "Everything is OK, you can now call: ./makeKG.sh." >&2

