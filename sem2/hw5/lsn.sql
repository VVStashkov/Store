SELECT pg_current_wal_lsn() AS lsn_before;

--получили 1/1443BA0

INSERT INTO warehouse.customer (last_name, first_name, email)
VALUES ('Тестов', 'Тест', 'test@example.com');

SELECT pg_current_wal_lsn() AS lsn_after;

--получили 1/14491F8

SELECT pg_wal_lsn_diff('1/1443BA0', '1/14491F8') AS wal_bytes;

--получили -22104
--вывод: в wal появилась новая запись поэтому lsn увеличил