
SELECT
c.oid::regclass AS table_name,
greatest(age(c.relfrozenxid), age(t.relfrozenxid)) AS age, 
pg_size_pretty(pg_table_size(c.oid)) AS table_size
FROM pg_class c LEFT JOIN pg_class t ON c.reltoastrelid = t.oid
WHERE c.relkind = 'r'
ORDER BY 2 DESC LIMIT 20;
