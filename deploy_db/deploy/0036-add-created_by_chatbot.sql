-- Deploy prep_api:0036-add-created_by_chatbot to pg
-- requires: 0035-add-notification_queue

BEGIN;

ALTER TABLE appointment
    ADD COLUMN created_by_chatbot BOOLEAN DEFAULT FALSE,
    ADD COLUMN notification_created_at TIMESTAMP WITHOUT TIME ZONE;
UPDATE appointment SET created_by_chatbot = TRUE;

ALTER TABLE notification_queue ADD COLUMN text TEXT;

COMMIT;
