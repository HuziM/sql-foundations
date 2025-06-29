SELECT * FROM "Customers";
SELECT * FROM "Sales_Transactions";

###Added a new customer with new customer_id and same name as an existing customer
INSERT INTO "Customers" ("customer_id", "customer_name")
VALUES
(7, 'Alex');

###UNION vs UNION ALL (Goal: See how UNION removes duplicates, while UNION ALL doesn’t.)
-- UNION removes duplicates, while UNION ALL keeps all records, including duplicates.
-- Example of UNION: shows 6 records instead of 7 as it removes the duplicate 'Alex'.
SELECT C.customer_name FROM "Customers" C WHERE customer_id < 7
UNION
SELECT C.customer_name FROM "Customers" C WHERE customer_id >= 7;
-- Example of UNION ALL: shows all 7 records, including the duplicate 'Alex'.
SELECT C.customer_name FROM "Customers" C WHERE customer_id < 7
UNION ALL
SELECT C.customer_name FROM "Customers" C WHERE customer_id >= 7;

###Find the customers who bought each product
-- This query shows all unique combinations of customers and products they bought.
SELECT DISTINCT ST.customer_id, ST.product_id FROM "Sales_Transactions" ST ORDER BY ST.customer_id, ST.product_id; 


###had to insert a new customer and transactions to see the effect of INTERSECT that follows
INSERT INTO "Customers" ("customer_id", "customer_name")
VALUES
(8, 'John');
INSERT INTO "Sales_Transactions" ("transaction_id", "customer_id", "product_id", "amount", "transaction_date")
VALUES
(45, 7, 101, 1000, '2025-06-29'),
(46, 8, 102, 500,  '2025-06-29');

INSERT INTO "Sales_Transactions" ("transaction_id", "customer_id", "product_id", "amount", "transaction_date")
VALUES
(47, 7, 102, 500,  '2025-06-29');

###INTERSECT (Goal: Find common customers in two different sets)
-- INTERSECT returns only the records that are present in both sets.
-- This query finds customers who bought product 101 and also bought product 102.
-- It will return customer_id 7, as they bought both products.
-- while customer_id 8 will not be returned as they only bought product 102.
SELECT ST.customer_id FROM "Sales_Transactions" ST WHERE ST.product_id = 101 AND ST.customer_id > 6
INTERSECT
SELECT ST.customer_id FROM "Sales_Transactions" ST WHERE ST.product_id = 102 AND ST.customer_id > 6;

###Have to insert a new customer and transactions to see the effect of LEFT JOIN WHERE NULL that follows
INSERT INTO "Customers" ("customer_id", "customer_name")
VALUES
(9, 'John'),
(10, 'Doe');

###LEFT JOIN WHERE NULL – Same logic, different pattern
-- Customers without transactions
-- This query finds customers who have not made any transactions.
-- It uses a LEFT JOIN to find customers and checks for NULL in the transaction_id.
-- It will return customer_id 9 and 10, as they have no transactions.
-- Note: The LEFT JOIN ensures that all customers are included, and the WHERE clause filters out
-- those who have made transactions.
-- This is a common pattern to find records in one table that do not have corresponding records in another table.
-- It is often used to find missing or unmatched records.
SELECT C.customer_id 
FROM "Customers" C
    LEFT JOIN "Sales_Transactions" ST1 ON C.customer_id = ST1.customer_id
WHERE ST1.transaction_id IS NULL;

###6. Combine Filters With Sets
-- Using EXCEPT to find customers who bought in the second half of June but not in the first half
-- This query finds customers who made purchases in the second half of June (after the 15th)
-- but did not make any purchases in the first half of June (before the 16th).
-- It uses EXCEPT to find the difference between two sets.
-- Used in real world cases to find customers who have changed their buying patterns or to identify new customers.
SELECT DISTINCT ST.customer_id 
FROM "Sales_Transactions" ST
WHERE ST.transaction_date >= '2025-06-16'
EXCEPT
SELECT DISTINCT ST.customer_id 
FROM "Sales_Transactions" ST
WHERE ST.transaction_date < '2025-06-16';

###7. Using CTEs with Set Operations
-- Common Table Expressions (CTEs) can be used to simplify complex queries.
-- This example uses a CTE to find customers who made purchases in the first half of June
-- and then uses a UNION to combine it with customers who made purchases in the second half of June.
WITH first_half AS (
    SELECT DISTINCT ST.customer_id 
    FROM "Sales_Transactions" ST
    WHERE ST.transaction_date < '2025-06-16'
),
second_half AS (
    SELECT DISTINCT ST.customer_id 
    FROM "Sales_Transactions" ST
    WHERE ST.transaction_date >= '2025-06-16'
)
SELECT customer_id FROM first_half
UNION
SELECT customer_id FROM second_half;

###8. Using Set Operations with Aggregates
-- Set operations can also be used with aggregate functions.
-- This example finds the total amount spent by customers in the first half of June
-- and combines it with the total amount spent in the second half of June.
WITH first_half AS (
    SELECT customer_id, SUM(amount) AS total_spent, 1 AS half
    FROM "Sales_Transactions"
    WHERE transaction_date < '2025-06-16'
    GROUP BY customer_id
),
second_half AS (
    SELECT customer_id, SUM(amount) AS total_spent, 2 AS half
    FROM "Sales_Transactions"
    WHERE transaction_date >= '2025-06-16'
    GROUP BY customer_id
)
SELECT customer_id, total_spent, half FROM first_half
UNION ALL
SELECT customer_id, total_spent, half FROM second_half
ORDER BY customer_id, half;

###INTERSECT with Multiple Columns
-- INTERSECT can also be used with multiple columns.
-- This example finds customers who bought the same product, may or may not have bought more products as well.
SELECT ST.customer_id, ST.product_id 
FROM "Sales_Transactions" ST
WHERE ST.customer_id > 6 AND ST.product_id = 102
INTERSECT
SELECT ST.customer_id, ST.product_id 
FROM "Sales_Transactions" ST
WHERE ST.customer_id > 6;

SELECT * FROM "Customers";
###Create a new table Leads to show status of customers and how many leads were converted to customers.
DROP TABLE IF EXISTS "Leads";
CREATE TABLE "Leads" (
    lead_id SERIAL PRIMARY KEY,
    lead_name TEXT
);
INSERT INTO "Leads" (lead_name)
VALUES
('Lucas'),
('Harry'),
('Sarah'),
('Alice'),
('Hansen'),
('Doe'),
('Bob');


###Show leads who became customers (INTERSECT)
SELECT C.customer_name 
FROM "Customers" C
INTERSECT
SELECT L.lead_name 
FROM "Leads" L;


###Show customers not from leads (EXCEPT)
SELECT C.customer_name 
FROM "Customers" C
EXCEPT
SELECT L.lead_name 
FROM "Leads" L;

###Tag all leads with Status: 'Converted' or 'Unconverted' using LEFT JOIN
SELECT C.customer_name, 
       CASE 
           WHEN L.lead_id IS NOT NULL THEN 'Converted' 
           ELSE 'Unconverted' 
       END AS status
FROM "Customers" C
LEFT JOIN "Leads" L ON C.customer_name = L.lead_name
ORDER BY L.lead_id;