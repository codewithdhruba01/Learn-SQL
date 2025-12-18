-- 🎯 SQL Interview Practice Exercises
-- Based on the 50 most important SQL interview questions

-- ===========================================
-- SETUP: Create sample database and tables
-- ===========================================

-- Create database
CREATE DATABASE IF NOT EXISTS interview_practice;
USE interview_practice;

-- Create departments table
CREATE TABLE departments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    department_name VARCHAR(100) NOT NULL,
    location VARCHAR(100),
    budget DECIMAL(10,2)
);

-- Create employees table
CREATE TABLE employees (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE,
    salary DECIMAL(10,2) NOT NULL,
    hire_date DATE DEFAULT CURRENT_DATE,
    department_id INT,
    manager_id INT,
    FOREIGN KEY (department_id) REFERENCES departments(id),
    FOREIGN KEY (manager_id) REFERENCES employees(id)
);

-- Insert sample data
INSERT INTO departments (department_name, location, budget) VALUES
('IT', 'New York', 500000),
('HR', 'New York', 200000),
('Finance', 'Chicago', 300000),
('Marketing', 'Los Angeles', 250000),
('Sales', 'Boston', 400000);

INSERT INTO employees (name, email, salary, department_id, manager_id) VALUES
('John Smith', 'john.smith@company.com', 75000, 1, NULL),
('Jane Doe', 'jane.doe@company.com', 65000, 1, 1),
('Bob Johnson', 'bob.johnson@company.com', 55000, 1, 1),
('Alice Brown', 'alice.brown@company.com', 80000, 2, NULL),
('Charlie Wilson', 'charlie.wilson@company.com', 45000, 2, 4),
('Diana Davis', 'diana.davis@company.com', 95000, 3, NULL),
('Eve Miller', 'eve.miller@company.com', 70000, 4, NULL),
('Frank Garcia', 'frank.garcia@company.com', 60000, 5, NULL),
('Grace Lee', 'grace.lee@company.com', 52000, 5, 8),
('Henry Taylor', 'henry.taylor@company.com', 48000, 5, 8);

-- ===========================================
-- PRACTICE EXERCISES
-- ===========================================

-- Q1-Q8: Basic Concepts & DDL Practice
-- Exercise 1: Create a projects table
CREATE TABLE projects (
    id INT PRIMARY KEY AUTO_INCREMENT,
    project_name VARCHAR(200) NOT NULL,
    start_date DATE,
    end_date DATE,
    budget DECIMAL(12,2),
    department_id INT,
    FOREIGN KEY (department_id) REFERENCES departments(id)
);

-- Exercise 2: Add a status column to projects
ALTER TABLE projects ADD COLUMN status ENUM('Active', 'Completed', 'On Hold') DEFAULT 'Active';

-- Exercise 3: Create an index on employee salaries
CREATE INDEX idx_employee_salary ON employees(salary);

-- Q9-Q15: DDL Commands Practice
-- Exercise 4: Add phone column to employees
ALTER TABLE employees ADD COLUMN phone VARCHAR(20);

-- Exercise 5: Modify email column to be NOT NULL
ALTER TABLE employees MODIFY COLUMN email VARCHAR(255) NOT NULL;

-- Exercise 6: Rename projects table to company_projects
ALTER TABLE projects RENAME TO company_projects;

-- Q16-Q22: DML Commands Practice
-- Exercise 7: Insert new employee
INSERT INTO employees (name, email, salary, department_id)
VALUES ('Ivy Chen', 'ivy.chen@company.com', 58000, 1);

-- Exercise 8: Update employee salary
UPDATE employees SET salary = salary * 1.1 WHERE department_id = 1;

-- Exercise 9: Delete employees with low salary
DELETE FROM employees WHERE salary < 50000;

-- Exercise 10: Select with complex WHERE
SELECT * FROM employees
WHERE salary BETWEEN 50000 AND 80000
AND department_id IN (1, 2, 4)
ORDER BY salary DESC;

-- Q23-Q30: JOINs Practice
-- Exercise 11: INNER JOIN employees with departments
SELECT e.name, e.salary, d.department_name, d.location
FROM employees e
INNER JOIN departments d ON e.department_id = d.id;

-- Exercise 12: LEFT JOIN to find employees without departments
SELECT e.name, d.department_name
FROM employees e
LEFT JOIN departments d ON e.department_id = d.id
WHERE d.id IS NULL;

-- Exercise 13: Self-join for manager-employee relationships
SELECT e.name as employee, m.name as manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.id;

-- Exercise 14: Find employees with salary above department average
SELECT e.name, e.salary, d.department_name
FROM employees e
JOIN departments d ON e.department_id = d.id
WHERE e.salary > (
    SELECT AVG(salary) FROM employees
    WHERE department_id = e.department_id
);

-- Q31-Q35: Subqueries & CTEs Practice
-- Exercise 15: Subquery to find highest paid employee per department
SELECT * FROM employees e1
WHERE salary = (
    SELECT MAX(salary) FROM employees e2
    WHERE e2.department_id = e1.department_id
);

-- Exercise 16: CTE for department statistics
WITH dept_stats AS (
    SELECT department_id,
           COUNT(*) as emp_count,
           AVG(salary) as avg_salary,
           MAX(salary) as max_salary
    FROM employees
    GROUP BY department_id
)
SELECT d.department_name, ds.emp_count, ds.avg_salary, ds.max_salary
FROM dept_stats ds
JOIN departments d ON ds.department_id = d.id;

-- Q36-Q42: Aggregate Functions Practice
-- Exercise 17: Department-wise statistics
SELECT d.department_name,
       COUNT(e.id) as employee_count,
       AVG(e.salary) as avg_salary,
       MIN(e.salary) as min_salary,
       MAX(e.salary) as max_salary,
       SUM(e.salary) as total_salary
FROM departments d
LEFT JOIN employees e ON d.id = e.department_id
GROUP BY d.id, d.department_name;

-- Exercise 18: Find departments with more than 2 employees
SELECT d.department_name, COUNT(e.id) as emp_count
FROM departments d
JOIN employees e ON d.id = e.department_id
GROUP BY d.id, d.department_name
HAVING COUNT(e.id) > 2;

-- Exercise 19: Running total of salaries by hire date
SELECT name, salary, hire_date,
       SUM(salary) OVER (ORDER BY hire_date) as running_total
FROM employees
ORDER BY hire_date;

-- Exercise 20: Categorize employees by salary range
SELECT name, salary,
       CASE
           WHEN salary >= 80000 THEN 'Executive'
           WHEN salary >= 60000 THEN 'Senior'
           WHEN salary >= 40000 THEN 'Mid-level'
           ELSE 'Entry-level'
       END as salary_category
FROM employees;

-- Q43-Q47: Constraints & Keys Practice
-- Exercise 21: Add CHECK constraint for salary
ALTER TABLE employees ADD CONSTRAINT chk_salary_positive CHECK (salary > 0);

-- Exercise 22: Add UNIQUE constraint for phone
ALTER TABLE employees ADD CONSTRAINT uk_phone UNIQUE (phone);

-- Exercise 23: Create index for performance
CREATE INDEX idx_dept_salary ON employees(department_id, salary);

-- Q48-Q50: Advanced Topics Practice
-- Exercise 24: Create a view for employee summary
CREATE VIEW employee_summary AS
SELECT e.name, e.salary, d.department_name,
       CASE
           WHEN e.salary > 70000 THEN 'High'
           WHEN e.salary > 50000 THEN 'Medium'
           ELSE 'Low'
       END as salary_range
FROM employees e
JOIN departments d ON e.department_id = d.id;

-- Exercise 25: Query the view
SELECT * FROM employee_summary WHERE salary_range = 'High';

-- ===========================================
-- PERFORMANCE OPTIMIZATION EXAMPLES
-- ===========================================

-- Example 26: Bad query (uses SELECT *)
SELECT * FROM employees WHERE department_id = 1;

-- Example 27: Good query (specific columns)
SELECT name, email, salary FROM employees WHERE department_id = 1;

-- Example 28: Using EXISTS instead of IN
-- Bad: SELECT * FROM employees WHERE department_id IN (SELECT id FROM departments WHERE location = 'New York');
-- Good: SELECT * FROM employees e WHERE EXISTS (SELECT 1 FROM departments d WHERE d.id = e.department_id AND d.location = 'New York');

-- ===========================================
-- CLEANUP (Optional - run to reset database)
-- ===========================================
/*
DROP VIEW IF EXISTS employee_summary;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS departments;
DROP TABLE IF EXISTS company_projects;
DROP DATABASE IF EXISTS interview_practice;
*/

-- ===========================================
-- SOLUTION QUERIES (Uncomment to see results)
-- ===========================================

-- View all tables
-- SHOW TABLES;

-- View table structures
-- DESCRIBE employees;
-- DESCRIBE departments;

-- Sample data verification
-- SELECT * FROM employees LIMIT 5;
-- SELECT * FROM departments;

-- Practice query results
-- SELECT COUNT(*) as total_employees FROM employees;
-- SELECT AVG(salary) as avg_salary FROM employees;
-- SELECT department_name, COUNT(*) as emp_count FROM employees e JOIN departments d ON e.department_id = d.id GROUP BY d.id;
