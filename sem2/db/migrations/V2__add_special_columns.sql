-- 1. JSONB в таблицу customer
ALTER TABLE warehouse.customer ADD COLUMN metadata JSONB;

-- 2. Массив текста в customer (теги)
ALTER TABLE warehouse.customer ADD COLUMN tags TEXT[];

-- 3. Range-тип (daterange) в product_catalog – срок действия
ALTER TABLE warehouse.product_catalog ADD COLUMN valid_period daterange;

-- 4. Геометрический тип (point) в warehouse – координаты склада
ALTER TABLE warehouse.warehouse ADD COLUMN location POINT;

-- 5. Полнотекстовое поле (description) в product_catalog
ALTER TABLE warehouse.product_catalog ADD COLUMN description TEXT;