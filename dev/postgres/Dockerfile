# syntax=docker/dockerfile:1.2

ARG pgver=14-alpine
FROM postgres:${pgver} AS dev

# Docker container initialization things
ENV POSTGRES_INITDB_ARGS='--data-checksums --auth-host=scram-sha-256'
ENV POSTGRES_HOST_AUTH_METHOD=scram-sha-256

COPY docker-entrypoint-initdb.d/ /docker-entrypoint-initdb.d
# To make "peer" not trust, auth over UNIX domain socket work.
USER postgres:postgres
HEALTHCHECK CMD ["psql", "-c", "SELECT 1"]
