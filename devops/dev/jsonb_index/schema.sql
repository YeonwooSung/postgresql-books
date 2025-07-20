CREATE TABLE user_events (
    id SERIAL PRIMARY KEY,
    user_id INTEGER,
    timestamp TIMESTAMP DEFAULT NOW(),
    event_data JSONB
);

CREATE INDEX idx_event_data_gin ON user_events USING GIN (event_data);


-- Find users who signed up in the last 7 days
SELECT DISTINCT user_id 
FROM user_events 
WHERE event_data->>'type' = 'signup' 
  AND event_data->>'step' = 'completed'
  AND timestamp > NOW() - INTERVAL '7 days';


-- Find users who made purchases with promotion codes
SELECT user_id, COUNT(*) as purchase_count
FROM user_events
WHERE event_data @> '{"type": "purchase"}'
  AND event_data ? 'promotion_code'
  AND timestamp > NOW() - INTERVAL '30 days'
GROUP BY user_id
ORDER BY purchase_count DESC;
