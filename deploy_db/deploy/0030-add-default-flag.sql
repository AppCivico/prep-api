-- Deploy prep_api:0030-add-default-flag to pg
-- requires: 0029-add-notification

BEGIN;

ALTER TABLE recipient_flags ALTER COLUMN is_part_of_research SET DEFAULT FALSE;
ALTER TABLE recipient_flags ALTER COLUMN is_part_of_research SET NOT NULL;
ALTER TABLE recipient_flags ALTER COLUMN signed_term SET DEFAULT FALSE;
ALTER TABLE recipient_flags ALTER COLUMN signed_term SET NOT NULL;
ALTER TABLE recipient_flags ALTER COLUMN is_prep SET DEFAULT FALSE;
ALTER TABLE recipient_flags ALTER COLUMN is_prep SET NOT NULL;

COMMIT;
