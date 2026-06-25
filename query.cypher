// THIS QUERY EXTRACTS A LIST OF GENES ASSOCIATED TO YOUR CONTEXT 
// CONTEXT : FLOBAK ET AL., 2015
// - GASTRIC CANCER 
// - 7 DRUG TARGETS 


// 1 - FIND GENES ASSOCIATED TO GASTRIC CANCER
MATCH (g:Gene)-[:AssociatedTo]->(c:Cancer)
WHERE c.id IN ['Esophagogastric Adenocarcinoma:cancer', 'Esophagogastric Cancer:cancer']
RETURN g.gene_symbol

UNION

// 2 - FIND THE 7 DRUG TARGETED GENES 
MATCH (g:Gene)
WHERE g.gene_symbol IN ['PIK3CA', 'MAP2K1', 'AKT1', 'MAP3K7', 'MAPK14', 'GSK3B', 'CTNNB1']
RETURN g.gene_symbol


// RETURNS THE GENE SYMBOLE OF GENES (aka : their HUGO symbol)
// YOU CAN ADD MORE TO THIS QUERY (EX : genes associated to apoptosis pathway)