# wener/postgres

Drop-in replacement for the [official PostgreSQL Docker image](https://hub.docker.com/_/postgres) with additional extensions pre-installed. Based on `postgres:18-alpine`.

## Included Extensions

| Extension | Version | Description |
| --------- | ------- | ----------- |
| [pgvector](https://github.com/pgvector/pgvector) | 0.8.2 | Vector similarity search (ivfflat, hnsw) |
| [pg_cron](https://github.com/citusdata/pg_cron) | 1.6.7 | Cron-based job scheduler |
| [pg_tle](https://github.com/aws/pg_tle) | 1.5.2 | Trusted Language Extensions framework |
| [mysql_fdw](https://github.com/EnterpriseDB/mysql_fdw) | 2.9.3 | Foreign data wrapper for MySQL/MariaDB |

All standard contrib extensions (e.g. `pg_stat_statements`, `hstore`, `uuid-ossp`) are also available from the base image.

## Quick Start

```bash
docker run --rm -e POSTGRES_PASSWORD=secret -p 5432:5432 wener/postgres:18
```

Extensions that register background workers (`pg_cron`, `pg_tle`) must be loaded via `shared_preload_libraries`:

```bash
docker run --rm -e POSTGRES_PASSWORD=secret -p 5432:5432 wener/postgres:18 \
  postgres \
    -c shared_preload_libraries=pg_cron,pg_tle \
    -c cron.database_name=postgres
```

Then create the extensions inside your database:

```sql
CREATE EXTENSION vector;
CREATE EXTENSION pg_cron;
CREATE EXTENSION pg_tle;
CREATE EXTENSION mysql_fdw;
```

## Docker Compose

```yaml
services:
  db:
    image: wener/postgres:18
    environment:
      POSTGRES_PASSWORD: secret
    command:
      - postgres
      - -c
      - shared_preload_libraries=pg_cron,pg_tle,pg_stat_statements
      - -c
      - cron.database_name=postgres
    ports:
      - "5432:5432"
    volumes:
      - pgdata:/var/lib/postgresql
volumes:
  pgdata:
```

## Compatibility

This image preserves full compatibility with the official `postgres` Alpine image:

- Same entrypoint (`docker-entrypoint.sh`) and initialization flow
- `/docker-entrypoint-initdb.d/` scripts run at first start (`.sh`, `.sql`, `.sql.gz`, `.sql.xz`, `.sql.zst`)
- Same environment variables: `POSTGRES_PASSWORD`, `POSTGRES_USER`, `POSTGRES_DB`, `POSTGRES_INITDB_ARGS`, `POSTGRES_HOST_AUTH_METHOD`
- Default data directory: `/var/lib/postgresql/18/docker`
- `STOPSIGNAL SIGINT` for fast shutdown
- Mount at `/var/lib/postgresql` is recommended (supports `pg_upgrade --link`)

## Extension Notes

### pgvector

No preloading required. Create the extension and start using vector columns:

```sql
CREATE EXTENSION vector;
CREATE TABLE items (id serial PRIMARY KEY, embedding vector(1536));
CREATE INDEX ON items USING hnsw (embedding vector_cosine_ops);
```

### pg_cron

Requires `shared_preload_libraries = 'pg_cron'` and `cron.database_name` to be set.

```sql
CREATE EXTENSION pg_cron;
SELECT cron.schedule('nightly-vacuum', '0 3 * * *', 'VACUUM ANALYZE');
SELECT cron.unschedule('nightly-vacuum');
```

### pg_tle

Requires `shared_preload_libraries = 'pg_tle'`.

```sql
CREATE EXTENSION pg_tle;
```

See the [pg_tle documentation](https://github.com/aws/pg_tle) for creating trusted language extensions.

### mysql_fdw

No preloading required.

```sql
CREATE EXTENSION mysql_fdw;
CREATE SERVER mysql_svr FOREIGN DATA WRAPPER mysql_fdw
  OPTIONS (host 'mysql-host', port '3306');
CREATE USER MAPPING FOR postgres SERVER mysql_svr
  OPTIONS (username 'remote_user', password 'remote_pass');
CREATE FOREIGN TABLE remote_table (id int, name text)
  SERVER mysql_svr OPTIONS (dbname 'mydb', table_name 'users');
```

## Build

```bash
cd postgres/
docker buildx bake --load --set '*.platform=linux/arm64'
```

Extension versions can be overridden via variables in `docker-bake.hcl` or the command line:

```bash
docker buildx bake --load \
  --set '*.platform=linux/arm64' \
  --set '*.args.PGVECTOR_VERSION=0.8.2' \
  --set '*.args.PG_CRON_VERSION=1.6.7'
```
