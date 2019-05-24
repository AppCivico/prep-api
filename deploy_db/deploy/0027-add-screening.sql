-- Deploy prep_api:0027-add-screening to pg
-- requires: 0026-add-flag

BEGIN;

CREATE TABLE screenings (
    id              SERIAL PRIMARY KEY,
    recipient_id    INTEGER NOT NULL REFERENCES recipient(id),
    question_map_id INTEGER NOT NULL REFERENCES question_map(id),
    answers         JSON    NOT NULL,
    created_at      TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW()
);

COMMIT;
