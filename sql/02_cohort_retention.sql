-- 02_cohort_retention.sql — monthly signup cohorts, % active in later months
-- "Active" = placed at least one completed order that month.
WITH cohorts AS (
    SELECT customer_id,
           substr(signup_date, 1, 7) AS cohort_month
    FROM customers
),
activity AS (
    SELECT DISTINCT c.customer_id, c.cohort_month,
           substr(o.order_date, 1, 7) AS active_month
    FROM cohorts c
    JOIN orders o ON o.customer_id = c.customer_id
    WHERE o.status = 'completed'
),
cohort_sizes AS (
    SELECT cohort_month, COUNT(*) AS customers
    FROM cohorts
    GROUP BY 1
),
months AS (
    SELECT DISTINCT substr(order_date, 1, 7) AS m FROM orders
),
grid AS (
    SELECT cs.cohort_month, m.m AS active_month, cs.customers
    FROM cohort_sizes cs CROSS JOIN months m
    WHERE m.m >= cs.cohort_month
)
SELECT g.cohort_month,
       g.active_month,
       g.customers AS cohort_size,
       COUNT(a.customer_id) AS active_customers,
       ROUND(100.0 * COUNT(a.customer_id) / g.customers, 1) AS retention_pct
FROM grid g
LEFT JOIN activity a
  ON a.cohort_month = g.cohort_month AND a.active_month = g.active_month
GROUP BY 1, 2, 3
ORDER BY 1, 2;
