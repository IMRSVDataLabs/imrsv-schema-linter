\set QUIET on

-- Very original.
\set unprivileged_user unprivileged_u
\set unprivileged_password password
\set dev_database dev

CREATE ROLE :"unprivileged_user"
LOGIN PASSWORD :'unprivileged_password'
NOINHERIT;
\echo 'INFO:Created unprivileged user'

CREATE DATABASE :"dev_database";
\echo 'INFO:Created dev database'
GRANT CONNECT ON DATABASE :"dev_database" TO :"unprivileged_user";

\c :"dev_database"

DROP SCHEMA public;
CREATE SCHEMA public;
