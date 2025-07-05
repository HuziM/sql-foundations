### File: day7_recursive_cte.sql
-- This file contains a recursive CTE to generate Fibonacci numbers up to the 10th number.
-- Recursive Common Table Expression (CTE) to generate Fibonacci numbers
-- This example generates Fibonacci numbers up to the 10th number using a recursive CTE.
-- It starts with the first two numbers (0 and 1) and then recursively calculates the next numbers in the sequence.
WITH RECURSIVE fibonacci AS (
    SELECT 0 AS number, 1 AS next_number, 1 AS position
    UNION ALL
    SELECT next_number, number + next_number, position + 1
    FROM fibonacci
    WHERE position < 10
)
SELECT *
FROM fibonacci
ORDER BY position;

-- This query will output the Fibonacci sequence up to the 10th number, showing each number, its next number, and its position in the sequence.
-- The output will look like this:
-- number | next_number | position
-- -------+-------------+---------
-- 0      | 1           | 1
-- 1      | 1           | 2
-- 1      | 2           | 3     
-- 2      | 3           | 4
-- 3      | 5           | 5
-- 5      | 8           | 6
-- 8      | 13          | 7  
-- 13     | 21          | 8
-- 21     | 34          | 9
-- 34     | 55          | 10

###2. Recursive CTE for Employee Hierarchy
--Employee Org Drilldown
WITH RECURSIVE employee_hierarchy AS (
    SELECT e.emp_id, e.emp_name, e.manager_id, 1 AS level
    FROM "Employees" e
    WHERE manager_id IS NULL  -- Start with top-level employees (no manager)
    
    UNION ALL
    
    SELECT e.emp_id, e.emp_name, e.manager_id, eh.level + 1
    FROM "Employees" e
    JOIN employee_hierarchy eh ON e.manager_id = eh.emp_id
)
SELECT emp_id, emp_name, manager_id, level
FROM employee_hierarchy
ORDER BY level, emp_id;

###3. Count number of subordinates each manager has
WITH RECURSIVE employee_hierarchy AS (
    SELECT emp_id, manager_id, 1 AS level
    FROM "Employees"
    
    UNION ALL
    
    SELECT e.emp_id, e.manager_id, eh.level + 1
    FROM "Employees" e
    JOIN employee_hierarchy eh ON e.manager_id = eh.emp_id
)
SELECT manager_id, COUNT( DISTINCT emp_id ) AS subordinate_count
FROM employee_hierarchy
WHERE manager_id IS NOT NULL
GROUP BY manager_id
ORDER BY manager_id;

###4. Count number of employees at each level in the hierarchy
WITH RECURSIVE employee_hierarchy AS (
    SELECT emp_id, manager_id, 1 AS level
    FROM "Employees"
    WHERE manager_id IS NULL  -- Start with top-level employees (no manager)
    UNION ALL
    SELECT e.emp_id, e.manager_id, eh.level + 1
    FROM "Employees" e
    JOIN employee_hierarchy eh ON e.manager_id = eh.emp_id
)
SELECT level, COUNT(DISTINCT emp_id) AS employee_count
FROM employee_hierarchy
GROUP BY level
ORDER BY level;

###5. Count number of subordinates each manager has altogether including indirect subordinates
-- This query counts the total number of subordinates each manager has, including indirect subordinates.
-- It uses a recursive CTE to traverse the employee hierarchy and count all subordinates for each manager.
-- The result will show each manager's ID and the total count of their subordinates,
-- including those who report indirectly through other employees.
-- This is useful for understanding the overall structure of the organization and how many employees report to each manager.
-- It can help in identifying managers with large teams and understanding the distribution of employees across the hierarchy.
WITH RECURSIVE employee_hierarchy AS (
    -- Start from the top-most manager (e.g., CEO)
    SELECT 
        emp_id AS manager_id,
        emp_id AS subordinate_id
    FROM "Employees"
    UNION ALL
    -- Recursively find all subordinates
    SELECT 
        eh.manager_id,
        e.emp_id AS subordinate_id
    FROM "Employees" e
    JOIN employee_hierarchy eh ON e.manager_id = eh.subordinate_id
)
SELECT 
    manager_id,
    COUNT(*) - 1 AS total_subordinates  -- subtract 1 to exclude the manager themselves
FROM employee_hierarchy
GROUP BY manager_id
HAVING COUNT(*) > 1  -- Only include managers with subordinates
ORDER BY manager_id;