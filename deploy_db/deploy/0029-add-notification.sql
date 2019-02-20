-- Deploy prep_api:0029-add-notification to pg
-- requires: 0028-add-question-rules

BEGIN;

CREATE TABLE external_notification (
    id           SERIAL    PRIMARY KEY,
    recipient_id INTEGER   NOT NULL REFERENCES recipient(id),
    url          TEXT      NOT NULL,
    sent_at      TIMESTAMP WITHOUT TIME ZONE,
    created_at   TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW()
);


COMMIT;
