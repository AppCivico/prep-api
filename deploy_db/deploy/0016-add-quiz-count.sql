-- Deploy prep_api:0016-add-quiz-count to pg
-- requires: 0015-drop-constraint

BEGIN;

ALTER TABLE recipient ADD COLUMN count_sent_quiz INTEGER NOT NULL DEFAULT 0;

COMMIT;
