# Scaling PostgreSQL with Citus

```sql
-- Install Citus extension
CREATE EXTENSION citus;
-- Configure the coordinator node (this is where metadata resides)
SELECT citus_master_configure_node('coordinator-node-hostname');
-- Configure worker nodes (where data resides)
SELECT citus_worker_configure_node('worker-node-hostname', 5432);

-- Repeat the above for each worker node


-- Create a distributed table
CREATE TABLE distributed_table (
    id SERIAL PRIMARY KEY,
    name TEXT
) DISTRIBUTED BY HASH (id);


-- Add worker nodes to the distributed table
SELECT create_distributed_table('distributed_table', 'id');

-- Insert data into the distributed table
INSERT INTO distributed_table (name) VALUES ('Row 1'), ('Row 2');

-- Query data across shards
SELECT * FROM distributed_table;
```

This example demonstrates setting up Citus to shard a table named `distributed_table` across multiple worker nodes based on the `id` column.
Queries issued against this table are automatically distributed and executed in parallel across the worker nodes.

Keep in mind that setting up and configuring distributed PostgreSQL environments requires careful planning and consideration of factors such as data distribution, query performance, and fault tolerance.
It’s recommended to thoroughly review the documentation and best practices of the chosen framework or tool before deploying it in production.
