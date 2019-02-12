-- Deploy prep_api:0019-add-logic-jump to pg
-- requires: 0018-add-invite-count

BEGIN;

CREATE TABLE stash (
    id              SERIAL    PRIMARY KEY,
    recipient_id    INTEGER   NOT NULL REFERENCES recipient(id),
    question_map_id INTEGER   NOT NULL REFERENCES question_map(id),
    value           JSON      NOT NULL DEFAULT '{}',
    updated_at      TIMESTAMP WITHOUT TIME ZONE,
    created_at      TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOw(),
    UNIQUE( recipient_id, question_map_id )
);

COMMIT;
