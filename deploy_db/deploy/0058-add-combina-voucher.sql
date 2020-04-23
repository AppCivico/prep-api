-- Deploy prep_api:0058-add-combina-voucher to pg
-- requires: 0057-add-notification-type

BEGIN;

CREATE TABLE combina_voucher (
    id           SERIAL PRIMARY KEY,
    recipient_id INTEGER REFERENCES recipient("id"),
    assigned_at  TIMESTAMP WITHOUT TIME ZONE,
    value        TEXT NOT NULL
);

COMMIT;
