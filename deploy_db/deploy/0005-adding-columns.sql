-- Deploy prep_api:0005-adding-columns to pg
-- requires: 0004-update-appointment_window

BEGIN;

CREATE TABLE appointment_window_days_of_week (
    appointment_window_id INTEGER NOT NULL REFERENCES appointment_window(id),
    day_of_week           SMALLINT NOT NULL
);

COMMIT;
