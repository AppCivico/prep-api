-- Deploy prep_api:0047-allow-multiple-responses to pg
-- requires: 0046-add-quick_reply_log

BEGIN;

ALTER TABLE answer ADD COLUMN question_map_iteration INTEGER;
UPDATE answer SET question_map_iteration = 1;
ALTER TABLE answer ALTER COLUMN question_map_iteration SET NOT NULL;

ALTER TABLE stash
    ADD COLUMN times_answered  INTEGER NOT NULL DEFAULT 0,
    ADD COLUMN must_be_reseted BOOLEAN NOT NULL DEFAULT FALSE;
UPDATE stash SET times_answered = 1 WHERE finished = true;


ALTER TABLE category ADD COLUMN can_be_iterated boolean NOT NULL DEFAULT FALSE;
UPDATE category SET can_be_iterated = TRUE where name = 'screening';

COMMIT;
