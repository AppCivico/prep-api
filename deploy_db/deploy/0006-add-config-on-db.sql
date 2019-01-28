-- Deploy prep_api:0006-add-config-on-db to pg
-- requires: 0005-adding-columns

BEGIN;

ALTER TABLE calendar ADD COLUMN client_id VARCHAR, ADD COLUMN client_secret VARCHAR, ADD COLUMN refresh_token VARCHAR;
UPDATE calendar SET client_id = '', client_secret = '', refresh_token = '';
ALTER TABLE calendar ALTER COLUMN client_id SET NOT NULL;
ALTER TABLE calendar ALTER COLUMN client_secret SET NOT NULL;
ALTER TABLE calendar ALTER COLUMN refresh_token SET NOT NULL;

COMMIT;
