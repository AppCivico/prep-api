-- Deploy prep_api:0010-add-city to pg
-- requires: 0009-add-config

BEGIN;

ALTER TABLE calendar ADD COLUMN city TEXT;
UPDATE calendar SET city = 'São Paulo';
ALTER TABLE calendar ALTER COLUMN city SET NOT NULL;

COMMIT;
