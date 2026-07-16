1.1 — Umsatz, Anzahl der Bestellungen und durchschnittlicher Bestellwert nach Region und Jahr

SELECT
    c.region,
    o.order_year,
    COUNT(o.order_id) AS num_orders,
    SUM(o.net_amount) AS total_revenue,
    AVG(o.net_amount) AS avg_order_value
FROM shopsphere_orders o
JOIN shopsphere_customers c ON o.customer_id = c.customer_id
GROUP BY c.region, o.order_year
ORDER BY c.region, o.order_year;

1.2 — Top 10 Kunden nach Gesamtausgaben

SELECT
    c.customer_id,
    c.region,
    c.acquisition_channel,
    COUNT(o.order_id) AS num_orders,
    SUM(o.net_amount) AS total_spent
FROM shopsphere_orders o
JOIN shopsphere_customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.region, c.acquisition_channel
ORDER BY total_spent DESC
LIMIT 10;

1.3 — Nach Kategorien: Umsatz, durchschnittliche Marge, Retourenquote

SELECT
    oi.category,
    SUM(oi.line_total) AS total_revenue,
    AVG(p.margin_pct)  AS avg_margin_pct,
    1.0 * COUNT(DISTINCT CASE WHEN o.is_returned = 1 THEN o.order_id END)
        / COUNT(DISTINCT o.order_id) AS return_rate
FROM shopsphere_order_items oi
JOIN shopsphere_orders   o ON oi.order_id   = o.order_id
JOIN shopsphere_products p ON oi.product_id = p.product_id
GROUP BY oi.category
ORDER BY total_revenue DESC;

1.4 — Kunden mit überdurchschnittlichen Ausgaben (Unterabfrage)

WITH customer_totals AS (
    SELECT customer_id, SUM(net_amount) AS total_spent
    FROM shopsphere_orders
    GROUP BY customer_id
)
SELECT
    COUNT(*) AS num_customers_above_avg,
    SUM(total_spent) AS revenue_from_above_avg,
    (SELECT SUM(total_spent) FROM customer_totals) AS total_revenue_all,
    1.0 * SUM(total_spent) / (SELECT SUM(total_spent) FROM customer_totals) AS share_of_total_revenue
FROM customer_totals
WHERE total_spent > (SELECT AVG(total_spent) FROM customer_totals);

1.5 — Nach Marketingkanälen: Budget, Umsatz, ROI

SELECT
    channel,
    SUM(budget) AS total_budget,
    SUM(attributed_reven) AS total_attributed_revenue,
    1.0 * SUM(attributed_reven) / SUM(budget) AS roi
FROM shopsphere_marketing
GROUP BY channel
ORDER BY roi DESC;


2.1

SELECT
    channel,
    SUM(budget) AS total_budget,
    SUM(attributed_revenue) AS total_attributed_revenue,
    1.0 * SUM(attributed_revenue) / SUM(budget) AS roi
FROM shopsphere_marketing
GROUP BY channel
ORDER BY roi DESC;

2.5

WITH customer_totals AS (
    SELECT customer_id, SUM(net_amount) AS total_spent
    FROM shopsphere_orders
    GROUP BY customer_id
)
SELECT
    customer_id,
    total_spent,
    ROW_NUMBER() OVER (ORDER BY total_spent DESC) * 100.0 / COUNT(*) OVER () AS rank_pct,
    SUM(total_spent) OVER (ORDER BY total_spent DESC) * 1.0
        / (SELECT SUM(total_spent) FROM customer_totals) AS cumulative_share
FROM customer_totals
ORDER BY total_spent DESC;

2.6

SELECT
    free_shipping,
    COUNT(*) AS num_orders,
    AVG(net_amount) AS avg_order_value,
    1.0 * SUM(is_returned) / COUNT(*) AS return_rate
FROM shopsphere_orders
GROUP BY free_shipping;

3.0

SELECT
    SUM(net_amount) AS total_revenue,
    COUNT(*) AS num_orders,
    AVG(net_amount) AS avg_order_value,
    1.0 * SUM(is_returned) / COUNT(*) AS return_rate
FROM shopsphere_orders;
