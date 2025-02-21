# Partitioning

## pg_partman

`pg_partman` is an extension that simplifies creating and maintaining partitions of your PostgreSQL tables.
Partitioning is a key database technique that involves splitting a large table into smaller, more manageable pieces while allowing you to access the data as if it were one table.
It's a powerful way to keep your large PostgreSQL tables fast and manageable.

With `pg_partman`, PostgreSQL can manage partitions based on a variety of criteria such as time, serial IDs, or custom values.
It eases the maintenance tasks associated with partitioning, such as creating new partitions in advance and purging old ones.
This automation is particularly useful for large, time-series datasets that can grow rapidly.

### Pre-requisites

To use `pg_partman` properly, it is recommended to install `pg_jobmon` first.
And `pg_jobmon` requries `dblink` first.

```sql
-- Install the extension dblink
CREATE EXTENSION dblink;
```

Then install [`pg_jobmon`](https://github.com/omniti-labs/pg_jobmon)

```sql
CREATE SCHEMA jobmon;
CREATE EXTENSION pg_jobmon SCHEMA jobmon;
```

Next, compile and install the `pg_partman` extension.

```bash
git clone https://github.com/pgpartman/pg_partman.git

cd pg_partman

make install
```

Then, edit the `postgresql.conf` file to set the pg_partman_bgw library as a shared preload library.
```
shared_preload_libraries = 'pg_partman_bgw'     # (change requires restart)
```

### Setup

You could set other control variables for the BGW in `postgresql.conf`.
"dbname" is required at a minimum for maintenance to run on the given database(s).
These can be added/changed at anytime with a simple reload. 

```
pg_partman_bgw.interval = 3600
pg_partman_bgw.role = 'neosearch'
pg_partman_bgw.dbname = 'neosearch'
```

### Instructions

```sql
-- Install the extension
CREATE SCHEMA partman;
CREATE EXTENSION pg_partman SCHEMA partman;
```

### Sample Usage

```sql
-- Install the extension
CREATE SCHEMA partman;
CREATE EXTENSION pg_partman SCHEMA partman;

-- Create a parent table
CREATE TABLE device_data (
    time timestamptz NOT NULL,
    device_id int NOT NULL,
    data jsonb NOT NULL
);

-- Set up pg_partman to manage daily partitions of the device_data table
SELECT partman.create_parent('public.device_data', 'time', 'partman', 'daily');
```

In this setup, create_parent is a function provided by pg_partman that takes the parent table name and the column to partition on (time), as well as the schema (partman) and the partition interval (daily).
After setting up the partitions, pg_partman will help you manage them.
