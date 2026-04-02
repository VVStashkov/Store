CREATE TABLE orders_range (
  id SERIAL,
  order_date DATE NOT NULL,
  customer_id INT,
  amount NUMERIC
) PARTITION BY RANGE (order_date);

CREATE TABLE orders_range_2025_01 PARTITION OF orders_range
    FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');
CREATE TABLE orders_range_2025_02 PARTITION OF orders_range
    FOR VALUES FROM ('2025-02-01') TO ('2025-03-01');
CREATE TABLE orders_range_2025_03 PARTITION OF orders_range
    FOR VALUES FROM ('2025-03-01') TO ('2025-04-01');

CREATE INDEX idx_orders_range_date ON orders_range (order_date);
INSERT INTO orders_range (order_date, customer_id, amount)
SELECT
    '2025-01-01'::date + (random() * 60)::int,
    (random() * 100)::int,
    (random() * 1000)::numeric
FROM generate_series(1, 10000);

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM orders_range
WHERE order_date >= '2025-02-01' AND order_date < '2025-03-01';

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM orders_range
WHERE order_date BETWEEN '2025-01-15' AND '2025-02-15';

DROP TABLE orders_range;

