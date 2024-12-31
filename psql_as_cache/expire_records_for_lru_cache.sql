CREATE OR REPLACE PROCEDURE expire_rows (retention_period INTERVAL) AS
$$
BEGIN
    DELETE FROM cache WHERE inserted_at < NOW() - retention_period;
    COMMIT;
END;
$$ LANGUAGE plpgsql;

-- CALL expire_rows('60 minutes');
-- CALL expire_rows('1 day');


--
-- Use pg_cron for scheduling expiration of records
-- Need to install pg_cron extension first
--

CREATE EXTENSION pg_cron;

-- Create a schedule to run the procedure every hour
SELECT cron.schedule('0 * * * *', $$CALL expire_rows('60 minutes');$$);

-- List all scheduled jobs
SELECT * FROM cron.job;
