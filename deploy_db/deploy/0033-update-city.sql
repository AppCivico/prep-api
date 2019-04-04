-- Deploy prep_api:0033-update-city to pg
-- requires: 0032-add-city

BEGIN;

UPDATE recipient SET city = '1' WHERE city = 'São Paulo e Gde SP';
UPDATE recipient SET city = '2' WHERE city = 'Belo Horizonte - MG';
UPDATE recipient SET city = '3' WHERE city = 'Salvador - BA';

COMMIT;
