import biocypher
import ontoweaver

# Importing OmniPath custom transformer and registering it.
from KG2BM.transformers.networks import OmniPath_directed
ontoweaver.transformer.register(OmniPath_directed)

from KG2BM.transformers.ot_transformers import access_proteins, urls_to_prop
ontoweaver.transformer.register(access_proteins)
ontoweaver.transformer.register(urls_to_prop)

# Define the path to the mapping file. This time we define two paris of DATABASE:MAPPING_FILE mappings.
# data_mappings = {f"./data/oncokb_biomarker_drug_associations.tsv": f"./KG2BM/adapters/oncoKB.yaml"}
#                 f"./data/rna_tissue_consensus_head10.tsv": f"./KG2BM/adapters/HPA.yaml" }
#                 f"./data/jobim_subsets/4_Fusion/cna_subset.csv": f"./jobim/4_Fusion/cna.yaml"}

# Extract nodes and edges from the mapping file. Reconciliate properties, and write nodes.
# ontoweaver.weave(filename_to_mapping=data_mappings, 
#                 affix = "suffix",
#                 biocypher_config_path=f"./config/biocypher_config.yaml",
#                 schema_path=f"./config/schema_config.yaml",)

