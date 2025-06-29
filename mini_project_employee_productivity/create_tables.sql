DROP TABLE IF EXISTS "Employees";
CREATE TABLE "Employees" (
    emp_id SERIAL PRIMARY KEY,
    emp_name TEXT,
    department TEXT
);

DROP TABLE IF EXISTS "Work_Log";
CREATE TABLE "Work_Log" (
    log_id SERIAL PRIMARY KEY,
    emp_id INT REFERENCES "Employees"(emp_id),
    work_date DATE,
    hours_worked INT,
    task_type TEXT
);


