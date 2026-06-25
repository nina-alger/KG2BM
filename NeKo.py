from neko.inputs import Universe, signor
import omnipath as op
from neko._annotations.gene_ontology import Ontology
from neko.core.network import Network
from neko._visual.visualize_network import NetworkVisualizer
from neko._outputs.exports import Exports
import pandas as pd
from neko._methods.compare import compare_networks


# INPUT 
# Gene list :
genes = ["MAP2K1", "PIK3CA", "CTNNB1", "MAP3K7", "MAPK14", "GSK3B", "AKT1","ERBB2","EGFR"]
output_nodes = ["MYC", "CCND1", "TCF7L2", "FOXO3", "CASP8", "CASP9"]

# Resource : 
resources = Universe()
resources = signor("./Signor_filtered.tsv")  # here you put the signor file path
resources.build()

# NETWORK CONSTRUCTION
# INE : Radial | Consensus = False
net1 = Network(genes, resources = resources.interactions)
net1.connect_nodes(only_signed=True, consensus_only=True)
net1.connect_as_atopo(max_len=1, strategy="radial",outputs=output_nodes)
# net1.complete_connection(maxlen=3, algorithm="bfs", only_signed=True, connect_with_bias=False, consensus=True)

# EXPORT .SIF AND .BNET 
# Create a dictionary mapping your variable names to the actual Network objects
# This makes it easy to loop through them for export
network_to_export = {"GRN": net1}

print("Starting export process...")

# Loop through the dictionary and export each one
for name, net_obj in networks_to_export.items():
    # Initialize the exporter for the specific network object
    exporter = Exports(net_obj)
    
    # Define the output file name
    filename = f"./{name}.sif"
    
    # Export to BNET
    exporter.export_bnet(filename)
    print(f"Successfully exported: {filename}")