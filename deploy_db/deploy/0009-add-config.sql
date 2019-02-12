-- Deploy prep_api:0009-add-config to pg
-- requires: 0008-add-question_map_id

BEGIN;

CREATE TABLE config (
    id    SERIAL PRIMARY KEY,
    key   TEXT NOT NULL,
    value TEXT NOT NULL
);
INSERT INTO config (key, value) VALUES ('ACCESS_TOKEN', 'undef');

COMMIT;
