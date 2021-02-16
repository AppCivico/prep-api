-- Deploy prep_api:0044-add-phone-instagram to pg
-- requires: 0043-add-counts

BEGIN;

ALTER TABLE recipient
    ADD COLUMN phone TEXT,
    ADD COLUMN instagram TEXT;

COMMIT;
