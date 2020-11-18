-- Deploy prep_api:0063-add-active-calendars to pg
-- requires: 0062-add-calendar-holidays

BEGIN;

ALTER TABLE calendar ADD COLUMN active BOOLEAN NOT NULL DEFAULT TRUE;

COMMIT;
