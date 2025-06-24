INSERT INTO "Customers" (customer_id, customer_name)
VALUES
(1, 'Sara'),
(2, 'Ahmed'),
(3, 'Ali'),
(4, 'Amna'),
(5, 'Danish');

INSERT INTO "Products" (product_id, product_name, category, price)
VALUES
(101, 'Laptop', 'Electronics', 1200.00),
(102, 'Smartphone', 'Electronics', 800.00),
(103, 'Tablet', 'Electronics', 500.00),
(104, 'Headphones', 'Accessories', 150.00), 
(105, 'Smartwatch', 'Accessories', 300.00),
(106, 'Charger', 'Accessories', 50.00);

INSERT INTO "Sales" (customer_id, product_id, quantity, sale_date)
VALUES
(1, 101, 1, '2025-06-11'),
(2, 102, 2, '2025-06-12'),
(3, 103, 1, '2025-06-13'),
(4, 104, 3, '2025-06-14'),
(5, 105, 1, '2025-06-15'),
(1, 106, 5, '2025-06-16'),
(2, 101, 1, '2025-06-17'),
(3, 102, 2, '2025-06-18'),
(4, 103, 1, '2025-06-19'),
(5, 104, 3, '2025-06-20'),
(1, 105, 1, '2025-06-21'),
(2, 106, 2, '2025-06-22'),
(3, 101, 1, '2025-06-23'),
(4, 102, 2, '2025-06-24'),
(5, 103, 1, '2025-06-25');
