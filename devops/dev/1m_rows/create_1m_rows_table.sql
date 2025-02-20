CREATE TABLE IF NOT EXISTS temp (t INT);

INSERT INTO temp (t) SELECT random() * 100 FROM generate_series(1, 1000000);
