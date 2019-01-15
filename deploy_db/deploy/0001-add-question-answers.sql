-- Deploy prep_api:0001-add-question-answers to pg
-- requires: 0000-appschema

BEGIN;

CREATE TABLE question (
    id                  SERIAL PRIMARY KEY,
    code                VARCHAR(4) NOT NULL UNIQUE,
    type                TEXT       NOT NULL CHECK ( type IN ( 'multiple_choice', 'open_text' ) ),
    text                TEXT       NOT NULL,
    multiple_choices    JSON,
    extra_quick_replies JSON,
    is_differentiator   BOOLEAN   NOT NULL,
    updated_at          TIMESTAMP WITHOUT TIME ZONE,
    created_at          TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_type_multiple_choices CHECK ( (type = 'multiple_choice' AND multiple_choices IS NOT NULL) OR (type = 'open_text' AND multiple_choices IS NULL) )
);

CREATE TABLE question_map (
    id         SERIAL  PRIMARY KEY,
    map        JSON    NOT NULL,
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE answer (
    id              SERIAL PRIMARY KEY,
    recipient_id    INTEGER NOT NULL REFERENCES recipient(id),
    question_id     INTEGER NOT NULL REFERENCES question(id),
    question_map_id INTEGER NOT NULL REFERENCES question_map(id),
    answer_value    TEXT NOT NULL,
    created_at      TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW(),
    UNIQUE( recipient_id, question_id )
);

COMMIT;
