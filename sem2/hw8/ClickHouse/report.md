# Задание 1

1
```
192.168.0.48,10000
192.168.0.22,10000
192.168.0.8,10000
192.168.0.11,10000
192.168.0.46,10000
192.168.0.37,10000
192.168.0.18,10000
192.168.0.1,10000
192.168.0.0,10000
192.168.0.43,10000
```
2
```
57.14, 28.57

```

3
```
/home,100000,500068.90477
```

4
```
0,3086
```


# Задание 2

ClickHouse
```bash
[2026-05-05 22:58:59] default> INSERT INTO sales_ch
                               SELECT
                                   toDateTime('2024-01-01 00:00:00') + INTERVAL number MINUTE,
                                   number % 1000,
                                   arrayElement(['Electronics', 'Clothing', 'Food', 'Books'], number % 4 + 1),
                                   rand() % 10 + 1,
                                   round(rand() % 10000 / 100, 2),
                                   number % 50000
                               FROM numbers(1000000)
[2026-05-05 22:58:59] 1,000,000 rows affected in 170 ms
```
PostgresSql
```shell
[2026-05-05 23:06:11] postgres.public> INSERT INTO sales_pg
                                       SELECT
                                           '2024-01-01 00:00:00'::timestamp + (n || ' minutes')::interval,
                                           n % 1000,
                                           CASE (n % 4)
                                               WHEN 0 THEN 'Electronics'
                                               WHEN 1 THEN 'Clothing'
                                               WHEN 2 THEN 'Food'
                                               ELSE 'Books'
                                       END,
                                           (random() * 9 + 1)::integer,
                                           round((random() * 100)::numeric, 2),
                                           n % 50000
                                       FROM generate_series(1, 1000000) AS n
[2026-05-05 23:06:16] 1,000,000 rows affected in 4 s 759 ms

```
вставка длилась на 4 секунды дольше

## Запросы
### 1
ClickHouse
```shell
[2026-05-05 23:07:15] default> SELECT sum(quantity * price) AS total_sales
                               FROM sales_ch
                               WHERE sale_date >= '2024-01-01' AND sale_date < '2024-02-01'
[2026-05-05 23:07:15] 1 row retrieved starting from 1 in 387 ms (execution: 16 ms, fetching: 371 ms)
```
PostgresSQL
```shell
[2026-05-05 23:11:13] postgres.public> SELECT sum(quantity * price) AS total_sales
                                       FROM sales_pg
                                       WHERE sale_date >= '2024-01-01' AND sale_date < '2024-02-01'
[2026-05-05 23:11:13] 1 row retrieved starting from 1 in 424 ms (execution: 19 ms, fetching: 405 ms)
```

### 2
ClickHouse
```shell
[2026-05-05 23:13:36] default> SELECT
                                   table,
                                   formatReadableSize(sum(bytes)) AS size
                               FROM system.parts
                               WHERE table = 'sales_ch' AND active
                               GROUP BY table
[2026-05-05 23:13:37] 1 row retrieved starting from 1 in 445 ms (execution: 16 ms, fetching: 429 ms)

sales_ch,14.88 MiB

```
PostgresSQL
```shell
[2026-05-05 23:13:52] postgres.public> SELECT pg_size_pretty(pg_total_relation_size('sales_pg')) AS size
[2026-05-05 23:13:53] 1 row retrieved starting from 1 in 334 ms (execution: 7 ms, fetching: 327 ms)
102 MB
```

# Ответы на вопросы

1. ClickHouse справился примерно в 40 раз быстрее
2. ClickHouse сжал данные эффективнее в 7 раз
3. ClickHouse идеален для OLAP-запросов
4. Разница ClickHouse и PostgreSQL 


- Модель хранения: колоночная vs строчная.
- Транзакции: отсутствие ACID (в традиционном смысле) vs полная поддержка.
- Индексы: разреженные (sparse) vs B-tree/GIN.
- Оптимизация: массовые вставки, агрегации, SIMD vs мелкие операции, JOIN, FK.
- Язык запросов: SQL-подобный, но с ограничениями (нет UPDATE/DELETE на лету без перезаписи данных) vs полноценный SQL.