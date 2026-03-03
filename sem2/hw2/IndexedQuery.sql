CREATE INDEX customer_last_name_btree ON warehouse.customer USING btree(last_name);
EXPLAIN ANALYSE
SELECT *  FROM warehouse.customer WHERE last_name LIKE 'Иван%';
EXPLAIN (ANALYSE, BUFFERS)
SELECT *  FROM warehouse.customer WHERE last_name LIKE 'Иван%';
drop index warehouse.customer_last_name_btree;

CREATE INDEX customer_last_name_hash ON warehouse.customer USING hash(last_name);
EXPLAIN ANALYSE
SELECT *  FROM warehouse.customer WHERE last_name LIKE 'Иван%';
EXPLAIN (ANALYSE, BUFFERS)
SELECT *  FROM warehouse.customer WHERE last_name LIKE 'Иван%';
drop index warehouse.customer_last_name_hash;




CREATE INDEX product_catalog_on_unit_price_btree on warehouse.product_catalog USING btree(unit_price);
EXPLAIN ANALYSE
SELECT *  FROM warehouse.product_catalog WHERE unit_price < 30000;
EXPLAIN (ANALYSE, BUFFERS)
SELECT *  FROM warehouse.product_catalog WHERE unit_price < 30000;
DROP INDEX warehouse.product_catalog_on_unit_price_btree;

CREATE INDEX product_catalog_on_unit_price_hash on warehouse.product_catalog USING hash(unit_price);
EXPLAIN ANALYSE
SELECT *  FROM warehouse.product_catalog WHERE unit_price < 30000;
EXPLAIN (ANALYSE, BUFFERS)
SELECT *  FROM warehouse.product_catalog WHERE unit_price < 30000;
DROP INDEX warehouse.product_catalog_on_unit_price_hash;



CREATE INDEX order_item_on_product_id_btree on warehouse.order_item using btree(product_id);
EXPLAIN ANALYSE
SELECT *  FROM warehouse.order_item WHERE product_id = 124;
EXPLAIN (ANALYSE, BUFFERS)
SELECT *  FROM warehouse.order_item WHERE product_id = 124;
DROP INDEX warehouse.order_item_on_product_id_btree;

CREATE INDEX order_item_on_product_id_hash on warehouse.order_item using hash(product_id);
EXPLAIN ANALYSE
SELECT *  FROM warehouse.order_item WHERE product_id = 124;
EXPLAIN (ANALYSE, BUFFERS)
SELECT *  FROM warehouse.order_item WHERE product_id = 124;
DROP INDEX warehouse.order_item_on_product_id_hash;




CREATE INDEX product_catalog_on_category_id_btree on warehouse.product_catalog using btree(category_id);
EXPLAIN (ANALYSE, BUFFERS)
SELECT *  FROM warehouse.product_catalog WHERE category_id = 3;
DROP INDEX warehouse.product_catalog_on_category_id_btree;

CREATE INDEX product_catalog_on_category_id_hash on warehouse.product_catalog using hash(category_id);
EXPLAIN (ANALYSE, BUFFERS)
SELECT *  FROM warehouse.product_catalog WHERE category_id = 3;
DROP INDEX warehouse.product_catalog_on_category_id_hash;






CREATE INDEX  customer_on_email_hash on warehouse.customer using hash(email);
EXPLAIN (ANALYSE, BUFFERS)
SELECT *  FROM warehouse.customer WHERE email LIKE  'станислав.ширяева@gmail.com';
DROP INDEX warehouse.customer_on_email_hash;


CREATE INDEX  customer_on_email_btree on warehouse.customer using btree(email);
EXPLAIN (ANALYSE, BUFFERS)
SELECT *  FROM warehouse.customer WHERE email LIKE  'станислав.ширяева@gmail.com';
DROP INDEX warehouse.customer_on_email_btree;
-- drop index warehouse.customer_on_email;
--     drop index warehouse.product_catalog_on_category_id_using_hash;
--     drop index warehouse.product_catalog_on_category_id_using_btree;
--     drop index warehouse.order_item_on_product_id;
--     drop index warehouse.product_catalog_on_unit_price;
--     drop index warehouse.customer_last_name;


