-- Deploy prep_api:0037-custom_quota_time to pg
-- requires: 0036-add-created_by_chatbot

BEGIN;

ALTER TABLE appointment_window DROP COLUMN custom_quota_time;
ALTER TABLE appointment_window ADD COLUMN custom_quota_time INTERVAL;

COMMIT;
