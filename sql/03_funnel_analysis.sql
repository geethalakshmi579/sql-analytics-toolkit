-- 03_funnel_analysis.sql — channel funnel: signups -> first order -> repeat order
-- Shows conversion by acquisition channel (completed orders only).
WITH first_order AS (
    SELECT customer_id, MIN(order_date) AS first_order_date
    FROM orders
    WHERE status = 'completed'
    GROUP BY 1
),
order_counts AS (
    SELECT customer_id, COUNT(*) AS n_orders
    FROM orders
    WHERE status = 'completed'
    GROUP BY 1
)
SELECT c.channel,
       COUNT(*) AS signups,
       COUNT(f.customer_id) AS with_first_order,
       ROUND(100.0 * COUNT(f.customer_id) / COUNT(*), 1) AS signup_to_order_pct,
       SUM(CASE WHEN oc.n_orders >= 2 THEN 1 ELSE 0 END) AS repeat_buyers,
       ROUND(100.0 * SUM(CASE WHEN oc.n_orders >= 2 THEN 1 ELSE 0 END)
             / NULLIF(COUNT(f.customer_id), 0), 1) AS first_to_repeat_pct
FROM customers c
LEFT JOIN first_order f ON f.customer_id = c.customer_id
LEFT JOIN order_counts oc ON oc.customer_id = c.customer_id
GROUP BY 1
ORDER BY signups DESC;
