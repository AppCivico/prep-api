-- Deploy prep_api:0011-appointment to pg
-- requires: 0010-add-city

BEGIN;

ALTER TABLE recipient ADD COLUMN integration_token TEXT NOT NULL DEFAULT substring( md5(random()::text), 0, 12);
ALTER TABLE appointment ALTER COLUMN quota_number DROP NOT NULL;
ALTER TABLE appointment ALTER COLUMN appointment_window_id DROP NOT NULL;

ALTER TABLE appointment ADD COLUMN calendar_id INTEGER references calendar(id);
UPDATE
    appointment
SET
    calendar_id = sq.calendar_id
FROM
    ( SELECT c.id as calendar_id, a.id FROM appointment a, calendar c, appointment_window aw WHERE a.appointment_window_id = aw.id AND c.id = aw.calendar_id ) sq
WHERE
    appointment.id = sq.id;
ALTER TABLE appointment ADD CONSTRAINT recipient_calendar_id UNIQUE (recipient_id, calendar_id, appointment_at);
ALTER TABLE appointment ADD COLUMN notification_sent_at TIMESTAMP WITHOUT TIME ZONE;


COMMIT;
