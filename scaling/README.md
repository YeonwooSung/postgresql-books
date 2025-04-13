# Scaling

To handle large scale of data, we definitely need to scale our database.
There are two types of scaling:
1. **Vertical Scaling**: This involves adding more resources (CPU, RAM, Disk) to the existing database server. This is often the simplest approach but has its limits.
2. **Horizontal Scaling**: This involves adding more database servers to distribute the load. This is more complex but allows for greater scalability.

For horizontal scaling, there are several options available:
- **Sharding**: This involves splitting the data across multiple database servers. Each server holds a subset of the data, and queries are distributed across the servers.
- **Replication**: This involves creating copies of the database on multiple servers. This can be used for load balancing and failover.
- **Partitioning**: This involves splitting a single table into multiple smaller tables. This can improve performance and manageability.
- **Distributed Databases**: These are databases that are designed to work across multiple servers. They can handle large amounts of data and provide high availability and fault tolerance.
- **Database Clustering**: This involves grouping multiple database servers to work together as a single system. This can provide high availability and load balancing.

## Sharding

Sharding is a method of distributing data across multiple servers. Each server holds a subset of the data, and queries are distributed across the servers.
This can improve performance and scalability.

### Real-World Example

- [Instagram](https://instagram-engineering.com/sharding-ids-at-instagram-1cf5a71e5a5c)
    - Instagram uses a custom sharding solution
    - Uses `schema` as logical shards
        - Assume we initially have 2 machines and 1000 logical shards
        - We can assign 500 logical shards to each machine
        - Each logical shards named `schema_0`, `schema_1`, ..., `schema_999`
        - Each machine will have 500 logical shards
        - When we add a new machine, we can assign 333 (or 334) logical shards (schemas) to each machine
    - To achieve this, instgram lets table names to be unique across schemas, not across the database

- [Figma](https://www.figma.com/blog/how-figmas-databases-team-lived-to-tell-the-scale/)
    - Figma uses RDS, which does not support citus, so they implemented custom dbproxy, which proxies queries to different shards.

### citus

`Citus` is an extension to PostgreSQL that allows you to shard your data across multiple nodes.
It provides a distributed database solution that can scale horizontally.
Citus is a mature and widely used solution for scaling PostgreSQL, but managed services like AWS RDS do not support it.
