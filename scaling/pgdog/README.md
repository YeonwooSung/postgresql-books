# pg_dog

[PgDog](https://github.com/pgdogdev/pgdog) is a transaction pooler and logical replication manager that can shard PostgreSQL.
Written in Rust, PgDog is fast, secure and can manage hundreds of databases and hundreds of thousands of connections.

## Running pg_dog

### Kubernetes

pg_dog can be deployed on Kuberentes using helm.

```bash
git clone https://github.com/pgdogdev/helm && \
cd helm && \
helm install -f values.yaml pgdog ./
```

### Docker

The provided docker-compose file can be used to run pg_dog locally.
It creates 3 shards of ParadeDB with PostgreSQL 17.

```bash
docker-compose up -d
```

Once started, you can connect to pg_dog using the following command:

```bash
PGPASSWORD=postgres psql -h 127.0.0.1 -p 6432 -U postgres
```
