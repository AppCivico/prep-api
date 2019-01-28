-- Deploy prep_api:0004-update-appointment_window to pg
-- requires: 0003-add-calendar

BEGIN;

ALTER TABLE appointment_window ADD COLUMN custom_quota_time TIME;

COMMIT;
