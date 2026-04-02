--на мастере
CREATE TABLE orders_part (
     id SERIAL,
     order_date DATE,
     amount NUMERIC
) PARTITION BY RANGE (order_date);

CREATE TABLE orders_part_2025_01 PARTITION OF orders_part
    FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');
CREATE TABLE orders_part_2025_02 PARTITION OF orders_part
    FOR VALUES FROM ('2025-02-01') TO ('2025-03-01');
CREATE TABLE orders_part_default PARTITION OF orders_part DEFAULT;

CREATE PUBLICATION pub_orders FOR TABLE orders_part;


--на реплике
CREATE TABLE orders_part (
     id SERIAL,
     order_date DATE,
     amount NUMERIC
) PARTITION BY RANGE (order_date);

CREATE TABLE orders_part_2025_01 PARTITION OF orders_part
    FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');
CREATE TABLE orders_part_2025_02 PARTITION OF orders_part
    FOR VALUES FROM ('2025-02-01') TO ('2025-03-01');
CREATE TABLE orders_part_default PARTITION OF orders_part DEFAULT;

CREATE SUBSCRIPTION sub_orders
    CONNECTION 'host=postgres port=5432 dbname=Warehouse_DB user=admin password=admin_pass'
    PUBLICATION pub_orders;


-- для publish_via_partition_root = on
-- на мастере
ALTER PUBLICATION pub_orders SET (publish_via_partition_root = on);

--на реплике
CREATE TABLE orders_part (
     id SERIAL,
     order_date DATE,
     amount NUMERIC
) PARTITION BY HASH (amount);

CREATE TABLE orders_part_hash0 PARTITION OF orders_part
    FOR VALUES WITH (MODULUS 2, REMAINDER 0);
CREATE TABLE orders_part_hash1 PARTITION OF orders_part
    FOR VALUES WITH (MODULUS 2, REMAINDER 1);

CREATE SUBSCRIPTION sub_orders
    CONNECTION 'host=publisher port=5432 dbname=pub_db user=admin password=pass'
    PUBLICATION pub_orders;