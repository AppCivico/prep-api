-- Deploy prep_api:0023-add-address-data to pg
-- requires: 0022-updating-integration_token

BEGIN;

ALTER TABLE calendar RENAME city TO address_city;
ALTER TABLE calendar
    ADD COLUMN address_state      TEXT,
    ADD COLUMN address_street     TEXT,
    ADD COLUMN address_zipcode    TEXT,
    ADD COLUMN address_number     INTEGER,
    ADD COLUMN address_district   TEXT,
    ADD COLUMN address_complement TEXT,
    ADD COLUMN phone              TEXT;

UPDATE calendar SET address_street = '', address_state = '', address_zipcode = '', address_number = 0, address_district = '';
ALTER TABLE calendar
    ALTER COLUMN address_street SET NOT NULL,
    ALTER COLUMN address_state SET NOT NULL,
    ALTER COLUMN address_zipcode SET NOT NULL,
    ALTER COLUMN address_number SET NOT NULL,
    ALTER COLUMN address_district SET NOT NULL;

COMMIT;
