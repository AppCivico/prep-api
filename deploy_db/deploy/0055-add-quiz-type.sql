-- Deploy prep_api:0055-add-quiz-type to pg
-- requires: 0054-add-test_request

BEGIN;

INSERT INTO category (id, name, can_be_iterated) VALUES (8, 'duvidas_nao_prep', true);

COMMIT;
