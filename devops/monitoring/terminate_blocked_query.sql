-- Terminate the transactions that acquire the lock
SELECT pg_terminate_backend(blocking_pid)
FROM (
    SELECT DISTINCT unnest(pg_blocking_pids(pid)) AS blocking_pid
    FROM pg_stat_activity
    WHERE state IN ('active')
) AS blocking_transactions;
