-- 04_window_functions.sql — revenue analytics with window functions
-- a) Monthly revenue + running total + month-over-month growth
-- b) Top 2 products per category by revenue (ROW_NUMBER)
-- c) Each customer's order sequence and lifetime value so far

-- a)
WITH monthly AS (
    SELECT substr(order_date, 1, 7) AS month,
           ROUND(SUM(quantity * unit_price), 2) AS revenue
    FROM orders
    WHERE status = 'completed'
    GROUP BY 1
)
SELECT month,
       revenue,
       ROUND(SUM(revenue) OVER (ORDER BY month), 2) AS running_revenue,
       ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY month))
             / NULLIF(LAG(revenue) OVER (ORDER BY month), 0), 1) AS mom_growth_pct
FROM monthly
ORDER BY month;

-- b)
SELECT category, product_name, revenue, rnk
FROM (
    SELECT p.category, p.product_name,
           ROUND(SUM(o.quantity * o.unit_price), 2) AS revenue,
           ROW_NUMBER() OVER (PARTITION BY p.category
                              ORDER BY SUM(o.quantity * o.unit_price) DESC) AS rnk
    FROM orders o
    JOIN products p ON p.product_id = o.product_id
    WHERE o.status = 'completed'
    GROUP BY 1, 2
)
WHERE rnk <= 2
ORDER BY category, rnk;

-- c)
SELECT customer_id, order_id, order_date,
       ROUND(quantity * unit_price, 2) AS order_value,
       ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date, order_id) AS order_seq,
       ROUND(SUM(quantity * unit_price) OVER (
           PARTITION BY customer_id ORDER BY order_date, order_id
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 2) AS lifetime_value_so_far
FROM orders
WHERE status = 'completed'
ORDER BY customer_id, order_seq
LIMIT 50;
