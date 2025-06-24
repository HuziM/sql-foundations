### This file contains SQL queries that demonstrate the use of GROUP BY, HAVING, and JOIN clauses.


SELECT * 
FROM "Sales_Transactions" ST
LEFT JOIN "Customers" C ON ST.customer_id = C.customer_id;


###Total sales and number of transactions per product
SELECT ST.product_id,
       SUM(ST.amount) AS total_sales,
       COUNT(ST.transaction_id) AS number_of_transactions
FROM "Sales_Transactions" ST
GROUP BY ST.product_id
ORDER BY total_sales DESC;

###Total sales and number of transactions per product, excluding products with no sales
SELECT ST.product_id,
       SUM(ST.amount) AS total_sales,
       COUNT(ST.transaction_id) AS number_of_transactions
FROM "Sales_Transactions" ST
WHERE ST.amount > 0
GROUP BY ST.product_id
ORDER BY total_sales DESC;  

###Average spend per customer
SELECT C.customer_id, C.customer_name,
       ROUND(AVG(ST.amount)) AS average_spend
FROM "Sales_Transactions" ST
JOIN "Customers" C ON ST.customer_id = C.customer_id
GROUP BY C.customer_id, C.customer_name
ORDER BY average_spend DESC;

###Top 3 customers by total spend
SELECT C.customer_id, C.customer_name,
       SUM(ST.amount) AS total_spend
FROM "Sales_Transactions" ST
JOIN "Customers" C ON ST.customer_id = C.customer_id
GROUP BY C.customer_id, C.customer_name
ORDER BY total_spend DESC
LIMIT 3;

###Products with more than 1 transaction
SELECT ST.product_id,
       COUNT(ST.transaction_id) AS number_of_transactions
FROM "Sales_Transactions" ST
GROUP BY ST.product_id
HAVING COUNT(ST.transaction_id) > 1
ORDER BY number_of_transactions DESC;

###Customers who spent more than 1000 total (use HAVING)
SELECT C.customer_id, C.customer_name,
      ROUND(SUM(ST.amount)) AS total_spend
FROM "Sales_Transactions" ST
JOIN "Customers" C ON ST.customer_id = C.customer_id
GROUP BY C.customer_id, C.customer_name
HAVING SUM(ST.amount) > 1000
ORDER BY total_spend DESC;
