## Setup postgres_fdw

```sql
CREATE EXTENSION IF NOT EXISTS postgres_fdw;

-- Setup remote server
CREATE SERVER migration_source
FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (
    host 'remote_db_host', -- remote db host
    port '5432', -- remote db port
    dbname 'legacy', -- remote db name
    application_name 'migration'
);

-- Setup user mapping for remote server access
CREATE USER MAPPING FOR PUBLIC SERVER migration_source
OPTIONS (
    user 'migration_user', -- remote db user 
    password 'password'    -- password for remote db user
);

-- Assuming that the remote table "example" in the remote DB has 3 columns: id(bigint), code(text), name(varchar)
-- Create a foreign table in the "legacy_remote" schema to access the remote DB (It is not necessary to create a separate schema, but it is for the purpose of distinguishing foreign tables)
-- Create a foreign table "example_ft" in the "legacy_remote" schema that will be connected to the remote table "example"
CREATE FOREIGN TABLE legacy_remote.example_ft (
    id bigint NOT NULL,
    code text NOT NULL,
    name varchar(200) NOT NULL 
)
SERVER migration_source
OPTIONS (schema_name 'legacy', table_name 'example'); -- remote table name

-- Query the example_ft table to access the data in the remote DB's example table
SELECT * FROM legacy_remote.example_ft LIMIT 1;
```
