-- Deploy prep_api:0045-add-interaction to pg
-- requires: 0044-add-phone-instagram

BEGIN;

CREATE TABLE interaction (
    id           SERIAL    PRIMARY KEY,
    recipient_id INTEGER   NOT NULL REFERENCES recipient(id),
    started_at   TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW(),
    closed_at    TIMESTAMP WITHOUT TIME ZONE
);

COMMIT;
