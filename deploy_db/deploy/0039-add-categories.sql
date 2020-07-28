-- Deploy prep_api:0039-add-categories to pg
-- requires: 0038-add-notification_type

BEGIN;

INSERT INTO category (id, name) VALUES (3, 'publico_interesse'), (4, 'recrutamento'), (5, 'quiz_brincadeira');

COMMIT;
