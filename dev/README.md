# Dev environment #

This is a Docker Compose (expects 2.0, untested 1.0) dev-only
environment. None of the assumptions in here should be taken to apply
to prod.

It's just a local, this-project-only DB. You shouldn't manually touch
it. It should be used only via `pytest`, dev or CI.

## Usage ##

```sh
make -C postgres/secrets all
docker compose build
docker compose up -d db
docker compose run linter imrsv-schema-linter  # dev
docker compose run linter pytest
# etc.
```

Uninstall:

```sh
docker compose down --volumes
```
