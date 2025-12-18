# 50 Most Important SQL Interview Questions & Answers

## Section 1: Basic SQL Concepts

### 1. What is SQL? Explain its components.
**Answer:** SQL (Structured Query Language) is a standard language for managing relational databases. Its main components are:
- **DDL (Data Definition Language)**: CREATE, ALTER, DROP
- **DML (Data Manipulation Language)**: SELECT, INSERT, UPDATE, DELETE
- **DCL (Data Control Language)**: GRANT, REVOKE
- **TCL (Transaction Control Language)**: COMMIT, ROLLBACK, SAVEPOINT

### 2. What is the difference between SQL and MySQL?
**Answer:** SQL is a query language, while MySQL is a database management system that uses SQL. SQL is the language, MySQL is one implementation of it.

### 3. What are the different types of SQL commands?
**Answer:**
- **DDL**: CREATE, ALTER, DROP, TRUNCATE
- **DML**: SELECT, INSERT, UPDATE, DELETE
- **DCL**: GRANT, REVOKE
- **TCL**: COMMIT, ROLLBACK, SAVEPOINT

### 4. What is a Database?
**Answer:** A database is an organized collection of structured data that is stored electronically. It allows for efficient retrieval, insertion, and management of data.

### 5. What is a Relational Database?
**Answer:** A relational database organizes data into tables with relationships between them. It follows the relational model proposed by E.F. Codd.

### 6. What is a Primary Key?
**Answer:** A Primary Key is a column or set of columns that uniquely identifies each row in a table. It cannot contain NULL values.

### 7. What is Normalization?
**Answer:** Normalization is the process of organizing data in a database to reduce redundancy and improve data integrity. It involves dividing large tables into smaller, related tables.

### 8. What are the different normal forms?
**Answer:**
- **1NF**: Eliminates repeating groups
- **2NF**: Removes partial dependencies
- **3NF**: Removes transitive dependencies
- **BCNF**: Boyce-Codd Normal Form

---

## Section 2: DDL Commands

### 9. How do you create a table in SQL?
**Answer:**
```sql
CREATE TABLE employees (
    id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE,
    salary DECIMAL(10,2),
    hire_date DATE DEFAULT CURRENT_DATE
);
```

### 10. How do you add a new column to an existing table?
**Answer:**
```sql
ALTER TABLE employees ADD COLUMN department VARCHAR(50);
```

### 11. How do you modify a column in a table?
**Answer:**
```sql
ALTER TABLE employees MODIFY COLUMN salary DECIMAL(12,2);
```

### 12. How do you delete a column from a table?
**Answer:**
```sql
ALTER TABLE employees DROP COLUMN department;
```

### 13. How do you rename a table?
**Answer:**
```sql
ALTER TABLE employees RENAME TO staff;
-- or
RENAME TABLE employees TO staff;
```

### 14. How do you drop a table?
**Answer:**
```sql
DROP TABLE employees;
-- To drop if exists and avoid errors:
DROP TABLE IF EXISTS employees;
```

### 15. What is the difference between TRUNCATE and DELETE?
**Answer:**
- **DELETE**: Removes specific rows, can be rolled back, triggers fire
- **TRUNCATE**: Removes all rows, cannot be rolled back, faster, doesn't fire triggers

---

## Section 3: DML Commands

### 16. How do you insert data into a table?
**Answer:**
```sql
-- Single row
INSERT INTO employees (name, email, salary) VALUES ('John Doe', 'john@example.com', 50000);

-- Multiple rows
INSERT INTO employees (name, email, salary) VALUES
('Jane Smith', 'jane@example.com', 55000),
('Bob Johnson', 'bob@example.com', 45000);
```

### 17. How do you update data in a table?
**Answer:**
```sql
UPDATE employees SET salary = 60000 WHERE id = 1;
UPDATE employees SET salary = salary * 1.1 WHERE department = 'IT';
```

### 18. How do you delete data from a table?
**Answer:**
```sql
DELETE FROM employees WHERE id = 1;
DELETE FROM employees WHERE hire_date < '2020-01-01';
```

### 19. What is the basic structure of a SELECT statement?
**Answer:**
```sql
SELECT column1, column2, ...
FROM table_name
WHERE condition
GROUP BY column
HAVING condition
ORDER BY column
LIMIT number;
```

### 20. How do you select all columns from a table?
**Answer:**
```sql
SELECT * FROM employees;
-- Note: Avoid using * in production code
```

### 21. How do you use WHERE clause with multiple conditions?
**Answer:**
```sql
SELECT * FROM employees
WHERE department = 'IT' AND salary > 50000;

SELECT * FROM employees
WHERE (department = 'IT' OR department = 'HR') AND age BETWEEN 25 AND 35;
```

### 22. How do you sort results in SQL?
**Answer:**
```sql
-- Ascending order (default)
SELECT * FROM employees ORDER BY salary;

-- Descending order
SELECT * FROM employees ORDER BY salary DESC;

-- Multiple columns
SELECT * FROM employees ORDER BY department ASC, salary DESC;
```

---

## 🔗 Section 4: Joins & Relationships

### 23. What are the different types of JOINs in SQL?
**Answer:**
- **INNER JOIN**: Returns matching rows from both tables
- **LEFT JOIN**: Returns all rows from left table and matching rows from right table
- **RIGHT JOIN**: Returns all rows from right table and matching rows from left table
- **FULL OUTER JOIN**: Returns all rows from both tables
- **CROSS JOIN**: Returns Cartesian product of both tables

### 24. Explain INNER JOIN with an example.
**Answer:**
```sql
SELECT e.name, d.department_name
FROM employees e
INNER JOIN departments d ON e.department_id = d.id;
```
This returns only employees who have a matching department.

### 25. Explain LEFT JOIN with an example.
**Answer:**
```sql
SELECT e.name, d.department_name
FROM employees e
LEFT JOIN departments d ON e.department_id = d.id;
```
This returns all employees, even those without a department (department_name will be NULL).

### 26. What is a self-join? Give an example.
**Answer:** A self-join joins a table with itself.
```sql
SELECT e1.name as employee, e2.name as manager
FROM employees e1
LEFT JOIN employees e2 ON e1.manager_id = e2.id;
```

### 27. How do you handle NULL values in JOINs?
**Answer:**
```sql
-- Using COALESCE to replace NULL
SELECT e.name, COALESCE(d.department_name, 'No Department') as department
FROM employees e
LEFT JOIN departments d ON e.department_id = d.id;
```

### 28. What is the difference between WHERE and HAVING?
**Answer:**
- **WHERE** filters rows before grouping
- **HAVING** filters groups after GROUP BY
- WHERE cannot use aggregate functions, HAVING can

### 29. Explain the concept of foreign keys.
**Answer:** A foreign key is a column that refers to the primary key of another table. It establishes a relationship between tables and ensures referential integrity.

### 30. How do you find records that exist in one table but not another?
**Answer:**
```sql
-- Using LEFT JOIN
SELECT e.* FROM employees e
LEFT JOIN departments d ON e.department_id = d.id
WHERE d.id IS NULL;

-- Using NOT IN
SELECT * FROM employees
WHERE department_id NOT IN (SELECT id FROM departments);

-- Using NOT EXISTS
SELECT * FROM employees e
WHERE NOT EXISTS (SELECT 1 FROM departments d WHERE d.id = e.department_id);
```

---

## Section 5: Subqueries & CTEs

### 31. What is a subquery? Give an example.
**Answer:** A subquery is a query nested inside another query.
```sql
-- Find employees with salary above average
SELECT * FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);
```

### 32. What are the different types of subqueries?
**Answer:**
- **Scalar subquery**: Returns a single value
- **Multi-row subquery**: Returns multiple rows
- **Correlated subquery**: References columns from outer query
- **Nested subquery**: Subquery inside another subquery

### 33. What is a Common Table Expression (CTE)?
**Answer:** A CTE is a temporary named result set that exists within the scope of a SQL statement.
```sql
WITH high_paid_employees AS (
    SELECT * FROM employees WHERE salary > 50000
)
SELECT * FROM high_paid_employees WHERE department = 'IT';
```

### 34. What is a correlated subquery? Give an example.
**Answer:** A correlated subquery references columns from the outer query.
```sql
-- Find employees earning more than their department average
SELECT e.name, e.salary, e.department
FROM employees e
WHERE e.salary > (
    SELECT AVG(salary)
    FROM employees
    WHERE department = e.department
);
```

### 35. When should you use a CTE vs a subquery?
**Answer:**
- Use **CTE** when you need to reference the result multiple times or for recursive queries
- Use **subquery** for simple, one-time nested queries
- CTEs are more readable for complex queries

---

## Section 6: Aggregate Functions & Grouping

### 36. What are aggregate functions in SQL?
**Answer:** Aggregate functions perform calculations on multiple rows and return a single value:
- COUNT(): Counts rows
- SUM(): Sums numeric values
- AVG(): Calculates average
- MIN(): Finds minimum value
- MAX(): Finds maximum value

### 37. Explain GROUP BY with an example.
**Answer:**
```sql
SELECT department, COUNT(*) as employee_count, AVG(salary) as avg_salary
FROM employees
GROUP BY department;
```
Groups rows by department and calculates aggregates for each group.

### 38. Explain HAVING clause with an example.
**Answer:**
```sql
SELECT department, AVG(salary) as avg_salary, COUNT(*) as count
FROM employees
GROUP BY department
HAVING AVG(salary) > 50000 AND COUNT(*) > 5;
```
Filters groups based on aggregate conditions.

### 39. How do you find duplicate records in a table?
**Answer:**
```sql
-- Find duplicates
SELECT name, email, COUNT(*)
FROM employees
GROUP BY name, email
HAVING COUNT(*) > 1;

-- Delete duplicates (keep one record)
DELETE e1 FROM employees e1
INNER JOIN employees e2
WHERE e1.id > e2.id AND e1.email = e2.email;
```

### 40. How do you calculate running totals?
**Answer:**
```sql
SELECT name, salary,
       SUM(salary) OVER (ORDER BY hire_date) as running_total
FROM employees
ORDER BY hire_date;
```

### 41. What is the difference between COUNT(*) and COUNT(column)?
**Answer:**
- **COUNT(*)**: Counts all rows including NULL values
- **COUNT(column)**: Counts non-NULL values in the specified column

### 42. How do you use CASE statements in SQL?
**Answer:**
```sql
SELECT name, salary,
       CASE
           WHEN salary >= 80000 THEN 'High'
           WHEN salary >= 50000 THEN 'Medium'
           ELSE 'Low'
       END as salary_category
FROM employees;
```

---

## Section 7: Constraints & Keys

### 43. What are the different types of constraints in SQL?
**Answer:**
- **PRIMARY KEY**: Uniquely identifies each record
- **FOREIGN KEY**: Maintains referential integrity
- **UNIQUE**: Ensures unique values
- **NOT NULL**: Prevents NULL values
- **CHECK**: Validates data against a condition
- **DEFAULT**: Provides default values

### 44. How do you add a constraint to an existing table?
**Answer:**
```sql
-- Add NOT NULL (requires table recreation)
ALTER TABLE employees MODIFY COLUMN name VARCHAR(100) NOT NULL;

-- Add UNIQUE constraint
ALTER TABLE employees ADD CONSTRAINT uk_email UNIQUE (email);

-- Add CHECK constraint
ALTER TABLE employees ADD CONSTRAINT ck_salary CHECK (salary > 0);

-- Add FOREIGN KEY
ALTER TABLE employees ADD CONSTRAINT fk_dept
FOREIGN KEY (department_id) REFERENCES departments(id);
```

### 45. What is referential integrity?
**Answer:** Referential integrity ensures that relationships between tables remain consistent. It prevents:
- Adding records with invalid foreign key values
- Deleting records that are referenced by other records (unless CASCADE is used)

### 46. How do you handle foreign key constraints during DELETE operations?
**Answer:**
```sql
-- CASCADE: Delete related records
FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE CASCADE

-- SET NULL: Set foreign key to NULL
FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE SET NULL

-- RESTRICT: Prevent deletion (default)
FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE RESTRICT
```

### 47. What is an index? When should you use it?
**Answer:** An index is a database object that improves query performance by providing fast access to rows.
**When to use:**
- On columns frequently used in WHERE clauses
- On columns used for JOIN operations
- On columns used for sorting (ORDER BY)
**When NOT to use:**
- On small tables
- On columns with low selectivity
- On columns that are frequently updated

---

## Section 8: Advanced Topics

### 48. What are Views? Why use them?
**Answer:** A view is a virtual table based on a SELECT query. Benefits:
- Simplify complex queries
- Provide security by restricting access
- Present aggregated data
- Maintain backward compatibility

```sql
CREATE VIEW employee_summary AS
SELECT department, COUNT(*) as count, AVG(salary) as avg_salary
FROM employees
GROUP BY department;
```

### 49. What are Triggers? Give an example.
**Answer:** Triggers are special stored procedures that automatically execute when certain events occur.
```sql
CREATE TRIGGER audit_salary_changes
AFTER UPDATE ON employees
FOR EACH ROW
BEGIN
    IF OLD.salary != NEW.salary THEN
        INSERT INTO salary_audit (employee_id, old_salary, new_salary, changed_at)
        VALUES (NEW.id, OLD.salary, NEW.salary, NOW());
    END IF;
END;
```

### 50. How do you optimize SQL queries?
**Answer:**
1. **Use appropriate indexes**: On WHERE, JOIN, and ORDER BY columns
2. **Avoid SELECT *** : Specify only needed columns
3. **Use EXISTS instead of IN** for subqueries
4. **Use UNION ALL instead of UNION** when possible
5. **Limit result sets** with WHERE clauses early
6. **Use EXPLAIN PLAN** to analyze query execution
7. **Normalize tables** appropriately
8. **Use stored procedures** for complex business logic
9. **Avoid correlated subqueries** when possible
10. **Use appropriate data types** to save space

---

## Quick Reference Cheat Sheet

### Most Common SQL Interview Questions:
1. Difference between TRUNCATE and DELETE
2. Types of JOINs and their differences
3. Primary Key vs Foreign Key vs Unique Key
4. Normalization vs Denormalization
5. Clustered vs Non-clustered indexes
6. ACID properties
7. Difference between WHERE and HAVING
8. How to find duplicate records
9. Self-join use cases
10. Subquery vs CTE

### SQL Best Practices:
- Always use parameterized queries to prevent SQL injection
- Use meaningful table and column names
- Comment complex queries
- Test queries on sample data first
- Use transactions for data consistency
- Regularly backup databases
- Monitor query performance

---

*Happy Learning! Remember, practice is key to mastering SQL. Try implementing these concepts in your own database projects.*
