--1
DROP INDEX IF EXISTS warehouse.idx_customer_tags;

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM warehouse.customer WHERE tags @> ARRAY['tag1'];

CREATE INDEX idx_customer_tags ON warehouse.customer USING GIN (tags);

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM warehouse.customer WHERE tags @> ARRAY['tag1'];


--2
DROP INDEX IF EXISTS warehouse.idx_customer_metadata;

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM warehouse.customer WHERE metadata ? 'preferences';

CREATE INDEX idx_customer_metadata ON warehouse.customer USING GIN (metadata);

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM warehouse.customer WHERE metadata ? 'preferences';

--3

DROP INDEX IF EXISTS warehouse.idx_customer_metadata;

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM warehouse.customer WHERE metadata @> '{"preferences": {"newsletter": true}}';

CREATE INDEX idx_customer_metadata ON warehouse.customer USING GIN (metadata);

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM warehouse.customer WHERE metadata @> '{"preferences": {"newsletter": true}}';


-- 4
DROP INDEX IF EXISTS warehouse.idx_product_description;

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM warehouse.product_catalog
WHERE to_tsvector('english', description) @@ to_tsquery('english', 'repellat');

CREATE INDEX idx_product_description ON warehouse.product_catalog
    USING GIN (to_tsvector('english', description));

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM warehouse.product_catalog
WHERE to_tsvector('english', description) @@ to_tsquery('english', 'repellat');

--5
DROP INDEX IF EXISTS warehouse.idx_customer_tags;

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM warehouse.customer WHERE tags && ARRAY['tag1', 'tag2'];

CREATE INDEX idx_customer_tags ON warehouse.customer USING GIN (tags);

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM warehouse.customer WHERE tags && ARRAY['tag1', 'tag2'];