-- Deploy prep_api:0008-add-question_map_id to pg
-- requires: 0007-add-ymd

BEGIN;

ALTER TABLE question ADD COLUMN question_map_id INTEGER REFERENCES question_map(id);
UPDATE question SET question_map_id = 2;
ALTER TABLE question ALTER COLUMN question_map_id SET NOT NULL;
ALTER TABLE question DROP CONSTRAINT question_code_key;

COMMIT;
