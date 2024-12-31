select i.*
from pg_indexes i
join pg_class c
    on schemaname = relnamespace::regnamespace::text 
    and tablename = relname
where relkind = 'm';
