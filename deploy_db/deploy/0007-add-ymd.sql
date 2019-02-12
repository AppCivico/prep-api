-- Deploy prep_api:0007-add-ymd to pg
-- requires: 0006-add-config-on-db

BEGIN;

DELETE FROM appointment;
ALTER TABLE appointment ADD COLUMN appointment_at TIMESTAMP WITHOUT TIME ZONE NOT NULL;

COMMIT;
