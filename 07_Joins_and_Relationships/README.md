# 🔗 Chapter 7: JOINs and Relationships - Multi-Table Queries

## 🎯 Why JOINs Matter?

**JOINs** allow you to combine data from multiple tables based on **related columns**. They're essential because:

- **Normalize data** is split across tables for efficiency
- **Relationships** exist between entities (customers ↔ orders)
- **Complex queries** require data from multiple sources
- **Data integrity** is maintained through relationships

---

## 🏗️ Understanding Relationships

### Types of Relationships

#### 1. One-to-One (1:1)
- One record in Table A relates to exactly one record in Table B
- Example: Employee ↔ Employee_Details

```sql
-- Employee personal details
CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    department_id INT
);

-- Additional sensitive information
CREATE TABLE employee_details (
    employee_id INT PRIMARY KEY, -- Same as employees.employee_id
    ssn VARCHAR(20),
    salary DECIMAL(10,2),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);
```

#### 2. One-to-Many (1:N)
- One record in Table A relates to multiple records in Table B
- Most common relationship type
- Example: Department ↔ Employees

```sql
CREATE TABLE departments (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(100),
    manager_id INT
);

CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    department_id INT,
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);
```

#### 3. Many-to-Many (N:N)
- Multiple records in Table A relate to multiple records in Table B
- Requires a **junction/intermediate table**
- Example: Students ↔ Courses

```sql
CREATE TABLE students (
    student_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50)
);

CREATE TABLE courses (
    course_id INT PRIMARY KEY,
    course_name VARCHAR(100),
    credits INT
);

-- Junction table
CREATE TABLE enrollments (
    student_id INT,
    course_id INT,
    enrollment_date DATE,
    grade VARCHAR(2),
    PRIMARY KEY (student_id, course_id),
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
);
```

---

## 🔗 JOIN Types

### INNER JOIN
Returns only matching records from both tables.

```sql
-- Basic syntax
SELECT columns
FROM table1
INNER JOIN table2 ON table1.column = table2.column;

-- Example: Employees with their departments
SELECT e.first_name, e.last_name, d.department_name
FROM employees e
INNER JOIN departments d ON e.department_id = d.department_id;

-- Multiple INNER JOINs
SELECT e.first_name, e.last_name, d.department_name, m.first_name as manager_name
FROM employees e
INNER JOIN departments d ON e.department_id = d.department_id
INNER JOIN employees m ON d.manager_id = m.employee_id;
```

### LEFT JOIN (LEFT OUTER JOIN)
Returns all records from left table + matching records from right table.

```sql
-- Syntax
SELECT columns
FROM table1
LEFT JOIN table2 ON table1.column = table2.column;

-- Example: All employees, with department info (if available)
SELECT e.first_name, e.last_name, d.department_name
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id;

-- Find employees without departments
SELECT e.first_name, e.last_name
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id
WHERE d.department_id IS NULL;
```

### RIGHT JOIN (RIGHT OUTER JOIN)
Returns all records from right table + matching records from left table.

```sql
-- Example: All departments, with employee info
SELECT d.department_name, e.first_name, e.last_name
FROM employees e
RIGHT JOIN departments d ON e.department_id = d.department_id;

-- Find departments with no employees
SELECT d.department_name
FROM employees e
RIGHT JOIN departments d ON e.department_id = d.department_id
WHERE e.employee_id IS NULL;
```

### FULL OUTER JOIN
Returns all records from both tables (MySQL doesn't support this directly).

```sql
-- MySQL workaround using UNION
SELECT e.first_name, e.last_name, d.department_name
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id

UNION

SELECT e.first_name, e.last_name, d.department_name
FROM employees e
RIGHT JOIN departments d ON e.department_id = d.department_id;

-- PostgreSQL/SQL Server direct syntax
SELECT e.first_name, e.last_name, d.department_name
FROM employees e
FULL OUTER JOIN departments d ON e.department_id = d.department_id;
```

### CROSS JOIN
Returns Cartesian product of both tables (every row from table1 with every row from table2).

```sql
-- Explicit CROSS JOIN
SELECT e.first_name, d.department_name
FROM employees e
CROSS JOIN departments d;

-- Implicit CROSS JOIN (comma syntax)
SELECT e.first_name, d.department_name
FROM employees e, departments d;

-- CROSS JOIN with WHERE (effectively INNER JOIN)
SELECT e.first_name, d.department_name
FROM employees e
CROSS JOIN departments d
WHERE e.department_id = d.department_id;
```

### SELF JOIN
Join a table with itself.

```sql
-- Example: Employees and their managers
SELECT e.first_name as employee, m.first_name as manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.employee_id;

-- Example: Find employees in same department
SELECT e1.first_name, e2.first_name, e1.department_id
FROM employees e1
INNER JOIN employees e2 ON e1.department_id = e2.department_id
WHERE e1.employee_id < e2.employee_id; -- Avoid duplicates
```

---

## 🏗️ Advanced JOIN Techniques

### Multiple Table JOINs

```sql
-- Three table JOIN: Customers, Orders, Products
SELECT c.customer_name, o.order_date, p.product_name, oi.quantity
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
INNER JOIN order_items oi ON o.order_id = oi.order_id
INNER JOIN products p ON oi.product_id = p.product_id;

-- Four table JOIN with aliases
SELECT
    emp.first_name,
    emp.last_name,
    dept.department_name,
    proj.project_name,
    tsk.task_name
FROM employees emp
INNER JOIN departments dept ON emp.department_id = dept.department_id
INNER JOIN project_assignments pa ON emp.employee_id = pa.employee_id
INNER JOIN projects proj ON pa.project_id = proj.project_id
INNER JOIN tasks tsk ON pa.task_id = tsk.task_id;
```

### JOIN with Aggregates

```sql
-- Department-wise employee statistics
SELECT d.department_name,
       COUNT(e.employee_id) as employee_count,
       AVG(e.salary) as avg_salary,
       SUM(e.salary) as total_salary
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id
GROUP BY d.department_name;

-- Products with total sales
SELECT p.product_name,
       SUM(oi.quantity) as total_quantity,
       SUM(oi.quantity * oi.unit_price) as total_revenue
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_name
ORDER BY total_revenue DESC;
```

### Conditional JOINs

```sql
-- Different JOIN conditions based on data
SELECT e.first_name, e.last_name,
       CASE
           WHEN e.salary > 80000 THEN 'Senior'
           ELSE 'Regular'
       END as employee_type,
       d.department_name
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id
  AND e.salary > 80000; -- Conditional JOIN
```

### Anti-JOINs (NOT EXISTS/EXCEPT)

```sql
-- Employees not assigned to any project
SELECT e.first_name, e.last_name
FROM employees e
WHERE NOT EXISTS (
    SELECT 1 FROM project_assignments pa
    WHERE pa.employee_id = e.employee_id
);

-- Alternative using LEFT JOIN
SELECT e.first_name, e.last_name
FROM employees e
LEFT JOIN project_assignments pa ON e.employee_id = pa.employee_id
WHERE pa.project_id IS NULL;
```

---

## 📊 Real-World JOIN Examples

### E-commerce Database

```sql
-- Sample schema
CREATE TABLE customers (customer_id INT, name VARCHAR(100), email VARCHAR(100));
CREATE TABLE orders (order_id INT, customer_id INT, order_date DATE, total DECIMAL(10,2));
CREATE TABLE order_items (order_id INT, product_id INT, quantity INT, price DECIMAL(10,2));
CREATE TABLE products (product_id INT, name VARCHAR(100), category VARCHAR(50));

-- Customer order history
SELECT c.name as customer_name,
       COUNT(o.order_id) as total_orders,
       SUM(o.total) as total_spent,
       MAX(o.order_date) as last_order_date
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name
ORDER BY total_spent DESC;

-- Product sales analysis
SELECT p.name as product_name,
       p.category,
       SUM(oi.quantity) as total_sold,
       SUM(oi.quantity * oi.price) as total_revenue,
       COUNT(DISTINCT o.customer_id) as unique_customers
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
LEFT JOIN orders o ON oi.order_id = o.order_id
GROUP BY p.product_id, p.name, p.category
ORDER BY total_revenue DESC;

-- Customer segmentation
SELECT
    CASE
        WHEN total_spent > 10000 THEN 'High Value'
        WHEN total_spent > 5000 THEN 'Medium Value'
        ELSE 'Low Value'
    END as customer_segment,
    COUNT(*) as customer_count,
    AVG(total_spent) as avg_spent_per_segment
FROM (
    SELECT c.customer_id,
           COALESCE(SUM(o.total), 0) as total_spent
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id
) customer_totals
GROUP BY
    CASE
        WHEN total_spent > 10000 THEN 'High Value'
        WHEN total_spent > 5000 THEN 'Medium Value'
        ELSE 'Low Value'
    END;
```

### Employee Management System

```sql
-- Organization hierarchy
SELECT e.first_name as employee,
       m.first_name as manager,
       d.department_name,
       COUNT(sub.employee_id) as direct_reports
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.employee_id
LEFT JOIN departments d ON e.department_id = d.department_id
LEFT JOIN employees sub ON e.employee_id = sub.manager_id
GROUP BY e.employee_id, e.first_name, m.first_name, d.department_name;

-- Department performance
SELECT d.department_name,
       COUNT(DISTINCT e.employee_id) as employee_count,
       COUNT(DISTINCT p.project_id) as active_projects,
       AVG(e.salary) as avg_salary,
       SUM(p.budget) as total_project_budget
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id
LEFT JOIN project_assignments pa ON e.employee_id = pa.employee_id
LEFT JOIN projects p ON pa.project_id = p.project_id AND p.status = 'active'
GROUP BY d.department_id, d.department_name;
```

---

## 🚀 JOIN Performance Optimization

### 1. Use Appropriate JOIN Types

```sql
-- Use INNER JOIN when you only need matching records
SELECT * FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id;

-- Use LEFT JOIN when you need all records from left table
SELECT * FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id;
```

### 2. Index Foreign Key Columns

```sql
-- Always index foreign key columns
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_employees_dept_id ON employees(department_id);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);
```

### 3. Avoid Unnecessary Columns

```sql
-- Bad: Select all columns
SELECT * FROM employees e
INNER JOIN departments d ON e.department_id = d.department_id;

-- Good: Select only needed columns
SELECT e.first_name, e.last_name, d.department_name
FROM employees e
INNER JOIN departments d ON e.department_id = d.department_id;
```

### 4. Use WHERE Early in the Process

```sql
-- Filter before joining (more efficient)
SELECT e.first_name, d.department_name
FROM employees e
INNER JOIN departments d ON e.department_id = d.department_id
WHERE e.salary > 50000;

-- Avoid filtering after joining large datasets
```

### 5. Consider JOIN Order

```sql
-- Join smaller tables first
SELECT *
FROM small_table s
INNER JOIN large_table l ON s.id = l.small_id
INNER JOIN another_table a ON l.id = a.large_id;
```

---

## 🔧 Common JOIN Patterns

### 1. Lookup Tables

```sql
-- Status lookup
SELECT o.order_id, o.total, s.status_name
FROM orders o
INNER JOIN order_status s ON o.status_id = s.status_id;

-- Category lookup
SELECT p.product_name, c.category_name
FROM products p
INNER JOIN categories c ON p.category_id = c.category_id;
```

### 2. Many-to-Many Resolution

```sql
-- Students and courses
SELECT s.first_name, s.last_name, c.course_name, e.grade
FROM students s
INNER JOIN enrollments e ON s.student_id = e.student_id
INNER JOIN courses c ON e.course_id = c.course_id;

-- Users and roles
SELECT u.username, r.role_name
FROM users u
INNER JOIN user_roles ur ON u.user_id = ur.user_id
INNER JOIN roles r ON ur.role_id = r.role_id;
```

### 3. Hierarchical Data

```sql
-- Employee hierarchy
SELECT emp.first_name as employee,
       mgr.first_name as manager,
       dept.department_name
FROM employees emp
LEFT JOIN employees mgr ON emp.manager_id = mgr.employee_id
LEFT JOIN departments dept ON emp.department_id = dept.department_id
ORDER BY mgr.first_name, emp.first_name;
```

---

## 📚 Practice Exercises

### Exercise 1: Library Management System
Given tables: books, authors, borrowers, loans
Write queries to:
1. List all books with their authors
2. Find books currently on loan
3. Show borrower loan history
4. Find overdue books
5. Generate library statistics

### Exercise 2: Online Store Analysis
Given tables: customers, orders, order_items, products, categories
Create queries for:
1. Best-selling products by category
2. Customer purchase frequency analysis
3. Monthly sales trends
4. Product recommendations based on purchase history
5. Customer lifetime value calculation

### Exercise 3: Social Network
Given tables: users, posts, likes, comments, friendships
Implement:
1. User feed (posts from friends)
2. Most liked posts this week
3. User engagement metrics
4. Friend recommendations
5. Trending topics

---

## 🎯 Chapter Summary

- JOINs combine data from related tables
- INNER JOIN: Only matching records
- LEFT/RIGHT JOIN: All records from one table + matches
- FULL OUTER JOIN: All records from both tables
- SELF JOIN: Table joined with itself
- Performance depends on indexes and query structure
- Choose JOIN types based on data requirements
- Always consider the relationship type (1:1, 1:N, N:N)

---

## 🚀 Next Steps
- Master **aggregate functions** with GROUP BY
- Learn **subqueries** for complex filtering
- Understand **window functions** for advanced analytics
- Practice **query optimization** techniques
- Build complex **real-world applications**
