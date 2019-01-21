-- Deploy prep_api:0002-update-recipient to pg
-- requires: 0001-add-question-answers

BEGIN;

ALTER TABLE recipient ADD COLUMN question_notification_sent_at TIMESTAMP WITHOUT TIME ZONE, ADD COLUMN finished_quiz BOOLEAN NOT NULL DEFAULT FALSE;

COMMIT;
