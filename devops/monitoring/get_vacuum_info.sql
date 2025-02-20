
SELECT datname, usename, pid, CURRENT_TIMESTAMP - xact_start AS xact_runtime, query
FROM pg_stat_activity
WHERE upper(query) LIKE '%VACUUM%'
ORDER BY xact_start;
