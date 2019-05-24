-- Deploy prep_api:0025-add-signed_term to pg
-- requires: 0024-add-term_signature

BEGIN;

ALTER TABLE recipient_flags ADD COLUMN signed_term BOOLEAN;

COMMIT;
