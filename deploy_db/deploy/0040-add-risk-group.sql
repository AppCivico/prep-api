-- Deploy prep_api:0040-add-risk-group to pg
-- requires: 0039-add-categories

BEGIN;

ALTER TABLE recipient_flags ADD COLUMN risk_group BOOLEAN;

COMMIT;
