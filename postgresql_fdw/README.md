# postgres_fdw

The postgres_fdw module provides the foreign-data wrapper postgres_fdw, which can be used to access data stored in external PostgreSQL servers.

## Useful tips

1. Do not join local tables with foreign tables. Only join foreign tables with foreign tables. When trying to join local tables with foreign tables, the DBMS will do the `full scan`, which is very slow.
2. If the foreign table is not too large (and does not change frequently), try to migrate the remote table to the local database and query it locally.
3. If the target remote database is using for real-time services, it might be a good choice to create a snapshot of the remote table and query the snapshot (again, locally if possible).

## References

- [PostgreSQL: Documentation: 17: F.36. postgres_fdw — access data stored in external PostgreSQL servers](https://www.postgresql.org/docs/current/postgres-fdw.html)
- [Performance Tips for PostgreSQL FDW](https://www.crunchydata.com/blog/performance-tips-for-postgres-fdw)
- [4.2. How the Postgres_fdw Extension Performs](https://www.interdb.jp/pg/pgsql04/02.html)
- [postgres_fdw로 마이그레이션 생산성 높이기](https://techblog.woowahan.com/20371/)
