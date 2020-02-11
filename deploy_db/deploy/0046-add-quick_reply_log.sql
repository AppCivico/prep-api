-- Deploy prep_api:0046-add-quick_reply_log to pg
-- requires: 0045-add-interaction

BEGIN;

CREATE TABLE quick_reply_log (
    recipient_id INTEGER   NOT NULL REFERENCES recipient(id),
    button_text  TEXT      NOT NULL,
    payload      TEXT      NOT NULL,
    created_at   TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now()
);

COMMIT;
