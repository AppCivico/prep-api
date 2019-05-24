-- Deploy prep_api:0032-add-city to pg
-- requires: 0031-add-prep_since

BEGIN;

ALTER TABLE recipient ADD COLUMN city TEXT;
UPDATE recipient SET city = 'São Paulo e Gde SP'  WHERE id IN (45,14,76,48,22,70,53,67,72,1,4,15,18,23,20,79,30);
UPDATE recipient SET city = 'Belo Horizonte - MG' WHERE id IN (10, 47, 39, 9, 60, 44);
UPDATE recipient SET city = 'Salvador - BA'       WHERE id IN (56, 59, 51, 71, 77, 81);

COMMIT;
