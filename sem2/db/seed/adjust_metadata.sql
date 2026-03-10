
UPDATE warehouse.customer
SET metadata = metadata - 'preferences'
WHERE random() < 0.95;

UPDATE warehouse.customer
SET metadata = jsonb_set(metadata, '{preferences,newsletter}', 'false', false)
WHERE metadata ? 'preferences' AND random() < 0.8;

ANALYZE warehouse.customer;


        -- Доля записей с ключом 'preferences' (ожидается ~5%)
SELECT count(*) * 1.0 / (SELECT count(*) FROM warehouse.customer) AS ratio
FROM warehouse.customer WHERE metadata ? 'preferences';

-- Доля записей с newsletter = true (ожидается ~1%)
SELECT count(*) * 1.0 / (SELECT count(*) FROM warehouse.customer) AS ratio
FROM warehouse.customer WHERE metadata @> '{"preferences": {"newsletter": true}}';