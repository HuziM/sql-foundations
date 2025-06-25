-- Subquery inside SELECT
-- Subquery inside WHERE
-- Subquery in FROM
-- CTE for multi-step logic
-- CTE + aggregation
-- CTE + JOIN + filter
-- Bonus: CTE + RANK()

-- Subquery inside SELECT
###Show each transaction and how it compares to the customer’s total and as a percentage of their total spending.

SELECT ST.transaction_id, C.customer_name, ROUND(ST.amount),
    ROUND((SELECT SUM(ST2.amount) FROM "Sales_Transactions" ST2 WHERE ST2.customer_id = ST.customer_id)) AS total_spent,
        ROUND((ST.amount / (SELECT SUM(ST2.amount) FROM "Sales_Transactions" ST2 WHERE ST2.customer_id = ST.customer_id)) * 100, 2) AS percent_of_total
    FROM "Sales_Transactions" ST
JOIN "Customers" C ON ST.customer_id = C.customer_id;

-- Use subquery to get avg spend
###Find all customers who spent more than the average spend of all customers.
SELECT C.customer_name, ST.amount
FROM "Sales_Transactions" ST
JOIN "Customers" C ON ST.customer_id = C.customer_id
WHERE ST.amount > (SELECT AVG(ST2.amount) FROM "Sales_Transactions" ST2);

###Find the product with the highest total sales (revenue).
-- Build a subquery that aggregates by product_id first
-- Then filter outer query to get highest
SELECT ST2.product_id, ST.total_sales
FROM (
    SELECT ST.product_id, SUM(ST.amount) AS total_sales 
    FROM "Sales_Transactions" ST
    GROUP BY ST.product_id
) AS ST
LEFT JOIN "Sales_Transactions" ST2 ON ST.product_id = ST2.product_id
ORDER BY ST.total_sales DESC
LIMIT 1;

###List customers and their total spend, and filter only those above 1000 using a CTE.
WITH customer_spend AS (
    SELECT C.customer_id, C.customer_name, SUM(ST.amount) AS total_spend
    FROM "Sales_Transactions" ST
    JOIN "Customers" C ON ST.customer_id = C.customer_id
    GROUP BY C.customer_id, C.customer_name
)
SELECT customer_id, customer_name, total_spend
FROM customer_spend
WHERE total_spend > 1000;


-- CTE for multi-step logic
###Find the top 3 customers by total spend, and show their average spend per transaction.
WITH customer_spend AS (
    SELECT C.customer_id, C.customer_name, SUM(ST.amount) AS total_spend,
           COUNT(ST.transaction_id) AS transaction_count
    FROM "Sales_Transactions" ST
    JOIN "Customers" C ON ST.customer_id = C.customer_id
    GROUP BY C.customer_id, C.customer_name
)
SELECT customer_id, customer_name, total_spend, transaction_count, ROUND((total_spend / transaction_count), 2) AS avg_spend_per_transaction
FROM customer_spend
ORDER BY total_spend DESC
LIMIT 3;

###Create Product table and insert data if needed.
DROP TABLE IF EXISTS "Product";
CREATE TABLE "Product" (
    product_id INT PRIMARY KEY,
    product_name TEXT,
    category TEXT,
    price DECIMAL(10, 2)
);

INSERT INTO "Product" (product_id, product_name, category, price)
VALUES
(101, 'Laptop', 'Electronics', 1000),
(102, 'Smartphone', 'Electronics', 500),
(103, 'Tablet', 'Electronics', 400),
(104, 'Headphones', 'Accessories', 200),
(105, 'Charger', 'Accessories', 50);

###Update Sales_Transactions to fix transaction amounts.
UPDATE "Sales_Transactions" SET amount = 1000 WHERE product_id = 101;
UPDATE "Sales_Transactions" SET amount = 500 WHERE product_id = 102;
UPDATE "Sales_Transactions" SET amount = 400 WHERE product_id = 103;
UPDATE "Sales_Transactions" SET amount = 200 WHERE product_id = 104;
UPDATE "Sales_Transactions" SET amount = 50 WHERE product_id = 105; 


###For each product category, show total revenue and number of customers who bought from it.
-- Also calculate average transaction value and average revenue per customer.
-- Use CTE to aggregate data by category.    
    WITH category_revenue AS (
    SELECT P.category, SUM(ST.amount) AS total_revenue,
           COUNT(DISTINCT ST.customer_id) AS customer_count,
           COUNT(ST.transaction_id) AS transaction_count
    FROM "Sales_Transactions" ST
    JOIN "Product" P ON ST.product_id = P.product_id
    GROUP BY P.category
) 
SELECT 
    CR.category, 
    CR.total_revenue, 
    CR.transaction_count, 
    ROUND((CR.total_revenue / CR.transaction_count), 2) AS avg_transaction_value,
    CR.customer_count, 
    ROUND((CR.total_revenue / CR.customer_count), 2) AS avg_revenue_per_customer
FROM category_revenue CR;

###Tag each customer as 'High Value' if they spent above 1200 total, else 'Regular'.
###Rank customers by total spend and show top 3 only.
WITH customer_tags AS (
    SELECT C.customer_name,
           CASE WHEN SUM(ST.amount) > 1200 THEN 'High Value' ELSE 'Regular' END AS customer_type,
           RANK() OVER (ORDER BY SUM(ST.amount) DESC) AS rank
    FROM "Sales_Transactions" ST
    JOIN "Customers" C ON ST.customer_id = C.customer_id
    GROUP BY C.customer_name
)
SELECT CT.* FROM customer_tags CT
WHERE CT.rank <= 3
ORDER BY CT.rank;

###Which customer made the most transactions AND had the highest average transaction size?
WITH customer_stats AS (
    SELECT C.customer_name,
           COUNT(ST.transaction_id) AS transaction_count,
           ROUND(AVG(ST.amount),2) AS avg_transaction_size
    FROM "Sales_Transactions" ST
    JOIN "Customers" C ON ST.customer_id = C.customer_id
    GROUP BY C.customer_name
)
SELECT * FROM customer_stats
WHERE transaction_count = (SELECT MAX(transaction_count) FROM customer_stats)
AND avg_transaction_size = (SELECT MAX(avg_transaction_size) FROM customer_stats);  