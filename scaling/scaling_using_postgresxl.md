# Scaling Using Postgres-XL

1. Create distributed table

```sql
CREATE TABLE orders (
    store_id UUID NOT NULL,
    customer_id UUID NOT NULL,
    order_id UUID PRIMARY KEY,
    amount_in_cents INTEGER,
    created_at TIMESTAMP SET DEFAULT CURRENT_TIMESTAMP; 
) DISTRIBUTE BY HASH (store_id);
```

2. Partition the Table by created_at

```sql
CREATE TABLE orders_2022 PARTITION OF orders FOR VALUES FROM ('2022–01–01') TO ('2023–01–01');

CREATE TABLE orders_2023 PARTITION OF orders FOR VALUES FROM ('2023–01–01') TO ('2024–01–01');

-- Add more partitions for subsequent years as needed, you can always use 
-- a monthly or annualy cron job
```

3. Configure the Nodes

- Configure the worker nodes to participate in the cluster.
- This involves ensuring that each node is set up correctly and can communicate with the coordinator node.

4. Insert Data

```sql
INSERT INTO orders (store_id, created_at, customer_id, order_id, amount_in_cents)
VALUES
    ('uuid1', '2022–01–15', 'uuid_customer1', 'uuid_order1', 1000),
    ('uuid2', '2023–03–20', 'uuid_customer2', 'uuid_order2', 1500),
    ('uuid3', '2023–03–20', 'uuid_customer3', 'uuid_order3', 2000);
```

5. Querying Data

```sql
-- Select orders for a specific store_id
SELECT * FROM orders WHERE store_id = 'uuid1';
 
-- Select orders for a specific time range
SELECT * FROM orders WHERE created_at >= '2022–01–01' AND created_at < '2023–01–01';
```
