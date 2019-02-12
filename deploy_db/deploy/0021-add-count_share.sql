-- Deploy prep_api:0021-add-count_share to pg
-- requires: 0020-add-flag

BEGIN;

ALTER TABLE recipient ADD COLUMN count_share INTEGER NOT NULL DEFAULT 0;


COMMIT;
