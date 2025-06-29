###Show each employee's cumulative total hours using SUM() OVER (...)
-- This query calculates the total hours worked by each employee across all work logs.
-- It uses a window function to sum the hours worked, partitioned by employee ID.
SELECT DISTINCT ON (WL.emp_id)
    WL.emp_id,
    E.emp_name,
    E.department,
    SUM(WL.hours_worked) OVER (PARTITION BY WL.emp_id) AS total_hours
FROM "Work_Log" WL
    LEFT JOIN "Employees" E ON WL.emp_id = E.emp_id
ORDER BY WL.emp_id;
###Solution using a simple GROUP BY
-- This query aggregates the total hours worked by each employee using a GROUP BY clause.
-- It sums the hours worked for each employee and groups the results by employee ID, name,
-- and department.
-- The results are ordered by employee ID.
-- This is a more straightforward approach compared to the window function, as it does not require
-- the use of window functions and directly aggregates the data.
-- It provides the same total hours worked by each employee but does not include the cumulative
-- total in the same way as the window function does.
-- This query is useful for generating a summary report of total hours worked by each employee.
-- It can be used to analyze employee productivity and workload distribution.
SELECT 
    WL.emp_id,
    E.emp_name,
    E.department,
    SUM(WL.hours_worked) AS total_hours
FROM "Work_Log" WL
    LEFT JOIN "Employees" E ON WL.emp_id = E.emp_id
GROUP BY WL.emp_id, E.emp_name, E.department
ORDER BY WL.emp_id;

###Use LAG() to calculate daily hour changes
-- This query calculates the change in hours worked by each employee compared to the previous day.
-- It uses the LAG() window function to retrieve the hours worked on the previous day for each employee.
-- The results are ordered by employee ID and work date.
-- The query also includes the current hours worked and the difference from the previous day's hours.
WITH hours_day AS (
    SELECT 
        WL.emp_id,
        WL.work_date,
        SUM(WL.hours_worked) AS hours_worked
    FROM "Work_Log" WL
    GROUP BY WL.emp_id, WL.work_date
)
SELECT 
    HD.emp_id,
    E.emp_name,
    HD.work_date,
    HD.hours_worked,
    LAG(HD.hours_worked) OVER (PARTITION BY HD.emp_id ORDER BY HD.work_date) AS prev_hours_worked,
    HD.hours_worked - LAG(HD.hours_worked) OVER (PARTITION BY HD.emp_id ORDER BY HD.work_date) AS hours_change
FROM "hours_day" HD
    LEFT JOIN "Employees" E ON HD.emp_id = E.emp_id
ORDER BY HD.emp_id, HD.work_date;

###Use RANK() to find top 3 hardest working employees by total hours
###Used dense_rankings to avoid gaps in rankings
-- This query calculates the total hours worked by each employee and ranks them using both RANK()
-- and DENSE_RANK() window functions. The results include the employee's ID, name, department,
-- total hours worked, and their rankings. The query filters the results to show only the top 3 employees
-- based on their dense rankings, ensuring that there are no gaps in the rankings.
-- The results are ordered by dense rankings, allowing for easy identification of the top performers and shows how dense rankings
-- can be used to avoid gaps in the rankings when multiple employees have the same total hours worked.
-- This query is useful for generating a leaderboard of employees based on their productivity, allowing for recognition
-- of the top performers and analysis of workload distribution across the team.
-- It can be used to motivate employees and encourage healthy competition within the organization.
-- It also demonstrates the use of window functions to calculate rankings and total hours worked in a single query.
WITH total_hours AS (
    SELECT 
        WL.emp_id,
        SUM(WL.hours_worked) AS total_hours,
        RANK() OVER (ORDER BY SUM(WL.hours_worked) DESC) AS rankings,
        DENSE_RANK() OVER (ORDER BY SUM(WL.hours_worked) DESC) AS dense_rankings
    FROM "Work_Log" WL
    GROUP BY WL.emp_id
)
SELECT 
    E.emp_id,
    E.emp_name,
    E.department,
    TH.total_hours,
    TH.rankings,
    TH.dense_rankings
FROM "total_hours" TH
    LEFT JOIN "Employees" E ON TH.emp_id = E.emp_id
WHERE TH.dense_rankings <= 3
ORDER BY TH.dense_rankings;

###Show each employee’s first and last working date
-- This query retrieves the first and last working date for each employee.
-- It uses the MIN() and MAX() aggregate functions to find the earliest and latest work dates
-- for each employee, respectively. The results are grouped by employee ID and ordered by employee ID.
-- This query is useful for understanding the work history of each employee, allowing for analysis of their
-- tenure and work patterns. It can be used to identify employees who have been with the company
-- for a long time or those who have recently joined. The results can also be used to
-- track employee attendance and work schedules, providing insights into their availability and productivity.
SELECT 
    WL.emp_id,
    E.emp_name,
    E.department,
    MIN(WL.work_date) AS first_work_date,
    MAX(WL.work_date) AS last_work_date
FROM "Work_Log" WL
    LEFT JOIN "Employees" E ON WL.emp_id = E.emp_id
GROUP BY WL.emp_id, E.emp_name, E.department
ORDER BY WL.emp_id; 

###Bucket employees into quartiles of productivity using NTILE(4)
-- This query calculates the quartiles of productivity for employees based on their total hours worked.
-- It uses the NTILE() window function to divide the employees into 4 quartiles based on their total hours worked.
-- The results include the employee's ID, name, department, total hours worked, and the quartile they belong to.
-- The query orders the results by quartile and then by employee ID.
-- This query is useful for analyzing employee productivity and identifying high-performing employees
-- who contribute significantly to the organization's success. It can be used to create targeted training programs
-- or recognition initiatives for employees in the top quartiles, while also identifying areas for improvement
-- for those in the lower quartiles. The results can help management make informed decisions about resource allocation,
-- performance evaluations, and employee development strategies.
WITH total_hours AS (
    SELECT 
        WL.emp_id,
        SUM(WL.hours_worked) AS total_hours
    FROM "Work_Log" WL
    GROUP BY WL.emp_id
)
SELECT 
    E.emp_id,
    E.emp_name,
    E.department,
    TH.total_hours,
    NTILE(4) OVER (ORDER BY TH.total_hours DESC) AS productivity_quartile
FROM "total_hours" TH
    LEFT JOIN "Employees" E ON TH.emp_id = E.emp_id
ORDER BY productivity_quartile, TH.total_hours DESC;

###Calculate KPI performance review using number of hours worked
-- This query calculates the performance review for each employee based on the number of hours worked.
-- It categorizes employees into three performance levels: "Exceeds Expectations", "Meets Expectations",
-- and "Needs Improvement" based on the total hours worked. The results include the employee's ID, name, department,
-- total hours worked, and their performance review. The query orders the results by employee ID.
-- This query is useful for evaluating employee performance and identifying areas for improvement.
-- It can be used to create performance improvement plans for employees who are not meeting expectations,
-- while also recognizing and rewarding high-performing employees. The results can help management make informed decisions
-- about promotions, raises, and other performance-related actions. It also demonstrates how to use conditional
-- expressions to categorize data based on specific criteria, providing a clear and concise way to evaluate employee
-- performance based on their productivity.
-- Needs Improvement < 155
-- Meets Expectations >155 and < 165 
-- Exceeds Expectations >165
SELECT 
    E.emp_id,
    E.emp_name,
    E.department,
    SUM(WL.hours_worked) AS total_hours,
    CASE
        WHEN SUM(WL.hours_worked) < 155 THEN 'Needs Improvement'
        WHEN SUM(WL.hours_worked) >= 155 AND SUM(WL.hours_worked) < 165 THEN 'Meets Expectations'
        ELSE 'Exceeds Expectations'
    END AS performance_review
FROM "Work_Log" WL
    LEFT JOIN "Employees" E ON WL.emp_id = E.emp_id
GROUP BY E.emp_id, E.emp_name, E.department
ORDER BY E.emp_id;

###Tag employees as "Bonus Eligible" if they ranked in top 25% of hours worked
-- This query identifies employees who are eligible for a bonus based on their ranking in the top 25% of total hours worked.
-- It uses the RANK() window function to rank employees based on their total hours worked and
-- filters the results to include only those employees whose rank is less than or equal to 25% of the total number of employees.
-- The results include the employee's ID, name, department, total hours worked, and a tag indicating whether they are "Bonus Eligible".
-- The query orders the results by employee ID.
-- This query is useful for recognizing and rewarding high-performing employees who contribute significantly to the organization's success.
-- It can be used to create targeted bonus programs or recognition initiatives for employees in the top quartile,
-- while also identifying areas for improvement for those in the lower quartiles.
-- The results can help management make informed decisions about resource allocation, performance evaluations, and employee development strategies.
WITH total_hours AS (
    SELECT 
        WL.emp_id,
        SUM(WL.hours_worked) AS total_hours,
        RANK() OVER (ORDER BY SUM(WL.hours_worked) DESC) AS rankings
    FROM "Work_Log" WL
    GROUP BY WL.emp_id
)
SELECT 
    E.emp_id,
    E.emp_name,
    E.department,
    TH.total_hours,
    CASE
        WHEN TH.rankings <= ROUND((SELECT COUNT(*) FROM "Employees") * 0.25) THEN 'Bonus Eligible'
        ELSE 'Not Eligible'
    END AS bonus_eligibility
FROM "total_hours" TH
    LEFT JOIN "Employees" E ON TH.emp_id = E.emp_id
ORDER BY E.emp_id;