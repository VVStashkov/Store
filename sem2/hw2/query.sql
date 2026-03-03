EXPLAIN ANALYSE
SELECT *  FROM warehouse.customer WHERE last_name LIKE 'Иван%';

EXPLAIN ANALYSE
SELECT *  FROM warehouse.product_catalog WHERE unit_price < 30000;

EXPLAIN ANALYSE
SELECT *  FROM warehouse.order_item WHERE product_id = 124;

EXPLAIN ANALYSE
SELECT *  FROM warehouse.product_catalog WHERE category_id = 3;

EXPLAIN ANALYSE
SELECT *  FROM warehouse.customer WHERE email LIKE  'станислав.ширяева@gmail.com';



EXPLAIN (ANALYSE, BUFFERS)
SELECT *  FROM warehouse.customer WHERE last_name LIKE 'Иван%';

EXPLAIN (ANALYSE, BUFFERS)
SELECT *  FROM warehouse.product_catalog WHERE unit_price < 30000;

EXPLAIN (ANALYSE, BUFFERS)
SELECT *  FROM warehouse.order_item WHERE product_id = 124;

EXPLAIN (ANALYSE, BUFFERS)
SELECT *  FROM warehouse.product_catalog WHERE category_id = 3;

EXPLAIN (ANALYSE, BUFFERS)
SELECT *  FROM warehouse.customer WHERE email LIKE  'станислав.ширяева@gmail.com';