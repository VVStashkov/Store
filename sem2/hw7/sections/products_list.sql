CREATE TABLE products_list (
   id SERIAL,
   category VARCHAR(20) NOT NULL,
   name TEXT,
   price NUMERIC
) PARTITION BY LIST (category);

-- Секции для разных категорий
CREATE TABLE products_list_elec PARTITION OF products_list
    FOR VALUES IN ('electronics');
CREATE TABLE products_list_cloth PARTITION OF products_list
    FOR VALUES IN ('clothing');
CREATE TABLE products_list_other PARTITION OF products_list
    DEFAULT;  -- секция по умолчанию

-- Индекс на ключе секционирования
CREATE INDEX idx_products_list_category ON products_list (category);

INSERT INTO products_list (category, name, price)
SELECT
    CASE (random() * 2)::int
        WHEN 0 THEN 'electronics'
        WHEN 1 THEN 'clothing'
        ELSE 'books'
END,
    'product_' || gs,
    (random() * 100)::numeric
FROM generate_series(1, 10000) as gs;

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM products_list WHERE category = 'electronics';

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM products_list WHERE category IN ('electronics', 'clothing');

DROP TABLE products_list;
