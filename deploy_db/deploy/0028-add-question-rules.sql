-- Deploy prep_api:0028-add-question-rules to pg
-- requires: 0027-add-screening

BEGIN;

ALTER TABLE question ADD COLUMN rules JSON, ADD COLUMN send_flags TEXT[];
ALTER TABLE stash ADD COLUMN finished BOOLEAN NOT NULL DEFAULT FALSE;

COMMIT;
