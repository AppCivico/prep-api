-- Deploy prep_api:0053-add-reminder to pg
-- requires: 0052-update-col

BEGIN;

CREATE TABLE prep_reminder (
    id           SERIAL PRIMARY KEY,
    recipient_id INTEGER NOT NULL REFERENCES recipient ("id") UNIQUE,

    reminder_before          BOOLEAN NOT NULL DEFAULT FALSE,
    reminder_before_interval INTERVAL,

    reminder_after          BOOLEAN NOT NULL DEFAULT FALSE,
    reminder_after_interval INTERVAL,

    reminder_temporal_wait_until   TIMESTAMP WITHOUT TIME ZONE,
    reminder_temporal_last_sent_at TIMESTAMP WITHOUT TIME ZONE,
    reminder_temporal_confirmed_at TIMESTAMP WITHOUT TIME ZONE,

    reminder_running_out              BOOLEAN NOT NULL DEFAULT FALSE,
    reminder_running_out_date         DATE,
    reminder_running_out_last_sent_at TIMESTAMP WITHOUT TIME ZONE,

    errmsg TEXT
);

ALTER TABLE recipient
    DROP COLUMN prep_reminder_before,
    DROP COLUMN prep_reminder_before_interval,
    DROP COLUMN prep_reminder_after,
    DROP COLUMN prep_reminder_after_interval,
    ADD COLUMN prep_reminder_on_demand BOOLEAN NOT NULL DEFAULT FALSE;


ALTER TABLE notification_queue ADD COLUMN prep_reminder_id INTEGER REFERENCES prep_reminder ("id");

INSERT INTO notification_type (id, name) VALUES
    (9, 'prep_reminder_before'),
    (10, 'prep_reminder_after');

COMMIT;
