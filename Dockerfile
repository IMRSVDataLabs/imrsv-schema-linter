# syntax=docker/dockerfile:1.2

ARG pythonver=3.10-alpine3.15
FROM python:${pythonver} AS builder

# Some people say upgrade is evil because it makes build
# nonreproducible… but look at all the other nonreproducible things in
# here, like not freezing system package versions. Also, I'll take
# security updates over reproducibility any day.
# hadolint ignore=DL3008,DL3009
RUN --mount=type=cache,target=/var/cache/apk,id=apk_cache,sharing=locked \
    apk update && \
    apk upgrade && \
    apk add build-base \
            libffi-dev \
            postgresql-dev \
            postgresql-libs \
            tzdata

# hadolint ignore=DL3059
RUN adduser user -D
ENV HOME /home/user
USER user
WORKDIR /home/user/linter

RUN python -m venv ../venv
ENV VIRTUAL_ENV /home/user/venv
ENV PATH $VIRTUAL_ENV/bin:$HOME/.local/bin:$PATH
COPY --chown=user setup.py requirements.txt MANIFEST.in ./
# DL3013 does not matter for pip and wheel nearly as much, and it's annoying to update.
# hadolint ignore=DL3013,DL3042
RUN --mount=type=cache,target=/home/user/.cache,id=home_cache,uid=1000,gid=1000 \
    pip install -U pip wheel && \
    PIP_NO_BINARY=psycopg2 pip install -r requirements.txt

COPY --chown=user src src
COPY --chown=user bin bin


FROM builder AS builder-prod
# hadolint ignore=DL3013,DL3042
RUN --mount=type=cache,target=/home/user/.cache,id=home_cache,uid=1000,gid=1000 \
    PIP_NO_BINARY=psycopg2 pip install . && \
    pip uninstall -y pip wheel


FROM python:${pythonver} AS base
LABEL maintainer='Alex Pilon <alex@imrsv.ai>'

# DL3008 is a pain if we just want auto rebuilds for security updates. It is
# mitigated instead by a future CI/CD pipeline that only *promotes*, not
# rebuilds images. Since we keep those or their manifests, it's not that big a
# deal to reproduce in the future if need be.
# hadolint ignore=DL3008,DL3009
RUN --mount=type=cache,target=/var/cache/apk,id=apk_cache,sharing=locked \
    apk update && \
    apk upgrade && \
    apk add curl \
                postgresql-libs \
                tzdata

# hadolint ignore=DL3059
RUN adduser -D user
WORKDIR /home/user
ENV HOME /home/user
USER user

ENV VIRTUAL_ENV /home/user/venv
ENV PATH $VIRTUAL_ENV/bin:$HOME/.local/bin:$PATH
WORKDIR /home/user/linter
COPY --from=builder --chown=user /home/user/venv /home/user/venv


# Separate COPY venv from builder and builder-prod, so that we don't need to
# pip uninstall in ci/dev (not builder-ci/builder-dev, because you already
# copied things from prod). Total size suboptimal but the resultant images are
# smaller to upload. Only a problem if copying large amounts of data into the container image.
FROM base AS prod
COPY --from=builder-prod --chown=user /home/user/venv /home/user/venv
COPY --from=builder-prod --chown=user /home/user/linter /home/user/linter
# No --reload, and no log-level trace in prod.
CMD ["imrsv-schema-linter", "-f", "logfmt", "lint"]
# TODO? ENV PYTHONOPTIMIZE=2


FROM builder AS builder-ci
# hadolint ignore=DL3042
RUN --mount=type=cache,target=/home/user/.cache,id=home_cache,uid=1000,gid=1000 \
    pip install -e '.[ci]'
# Don't bother uninstalling in CI, because dev needs those, even if nitpickily
# theoretically. Only matters in prod, to keep one less dep in the image for
# outdated package warnings to annoy us.
COPY --chown=user tests pytest.ini mypy.ini .coverage* .flake8 ./


FROM base AS ci
COPY --from=builder-ci --chown=user /home/user/venv /home/user/venv
# Keep separate copies for a reason! Splitting layers for smaller uploads
# because only one changes often.
COPY --from=builder-ci --chown=user /home/user/linter /home/user/linter


FROM builder-ci as builder-dev
# hadolint ignore=DL3042
RUN --mount=type=cache,target=/home/user/.cache,id=home_cache,uid=1000,gid=1000 \
    pip install -e '.[development]'


FROM ci AS dev
USER user
# Only copy everything in dev. The rest doesn't belong in prod.
# This is only a backup. In dev, you probably bind mounted over this anyway.
COPY --from=builder-dev --chown=user /home/user/venv /home/user/venv
COPY --chown=user . .
CMD ["imrsv-schema-linter", "-f", "print", "lint"]
#ENV PYTHONUNBUFFERED=1
# Does this even matter post pip-install.
#ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONFAULTHANDLER=1
# For VSCode, Atom, etc.
#PYTHONBREAKPOINT=0
# Really want to =error, but for now, figure things out.
ENV PYTHONWARNINGS=all
ENV SQLALCHEMY_WARN_20=1
