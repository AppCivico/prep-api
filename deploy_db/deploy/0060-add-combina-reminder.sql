-- Deploy prep_api:0060-add-combina-reminder to pg
-- requires: 0059-add-combina_city

BEGIN;

CREATE TABLE combina_reminder (
    id                     SERIAL PRIMARY KEY,
    recipient_id           INTEGER NOT NULL REFERENCES recipient("id") UNIQUE,
    reminder_hours_before  TIME,
    reminder_hour_exact    TIME,
    reminder_22h           TIMESTAMP WITHOUT TIME ZONE,
    reminder_double        TIMESTAMP WITHOUT TIME ZONE
);

COMMIT;
