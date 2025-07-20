# JSONB indexing

Assume we have a table `user_events` that stores user activity data in a JSONB column called `event_data`.
```sql
CREATE TABLE user_events (
    id SERIAL PRIMARY KEY,
    user_id INTEGER,
    timestamp TIMESTAMP DEFAULT NOW(),
    event_data JSONB
);
```

This table stores various user events each with different structures:
```json
// Page view event
{
  "type": "page_view",
  "path": "/products/shoes",
  "user_agent": "Chrome/118.0",
  "referrer": "google.com",
  "session_id": "abc123"
}

// Purchase event  
{
  "type": "purchase",
  "product_id": 1234,
  "amount": 99.99,
  "currency": "USD",
  "payment_method": "credit_card",
  "promotion_code": "SUMMER20"
}

// Feature usage event
{
  "type": "feature_usage",
  "feature": "advanced_search",
  "user_plan": "premium",
  "search_terms": ["wireless", "headphones"],
  "filters_applied": {"brand": ["Sony", "Bose"], "price_range": "100-200"}
}
```

## Performance Optimization with GIN Indexes

Initial query (could be slow for large datasets):
```sql
-- Find users who completed signup flow
SELECT DISTINCT user_id 
FROM user_events 
WHERE event_data->>'type' = 'signup' 
  AND event_data->>'step' = 'completed'
  AND timestamp > NOW() - INTERVAL '7 days';

-- Execution time: 45.2 seconds


-- Find users who used specific features
SELECT user_id, COUNT(*)
FROM user_events
WHERE event_data->>'type' = 'feature_usage'
  AND event_data->'filters_applied' ? 'brand'
  AND timestamp > NOW() - INTERVAL '30 days'
GROUP BY user_id;

-- Execution time: 1m 23s (timeout)
```

To improve performance, we can create GIN indexes on the JSONB column:
```sql
CREATE INDEX idx_event_data_gin ON user_events USING GIN (event_data);
```

GIN indexes are designed for handling composite values where you need to search for specific element values within the composite items.

After creating the index, we can re-run our queries:
```sql
-- Before: 45.2 seconds
-- After: 0.3 seconds
SELECT DISTINCT user_id 
FROM user_events 
WHERE event_data->>'type' = 'signup' 
  AND event_data->>'step' = 'completed'
  AND timestamp > NOW() - INTERVAL '7 days';

-- Performance improvement: 150x faster


-- Find users who made purchases with promotion codes
SELECT user_id, COUNT(*) as purchase_count
FROM user_events
WHERE event_data @> '{"type": "purchase"}'
  AND event_data ? 'promotion_code'
  AND timestamp > NOW() - INTERVAL '30 days'
GROUP BY user_id
ORDER BY purchase_count DESC;

-- Before: Timeout after 2 minutes
-- After: 1.2 seconds
```

## The Two Flavors of GIN: Choosing the Right Operator Class

### jsonb_ops (Default)

```sql
CREATE INDEX idx_event_data_gin ON user_events USING GIN (event_data);
-- Equivalent to:
CREATE INDEX idx_event_data_gin ON user_events USING GIN (event_data jsonb_ops);
```

This creates index entries for every key and value, supporting all JSONB operators but creating larger indexes.

### jsonb_path_ops (Optimized for Containment)

```sql
CREATE INDEX idx_event_data_gin_path ON user_events USING GIN (event_data jsonb_path_ops);
```

This creates smaller indexes (20–30% of table size vs 60–80%) but only supports the @> containment operator.

## References

- [The PostgreSQL Index Type That Makes Complex Queries 100x Faster](https://medium.com/@sohail_saifi/the-postgresql-index-type-that-makes-complex-queries-100x-faster-8fdd4e0474cc)
