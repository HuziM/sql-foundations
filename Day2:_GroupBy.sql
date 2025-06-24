SELECT * 
FROM "Sales_Transactions" ST
LEFT JOIN "Customers" C ON ST.customer_id = C.customer_id;


###Total sales and number of transactions per product
SELECT st.product_id,
       SUM(st.amount) AS total_sales,
       COUNT(st.transaction_id) AS number_of_transactions
FROM "Sales_Transactions" st
GROUP BY st.product_id
ORDER BY total_sales DESC;

###Total sales and number of transactions per product, excluding products with no sales
SELECT st.product_id,
       SUM(st.amount) AS total_sales,
       COUNT(st.transaction_id) AS number_of_transactions
FROM "Sales_Transactions" st
WHERE st.amount > 0
GROUP BY st.product_id
ORDER BY total_sales DESC;  

###Average spend per customer
SELECT c.customer_id, c.customer_name,
       ROUND(AVG(st.amount)) AS average_spend
FROM "Sales_Transactions" st
JOIN "Customers" c ON st.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name 
ORDER BY average_spend DESC;

###Top 3 customers by total spend
SELECT c.customer_id, c.customer_name,
       SUM(st.amount) AS total_spend
FROM "Sales_Transactions" st
JOIN "Customers" c ON st.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_spend DESC
LIMIT 3;

###Products with more than 1 transaction
SELECT st.product_id,
       COUNT(st.transaction_id) AS number_of_transactions
FROM "Sales_Transactions" st
GROUP BY st.product_id      
HAVING COUNT(st.transaction_id) > 1
ORDER BY number_of_transactions DESC;   

###Customers who spent more than 1000 total (use HAVING)
SELECT C.customer_id, C.customer_name,
      ROUND(SUM(ST.amount)) AS total_spend
FROM "Sales_Transactions" ST
JOIN "Customers" C ON ST.customer_id = C.customer_id
GROUP BY C.customer_id, C.customer_name
HAVING SUM(ST.amount) > 1000
ORDER BY total_spend DESC;
