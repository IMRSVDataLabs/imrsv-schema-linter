\set QUIET on

\echo 'INFO:Overriding some PG system settings'
-- Not strictly necessary for linting dev/CI.
-- We're not explicitly **not** targetting HDD-backed databases or
-- non-replicated databases BTW.
ALTER SYSTEM SET wal_compression = true;
ALTER SYSTEM SET wal_level = 'minimal';
ALTER SYSTEM SET max_wal_senders = 0;
ALTER SYSTEM SET log_line_prefix = '';
ALTER SYSTEM SET log_statement = 'ddl';
ALTER SYSTEM SET synchronous_commit = off;

-- Make sure our code plays nice.
ALTER SYSTEM SET lock_timeout = '50ms';
ALTER SYSTEM SET log_min_duration_statement = 50; -- ms
ALTER SYSTEM SET idle_in_transaction_session_timeout = '2s';
