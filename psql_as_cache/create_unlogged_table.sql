-- Unlogged table: No WAL, no crash recovery, no replication
CREATE UNLOGGED TABLE IF NOT EXISTS cache (
    id SERIAL PRIMARY KEY,
    key TEXT UNIQUE NOT NULL,
    value jsonb,
    inserted_at TIMESTAMP
);

CREATE INDEX IF NOT EXISTS cache_key_idx ON cache (key);
