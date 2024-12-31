-- The given PostgreSQL query retrieves information about blocked and blocking processes in the database.
-- 
-- Here is a step-by-step breakdown of what the query does:
-- 
-- 1) The SELECT statement is used to specify the columns that will be returned in the result set.
-- 2) The COALESCE function is used to handle cases where the blockingl.relation column is NULL. It converts the blockingl.relation to a text representation if it is not NULL, otherwise, it uses the blockingl.locktype value.
-- 3) The AS keyword is used to assign aliases to the selected columns for better readability.
-- 4) The now() - blockeda.query_start calculates the waiting duration by subtracting the query_start time from the current time (now()).
-- 5) The FROM clause specifies the tables involved in the query and their relationships.
-- 6) The JOIN keyword is used to combine the pg_locks table with the pg_stat_activity table based on the matching pid values.
-- 7) The ON keyword is used to define the join conditions between the tables.
-- 8) The second JOIN keyword is used to combine the pg_locks table again, this time with the pg_stat_activity table, based on additional conditions related to transaction ID, relation, and lock type.
-- 9) The WHERE clause filters the result set based on the specified conditions.
-- 10) The NOT blockedl.granted condition ensures that only blocked processes are included in the result set.
-- 11) The blockinga.datname = current_database() condition ensures that only processes in the current database are included.
-- 12) The result set includes columns such as the locked item, waiting duration, blocked process ID, blocked query, blocked mode, blocking process ID, blocking query, and blocking mode.

SELECT
   COALESCE(((blockingl.relation)::regclass)::text,
   blockingl.locktype) AS locked_item, (now() - blockeda.query_start) AS waiting_duration,
   blockeda.pid AS blocked_pid,
   blockeda.query AS blocked_query,
   blockedl.mode AS blocked_mode,
   blockinga.pid AS blocking_pid,
   blockinga.query AS blocking_query,
   blockingl.mode AS blocking_mode
FROM (((pg_locks blockedl
   JOIN pg_stat_activity blockeda ON ((blockedl.pid = blockeda.pid)))
   JOIN pg_locks blockingl ON ((((blockingl.transactionid = blockedl.transactionid)
      OR ((blockingl.relation = blockedl.relation)
      AND (blockingl.locktype = blockedl.locktype)))
      AND (blockedl.pid <> blockingl.pid))))
   JOIN pg_stat_activity blockinga ON (((blockingl.pid = blockinga.pid)
      AND (blockinga.datid = blockeda.datid))))
WHERE ((NOT blockedl.granted) AND (blockinga.datname = current_database()));
