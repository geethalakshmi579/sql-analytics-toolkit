-- 05_data_quality.sql — data-quality assertions; every query should return 0 rows
-- (or a value within its stated expectation) on a healthy dataset.

-- 1. Orders referencing missing customers (expect 0)
SELECT o.order_id FROM orders o
LEFT JOIN customers c ON c.customer_id = o.customer_id
WHERE c.customer_id IS NULL;

-- 2. Duplicate order_ids (expect 0)
SELECT order_id, COUNT(*) FROM orders GROUP BY 1 HAVING COUNT(*) > 1;

-- 3. Orders dated before the customer's signup (expect 0)
SELECT o.order_id, o.customer_id, o.order_date, c.signup_date
FROM orders o JOIN customers c ON c.customer_id = o.customer_id
WHERE o.order_date < c.signup_date;

-- 4. Non-positive quantities or prices (expect 0)
SELECT order_id FROM orders WHERE quantity <= 0 OR unit_price <= 0;

-- 5. Null key columns (expect 0)
SELECT * FROM (
    SELECT 'customers' AS tbl, COUNT(*) AS null_keys FROM customers WHERE customer_id IS NULL
    UNION ALL
    SELECT 'orders', COUNT(*) FROM orders WHERE order_id IS NULL OR customer_id IS NULL
    UNION ALL
    SELECT 'products', COUNT(*) FROM products WHERE product_id IS NULL
) WHERE null_keys > 0;

-- 6. Status values outside the allowed set (expect 0)
SELECT DISTINCT status FROM orders
WHERE status NOT IN ('completed', 'refunded', 'cancelled');

-- 7. Completeness: % of orders missing nothing critical (expect 100.0; row appears only if below)
SELECT * FROM (
    SELECT ROUND(100.0 * SUM(CASE WHEN customer_id IS NOT NULL
                                  AND product_id IS NOT NULL
                                  AND order_date IS NOT NULL THEN 1 ELSE 0 END)
                 / COUNT(*), 2) AS completeness_pct
    FROM orders
) WHERE completeness_pct < 100.0;
