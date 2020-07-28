-- Deploy prep_api:0061-add-uniq-combina_voucher to pg
-- requires: 0060-add-combina-reminder

BEGIN;

ALTER TABLE combina_voucher ADD CONSTRAINT uniq_value UNIQUE (value);

COMMIT;
