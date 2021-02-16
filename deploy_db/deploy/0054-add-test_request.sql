-- Deploy prep_api:0054-add-test_request to pg
-- requires: 0053-add-reminder

BEGIN;


CREATE TABLE test_request (
    id            SERIAL  PRIMARY KEY,
    recipient_id  INTEGER NOT NULL REFERENCES recipient("id"),
    address       TEXT    NOT NULL,
    contact       TEXT    NOT NULL,
    created_at    TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW()
);

COMMIT;
