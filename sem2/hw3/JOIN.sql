--1
EXPLAIN (ANALYZE, BUFFERS)
SELECT c.last_name, c.first_name, o.id, o.order_date, COUNT(oi.product_id) AS items_count
FROM warehouse.customer_order o
         JOIN warehouse.customer c ON o.customer_id = c.id
         LEFT JOIN warehouse.order_item oi ON o.id = oi.order_id
GROUP BY o.id, c.id, o.order_date
LIMIT 100;

--2
EXPLAIN (ANALYZE, BUFFERS)
SELECT c.*
FROM warehouse.customer c
         LEFT JOIN warehouse.customer_order o ON c.id = o.customer_id
WHERE o.id IS NULL;

--3
EXPLAIN (ANALYZE, BUFFERS)
SELECT p.name, COUNT(*) AS order_count
FROM warehouse.order_item oi
         JOIN warehouse.product_catalog p ON oi.product_id = p.id
GROUP BY p.id
ORDER BY order_count DESC
LIMIT 5;

--4
EXPLAIN (ANALYZE, BUFFERS)
SELECT w.name, w.address, COUNT(e.id) AS employee_count
FROM warehouse.warehouse w
         LEFT JOIN warehouse.employee e ON w.id = e.warehouse_id
GROUP BY w.id;

--5
EXPLAIN (ANALYZE, BUFFERS)
SELECT o.id, o.order_date, e.last_name AS employee_last, e.first_name AS employee_first
FROM warehouse.customer_order o
         JOIN warehouse.employee e ON o.employee_id = e.id
LIMIT 100;