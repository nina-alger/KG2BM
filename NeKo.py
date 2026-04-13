import pandas as pd
from neko.core.network import Network
from neko._visual.visualize_network import NetworkVisualizer
from neko.inputs import Universe, signor
import omnipath as op

# 1. Load the tab-separated file containing our targeted HUGO symbols
df = pd.read_csv('protein_list.txt', header=None, names=['protein_id'])

# 2. Convert the Pandas column into a flat Python list of strings
hugo_symbols = df['protein_id'].tolist()
print(f"Loaded {len(hugo_symbols)} targeted proteins for NeKo: {hugo_symbols}")

# 3. Initialize the NeKo Network using the HUGO list
neko_net = Network(proteins=hugo_symbols)

# From here, you can continue with your NeKo pipeline to build the BNET and SIF
# Example: neko_net.build_from_omnipath(...)