-- Deploy prep_api:0049-is_prep-default to pg
-- requires: 0048-add-cols

BEGIN;

ALTER TABLE recipient_flags ALTER COLUMN is_prep DROP DEFAULT;
UPDATE recipient_flags SET is_prep = null;

COMMIT;
