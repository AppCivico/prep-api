-- Deploy prep_api:0062-add-calendar-holidays to pg
-- requires: 0061-add-uniq-combina_voucher

BEGIN;

CREATE TABLE calendar_holidays (
    id           SERIAL    PRIMARY KEY,
    calendar_id  INTEGER   NOT NULL REFERENCES calendar("id") UNIQUE,
    year         INTEGER   NOT NULL,
    content      JSON      NOT NULL DEFAULT '{}',
    last_sync_at TIMESTAMP WITHOUT TIME ZONE,
    next_sync_at TIMESTAMP WITHOUT TIME ZONE
);

COMMIT;
