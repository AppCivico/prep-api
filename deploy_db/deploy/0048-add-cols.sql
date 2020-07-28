-- Deploy prep_api:0048-add-cols to pg
-- requires: 0047-allow-multiple-responses

BEGIN;

ALTER TABLE recipient ADD COLUMN voucher_type TEXT CHECK ( voucher_type IN ( 'sisprep', 'combina', 'sus' ) );

ALTER TABLE recipient
    ADD COLUMN prep_reminder_before BOOLEAN NOT NULL DEFAULT FALSE,
    ADD COLUMN prep_reminder_before_ts TIMESTAMP WITHOUT TIME ZONE,
    ADD COLUMN prep_reminder_after BOOLEAN NOT NULL DEFAULT FALSE,
    ADD COLUMN prep_reminder_after_interval INTERVAL;


COMMIT;
