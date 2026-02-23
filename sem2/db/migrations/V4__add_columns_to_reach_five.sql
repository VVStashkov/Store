ALTER TABLE warehouse.supplier
    ADD COLUMN address TEXT,
    ADD COLUMN contact_person VARCHAR(100);

ALTER TABLE warehouse.product_category
    ADD COLUMN description TEXT,
    ADD COLUMN parent_category_id INTEGER REFERENCES warehouse.product_category(id),
    ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

ALTER TABLE warehouse.payment_status
    ADD COLUMN description TEXT,
    ADD COLUMN sort_order INTEGER,
    ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

ALTER TABLE warehouse.warehouse
    ADD COLUMN name VARCHAR(100);

ALTER TABLE warehouse.customer_order
    ADD COLUMN order_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    ADD COLUMN status VARCHAR(20) DEFAULT 'new';

ALTER TABLE warehouse.payment
    ADD COLUMN comment TEXT;

ALTER TABLE warehouse.log
    ADD COLUMN username VARCHAR(100);

ALTER TABLE warehouse.manager_change_log
    ADD COLUMN reason TEXT;