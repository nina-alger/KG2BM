import biocypher
import ontoweaver
import logging
import glob

# Importing & Registering custom transformer : OmniPath & Open Targets
from KG2BM.transformers.networks import OmniPath_directed
ontoweaver.transformer.register(OmniPath_directed)

from KG2BM.transformers.OpenTargets import access_proteins, urls_to_prop
ontoweaver.transformer.register(access_proteins)
ontoweaver.transformer.register(urls_to_prop)

# Define the path to the mapping file. This time we define two paris of DATABASE:MAPPING_FILE mappings.
data_mappings = {
    # 1. Single tables : 
    "./data/oncokb_biomarker_drug_associations.tsv": "./KG2BM/adapters/oncoKB.yaml", # OncoKB
    "./data/rna_tissue_consensus_head10.tsv": "./KG2BM/adapters/HPA.yaml" , # Human Protein Atlas - RNA tissue consensus
    "./data/hgnc_complete_set.txt": "./KG2BM/adapters/networks.yaml", # OmniPath

    # 2. Parquet files (dynamically unpacked in one line!) : Open Targets
    **{f: "KG2BM/adapters/target.yaml" for f in glob.glob("./data/target/*.parquet")}, # Open Targets - target
    **{f: "KG2BM/adapters/drug_molecule.yaml" for f in glob.glob("./data/drug_molecule/*.parquet")}, # Open Targets - drug_molecule
    **{f: "KG2BM/adapters/drug_mechanism_of_action.yaml" for f in glob.glob("./data/drug_mechanisme_of_action/*.parquet")}, # Open Targets - drug_mechanism_of_action
}

# Extract nodes and edges from the mapping file. Reconciliate properties, and write nodes.
ontoweaver.weave(filename_to_mapping=data_mappings, 
                 affix = "suffix",
                 biocypher_config_path=f"./config/biocypher_config.yaml",
                 schema_path=f"./config/schema_config.yaml",)