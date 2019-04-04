-- Deploy prep_api:0033-update-city to pg
-- requires: 0032-add-city

BEGIN;

UPDATE recipient SET city = '1' WHERE id IN (45,14,76,48,22,70,53,67,72,1,4,15,18,23,20,79,30);
UPDATE recipient SET city = '2' WHERE id IN (10, 47, 39, 9, 60, 44);
UPDATE recipient SET city = '3' WHERE id IN (56, 59, 51, 71, 77, 81);

COMMIT;
