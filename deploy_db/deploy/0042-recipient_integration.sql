-- Deploy prep_api:0042-recipient_integration to pg
-- requires: 0041-add-flags

BEGIN;

CREATE TABLE recipient_integration (
    id            SERIAL     PRIMARY KEY,
    recipient_id  INTEGER    NOT NULL REFERENCES recipient(id) UNIQUE,
    data          JSON       NOT NULL DEFAULT '{}',
    retry_count   INTEGER    NOT NULL DEFAULT 0,
    err_msg       TEXT,
    next_retry_at TIMESTAMP  WITHOUT TIME ZONE,
    created_at    TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW()
);

COMMIT;
