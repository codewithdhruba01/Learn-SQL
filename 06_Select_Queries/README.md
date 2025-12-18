# 🔍 Chapter 6: SELECT Queries - Data Retrieval Mastery

## 🎯 What is SELECT?

**SELECT** is the most powerful and frequently used SQL command for **retrieving data** from database tables. It allows you to:

- Fetch specific columns or all columns
- Filter records with conditions
- Sort results
- Limit result sets
- Combine data from multiple tables

---

## 📋 Basic SELECT Syntax

```sql
SELECT column1, column2, ...
FROM table_name
WHERE condition
ORDER BY column_name [ASC|DESC]
LIMIT number_of_rows;
```

### SELECT All Columns

```sql
-- Select all columns (not recommended for production)
SELECT * FROM employees;

-- Select specific columns (recommended)
SELECT employee_id, first_name, last_name, salary
FROM employees;
```

### Column Aliases

```sql
-- Rename columns in output
SELECT
    employee_id AS id,
    first_name AS 'First Name',
    last_name AS 'Last Name',
    salary * 1.1 AS 'New Salary'
FROM employees;

-- Short aliases
SELECT
    e.employee_id,
    e.first_name fname,
    e.salary sal
FROM employees e;
```

---

## 🔍 WHERE Clause - Filtering Data

### Comparison Operators

```sql
-- Equal to
SELECT * FROM employees WHERE department = 'IT';

-- Not equal to
SELECT * FROM employees WHERE department != 'HR';
SELECT * FROM employees WHERE department <> 'HR';

-- Greater than/Less than
SELECT * FROM employees WHERE salary > 50000;
SELECT * FROM employees WHERE salary < 80000;
SELECT * FROM employees WHERE salary >= 50000;
SELECT * FROM employees WHERE salary <= 80000;

-- Range queries
SELECT * FROM employees WHERE salary BETWEEN 40000 AND 60000;
SELECT * FROM employees WHERE hire_date BETWEEN '2023-01-01' AND '2023-12-31';
```

### Pattern Matching with LIKE

```sql
-- Names starting with 'A'
SELECT * FROM employees WHERE first_name LIKE 'A%';

-- Names ending with 'a'
SELECT * FROM employees WHERE first_name LIKE '%a';

-- Names containing 'ar'
SELECT * FROM employees WHERE first_name LIKE '%ar%';

-- Names with exactly 4 characters
SELECT * FROM employees WHERE first_name LIKE '____';

-- Names starting with A, B, or C
SELECT * FROM employees WHERE first_name LIKE '[ABC]%';

-- Email domains
SELECT * FROM employees WHERE email LIKE '%@gmail.com';
```

### Logical Operators

```sql
-- AND: Both conditions must be true
SELECT * FROM employees
WHERE department = 'IT' AND salary > 60000;

-- OR: Either condition can be true
SELECT * FROM employees
WHERE department = 'IT' OR department = 'HR';

-- NOT: Negates the condition
SELECT * FROM employees
WHERE NOT department = 'HR';

-- Complex conditions
SELECT * FROM employees
WHERE (department = 'IT' AND salary > 70000)
   OR (department = 'HR' AND experience_years > 5);
```

### NULL Handling

```sql
-- Find records with NULL values
SELECT * FROM employees WHERE manager_id IS NULL;

-- Find records without NULL values
SELECT * FROM employees WHERE manager_id IS NOT NULL;

-- Safe NULL comparisons
SELECT * FROM employees
WHERE COALESCE(manager_id, 0) != 0;
```

### IN and NOT IN Operators

```sql
-- Match any value in a list
SELECT * FROM employees
WHERE department IN ('IT', 'HR', 'Finance');

-- Exclude values in a list
SELECT * FROM employees
WHERE department NOT IN ('Temp', 'Contract');

-- Subquery with IN
SELECT * FROM employees
WHERE employee_id IN (
    SELECT employee_id FROM bonuses
    WHERE amount > 5000
);
```

### EXISTS and NOT EXISTS

```sql
-- Find employees who have received bonuses
SELECT * FROM employees e
WHERE EXISTS (
    SELECT 1 FROM bonuses b
    WHERE b.employee_id = e.employee_id
);

-- Find employees who have never received bonuses
SELECT * FROM employees e
WHERE NOT EXISTS (
    SELECT 1 FROM bonuses b
    WHERE b.employee_id = e.employee_id
);
```

---

## 📊 ORDER BY - Sorting Results

### Basic Sorting

```sql
-- Sort by single column (ascending by default)
SELECT * FROM employees ORDER BY salary;

-- Sort descending
SELECT * FROM employees ORDER BY salary DESC;

-- Sort by multiple columns
SELECT * FROM employees
ORDER BY department ASC, salary DESC;

-- Sort by column position
SELECT first_name, last_name, salary FROM employees
ORDER BY 3 DESC; -- Sort by 3rd column (salary)
```

### Advanced Sorting

```sql
-- Sort by calculated fields
SELECT first_name, last_name, salary, salary * 1.1 as new_salary
FROM employees
ORDER BY new_salary DESC;

-- Sort with NULL values
SELECT * FROM employees
ORDER BY manager_id NULLS FIRST; -- PostgreSQL
-- or
SELECT * FROM employees
ORDER BY ISNULL(manager_id), manager_id; -- SQL Server/MySQL

-- Random ordering
SELECT * FROM employees ORDER BY RAND(); -- MySQL
SELECT * FROM employees ORDER BY RANDOM(); -- PostgreSQL
```

---

## 🎯 LIMIT and OFFSET - Result Pagination

### LIMIT Clause

```sql
-- Get first 10 records
SELECT * FROM employees LIMIT 10;

-- Get top 5 highest paid employees
SELECT * FROM employees
ORDER BY salary DESC
LIMIT 5;

-- LIMIT with OFFSET for pagination
SELECT * FROM employees
ORDER BY employee_id
LIMIT 10 OFFSET 20; -- Skip first 20, get next 10

-- Alternative syntax (MySQL)
SELECT * FROM employees LIMIT 20, 10; -- OFFSET 20, LIMIT 10
```

### Pagination Examples

```sql
-- Page 1 (records 1-10)
SELECT * FROM employees
ORDER BY employee_id
LIMIT 10 OFFSET 0;

-- Page 2 (records 11-20)
SELECT * FROM employees
ORDER BY employee_id
LIMIT 10 OFFSET 10;

-- Page 3 (records 21-30)
SELECT * FROM employees
ORDER BY employee_id
LIMIT 10 OFFSET 20;
```

---

## 🎨 Advanced SELECT Techniques

### DISTINCT - Remove Duplicates

```sql
-- Get unique departments
SELECT DISTINCT department FROM employees;

-- Get unique combinations
SELECT DISTINCT department, city FROM employees;

-- Count distinct values
SELECT COUNT(DISTINCT department) as dept_count FROM employees;

-- DISTINCT with ORDER BY
SELECT DISTINCT department FROM employees
ORDER BY department;
```

### CASE Statements

```sql
-- Simple CASE
SELECT first_name, last_name,
       CASE department
           WHEN 'IT' THEN 'Information Technology'
           WHEN 'HR' THEN 'Human Resources'
           ELSE 'Other'
       END as department_name
FROM employees;

-- Searched CASE
SELECT first_name, last_name, salary,
       CASE
           WHEN salary >= 80000 THEN 'Senior'
           WHEN salary >= 60000 THEN 'Mid-level'
           WHEN salary >= 40000 THEN 'Junior'
           ELSE 'Entry-level'
       END as level
FROM employees;

-- CASE in ORDER BY
SELECT * FROM employees
ORDER BY CASE department
    WHEN 'Management' THEN 1
    WHEN 'IT' THEN 2
    WHEN 'HR' THEN 3
    ELSE 4
END;
```

### UNION - Combine Results

```sql
-- Combine results from different queries
SELECT first_name, last_name, 'Employee' as type
FROM employees
WHERE department = 'IT'

UNION

SELECT first_name, last_name, 'Manager' as type
FROM managers;

-- UNION ALL (keeps duplicates)
SELECT department FROM employees
UNION ALL
SELECT department FROM contractors;

-- UNION vs UNION ALL
-- UNION: Removes duplicates, slower
-- UNION ALL: Keeps duplicates, faster
```

---

## 📈 Aggregate Functions in SELECT

### Basic Aggregates

```sql
-- Count records
SELECT COUNT(*) as total_employees FROM employees;
SELECT COUNT(manager_id) as with_managers FROM employees; -- Excludes NULL

-- Sum values
SELECT SUM(salary) as total_salary FROM employees;
SELECT SUM(salary) as it_salary FROM employees WHERE department = 'IT';

-- Average values
SELECT AVG(salary) as avg_salary FROM employees;

-- Minimum/Maximum
SELECT MIN(salary) as min_salary, MAX(salary) as max_salary FROM employees;
```

### GROUP BY with Aggregates

```sql
-- Group by department
SELECT department,
       COUNT(*) as employee_count,
       AVG(salary) as avg_salary,
       SUM(salary) as total_salary
FROM employees
GROUP BY department;

-- Multiple grouping
SELECT department, city,
       COUNT(*) as count,
       AVG(salary) as avg_salary
FROM employees
GROUP BY department, city
ORDER BY department, city;
```

### HAVING Clause

```sql
-- Filter groups (not individual records)
SELECT department, COUNT(*) as count, AVG(salary) as avg_salary
FROM employees
GROUP BY department
HAVING COUNT(*) > 5; -- Only departments with more than 5 employees

-- HAVING vs WHERE
SELECT department, AVG(salary) as avg_salary
FROM employees
WHERE salary > 30000  -- Filters individual records before grouping
GROUP BY department
HAVING AVG(salary) > 50000; -- Filters groups after aggregation
```

---

## 🔧 Practical Query Examples

### Employee Analytics Dashboard

```sql
-- Department-wise statistics
SELECT
    department,
    COUNT(*) as total_employees,
    ROUND(AVG(salary), 2) as avg_salary,
    MIN(salary) as min_salary,
    MAX(salary) as max_salary,
    SUM(salary) as total_salary
FROM employees
WHERE is_active = true
GROUP BY department
ORDER BY total_salary DESC;

-- Salary distribution
SELECT
    CASE
        WHEN salary < 40000 THEN 'Under 40K'
        WHEN salary < 60000 THEN '40K-60K'
        WHEN salary < 80000 THEN '60K-80K'
        ELSE 'Over 80K'
    END as salary_range,
    COUNT(*) as employee_count,
    ROUND(AVG(salary), 2) as avg_in_range
FROM employees
GROUP BY
    CASE
        WHEN salary < 40000 THEN 'Under 40K'
        WHEN salary < 60000 THEN '40K-60K'
        WHEN salary < 80000 THEN '60K-80K'
        ELSE 'Over 80K'
    END
ORDER BY avg_in_range;
```

### Recent Activity Queries

```sql
-- Recent hires (last 30 days)
SELECT * FROM employees
WHERE hire_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
ORDER BY hire_date DESC;

-- Employees with upcoming birthdays (next 30 days)
SELECT first_name, last_name,
       DATE_FORMAT(birth_date, '%M %d') as birthday,
       TIMESTAMPDIFF(YEAR, birth_date, CURDATE()) as age
FROM employees
WHERE DATE_FORMAT(birth_date, '%m-%d') BETWEEN
      DATE_FORMAT(CURDATE(), '%m-%d') AND
      DATE_FORMAT(DATE_ADD(CURDATE(), INTERVAL 30 DAY), '%m-%d')
ORDER BY MONTH(birth_date), DAY(birth_date);
```

### Search Functionality

```sql
-- Employee search (case-insensitive)
SELECT * FROM employees
WHERE LOWER(CONCAT(first_name, ' ', last_name)) LIKE LOWER('%john%');

-- Multi-field search
SELECT * FROM employees
WHERE first_name LIKE '%john%'
   OR last_name LIKE '%john%'
   OR email LIKE '%john%'
   OR department LIKE '%john%';

-- Fuzzy search with SOUNDEX
SELECT * FROM employees
WHERE SOUNDEX(first_name) = SOUNDEX('Jon'); -- Finds 'John', 'Jon', etc.
```

---

## 🚀 Query Optimization Techniques

### 1. Use Specific Columns (Avoid SELECT *)

```sql
-- Bad
SELECT * FROM employees WHERE department = 'IT';

-- Good (if you only need these columns)
SELECT employee_id, first_name, last_name FROM employees WHERE department = 'IT';
```

### 2. Use WHERE Before ORDER BY

```sql
-- Filter first, then sort
SELECT * FROM employees
WHERE department = 'IT'
ORDER BY salary DESC
LIMIT 10;
```

### 3. Use Appropriate Indexes

```sql
-- These queries benefit from indexes
CREATE INDEX idx_dept ON employees (department);
CREATE INDEX idx_salary ON employees (salary);
CREATE INDEX idx_dept_salary ON employees (department, salary);
```

### 4. Avoid Functions on Indexed Columns

```sql
-- Bad: Function on indexed column
SELECT * FROM employees WHERE YEAR(hire_date) = 2023;

-- Good: Use range comparison
SELECT * FROM employees WHERE hire_date BETWEEN '2023-01-01' AND '2023-12-31';
```

### 5. Use UNION ALL Instead of UNION When Possible

```sql
-- UNION ALL is faster when duplicates are not a concern
SELECT name FROM employees UNION ALL SELECT name FROM contractors;
```

---

## 📚 Practice Exercises

### Exercise 1: Employee Queries
Write queries to:
1. Find all employees in IT department earning more than 50K
2. List employees hired in the last year, sorted by salary
3. Find employees whose names start with 'A' or 'J'
4. Get department-wise employee count and average salary
5. Find top 10 highest paid employees

### Exercise 2: Product Catalog
Given a products table, write queries for:
1. Products in price range 100-500, sorted by price
2. Products with low stock (less than 10 units)
3. Products from specific categories using IN clause
4. Search products by name (case-insensitive)
5. Products with highest sales (using sales table)

### Exercise 3: Advanced Analytics
Create queries for:
1. Monthly sales summary with running totals
2. Customer segmentation based on purchase history
3. Employee performance ranking by department
4. Inventory turnover analysis
5. Trend analysis for sales over time

---

## 🎯 Chapter Summary

- SELECT is the foundation of data retrieval
- WHERE clause filters data with various operators
- ORDER BY sorts results, LIMIT controls output size
- DISTINCT removes duplicates, CASE adds conditional logic
- Aggregate functions work with GROUP BY and HAVING
- Query optimization improves performance significantly
- Always consider indexes and execution plans
- Practice with real datasets to master query writing

---

## 🚀 Next Steps
- Learn **JOIN operations** to combine data from multiple tables
- Master **aggregate functions** and **GROUP BY** clauses
- Understand **subqueries** for complex data retrieval
- Practice with **real-world scenarios** and **large datasets**
