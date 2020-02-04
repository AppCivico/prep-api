-- Deploy prep_api:0043-add-counts to pg
-- requires: 0042-recipient_integration

BEGIN;

ALTER TABLE recipient
    ADD COLUMN count_publico_interesse INTEGER NOT NULL DEFAULT 0,
    ADD COLUMN count_recrutamento      INTEGER NOT NULL DEFAULT 0,
    ADD COLUMN count_quiz_brincadeira  INTEGER NOT NULL DEFAULT 0;

COMMIT;
