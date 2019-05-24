-- Deploy prep_api:0034-signature-url to pg
-- requires: 0033-update-city

BEGIN;

ALTER TABLE term_signature ALTER COLUMN url DROP NOT NULL;
ALTER TABLE term_signature ADD COLUMN signed BOOLEAN NOT NULL;

COMMIT;
