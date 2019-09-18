-- Deploy prep_api:0038-add-notification_type to pg
-- requires: 0037-custom_quota_time

BEGIN;

INSERT INTO notification_type (id, name) VALUES (8, 'no_appointment_after_7_days_quiz');

COMMIT;
