-- Deploy prep_api:0059-add-combina_city to pg
-- requires: 0058-add-combina-voucher

BEGIN;

ALTER TABLE recipient ADD COLUMN combina_city TEXT;

COMMIT;
