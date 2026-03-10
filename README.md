# KG2BM
*M2 internship project with Institut de Mathémathique de Marseille (I2M) collaborating with Institut Pasteur (Paris).*  
Automating the Construction of Contextual Knowledge Graphs (using ontoweaver) for Boolean Modeling in Systems Biomedicine.  

# Datasets used 
## Human Protein Atlas
[Consensus RNA data](https://www.proteinatlas.org/download/tsv/rna_tissue_consensus.tsv.zip)
## OncoKB
Need to ask permission to download this data that you'll find in the `Actionable Genes` tab
## OmniPath
Out of the 5 db we used Networks
## Open Targets
3 datsets were used from this plateforme : 
- [Targets](https://platform.opentargets.org/downloads/target/access)
- [Drug - Mechanisme of actions](https://platform.opentargets.org/downloads/drug_mechanism_of_action/access)
- [Drug/Clinical Candidates](https://platform.opentargets.org/downloads/drug_molecule/access) 

# Ontoweaver & BioCypher
- 1 adapter for each dataset (**6 in total for this KG**)
    - Transformers for OmniPath and Open Targets
- 1 `biocypher-config.yaml` file for the ontology of the graph
- 1 `schema-config.yaml` file to coordinate every node and edge (and properties) of the graph

# Build SKG 
**Use** Ontoweaver with `weave_KG2BM.py` **running** `$ ./make.sh` in terminal.

# Visualise with Neo4j 
> :warning: Database name in `neo4j.conf` must be the same as in `.sh` file in **/biocypher-out** : here we named it **`neo4j`**. :warning:
>  
> To change it `$ sudo nano <path to neo4j.conf file>`

```` sh
# Stop neo4j before import data
 sudo -u neo4j neo4j-admin server stop 
 
 # Import SKG 
 sudo bash <path to .sh file>

# Recursively change ownership of the Neo4j data directory to the neo4j user and group to ensure the database service has read/write permissions.
sudo chown -R neo4j:neo4j /var/lib/neo4j/data

# Start/Launch neo4j 
 sudo -u neo4j neo4j-admin server start