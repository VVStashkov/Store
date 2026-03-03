CREATE INDEX idx_warehouse_location ON warehouse.warehouse USING GIST (location);

CREATE INDEX idx_product_description ON warehouse.product_catalog USING GIN (to_tsvector('russian', description));

CREATE INDEX idx_customer_email ON warehouse.customer (email);