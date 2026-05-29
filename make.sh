# Our safety check: If any command fails, stop the script immediately.
set -e
set -euo pipefail

# Run Preparation Script
echo "--- Step 0: Preparing data ---" >&2
bash prepare.sh

# ==========================================
# Step 1: Build the Knowledge Graph
# ==========================================
echo "Stopping Neo4j to allow bulk import..." >&2
NEO_USER="sudo -u neo4j"

# Turn off the database so we can safely inject the CSV files
${NEO_USER} neo4j-admin server stop

echo "[1/3] Running OntoWeaver to build the knowledge graph..." >&2
# Ensure Python environment is activated before running the script :
cmd="uv run python weave_KG2BM.py"

echo "Executing command: " >&2
echo "$cmd" >&2

$cmd > tmp.sh

echo "Injecting data into Neo4j..." >&2
chmod a+x tmp.sh
${NEO_USER} bash tmp.sh

echo "Restarting Neo4j server..." >&2
# Turn the database back on
${NEO_USER} neo4j-admin server start

sleep 5 # Wait a bit for Neo4j to be fully up and running

# ==========================================
# Step 2: Query Neo4j for the Protein List
# ==========================================
echo "[2/3] Extracting protein list from Neo4j..." >&2
${NEO_USER} cypher-shell \
    --username neo4j \
    --password $(cat neo4j.pass) \
    --format "MATCH (g:Gene) WHERE g.gene_symbol IN ['PIK3CA', 'MAP2K1', 'AKT1', 'MAP3K7', 'MAPK14', 'GSK3B', 'CTNNB1'] RETURN g.gene_symbol;" | tail -n +2 | tr -d '"' > protein_list.txt

# ==========================================
# Step 3: Construct the Network with NeKo
# ==========================================
# echo "[3/3] Running NeKo to generate BNET and SIF Networks..." >&2

# Create a folder to keep your outputs organized
# mkdir -p neko_outputs

# Run the NeKo python module, giving it the text file we just made in Step 2
# uv run python -m neko \
#   --proteins proteins.txt \
#   --sif neko_outputs/context_graph.sif \
#   --bnet neko_outputs/context_graph.bnet

# echo "--- Pipeline finished successfully! ---" >&2

echo "--- Preview of extracted protein IDs ---"
head -n 10 protein_list.txt