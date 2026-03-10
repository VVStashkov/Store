DROP INDEX IF EXISTS idx_product_description;

CREATE INDEX idx_product_description ON warehouse.product_catalog
    USING GIN (to_tsvector('english', description));