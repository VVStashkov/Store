-- 1
DROP INDEX IF EXISTS warehouse.idx_product_valid_period;

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM warehouse.product_catalog
WHERE valid_period @> '2027-01-01'::date;

CREATE INDEX idx_product_valid_period ON warehouse.product_catalog USING GIST (valid_period);

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM warehouse.product_catalog
WHERE valid_period @> '2027-01-01'::date;

--2
DROP INDEX IF EXISTS warehouse.idx_product_valid_period;

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM warehouse.product_catalog
WHERE valid_period @> '2025-4-10'::date;

CREATE INDEX idx_product_valid_period ON warehouse.product_catalog USING GIST (valid_period);

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM warehouse.product_catalog
WHERE valid_period @> '2025-4-10'::date;


--3
DROP INDEX IF EXISTS warehouse.idx_product_valid_period;

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM warehouse.product_catalog
WHERE valid_period && '[2028-01-01, 2028-01-02]'::daterange;

CREATE INDEX idx_product_valid_period ON warehouse.product_catalog USING GIST (valid_period);

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM warehouse.product_catalog
WHERE valid_period && '[2028-01-01, 2028-01-02]'::daterange;


--4
DROP INDEX IF EXISTS warehouse.idx_product_valid_period;

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM warehouse.product_catalog
WHERE valid_period << daterange('2025-01-01', '2025-12-31');

CREATE INDEX idx_product_valid_period ON warehouse.product_catalog USING GIST (valid_period);

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM warehouse.product_catalog
WHERE valid_period << daterange('2025-01-01', '2025-12-31');

--5
DROP INDEX IF EXISTS warehouse.idx_product_valid_period;

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM warehouse.product_catalog
WHERE valid_period -|- '[2028-01-01,2028-01-02]'::daterange;

CREATE INDEX idx_product_valid_period ON warehouse.product_catalog USING GIST (valid_period);

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM warehouse.product_catalog
WHERE valid_period -|- '[2028-01-01,2028-01-02]'::daterange;