# syntax=docker/dockerfile:1

ARG PG_MAJOR=18

# ── base build stage ────────────────────────────────────────────
FROM postgres:${PG_MAJOR}-alpine AS build

ARG TARGETARCH
ARG TARGETVARIANT

RUN --mount=type=cache,id=apk-pg-build-$TARGETARCH$TARGETVARIANT,sharing=locked,target=/etc/apk/cache \
    apk add \
        build-base \
        postgresql-dev \
        mariadb-connector-c-dev \
        openssl-dev \
        krb5-dev \
        flex \
        git

# ── mysql_fdw ───────────────────────────────────────────────────
FROM build AS mysql_fdw

ARG MYSQL_FDW_VERSION=REL-2_9_3

RUN set -eux; \
    git clone --branch ${MYSQL_FDW_VERSION} --depth 1 \
        https://github.com/EnterpriseDB/mysql_fdw.git /tmp/mysql_fdw; \
    cd /tmp/mysql_fdw; \
    sed -i '1i #ifndef RTLD_DEEPBIND\n#define RTLD_DEEPBIND 0\n#endif' mysql_fdw.c; \
    make USE_PGXS=1 with_llvm=no; \
    make USE_PGXS=1 with_llvm=no install DESTDIR=/tmp/install

# ── pgvector ────────────────────────────────────────────────────
FROM build AS pgvector

ARG PGVECTOR_VERSION=0.8.2

RUN set -eux; \
    git clone --branch v${PGVECTOR_VERSION} --depth 1 \
        https://github.com/pgvector/pgvector.git /tmp/pgvector; \
    cd /tmp/pgvector; \
    make USE_PGXS=1 with_llvm=no; \
    make USE_PGXS=1 with_llvm=no install DESTDIR=/tmp/install

# ── pg_cron ─────────────────────────────────────────────────────
FROM build AS pg_cron

ARG PG_CRON_VERSION=1.6.7

RUN set -eux; \
    git clone --branch v${PG_CRON_VERSION} --depth 1 \
        https://github.com/citusdata/pg_cron.git /tmp/pg_cron; \
    cd /tmp/pg_cron; \
    make USE_PGXS=1 with_llvm=no; \
    make USE_PGXS=1 with_llvm=no install DESTDIR=/tmp/install

# ── pg_tle ──────────────────────────────────────────────────────
FROM build AS pg_tle

ARG PG_TLE_VERSION=1.5.2

RUN set -eux; \
    git clone --branch v${PG_TLE_VERSION} --depth 1 \
        https://github.com/aws/pg_tle.git /tmp/pg_tle; \
    cd /tmp/pg_tle; \
    make USE_PGXS=1 FLEX=flex with_llvm=no; \
    make USE_PGXS=1 FLEX=flex with_llvm=no install DESTDIR=/tmp/install

# ── final image ─────────────────────────────────────────────────
FROM postgres:${PG_MAJOR}-alpine

ARG TARGETARCH
ARG TARGETVARIANT

RUN --mount=type=cache,id=apk-pg-$TARGETARCH$TARGETVARIANT,sharing=locked,target=/etc/apk/cache \
    apk add \
        mariadb-connector-c \
        krb5-libs \
    && ln -s libmariadb.so.3 /usr/lib/libmysqlclient.so

COPY --from=mysql_fdw /tmp/install/usr/local/ /usr/local/
COPY --from=pgvector  /tmp/install/usr/local/ /usr/local/
COPY --from=pg_cron   /tmp/install/usr/local/ /usr/local/
COPY --from=pg_tle    /tmp/install/usr/local/ /usr/local/
