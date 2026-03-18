SELECT pg_current_wal_lsn() AS before_mass;

-- 1/144DD40

INSERT INTO warehouse.customer (last_name, first_name, email)
SELECT 'Фамилия' || gs, 'Имя' || gs, 'user' || gs || '@example.com'
FROM generate_series(1, 100000) gs;

SELECT pg_current_wal_lsn() AS after_mass;

-- 1/685B970

SELECT pg_wal_lsn_diff('1/685B970', '1/144DD40') AS total_wal_bytes;

-- 88136752