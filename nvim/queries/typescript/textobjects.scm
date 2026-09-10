; (statement_block
;   [
;     (lexical_declaration)
;     (expression_statement)
;     (return_statement)
;     (for_statement)
;     (for_in_statement)
;     (if_statement)
;     (switch_statement)
;     (try_statement)
;     (throw_statement)
;   ] @statement.outer)
(statement_block
  (_) @statement.outer)
