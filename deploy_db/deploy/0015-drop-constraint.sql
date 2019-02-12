-- Deploy prep_api:0015-drop-constraint to pg
-- requires: 0014-add-external_integration_token

BEGIN;

ALTER TABLE answer DROP CONSTRAINT answer_recipient_id_question_id_key;

COMMIT;
