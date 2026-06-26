# KG2BM
*M2 internship project at Institut de Mathémathique de Marseille (I2M) collaborating with Institut Pasteur (Paris).*  
Automating the Construction of Gene Regulation Networks (GRNs) (with NeKo) with Knowledge Graphs (KG) (with Ontoweaver) for Boolean Modeling in Systems Biomedicine. 

This is an application for gastric cancer : *Flobak et al., 2015* https://doi.org/10.1371/journal.pcbi.1004426


# 1. Users Workflow for KG2BM

### <ins>Step 1</ins> : Select your data according to your biological question
### <ins>Step 2</ins> : Write your Cypher query to extract context-sepcific genes 
### <ins>Step 3</ins> : Select a connection startegy for the network construction  


# 2. KG2BM's Workflow 

## Step 1 : Install KG2BM pipeline 
**Clone** the repository and use **UV**. This automatically creats a virtual environment : 
```` sh
git clone https://github.com/nina-alger/KG2BM.git
cd KG2BM
uv sync
 ````

## Step 2 : Build the KG with Ontoweaver and Biocypher
> <span style="color: #4169E1;">***Note*** : You must first</span> 
> -  <span style="color: #4169E1;">**Create a Neo4j account** : https://neo4j.com/ </span>
> -  <span style="color: #4169E1;">**Install Neo4j** : https://neo4j.com/docs/operations-manual/current/installation/</span> 
1. **STOP** NEO4J before building KG

2. Build KG using *your* data
```` sh 
uv run weave_KG2BM.py
 ```` 
> <span style="color: #4169E1;">***Note*** : 
> 
> <span style="color: #4169E1;">For now `weave_KG2BM.py` is specific to the application : **Gastric cancer**. If you wish to change the KG's data, you must also change the OntoWeaver's **adapters** and **schema**.</span> 
> 
> <span style="color: #4169E1;"> Please refer yourself to the **Onotweaver <ins>documentation</ins> (https://ontoweaver.readthedocs.io/en/latest/)** and **<ins>github</ins> (https://github.com/oncodash/ontoweaver)**</span>  
3. **START** NEO4J after building KG

## Step 3 : Build the GRN with NeKo based on the extracted context-specific gene list queried from the KG with Neo4j 
> <span style="color: #4169E1;">***Note***</span>
> 
> <span style="color: #4169E1;">If you wish to first **explore** the associated genes to the query use **Neo4j** graph database management system visalization tool</span>
```` sh
bash makeGRN.sh 
 ```` 
> <span style="color: #4169E1;">***Note***</span> 
>
> <span style="color: #4169E1;">This takes in account a `query.cypher` file with **your** written query</span> 
>
> <span style="color: #4169E1;">This also runs `NeKo.py`. But before, you must select your **connection startegy** from NeKo. Please refere to their documentation : https://sysbio-curie.github.io/Neko/</span> 
> 
> <span style="color: #4169E1;"> If you prefere to  

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
- 1 `biocypher_config.yaml` file for the ontology of the graph
- 1 `schema_config.yaml` file to coordinate every node and edge (and properties) of the graph

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