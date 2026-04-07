# To do : 
* Create a `prepare.sh` file that'll : 
    1. Download OpenTargets and OmniPath adpaters and custom transformers from OncodashKB 
    2. ~~Download hgnc_complete_set.txt file~~  
* Create a `.sh` file that'll : 
    1. Run Ontoweaver : Build the SKG via `weave_KG2BM.py`
        * Pathways & GO? 
    2. Run the Query : Give a biological context to extract a **list of proteins**
        * Ideal to write as a user your `.yaml` file with your own context 
    3. Run NeKo : Build the Network for the BM
* Cite OncodashKB in this `README.md`. 

# KG2BM
*M2 internship project with Institut de Mathémathique de Marseille (I2M) collaborating with Institut Pasteur (Paris).*  
Automating the Construction of Contextual Knowledge Graphs (using ontoweaver) for Boolean Modeling in Systems Biomedicine.  

# Datasets used 
## Human Protein Atlas
[Consensus RNA data](https://www.proteinatlas.org/humanproteome/tissue/data#consensus_tissues_rna)

[Click here to download the data](https://www.proteinatlas.org/download/tsv/rna_tissue_consensus.tsv.zip)  
| Gene      | Gene name | Tissue | nTPM
| ----------- | ----------- | ---- | ----|
| Ensemble Id      | Hugo Symbole (HGNC) | tissue name | normalized expression |


## OncoKB
Need to ask permission to download this data that you'll find in the `Actionable Genes` tab once permission accepeted : https://faq.oncokb.org/licensing
| Level | Gene | Alterations
| --- | ---| ---
| Therapeutic level of Evidence | Hugo Symbol (HGNC) |  Alteration type(s)

## OmniPath
Out of the 5 db we used the **Networks** db (with 36 columns) 
## Open Targets
3 datasets were used from this plateforme : 
- [Targets](https://platform.opentargets.org/downloads/target/access) : Defines the biological **nodes** (genes and proteins), providing their genomic properties and tractability.
- [Drug - Mechanisme of actions](https://platform.opentargets.org/downloads/drug_mechanism_of_action/access) : Defines the **edges** connecting drugs to targets, specifying the exact biochemical interaction (e.g., inhibitor, agonist).
- [Drug/Clinical Candidates](https://platform.opentargets.org/downloads/drug_molecule/access) : Defines the therapeutic molecule **nodes**, detailing their chemical structures (SMILES) and clinical trial status.

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
 sudo bash <path to .sh file in /biocypher-out>

# Recursively change ownership of the Neo4j data directory to the neo4j user and group to ensure the database service has read/write permissions.
sudo chown -R neo4j:neo4j /var/lib/neo4j/data

# Start/Launch neo4j 
 sudo -u neo4j neo4j-admin server start