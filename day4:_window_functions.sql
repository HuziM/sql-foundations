###Insert more data into sales_transactions table so that I can have better query analysis 
##To practice subqueries, CTEs, and window functions. 

INSERT INTO "Customers" ("customer_id", "customer_name")
VALUES
(4, 'Alice'),
(5, 'Bob'),
(6, 'Charlie');

INSERT INTO "Sales_Transactions" ("transaction_id", "customer_id", "product_id", "amount", "transaction_date")
VALUES
(9,  4, 101,  1000, '2025-06-23'),
(10, 5, 102,  500,  '2025-06-23'),
(11, 6, 103,  400,  '2025-06-23'),
(12, 4, 104,  200,  '2025-06-23'),
(13, 5, 105,  50,   '2025-06-23'),
(14, 1, 101,  1000, '2025-06-24'),
(15, 2, 102,  500,  '2025-06-24'),
(16, 3, 103,  400,  '2025-06-24'),
(17, 4, 104,  200,  '2025-06-24'),
(18, 5, 105,  50,   '2025-06-24'),
(19, 6, 101,  1000, '2025-06-24'),
(20, 1, 102,  500,  '2025-06-25'),
(21, 2, 103,  400,  '2025-06-25'),
(22, 3, 104,  200,  '2025-06-25'),
(23, 4, 105,  50,   '2025-06-25'),
(24, 5, 101,  1000, '2025-06-25'),
(25, 6, 102,  500,  '2025-06-25'),
(26, 1, 103,  400,  '2025-06-26'),
(27, 2, 104,  200,  '2025-06-26'),
(28, 3, 105,  50,   '2025-06-26'),
(29, 4, 101,  1000, '2025-06-26'),
(30, 5, 102,  500,  '2025-06-26'),
(31, 6, 103,  400,  '2025-06-26'),
(32, 1, 104,  200,  '2025-06-27'),
(33, 2, 105,  50,   '2025-06-27'),
(34, 3, 101,  1000, '2025-06-27'),
(35, 4, 102,  500,  '2025-06-27'),
(36, 5, 103,  400,  '2025-06-27'),
(37, 6, 104,  200,  '2025-06-27'),
(38, 1, 105,  50,   '2025-06-27'),
(39, 2, 101,  1000, '2025-06-28'),
(40, 3, 102,  500,  '2025-06-28'),
(41, 4, 103,  400,  '2025-06-28'),
(42, 5, 104,  200,  '2025-06-28'),
(43, 6, 105,  50,   '2025-06-28'),
(44,  5, 102,  500, '2025-06-28');

###Rank customers by total spend (with ties):
WITH total_spend AS (
    SELECT  ST.customer_id, 
            SUM(amount) AS tot_amt
    FROM "Sales_Transactions" ST
    GROUP BY customer_id
)
SELECT  C.customer_id,
        C.customer_name,
        ST.tot_amt,
        RANK () OVER (ORDER BY ST.tot_amt DESC) AS rankings
FROM total_spend ST
    LEFT JOIN "Customers" C ON C.customer_id = ST.customer_id;

###Assign row number to each customer’s transaction (latest first):
SELECT ST.*,
    ROW_NUMBER () OVER (PARTITION BY ST.customer_id ORDER BY transaction_date DESC ) AS row_no
FROM "Sales_Transactions" ST;

###Assign row number to each transaction (latest first & biggest first):
SELECT ST.*,
    ROW_NUMBER () OVER (ORDER BY ST.transaction_date DESC, ST.amount DESC ) AS row_no
FROM "Sales_Transactions" ST;

###Compare each customer's transaction to their previous one:
SELECT ST.*,
    LAG(ST.amount) OVER (PARTITION BY ST.customer_id ORDER BY ST.transaction_date) AS prev_amount
FROM "Sales_Transactions" ST;

###Find 3 most recent transactions per customer:
WITH filter_trans AS (
    SELECT ST.transaction_id, ST.customer_id, ST.product_id, ST.amount, ST.transaction_date,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY transaction_date DESC) AS row_num
FROM "Sales_Transactions" ST
)
SELECT * FROM filter_trans FT 
WHERE row_num <= 3;