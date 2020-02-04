-- Deploy prep_api:0041-add-flags to pg
-- requires: 0040-add-risk-group

BEGIN;

ALTER TABLE recipient_flags
    ADD COLUMN finished_publico_interesse BOOLEAN NOT NULL DEFAULT FALSE,
    ADD COLUMN finished_recrutamento      BOOLEAN NOT NULL DEFAULT FALSE,
    ADD COLUMN finished_quiz_brincadeira  BOOLEAN NOT NULL DEFAULT FALSE;
UPDATE recipient_flags SET finished_quiz = true, finished_recrutamento = true, finished_quiz_brincadeira = true WHERE finished_quiz = true;

COMMIT;
