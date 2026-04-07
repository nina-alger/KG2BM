import biocypher
import ontoweaver
import logging
import glob
import pandas as pd # Needed to safely load mixed file formats 

# =========================================================
# 1. REGISTER TRANSFORMERS
# =========================================================
# Importing & Registering custom transformer : OmniPath & Open Targets
from KG2BM.transformers.networks import OmniPath_directed
ontoweaver.transformer.register(OmniPath_directed)

from KG2BM.transformers.OpenTargets import access_proteins, urls_to_prop
ontoweaver.transformer.register(access_proteins)
ontoweaver.transformer.register(urls_to_prop)

# =========================================================
# 2. YOUR ORIGINAL DATA MAPPINGS
# =========================================================
data_mappings = {
    # 1. Single tables : 
    "./data/oncokb_biomarker_drug_associations.tsv": "./KG2BM/adapters/oncoKB.yaml", # OncoKB
    "./data/rna_tissue_consensus_head10.tsv": "./KG2BM/adapters/HPA.yaml" , # Human Protein Atlas - RNA tissue consensus
    "./data/omnipath_webservice_interactions__latest.tsv": "./KG2BM/adapters/networks.yaml", # OmniPath

    # 2. Parquet files (dynamically unpacked in one line!) : Open Targets
    **{f: "KG2BM/adapters/target.yaml" for f in glob.glob("./data/target/*.parquet")}, # Open Targets - target
    **{f: "KG2BM/adapters/drug_molecule.yaml" for f in glob.glob("./data/drug_molecule/*.parquet")}, # Open Targets - drug_molecule
    **{f: "KG2BM/adapters/drug_mechanism_of_action.yaml" for f in glob.glob("./data/drug_mechanisme_of_action/*.parquet")}, # Open Targets - drug_mechanism_of_action
}

# =========================================================
# 3. LOAD EXTERNAL FILTER DATA
# =========================================================
translations_file = "./data/HGNC/hgnc_complete_set.txt"
translations_table = pd.read_table(translations_file, sep="\t")

# =========================================================
# 4. THE EXTRACTION LOOP
# =========================================================
nodes, edges = [], []

for filepath, yaml_adapter in data_mappings.items():
    print(f"Reading {filepath}...")
    
    # --- ROUTE A: It is the OmniPath file ---
    if "omnipath_webservice_interactions" in filepath:
        # Load instantly with standard pandas
        table = pd.read_csv(filepath, sep='\t', low_memory=False)
        
        # Filtering
        table['source_genesymbol'] = table['source_genesymbol'].str.upper()
        table['target_genesymbol'] = table['target_genesymbol'].str.upper()

        df = table[
            ((table['source_genesymbol'].isin(translations_table.symbol)) | (table.entity_type_source!="protein")) & 
            ((table['target_genesymbol'].isin(translations_table.symbol)) | (table.entity_type_target!="protein"))
        ]
        
    # --- ROUTE B: It is an Open Targets Parquet file ---
    elif filepath.endswith('.parquet'):
        df = pd.read_parquet(filepath)
        
    # --- ROUTE C: It is a standard TSV (like OncoKB or HPA) ---
    else:
        df = pd.read_csv(filepath, sep='\t', low_memory=False)
        
        
    # --- ONTOWEAVER EXTRACTION ---
    n, e = ontoweaver.extract_table(df, config=yaml_adapter, affix="suffix")
    nodes.extend(n)
    edges.extend(e)

# =========================================================
# 5. WRITE TO BIOCYPHER
# =========================================================
# Reconciliate properties, and write nodes to BioCypher.
print("Writing nodes and edges to BioCypher...")
bc_nodes = [n.as_tuple() for n in nodes]
bc_edges = [e.as_tuple() for e in edges]

bc = ontoweaver.reconciliate_write(
    nodes=bc_nodes,
    edges=bc_edges,
    biocypher_config_path="./config/biocypher_config.yaml",
    schema_path="./config/schema_config.yaml",
    reconciliate_sep="|"
)

# 4. EXPLICITLY COMMAND THE GENERATION OF THE BASH SCRIPT!
# import_script = bc.write_import_call()
# print(f"\nSUCCESS! Your Neo4j import script is located at: {import_script}")

print("Done!")