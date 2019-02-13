-- Deploy prep_api:0024-add-term_signature to pg
-- requires: 0023-add-address-data

BEGIN;

CREATE TABLE term_signature (
    recipient_id INTEGER   NOT NULL REFERENCES recipient(id),
    url          TEXT      NOT NULL,
    signed_at    TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW(),
    UNIQUE( recipient_id, url )
);

COMMIT;
