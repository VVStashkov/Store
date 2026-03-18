BEGIN;
SELECT pg_current_wal_lsn() AS before_insert;

-- 1/14492E0

INSERT INTO warehouse.customer (last_name, first_name, email)
VALUES ('Тестов', 'Тест', 'test@example.com');

SELECT pg_current_wal_lsn() AS after_insert;

-- 1/144C740

SELECT pg_wal_lsn_diff('1/144C740', '1/14492E0') AS wal_bytes;

-- 13408

COMMIT;

SELECT pg_current_wal_lsn() AS after_commit;

-- 1/144DC58

SELECT pg_wal_lsn_diff('1/144DC58', '1/144C740') AS wal_bytes;

-- 5400