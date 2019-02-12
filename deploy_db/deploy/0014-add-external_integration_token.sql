-- Deploy prep_api:0014-add-external_integration_token to pg
-- requires: 0013-appointment-type

BEGIN;

CREATE TABLE external_integration_token (
    id          SERIAL PRIMARY KEY,
    value       TEXT NOT NULL,
    assigned_at TIMESTAMP WITHOUT TIME ZONE,
    created_at  TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW()
);
ALTER TABLE recipient ADD COLUMN using_external_token BOOLEAN NOT NULL DEFAULT FALSE;

COMMIT;
