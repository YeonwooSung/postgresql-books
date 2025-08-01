# Postgres Performance Tuning

## 1. Baseline Everything

Amateurs start tuning random settings. Pros start with data.

```sql
-- Essential baseline queries every pro runs first
SELECT name, setting, unit, context 
FROM pg_settings 
WHERE name IN (
    'shared_buffers', 'work_mem', 'maintenance_work_mem',
    'max_connections', 'effective_cache_size'
);


-- Current database activity
SELECT 
    datname,
    numbackends,
    xact_commit,
    xact_rollback,
    blks_read,
    blks_hit,
    tup_returned,
    tup_fetched,
    tup_inserted,
    tup_updated,
    tup_deleted
FROM pg_stat_database;

-- Cache hit ratio (should be >99%)
SELECT 
    round(100.0 * blks_hit / (blks_hit + blks_read), 2) as cache_hit_ratio
FROM pg_stat_database 
WHERE datname = current_database();
```

Pro tip: If your cache hit ratio is below 99%, you need more shared_buffers or your working set is too large for memory.
Everything else is secondary.

## 2. The Query Performance Detective Work

```sql
-- Enable query statistics tracking
ALTER SYSTEM SET track_activity_query_size = 16384;
ALTER SYSTEM SET shared_preload_libraries = 'pg_stat_statements';
-- Restart required

-- Find your worst queries
SELECT 
    query,
    calls,
    total_time,
    mean_time,
    max_time,
    stddev_time,
    rows
FROM pg_stat_statements 
ORDER BY total_time DESC 
LIMIT 10;

-- Find queries with high variance (inconsistent performance)
SELECT 
    query,
    calls,
    mean_time,
    stddev_time,
    (stddev_time / mean_time) * 100 as variance_percentage
FROM pg_stat_statements 
WHERE calls > 100 
ORDER BY variance_percentage DESC 
LIMIT 10;
```

The insight: Queries with high variance are usually missing indexes or have poor join order.
Focus on these first — they’re your biggest wins.

## 3. The Memory Allocation Strategy That Actually Works

Forget the "25% of RAM for shared_buffers" rule.
Pros calculate based on workload.

```sql
-- Check current memory usage patterns
SELECT 
    pg_size_pretty(pg_database_size(current_database())) as db_size,
    pg_size_pretty(sum(pg_relation_size(oid))) as table_size,
    pg_size_pretty(sum(pg_total_relation_size(oid)) - sum(pg_relation_size(oid))) as index_size
FROM pg_class 
WHERE relkind = 'r';

-- Calculate your working set
WITH table_stats AS (
    SELECT 
        schemaname,
        tablename,
        n_tup_ins + n_tup_upd + n_tup_del as write_activity,
        seq_scan,
        seq_tup_read,
        idx_scan,
        idx_tup_fetch
    FROM pg_stat_user_tables
)
SELECT 
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size,
    write_activity,
    seq_scan,
    CASE 
        WHEN seq_scan > idx_scan THEN 'Sequential scan heavy'
        WHEN write_activity > 1000 THEN 'Write heavy'
        ELSE 'Normal'
    END as workload_type
FROM table_stats
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
```

Pro configuration strategy:

- Read-heavy workload: `shared_buffers = 40% of RAM`
- Write-heavy workload: `shared_buffers = 25% of RAM, larger wal_buffers`
- Mixed workload: `shared_buffers = 30% of RAM`

## 4. The Index Strategy That Separates Experts

Amateurs create indexes reactively. Pros create them strategically.

```sql
-- Find missing indexes (tables doing sequential scans)
SELECT 
    schemaname,
    tablename,
    seq_scan,
    seq_tup_read,
    seq_tup_read / seq_scan as avg_seq_tup_read
FROM pg_stat_user_tables 
WHERE seq_scan > 0
ORDER BY seq_tup_read DESC;

-- Find unused indexes (wasting space and write performance)
SELECT 
    schemaname,
    tablename,
    indexname,
    pg_size_pretty(pg_relation_size(indexrelid)) as size,
    idx_scan,
    idx_tup_read,
    idx_tup_fetch
FROM pg_stat_user_indexes 
WHERE idx_scan = 0
ORDER BY pg_relation_size(indexrelid) DESC;

-- Check index effectiveness
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan,
    idx_tup_read,
    idx_tup_fetch,
    idx_tup_read / NULLIF(idx_scan, 0) as avg_tuples_per_scan
FROM pg_stat_user_indexes 
WHERE idx_scan > 0
ORDER BY idx_scan DESC;
```

Pro indexing rules:

- Composite indexes: `Order matters. Most selective column first.`
- Partial indexes: `Use WHERE clauses for filtered queries.`
- Covering indexes: `Include frequently selected columns.`

## 5. The Connection Pool Optimization Nobody Talks About

Most developers set up connection pooling and forget about it.
Pros optimize the pool itself.

```sql
-- Monitor connection usage patterns
SELECT 
    datname,
    usename,
    application_name,
    client_addr,
    state,
    query_start,
    state_change,
    NOW() - query_start as query_duration,
    NOW() - state_change as state_duration
FROM pg_stat_activity 
WHERE state != 'idle'
ORDER BY query_duration DESC;

-- Check for connection churn
SELECT 
    datname,
    numbackends,
    xact_commit,
    xact_rollback,
    blks_read,
    blks_hit,
    temp_files,
    temp_bytes,
    deadlocks,
    blk_read_time,
    blk_write_time
FROM pg_stat_database 
WHERE datname = current_database();
```

Pro connection tuning:
```sql
-- For connection pooling optimization
ALTER SYSTEM SET max_connections = 200;  -- Lower than you think
ALTER SYSTEM SET shared_buffers = '8GB';  -- Higher per connection
ALTER SYSTEM SET max_prepared_transactions = 100;  -- Enable prepared statements
```

## 6. The Vacuum Strategy That Prevents Disasters

Amateurs let autovacuum handle everything.
Pros tune it aggressively.

```sql
-- Check vacuum performance
SELECT 
    schemaname,
    tablename,
    n_tup_ins,
    n_tup_upd,
    n_tup_del,
    n_dead_tup,
    last_vacuum,
    last_autovacuum,
    vacuum_count,
    autovacuum_count
FROM pg_stat_user_tables 
WHERE n_dead_tup > 0 
ORDER BY n_dead_tup DESC;

-- Check for bloat
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size,
    n_dead_tup,
    n_live_tup,
    round(100.0 * n_dead_tup / (n_live_tup + n_dead_tup), 2) as dead_tuple_percent
FROM pg_stat_user_tables 
WHERE n_live_tup > 0 
ORDER BY dead_tuple_percent DESC;
```

Pro vacuum configuration:
```sql
-- Aggressive autovacuum for write-heavy tables
ALTER SYSTEM SET autovacuum_max_workers = 6;
ALTER SYSTEM SET autovacuum_naptime = '30s';
ALTER SYSTEM SET autovacuum_vacuum_threshold = 1000;
ALTER SYSTEM SET autovacuum_vacuum_scale_factor = 0.1;
ALTER SYSTEM SET autovacuum_analyze_threshold = 500;
ALTER SYSTEM SET autovacuum_analyze_scale_factor = 0.05;


-- For specific high-churn tables
ALTER TABLE high_activity_table SET (
    autovacuum_vacuum_threshold = 100,
    autovacuum_vacuum_scale_factor = 0.01,
    autovacuum_analyze_threshold = 50,
    autovacuum_analyze_scale_factor = 0.005
);
```

## 7. The I/O Optimization That Transforms Performance

This is where pros separate themselves from everyone else.
They optimize at the storage layer.

```sql
-- Check I/O patterns
SELECT 
    schemaname,
    tablename,
    heap_blks_read,
    heap_blks_hit,
    idx_blks_read,
    idx_blks_hit,
    toast_blks_read,
    toast_blks_hit,
    tidx_blks_read,
    tidx_blks_hit
FROM pg_statio_user_tables 
ORDER BY heap_blks_read + idx_blks_read DESC;

-- Monitor checkpoint performance
SELECT 
    checkpoints_timed,
    checkpoints_req,
    checkpoint_write_time,
    checkpoint_sync_time,
    buffers_checkpoint,
    buffers_clean,
    maxwritten_clean,
    buffers_backend,
    buffers_backend_fsync,
    buffers_alloc
FROM pg_stat_bgwriter;
```

Pro I/O tuning:
```sql
-- Optimize for SSD storage
ALTER SYSTEM SET random_page_cost = 1.1;  -- SSD default
ALTER SYSTEM SET seq_page_cost = 1.0;
ALTER SYSTEM SET effective_io_concurrency = 200;  -- For SSDs
ALTER SYSTEM SET maintenance_io_concurrency = 100;

-- Optimize checkpoints
ALTER SYSTEM SET checkpoint_completion_target = 0.9;
ALTER SYSTEM SET max_wal_size = '4GB';
ALTER SYSTEM SET min_wal_size = '1GB';
ALTER SYSTEM SET wal_buffers = '64MB';
```

## 8. The Monitoring Dashboard Every Pro Uses

Pros don’t wait for problems.
They prevent them.

```sql
-- Create a performance monitoring view
CREATE OR REPLACE VIEW performance_dashboard AS
SELECT 
    'Cache Hit Ratio' as metric,
    round(100.0 * sum(blks_hit) / sum(blks_hit + blks_read), 2) || '%' as value,
    CASE 
        WHEN round(100.0 * sum(blks_hit) / sum(blks_hit + blks_read), 2) > 99 THEN 'Good'
        WHEN round(100.0 * sum(blks_hit) / sum(blks_hit + blks_read), 2) > 95 THEN 'Warning'
        ELSE 'Critical'
    END as status
FROM pg_stat_database
UNION ALL
SELECT 
    'Active Connections' as metric,
    count(*)::text as value,
    CASE 
        WHEN count(*) < 100 THEN 'Good'
        WHEN count(*) < 150 THEN 'Warning'
        ELSE 'Critical'
    END as status
FROM pg_stat_activity 
WHERE state = 'active'
UNION ALL
SELECT 
    'Deadlocks' as metric,
    sum(deadlocks)::text as value,
    CASE 
        WHEN sum(deadlocks) = 0 THEN 'Good'
        WHEN sum(deadlocks) < 10 THEN 'Warning'
        ELSE 'Critical'
    END as status
FROM pg_stat_database;

-- Check it regularly
SELECT * FROM performance_dashboard;
```

## 9. The Advanced Techniques That Blow Minds

### 9-1. Parallel Query Optimization

```sql
-- Enable parallel queries
ALTER SYSTEM SET max_parallel_workers_per_gather = 4;
ALTER SYSTEM SET max_parallel_workers = 8;
ALTER SYSTEM SET parallel_tuple_cost = 0.1;
ALTER SYSTEM SET parallel_setup_cost = 1000;

-- Force parallel query for testing
SET force_parallel_mode = on;
SET max_parallel_workers_per_gather = 4;
```

### 9-2. Partitioning strategies

```sql
-- Automatic partition management
CREATE OR REPLACE FUNCTION create_monthly_partitions(table_name text)
RETURNS void AS $$
DECLARE
    start_date date;
    end_date date;
    partition_name text;
BEGIN
    start_date := date_trunc('month', CURRENT_DATE);
    end_date := start_date + interval '1 month';
    partition_name := table_name || '_' || to_char(start_date, 'YYYY_MM');
    
    EXECUTE format('CREATE TABLE IF NOT EXISTS %I PARTITION OF %I 
                    FOR VALUES FROM (%L) TO (%L)',
                   partition_name, table_name, start_date, end_date);
END;
$$ LANGUAGE plpgsql;
```

### 9-3. Custom Statistics for Complex Queries

```sql
-- Create extended statistics for correlated columns
CREATE STATISTICS user_activity_stats (dependencies) 
ON user_id, created_at, status 
FROM user_activities;

ANALYZE user_activities;
```
