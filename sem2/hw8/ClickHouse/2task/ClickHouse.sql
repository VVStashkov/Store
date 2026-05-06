--подготовка таблицы
CREATE TABLE sales_ch (
    sale_date DateTime,
    product_id UInt64,
    category String,
    quantity UInt32,
    price Float64,
    customer_id UInt64
) ENGINE = MergeTree()
ORDER BY (sale_date);

INSERT INTO sales_ch
SELECT
    toDateTime('2024-01-01 00:00:00') + INTERVAL number MINUTE,
    number % 1000,
    arrayElement(['Electronics', 'Clothing', 'Food', 'Books'], number % 4 + 1),
    rand() % 10 + 1,
    round(rand() % 10000 / 100, 2),
    number % 50000
FROM numbers(1000000);

SELECT sum(quantity * price) AS total_sales
FROM sales_ch
WHERE sale_date >= '2024-01-01' AND sale_date < '2024-02-01';

SELECT
    table,
    formatReadableSize(sum(bytes)) AS size
FROM system.parts
WHERE table = 'sales_ch' AND active
GROUP BY table;

