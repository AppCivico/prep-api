-- Deploy prep_api:0052-update-col to pg
-- requires: 0051-add-triagem-category

BEGIN;


ALTER TABLE recipient DROP COLUMN prep_reminder_before_ts,
    ADD COLUMN prep_reminder_before_interval INTERVAL;

COMMIT;
