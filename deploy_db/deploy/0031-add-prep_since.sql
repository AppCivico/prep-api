-- Deploy prep_api:0031-add-prep_since to pg
-- requires: 0030-add-default-flag

BEGIN;

ALTER TABLE recipient_flags ADD COLUMN prep_since TIMESTAMP WITHOUT TIME ZONE;

COMMIT;
