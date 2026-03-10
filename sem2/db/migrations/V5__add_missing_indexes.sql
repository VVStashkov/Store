CREATE INDEX idx_customer_tags ON warehouse.customer USING GIN (tags);

CREATE INDEX idx_customer_metadata ON warehouse.customer USING GIN (metadata);

CREATE INDEX idx_product_valid_period ON warehouse.product_catalog USING GIST (valid_period);