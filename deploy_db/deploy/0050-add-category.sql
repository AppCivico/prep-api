-- Deploy prep_api:0050-add-category to pg
-- requires: 0049-is_prep-default

BEGIN;

INSERT INTO category (id, name, can_be_iterated) VALUES (6, 'deu_ruim_nao_tomei', true);

COMMIT;
