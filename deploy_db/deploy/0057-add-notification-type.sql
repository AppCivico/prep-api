-- Deploy prep_api:0057-add-notification-type to pg
-- requires: 0056-add-running-out-data

BEGIN;

INSERT INTO notification_type (id, name) VALUES (12, 'prep_reminder_running_out_followup');

COMMIT;
