-- user: fims admin
CREATE USER "fims-db" PASSWORD 'NFLApODULateMyoKERvaGalaQUeYeBRIdwOndiVeRseYeTeSoM';

-- create schema for tenant admin
CREATE SCHEMA "fims-db" AUTHORIZATION "fims-db";

-- revoke authorization for tenant admin
REVOKE ALL ON SCHEMA "fims-db" FROM public;