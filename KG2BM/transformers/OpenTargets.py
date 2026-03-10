# Is registered in the make.sh file (not in the weave.py) 
import logging

import ontoweaver

class urls_to_prop(ontoweaver.base.Transformer):

    class ValueMaker(ontoweaver.make_value.ValueMaker):
        def __init__(self,
            key,
            raise_errors: bool = True
        ):
            self.key = key
            super().__init__(raise_errors)

        def __call__(self, columns, row, i):
            for col in columns:
                if col not in row:
                    self.error(f"Column '{col}' not found in data", section="map.call",
                               exception=ontoweaver.exceptions.TransformerDataError)
                refs = row[col]
                if refs is not None:
                    for ref in refs:
                        if self.key in ref:
                            for item in ref[self.key]:
                                yield item

    def __init__(self,
            properties_of,
            label_maker = None,
            branching_properties = None,
            columns=None,
            output_validator = None,
            multi_type_dict = None,
            raise_errors = True,
            key = "urls",
            **kwargs
        ):

        self.value_maker = self.ValueMaker(key, raise_errors)

        super().__init__(
            properties_of,
            self.value_maker,
            label_maker,
            branching_properties,
            columns,
            output_validator,
            multi_type_dict,
            raise_errors=raise_errors,
            **kwargs
        )


class access_proteins(ontoweaver.base.Transformer): 
# Specifically for protein entries that come from UniProt Swiss-Prot.

    def __init__(self,
        properties_of,
        label_maker = None,
        branching_properties = None,
        columns=None,
        output_validator = None,
        multi_type_dict = None,
        raise_errors = True,
        separator = None,
        **kwargs
    ):
        """
        FIXME doc

        Initializes the transformer by setting up two sub-transformers: 
        one for splitting a delimited string (column 0), and one for 
        accessing nested dictionary-like data (columns 1+).
        """

        logging.debug(f"COLUMNS: {type(columns)}\n{columns}")
        assert columns, "I need 2 keys to operate."
        assert isinstance(columns, list), "I need several keys."
        assert len(columns) >= 2, "I need 2 keys, or you should use either split or nested."

        # STEP 1: Set up the 'split' transformer.
        # This will process ONLY the first column (columns[0]).
        self.split = ontoweaver.transformer.split(
            properties_of,
            label_maker,
            branching_properties,
            [columns[0]],
            output_validator,
            multi_type_dict,
            raise_errors=raise_errors,
            separator = separator,
            **kwargs,
        )

        keys = columns[1:]
        if not isinstance(keys, list):
            keys = [keys]

        # STEP 2: Set up the 'nested' transformer.
        self.nested = ontoweaver.transformer.nested(
            properties_of,
            label_maker,
            branching_properties,
            keys,
            output_validator,
            multi_type_dict,
            raise_errors=raise_errors,
            **kwargs,
        )

        super().__init__(properties_of,
            self.split.value_maker,
            label_maker,
            branching_properties,
            columns,
            output_validator,
            multi_type_dict,
            raise_errors=raise_errors,
            **kwargs
        )

    def __call__(self, row, i):
        for rowval in self.split.value_maker(self.split.columns, row, i):
            if rowval:
                if rowval['source']=="uniprot_swissprot":
                    val = self.nested.value_maker(self.nested.keys, rowval, i)
                    assert isinstance(val, list)
                    for v in val:
                        value, edge_type, node_type, reverse_edge = self.create(v, row)
                        if ontoweaver.base.is_not_null(value):
                            yield value, edge_type, node_type, reverse_edge

