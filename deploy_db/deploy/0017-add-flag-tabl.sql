-- Deploy prep_api:0017-add-flag-tabl to pg
-- requires: 0016-add-quiz-count

BEGIN;

CREATE TABLE recipient_flags (
    recipient_id             INTEGER PRIMARY KEY REFERENCES recipient(id),
    is_eligible_for_research BOOLEAN,
    is_part_of_research      BOOLEAN,
    is_prep                  BOOLEAN,
    updated_at               TIMESTAMP WITHOUT TIME ZONE
);
INSERT INTO recipient_flags (recipient_id) SELECT id AS recipient_id FROM recipient;

COMMIT;
