####Started on 2024-06-25 by creating a new database and 2 tables: Sales_Transactions and Customers
## This script creates the Sales_Transactions and Customers tables, inserts sample data, 
### and performs various queries based on practicing joins.

DROP TABLE IF EXISTS "Sales_Transactions";
CREATE TABLE "Sales_Transactions" (
	Transaction_ID SERIAL PRIMARY KEY,
	Customer_ID	INT,
	Product_ID INT,
	Amount DECIMAL(10,2),
	Transaction_Date DATE
);

INSERT INTO "Sales_Transactions" (customer_id, product_id, amount, transaction_date) VALUES
(1, 101, 500.00, '2024-06-01'),
(2, 102, 200.00, '2024-06-03'),
(1, 103, 450.00, '2024-06-10'),
(3, 101, 700.00, '2024-06-12'),
(2, 104, 150.00, '2024-06-15'),
(3, 105, 800.00, '2024-06-20'),
(1, 101, 300.00, '2024-06-22'),
(2, 102, 400.00, '2024-06-22');

DROP TABLE IF EXISTS "Customers";

CREATE TABLE "Customers" (
	Customer_ID	INT PRIMARY KEY,
	Customer_Name CHAR(40)
);

INSERT INTO "Customers" (Customer_ID, Customer_Name) 
VALUES
(1, 'Alex'),
(2, 'Lucas'),
(3, 'Anna');

SELECT * FROM "Sales_Transactions" ST
    LEFT JOIN "Customers" C ON ST.customer_id = C.customer_id;

###Get all transactions for product_id 101 with customer names
SELECT C.customer_name, ST.transaction_id, ST.transaction_date, ST.amount
FROM "Sales_Transactions" ST
LEFT JOIN "Customers" C ON ST.customer_id = C.customer_id
WHERE ST.product_id = 101
ORDER BY ST.transaction_id;

###Find total amount spent by each customer
SELECT C.customer_name, SUM(ST.amount) AS total_spent
FROM "Sales_Transactions" ST
LEFT JOIN "Customers" C ON ST.customer_id = C.customer_id
GROUP BY C.customer_name
ORDER BY total_spent DESC;

###Get the number of transactions for each customer
SELECT C.customer_name, COUNT(ST.transaction_id) AS transaction_count
FROM "Sales_Transactions" ST
LEFT JOIN "Customers" C ON ST.customer_id = C.customer_id
GROUP BY C.customer_name
ORDER BY transaction_count DESC;

###Get the average transaction amount for each customer
SELECT C.customer_name, ROUND(AVG(ST.amount)) AS average_spent
FROM "Sales_Transactions" ST
LEFT JOIN "Customers" C ON ST.customer_id = C.customer_id
GROUP BY C.customer_name
ORDER BY average_spent DESC;

###Update all the dates in the Sales_Transactions table to a year later
UPDATE "Sales_Transactions"
SET transaction_date = transaction_date + INTERVAL '1 year';

###List all transactions in the last 15 days
SELECT ST.transaction_id, ST.transaction_date, C.customer_name, ST.amount
FROM "Sales_Transactions" ST
LEFT JOIN "Customers" C ON ST.customer_id = C.customer_id
WHERE ST.transaction_date >= CURRENT_DATE - INTERVAL '15 days';

###Find the top 2 customers by total purchases
SELECT C.customer_name, SUM(ST.amount) AS total_purchases
FROM "Sales_Transactions" ST
LEFT JOIN "Customers" C ON ST.customer_id = C.customer_id
GROUP BY C.customer_name
ORDER BY total_purchases DESC
LIMIT 2;
