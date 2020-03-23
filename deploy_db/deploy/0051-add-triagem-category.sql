-- Deploy prep_api:0051-add-triagem-category to pg
-- requires: 0050-add-category

BEGIN;

INSERT INTO category (id, name, can_be_iterated) VALUES (7, 'triagem', true);

COMMIT;
