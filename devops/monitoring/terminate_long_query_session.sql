-- Terminates the backends (database connections) that are currently active, 
-- have been running for more than 5 minutes, 
-- and are waiting for specific events related to multi-transaction offset control and shared buffer management

SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE state IN ('active')
AND (now() - query_start) > interval '5 minutes' 
AND wait_event IN ('MultiXactOffsetControlLock', 'multixact_offset', 'SLRURead');
