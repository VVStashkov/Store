CREATE EXTENSION IF NOT EXISTS pageinspect;

SELECT ctid, xmin, xmax, * FROM warehouse.customer LIMIT 1;

SELECT lp, t_infomask
FROM heap_page_items(get_raw_page('warehouse.customer', 0))
WHERE lp = 1;