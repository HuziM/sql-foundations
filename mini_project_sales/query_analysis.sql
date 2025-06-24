###Total revenue per product
SELECT P.product_id, P.product_name, SUM(S.quantity * P.price) AS total_revenue
FROM "Sales" S
    LEFT JOIN "Products" P ON S.product_id = P.product_id
GROUP BY P.product_id, P.product_name
ORDER BY total_revenue DESC;

###Top 3 products by total revenue
SELECT P.product_id, P.product_name, SUM(S.quantity * P.price) AS total_revenue
FROM "Sales" S
    LEFT JOIN "Products" P ON S.product_id = P.product_id
GROUP BY P.product_id, P.product_name
ORDER BY total_revenue DESC
LIMIT 3;

###Top 3 customers by total spend
SELECT C.customer_id, C.customer_name, SUM(S.quantity * P.price) AS total_spend
FROM "Sales" S
    LEFT JOIN "Customers" C ON S.customer_id = C.customer_id
    LEFT JOIN "Products" P ON S.product_id = P.product_id
GROUP BY C.customer_id, C.customer_name
ORDER BY total_spend DESC
LIMIT 3;

###Best-selling category by quantity
SELECT P.category, SUM(S.quantity) AS total_quantity
FROM "Sales" S
    LEFT JOIN "Products" P ON S.product_id = P.product_id
GROUP BY P.category
ORDER BY total_quantity DESC
LIMIT 1;

###Daily revenue trend
SELECT S.sale_date, SUM(S.quantity * P.price) AS daily_revenue
FROM "Sales" S
    LEFT JOIN "Products" P ON S.product_id = P.product_id
GROUP BY S.sale_date
ORDER BY S.sale_date;

###Customer who bought the most unique products
SELECT C.customer_id, C.customer_name, COUNT(DISTINCT S.product_id) AS unique_products
FROM "Sales" S
    LEFT JOIN "Customers" C ON S.customer_id = C.customer_id
GROUP BY C.customer_id, C.customer_name
ORDER BY unique_products DESC
LIMIT 1;

###Average order value per customer
SELECT C.customer_id, C.customer_name, ROUND(AVG(S.quantity * P.price)) AS average_order_value
FROM "Sales" S
    LEFT JOIN "Customers" C ON S.customer_id = C.customer_id
    LEFT JOIN "Products" P ON S.product_id = P.product_id
GROUP BY C.customer_id, C.customer_name
ORDER BY average_order_value DESC;

###Total sales per customer
SELECT C.customer_id, C.customer_name, SUM(S.quantity * P.price) AS total_sales
FROM "Sales" S
    LEFT JOIN "Customers" C ON S.customer_id = C.customer_id
    LEFT JOIN "Products" P ON S.product_id = P.product_id
GROUP BY C.customer_id, C.customer_name
ORDER BY total_sales DESC
LIMIT 5;