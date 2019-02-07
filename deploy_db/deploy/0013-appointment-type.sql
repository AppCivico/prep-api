-- Deploy prep_api:0013-appointment-type to pg
-- requires: 0012-question_map-category

BEGIN;

CREATE TABLE appointment_type (
    id   INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);
INSERT INTO appointment_type (id, name) VALUES (1, 'recrutamento'), (2, 'emergencial');
ALTER TABLE appointment ADD COLUMN appointment_type_id INTEGER REFERENCES appointment_type(id);
UPDATE appointment SET appointment_type_id = 1;

COMMIT;
