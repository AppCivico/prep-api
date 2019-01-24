-- Deploy prep_api:0003-add-calendar to pg
-- requires: 0002-update-recipient

BEGIN;

CREATE TABLE calendar (
    id                SERIAL PRIMARY KEY,
    google_id         VARCHAR NOT NULL UNIQUE,
    name              TEXT    NOT NULL,
    time_zone         TEXT    NOT NULL,
    token             VARCHAR,
    token_valid_until TIMESTAMP WITHOUT TIME ZONE,
    updated_at        TIMESTAMP WITHOUT TIME ZONE,
    created_at        TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE appointment_window (
    id          SERIAL    PRIMARY KEY,
    calendar_id INTEGER   REFERENCES calendar(id) NOT NULL,
    start_time  TIME      NOT NULL,
    end_time    TIME      NOT NULL,
    quotas      INTEGER   NOT NULL,
    updated_at  TIMESTAMP WITHOUT TIME ZONE,
    created_at  TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE appointment (
    id                    SERIAL PRIMARY KEY,
    recipient_id          INTEGER NOT NULL REFERENCES recipient(id),
    appointment_window_id INTEGER NOT NULL REFERENCES appointment_window(id),
    quota_number          INTEGER NOT NULL,
    updated_at            TIMESTAMP WITHOUT TIME ZONE,
    created_at            TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW()
);

COMMIT;
