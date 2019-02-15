-- Deploy prep_api:0026-add-flag to pg
-- requires: 0025-add-signed_term

BEGIN;

ALTER TABLE recipient DROP COLUMN finished_quiz;
ALTER TABLE recipient_flags ADD COLUMN finished_quiz BOOLEAN NOT NULL DEFAULT FALSE;

COMMIT;
