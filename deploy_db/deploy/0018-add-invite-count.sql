-- Deploy prep_api:0018-add-invite-count to pg
-- requires: 0017-add-flag-tabl

BEGIN;

ALTER TABLE recipient ADD COLUMN count_invited_research INTEGER NOT NULL DEFAULT 0;

COMMIT;
