# pg_stat_statements

`pg_stat_statements` tracks statistics on the queries executed by a Postgres database.
It'll help you debug queries, identify slow queries, and generally give you deeper information about how your queries are running.
The statistics gathered by the module are made available via a system view named `pg_stat_statements`.

## Enable pg_stat_statements extension

```sql
CREATE EXTENSION pg_stat_statements;
```

The `pg_stat_statements` must be loaded via "shared_preload_libraries".
So, you need to edit the line in `postgresql.conf`:

```conf
shared_preload_libraries = 'pg_stat_statements'
```

Then, restart the Postgres server.

## Sample queries

What are the top 5 I/O-intensive SELECT queries?

Run the query below:
```sql
SELECT query, calls, total_time, rows, shared_blks_hit, shared_blks_read
FROM pg_stat_statements
WHERE query LIKE 'SELECT%'
ORDER BY shared_blks_read DESC, calls DESC
LIMIT 5;
```

The output will look something like this:
```
-[ RECORD 1 ]--—+---------------------------------------------------
query             | SELECT * FROM customer_data WHERE created_at > $1
calls             | 500
total_time        | 23000
rows              | 500000
shared_blks_hit   | 100000
shared_blks_read  | 75000
-[ RECORD 2 ]-----+---------------------------------------------------
query             | SELECT name, address FROM orders WHERE status = $1
calls             | 450
total_time        | 15000
rows              | 450000
shared_blks_hit   | 95000
shared_blks_read  | 55000
-[ RECORD 3 ]-----+---------------------------------------------------
query             | SELECT COUNT(*) FROM transactions WHERE amount > $1
calls             | 300
total_time        | 12000
rows              | 300000
shared_blks_hit   | 85000
shared_blks_read  | 50000
-[ RECORD 4 ]-----+---------------------------------------------------
query             | SELECT product_id FROM inventory WHERE quantity < $1
calls             | 400
total_time        | 16000
rows              | 400000
shared_blks_hit   | 80000
shared_blks_read  | 45000
-[ RECORD 5 ]-----+---------------------------------------------------
query             | SELECT * FROM user_logs WHERE user_id = $1 AND activity_date > $2
calls             | 350
total_time        | 17500
rows              | 350000
shared_blks_hit   | 75000
shared_blks_read  | 40000
```

## References

- [PostgreSQL Extensions: pg_stat_statements](https://www.timescale.com/learn/postgresql-extensions-pg-stat-statements?ref=timescale.com)
