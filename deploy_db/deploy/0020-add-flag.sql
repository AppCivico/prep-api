-- Deploy prep_api:0020-add-flag to pg
-- requires: 0019-add-logic-jump

BEGIN;

ALTER TABLE recipient_flags ADD COLUMN is_target_audience BOOLEAN;

COMMIT;
