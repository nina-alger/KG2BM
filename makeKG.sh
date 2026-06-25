#!/usr/bin/env bash

# ==========================================
# THIS CODE BUILDs THE KG BY : 
# STOPPING NEO4J 
# RUNNING ONTOWEAVER
# STARTING NEO4J 
# ==========================================

# Our safety check: If any command fails, stop the script immediately.
set -e
set -euo pipefail

# ==========================================
# Step 1: Build the Knowledge Graph
# ==========================================
echo "Stopping Neo4j to allow bulk import..." >&2
# NEO_USER="sudo -u neo4j"

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
    # When using Neo4j installed on system (like Ubuntu's packaged version),
    # the current directory must be writable by user "neo4j",
    # and all parent directories must be executable by "other".
    # Every interaction with the database must be done by user "neo4j",
    # and the import will try to write reports in the current directory.
    NEO_USER="sudo -u neo4j"
    # export JAVA_HOME="/usr/lib/jvm/java-21-openjdk-amd64"
else
    NEO_USER=""
fi

# Turn off the database so we can safely inject the CSV files
${NEO_USER} neo4j-admin server stop

echo "Running OntoWeaver to build the knowledge graph..." >&2
# Ensure Python environment is activated before running the script :
cmd="uv run python weave_KG2BM.py"

echo "Executing command: " >&2
echo "$cmd" >&2

$cmd > tmp.sh

echo "Injecting data into Neo4j..." >&2
chmod a+x tmp.sh
${NEO_USER} $SHELL tmp.sh

echo "Restarting Neo4j server..." >&2
# Turn the database back on
${NEO_USER} neo4j-admin server start

echo "Everything is OK, you can now call: ./makeGRN.sh. <your_query.cypher>" >&2