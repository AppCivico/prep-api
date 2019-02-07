-- Deploy prep_api:0012-question_map-category to pg
-- requires: 0011-appointment

BEGIN;

CREATE TABLE category (
    id   INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);
INSERT INTO category (id, name) VALUES (1, 'quiz'), (2, 'screening');

ALTER TABLE question_map ADD COLUMN category_id INTEGER REFERENCES category(id);
UPDATE question_map SET category_id = 1;
ALTER TABLE question_map ALTER COLUMN category_id SET NOT NULL;

COMMIT;
