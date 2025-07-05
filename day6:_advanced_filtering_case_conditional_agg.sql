###1. CASE logic for customer tiers
-- This query uses CASE logic to categorize customers into tiers based on their total spending.
SELECT 
    C.customer_id,
    C.customer_name,
    SUM(ST.amount) AS total_spent,
    CASE
        WHEN SUM(ST.amount) >= 4000 THEN 'Platinum'
        WHEN SUM(ST.amount) >= 3000 THEN 'Gold'
        WHEN SUM(ST.amount) >= 1500 THEN 'Silver'
        ELSE 'Bronze'
    END AS customer_tier
FROM "Sales_Transactions" ST
    LEFT JOIN "Customers" C ON ST.customer_id = C.customer_id
GROUP BY C.customer_id
ORDER BY total_spent DESC;

###2. Use Case to show day of week as either Weekend or Weekday
-- This query uses CASE logic to categorize transactions into weekend or weekday based on the transaction date.
SELECT 
    ST.transaction_id,
    ST.transaction_date,
    ST.amount,
    CASE 
        WHEN EXTRACT(DOW FROM ST.transaction_date) IN (0, 6) THEN 'Weekend' 
        WHEN EXTRACT(DOW FROM ST.transaction_date) IN (1, 2, 3, 4, 5) THEN 'Weekday'
    END AS weekday_or_weekend
FROM "Sales_Transactions" ST
ORDER BY ST.transaction_date;

###3. Show Total Revenue by Weekday and Weekend
-- This query calculates total revenue for weekdays and weekends, showing how much revenue comes from each.
SELECT 
    CASE 
        WHEN EXTRACT(DOW FROM ST.transaction_date) IN (0, 6) THEN 'Weekend' 
        WHEN EXTRACT(DOW FROM ST.transaction_date) IN (1, 2, 3, 4, 5) THEN 'Weekday'
    END AS weekday_or_weekend,
    SUM(ST.amount) AS total_revenue
FROM "Sales_Transactions" ST
GROUP BY weekday_or_weekend;

###4. Conditional aggregation – daily revenue vs weekend revenue
-- This query calculates daily revenue and weekend revenue, showing how much revenue comes from weekends.
SELECT 
    DATE(ST.transaction_date) AS transaction_date,
    SUM(ST.amount) AS daily_revenue,
    EXTRACT(DOW FROM ST.transaction_date) AS day_of_week,
    CASE 
        WHEN EXTRACT(DOW FROM ST.transaction_date) IN (0, 6) THEN 'Weekend' 
        WHEN EXTRACT(DOW FROM ST.transaction_date) IN (1, 2, 3, 4, 5) THEN 'Weekday'
    END AS weekday_or_weekend,
    SUM(CASE WHEN EXTRACT(DOW FROM ST.transaction_date) IN (0, 6) THEN ST.amount ELSE 0 END) AS weekend_revenue,
    SUM(CASE WHEN EXTRACT(DOW FROM ST.transaction_date) IN (1, 5) THEN ST.amount ELSE 0 END) AS weekday_revenue
FROM "Sales_Transactions" ST
GROUP BY DATE(ST.transaction_date)
ORDER BY transaction_date;

###5. Count how many high-value vs low-value days based on a threshold of total revenue in a day
-- This query counts the number of high-value and low-value days based on a threshold of total revenue in a day.
WITH daily_revenue AS (
    SELECT 
        DATE(ST.transaction_date) AS transaction_date,
        SUM(ST.amount) AS total_revenue
    FROM "Sales_Transactions" ST
    GROUP BY DATE(ST.transaction_date)
)
SELECT 
    CASE 
        WHEN total_revenue >= 2500 THEN 'High-Value Day'
        ELSE 'Low-Value Day'
    END AS day_type,
    COUNT(*) AS day_count
FROM daily_revenue
GROUP BY day_type
ORDER BY day_type;

###6. Count how many high-value vs low-value transactions
-- This query counts the number of high-value and low-value transactions based on a threshold of transaction amount.
SELECT 
    CASE 
        WHEN ST.amount >= 1000 THEN 'High-Value Transaction'
        ELSE 'Low-Value Transaction'
    END AS transaction_type,
    COUNT(*) AS transaction_count
FROM "Sales_Transactions" ST
GROUP BY transaction_type
ORDER BY transaction_type;

###7. Show whether more high-value transactions or low-value transactions happened on weekends vs weekdays
-- This query shows whether more high-value or low-value transactions happened on weekends vs weekdays.
SELECT 
    CASE 
        WHEN EXTRACT(DOW FROM ST.transaction_date) IN (0, 6) THEN 'Weekend' 
        WHEN EXTRACT(DOW FROM ST.transaction_date) IN (1, 2, 3, 4, 5) THEN 'Weekday'
    END AS weekday_or_weekend,
    CASE 
        WHEN ST.amount >= 1000 THEN 'High-Value Transaction'
        ELSE 'Low-Value Transaction'
    END AS transaction_type,
    COUNT(*) AS transaction_count
FROM "Sales_Transactions" ST
GROUP BY weekday_or_weekend, transaction_type
ORDER BY weekday_or_weekend, transaction_type;

###8. Show whether weekends or weekdays have more high-value days based on a threshold of total revenue in a day
-- This query shows whether weekends or weekdays have more high-value days based on a threshold of total revenue in a day.
WITH daily_revenue AS (
    SELECT 
        DATE(ST.transaction_date) AS transaction_date,
        SUM(ST.amount) AS total_revenue
    FROM "Sales_Transactions" ST
    GROUP BY DATE(ST.transaction_date)
)
SELECT 
    CASE 
        WHEN EXTRACT(DOW FROM transaction_date) IN (0, 6) THEN 'Weekend' 
        WHEN EXTRACT(DOW FROM transaction_date) IN (1, 2, 3, 4, 5) THEN 'Weekday'
    END AS weekday_or_weekend,
    CASE 
        WHEN total_revenue >= 2500 THEN 'High-Value Day'
        ELSE 'Low-Value Day'
    END AS day_type,
    COUNT(*) AS day_count
FROM daily_revenue
GROUP BY weekday_or_weekend, day_type
ORDER BY weekday_or_weekend, day_type;

###9. Show top 3 customers by total spending and which category they fall into
-- This query shows the top 3 customers by total spending. 
-- It also categorizes them into tiers based on their total spending.
-- The tiers are Platinum, Gold, Silver, and Bronze.
-- Platinum: >= 3000, Gold: >= 2000, Silver: >= 1000, Bronze: < 1000
-- It uses a CASE statement to categorize the customers.
-- The results are ordered by total spending in descending order.
-- This query can be used to identify high-value customers for targeted marketing or loyalty programs.
SELECT 
    C.customer_id,
    C.customer_name,
    SUM(ST.amount) AS total_spent,
    CASE
        WHEN SUM(ST.amount) >= 4000 THEN 'Platinum'
        WHEN SUM(ST.amount) >= 3000 THEN 'Gold'
        WHEN SUM(ST.amount) >= 2000 THEN 'Silver'
        ELSE 'Bronze'
    END AS customer_tier
FROM "Sales_Transactions" ST
    LEFT JOIN "Customers" C ON ST.customer_id = C.customer_id
GROUP BY C.customer_id, C.customer_name
ORDER BY total_spent DESC
LIMIT 3;


###Incorporating CASE LOGIC INTO WHERE CLAUSES
###10. Filter based on a business rule that changes by category
SELECT ST.*, P.category
FROM "Sales_Transactions" ST
JOIN "Product" P ON ST.product_id = P.product_id
WHERE ST.amount >
  CASE 
    WHEN P.category = 'Electronics' THEN 400
    WHEN P.category = 'Accessories' THEN 100
    ELSE 0
  END;

###11: Show transactions based on different date ranges per product
SELECT ST.*, P.product_name
FROM "Sales_Transactions" ST
JOIN "Product" P ON ST.product_id = P.product_id
WHERE ST.transaction_date >= 
  CASE 
    WHEN P.price >= 500 THEN CURRENT_DATE - INTERVAL '5 days'
    ELSE CURRENT_DATE - INTERVAL '30 days'
  END;
