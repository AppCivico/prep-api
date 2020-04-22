-- Deploy prep_api:0056-add-running-out-data to pg
-- requires: 0055-add-quiz-type

BEGIN;

ALTER TABLE prep_reminder
    ADD COLUMN reminder_running_out_count INTEGER,
    ADD COLUMN reminder_running_out_wait_until TIMESTAMP WITHOUT TIME ZONE;
INSERT INTO notification_type (id, name) VALUES (11, 'prep_reminder_running_out');

COMMIT;
