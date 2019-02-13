-- Deploy prep_api:0022-updating-integration_token to pg
-- requires: 0021-add-count_share

BEGIN;

ALTER TABLE recipient ALTER COLUMN integration_token DROP NOT NULL;
ALTER TABLE recipient ALTER COLUMN integration_token DROP DEFAULT;

COMMIT;
