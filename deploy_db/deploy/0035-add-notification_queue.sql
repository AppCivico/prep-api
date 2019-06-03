-- Deploy prep_api:0035-add-notification_queue to pg
-- requires: 0034-signature-url

BEGIN;

CREATE TABLE notification_type (
    id   INTEGER PRIMARY KEY,
    name TEXT   NOT NULL UNIQUE
);
INSERT INTO notification_type (id, name) VALUES
    (1, 'quiz_not_finished'), (2, 'upcoming_appointment'),
    (3, 'fa_7_days'), (4, 'fa_17_days'),
    (5, 'ra_15_days'), (6, 'ra_45_days'),
    (7, '3_month_ra_45_days');

CREATE TABLE notification_queue (
    id           SERIAL PRIMARY KEY,
    type_id      INTEGER NOT NULL REFERENCES notification_type(id),
    recipient_id INTEGER NOT NULL REFERENCES recipient(id),
    err_msg      TEXT,
    sent_at      TIMESTAMP WITHOUT TIME ZONE,
    wait_until   TIMESTAMP WITHOUT TIME ZONE,
    created_at   TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW()
);

COMMIT;
