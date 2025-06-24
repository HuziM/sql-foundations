DROP TABLE IF EXISTS "Customers";
CREATE TABLE "Customers" (
    customer_id INT PRIMARY KEY,
    customer_name TEXT
);

DROP TABLE IF EXISTS "Products";
CREATE TABLE "Products" (
    product_id INT PRIMARY KEY,
    product_name TEXT,
    category TEXT,
    price DECIMAL(10, 2)
);

DROP TABLE IF EXISTS "Sales";
CREATE TABLE "Sales" (
    sale_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES "Customers"(customer_id),
    product_id INT REFERENCES "Products"(product_id),
    quantity INT,
    sale_date DATE
);
