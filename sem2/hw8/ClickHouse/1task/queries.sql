-- создание таблиц
CREATE TABLE web_logs (
    log_time DateTime,
    ip String,
    url String,
    status_code UInt16,
    response_size UInt64
) ENGINE = MergeTree()
ORDER BY (log_time, status_code);

INSERT INTO web_logs
SELECT
    toDateTime('2024-03-01 00:00:00') + INTERVAL number SECOND,
    concat('192.168.0.', toString(number % 50)),
    arrayElement(['/home', '/api/users', '/api/orders', '/admin', '/products'], number % 5 + 1),
    arrayElement([200, 200, 200, 404, 500, 301, 200], number % 7 + 1),
    rand() % 1000000
FROM numbers(500000);

--1
SELECT ip, count(*) AS request_count
FROM web_logs
GROUP BY ip
ORDER BY request_count DESC
LIMIT 10;

--2
SELECT
round(countIf(status_code BETWEEN 200 AND 299) * 100.0 / count(*), 2) AS success_pct,
round(countIf(status_code >= 400) * 100.0 / count(*), 2) AS error_pct
FROM web_logs;

--3
SELECT
url,
count(*) AS hits,
avg(response_size) AS avg_size
FROM web_logs
GROUP BY url
ORDER BY hits DESC
LIMIT 1;

--4
SELECT
toHour(log_time) AS hour,
count(*) AS errors_500
FROM web_logs
WHERE status_code = 500
GROUP BY hour
ORDER BY errors_500 DESC
LIMIT 1;

