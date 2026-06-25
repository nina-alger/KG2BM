#!/usr/bin/env bash

# ==========================================
# THIS CODE BUILDS THE GRN BY : 
# CALLING THE CYPHER QUERY
# RUNNING NEKO WITH THE OUTCOME OF THE CYPHER QUERY 
# ==========================================

# Our safety check: If any command fails, stop the script immediately.
set -e
set -euo pipefail

# ==========================================
# Default Variables & Argument Parsing
# ==========================================
TIMESTAMP=$(date +"%Y%m%d%H%M%S")
QUERY_FILE="query.cypher"
PROTEIN_FILE="protein_list.txt"
OUTPUT_DIR="neko-out/${TIMESTAMP}"

while getopts "q:" option; do
  case $option in
    q) # Enter query file
        QUERY_FILE=$OPTARG;;
    \?) # Invalid option 
        echo "Error: Invalid option"
        echo "Usage: ./makeGRN.sh [-q query_file.cypher]"
        exit 1 ;;
  esac
done

mkdir -p "$OUTPUT_DIR"
FULL_PROTEIN_PATH="$OUTPUT_DIR/$PROTEIN_FILE"

# ==========================================
# OS Detection & Neo4j User Setup
# ==========================================
case "$(uname)" in
    FreeBSD)   OS=FreeBSD ;;
    DragonFly) OS=FreeBSD ;;
    OpenBSD)   OS=OpenBSD ;;
    Darwin)    OS=Darwin  ;;
    SunOS)     OS=SunOS   ;;
    *)         OS=Linux   ;;
esac

echo $OS

if [[ "$OS" == "Linux" ]] ; then
    NEO_USER="sudo -u neo4j"
else
    NEO_USER=""
fi

# ===========================================
# Extract DATA from NEO4J
# ===========================================

echo "Extracting protein list from Neo4j using $QUERY_FILE..." >&2

# Read the query file directly into cypher-shell using the -f flag
${NEO_USER} cypher-shell \
    --database oncodash \
    --username neo4j \
    --password $(cat neo4j.pass) \
    -f "$QUERY_FILE" | tail -n +2 | tr -d '"' > "$FULL_PROTEIN_PATH"

# ==========================================
# Construct the Network with NeKo
# ==========================================
echo "Running NeKo to generate GRN..." >&2

# Create a folder to keep your NeKo outputs organized
mkdir -p neko-out

# Run NeKo
uv run python NeKo.py --input_file "$FULL_PROTEIN_PATH" --output_dir "$OUTPUT_DIR"

echo "--- Pipeline finished successfully! Results saved in $OUTPUT_DIR ---" >&2

echo "--- Preview of extracted protein IDs ---"
head -n 10 "$FULL_PROTEIN_PATH"