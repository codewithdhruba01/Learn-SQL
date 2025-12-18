# 👁️ Chapter 12: Views and Indexes - Performance and Data Management

## 🎯 Why Views and Indexes Matter?

**Views** and **Indexes** are essential for:
- **Performance**: Speed up queries and reduce execution time
- **Security**: Control data access and hide sensitive information
- **Simplicity**: Provide simplified interfaces to complex data
- **Maintenance**: Organize and optimize database operations

---

## 👁️ Database Views

### What is a View?
A **View** is a virtual table based on the result of a SQL query. It contains rows and columns, just like a real table, but doesn't store data itself.

### Types of Views

#### 1. Simple Views

```sql
-- Basic view
CREATE VIEW active_employees AS
SELECT employee_id, first_name, last_name, department, salary
FROM employees
WHERE is_active = TRUE;

-- Query the view
SELECT * FROM active_employees WHERE department = 'IT';

-- View with calculated columns
CREATE VIEW employee_summary AS
SELECT
    employee_id,
    CONCAT(first_name, ' ', last_name) as full_name,
    salary,
    salary * 1.1 as increased_salary,
    DATEDIFF(CURDATE(), hire_date) as days_employed
FROM employees;
```

#### 2. Complex Views with JOINs

```sql
-- View combining multiple tables
CREATE VIEW employee_details AS
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    e.salary,
    d.department_name,
    m.first_name as manager_name,
    COUNT(p.project_id) as active_projects
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id
LEFT JOIN employees m ON e.manager_id = m.employee_id
LEFT JOIN project_assignments pa ON e.employee_id = pa.employee_id
LEFT JOIN projects p ON pa.project_id = p.project_id AND p.status = 'active'
GROUP BY e.employee_id, e.first_name, e.last_name, e.salary,
         d.department_name, m.first_name;

-- Department performance view
CREATE VIEW department_performance AS
SELECT
    d.department_name,
    COUNT(e.employee_id) as employee_count,
    AVG(e.salary) as avg_salary,
    SUM(p.budget) as total_project_budget,
    COUNT(DISTINCT p.project_id) as active_projects
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id
LEFT JOIN projects p ON d.department_id = p.department_id AND p.status = 'active'
GROUP BY d.department_id, d.department_name;
```

#### 3. Updatable Views

```sql
-- Simple updatable view
CREATE VIEW it_employees AS
SELECT employee_id, first_name, last_name, salary
FROM employees
WHERE department = 'IT';

-- Update through view (works)
UPDATE it_employees SET salary = salary * 1.05 WHERE employee_id = 1;

-- Complex view (usually not updatable)
CREATE VIEW employee_dept_summary AS
SELECT d.department_name, COUNT(*) as emp_count, AVG(salary) as avg_salary
FROM employees e
JOIN departments d ON e.department_id = d.department_id
GROUP BY d.department_name;

-- This won't work
UPDATE employee_dept_summary SET avg_salary = 60000 WHERE department_name = 'IT';
```

#### 4. Materialized Views (Database-specific)

```sql
-- MySQL doesn't have native materialized views
-- But you can simulate with tables and triggers

-- PostgreSQL materialized view
CREATE MATERIALIZED VIEW monthly_sales AS
SELECT
    DATE_TRUNC('month', order_date) as month,
    COUNT(*) as order_count,
    SUM(total_amount) as total_revenue,
    AVG(total_amount) as avg_order_value
FROM orders
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY month DESC;

-- Refresh materialized view
REFRESH MATERIALIZED VIEW monthly_sales;

-- SQL Server indexed view (similar to materialized)
CREATE VIEW sales_summary WITH SCHEMABINDING AS
SELECT
    YEAR(order_date) as order_year,
    MONTH(order_date) as order_month,
    COUNT_BIG(*) as order_count,
    SUM(total_amount) as total_revenue,
    COUNT_BIG(DISTINCT customer_id) as unique_customers
FROM dbo.orders
GROUP BY YEAR(order_date), MONTH(order_date);

-- Create unique clustered index on view
CREATE UNIQUE CLUSTERED INDEX idx_sales_summary
ON sales_summary (order_year, order_month);
```

---

## 🔍 Database Indexes

### What is an Index?
An **Index** is a data structure that improves the speed of data retrieval operations on a database table. It's like a book index that helps you find information quickly.

### Index Types

#### 1. B-Tree Index (Default)

```sql
-- Single column index
CREATE INDEX idx_employee_last_name ON employees (last_name);

-- Composite index
CREATE INDEX idx_employee_dept_salary ON employees (department_id, salary);

-- Unique index
CREATE UNIQUE INDEX idx_unique_employee_email ON employees (email);

-- Index with specific length (MySQL)
CREATE INDEX idx_product_name ON products (product_name(50));
```

#### 2. Clustered vs Non-Clustered Indexes

```sql
-- Clustered index (SQL Server/MySQL InnoDB)
-- Defines physical order of data
CREATE CLUSTERED INDEX idx_orders_date ON orders (order_date);

-- Non-clustered index (points to data location)
CREATE INDEX idx_orders_customer ON orders (customer_id);

-- Primary key is usually clustered
CREATE TABLE users (
    user_id INT PRIMARY KEY CLUSTERED, -- Data physically ordered by user_id
    email VARCHAR(255),
    created_at DATETIME
);
```

#### 3. Specialized Indexes

```sql
-- Full-text index (MySQL)
CREATE FULLTEXT INDEX idx_product_description ON products (description);

-- Search with full-text
SELECT * FROM products
WHERE MATCH(description) AGAINST('wireless bluetooth' IN NATURAL LANGUAGE MODE);

-- Spatial index (MySQL/PostgreSQL)
CREATE SPATIAL INDEX idx_location ON stores (location);

-- Partial index (PostgreSQL)
CREATE INDEX idx_active_orders ON orders (customer_id)
WHERE status IN ('pending', 'processing');

-- Expression index (PostgreSQL)
CREATE INDEX idx_lower_email ON users (LOWER(email));

-- Covering index (includes all columns needed)
CREATE INDEX idx_order_summary ON orders (customer_id, order_date, total_amount);
```

---

## 📊 Index Performance and Strategy

### When to Create Indexes

```sql
-- Index foreign keys (always)
CREATE INDEX idx_employee_dept ON employees (department_id);
CREATE INDEX idx_order_customer ON orders (customer_id);

-- Index columns in WHERE clauses
CREATE INDEX idx_product_category ON products (category_id, price);

-- Index columns in ORDER BY
CREATE INDEX idx_employee_salary ON employees (salary DESC);

-- Index columns used in JOINs
CREATE INDEX idx_dept_mgr ON departments (manager_id);

-- Composite indexes for multiple conditions
CREATE INDEX idx_emp_dept_status ON employees (department_id, is_active, hire_date);
```

### Index Best Practices

```sql
-- Good: Selective indexes
CREATE INDEX idx_high_salary ON employees (salary) WHERE salary > 80000;

-- Good: Covering indexes
CREATE INDEX idx_order_lookup ON orders (customer_id, order_date, status)
INCLUDE (total_amount, shipping_address);

-- Avoid: Low selectivity
-- Bad: Gender index (only M/F)
CREATE INDEX idx_gender ON employees (gender); -- Not useful

-- Avoid: Too many indexes
-- Don't index every column
-- Each index has maintenance overhead

-- Good: Index maintenance
SHOW INDEX FROM employees; -- Check existing indexes
DROP INDEX idx_old_index ON table_name; -- Remove unused indexes
```

### Index Usage Analysis

```sql
-- MySQL: Check index usage
SHOW INDEX FROM employees;

-- MySQL: Analyze query with EXPLAIN
EXPLAIN SELECT * FROM employees WHERE department_id = 1 AND salary > 50000;

-- PostgreSQL: Query execution plan
EXPLAIN ANALYZE
SELECT * FROM employees WHERE department_id = 1 AND salary > 50000;

-- SQL Server: Execution plan
SET SHOWPLAN_ALL ON;
SELECT * FROM employees WHERE department_id = 1 AND salary > 50000;
SET SHOWPLAN_ALL OFF;
```

---

## 🔧 View Management

### Creating and Modifying Views

```sql
-- Create or replace view
CREATE OR REPLACE VIEW employee_directory AS
SELECT
    employee_id,
    CONCAT(first_name, ' ', last_name) as full_name,
    email,
    department,
    phone
FROM employees
WHERE is_active = TRUE;

-- Alter view definition
ALTER VIEW employee_directory AS
SELECT
    employee_id,
    CONCAT(first_name, ' ', last_name) as full_name,
    email,
    department,
    phone,
    hire_date
FROM employees
WHERE is_active = TRUE;

-- Drop view
DROP VIEW employee_directory;

-- Drop view if exists
DROP VIEW IF EXISTS employee_directory;
```

### View Security and Access Control

```sql
-- Grant permissions on views
GRANT SELECT ON employee_directory TO hr_staff;
GRANT SELECT, UPDATE ON active_employees TO managers;

-- Create view for specific department access
CREATE VIEW it_department AS
SELECT employee_id, first_name, last_name, email, phone
FROM employees
WHERE department = 'IT';

-- Hide sensitive columns
CREATE VIEW public_employee_info AS
SELECT employee_id, first_name, last_name, department, hire_date
FROM employees;
-- Excludes salary, ssn, etc.
```

---

## 📈 Advanced View Techniques

### Partitioned Views

```sql
-- Create monthly sales views
CREATE VIEW sales_2024_q1 AS
SELECT * FROM sales WHERE order_date BETWEEN '2024-01-01' AND '2024-03-31';

CREATE VIEW sales_2024_q2 AS
SELECT * FROM sales WHERE order_date BETWEEN '2024-04-01' AND '2024-06-30';

-- Union all partitions
CREATE VIEW sales_2024 AS
SELECT * FROM sales_2024_q1
UNION ALL
SELECT * FROM sales_2024_q2;
```

### Recursive Views (Common Table Expressions)

```sql
-- Employee hierarchy (PostgreSQL)
WITH RECURSIVE employee_hierarchy AS (
    -- Base case: top-level managers
    SELECT employee_id, first_name, last_name, manager_id, 0 as level
    FROM employees
    WHERE manager_id IS NULL

    UNION ALL

    -- Recursive case: employees with managers
    SELECT e.employee_id, e.first_name, e.last_name, e.manager_id, eh.level + 1
    FROM employees e
    JOIN employee_hierarchy eh ON e.manager_id = eh.employee_id
)
SELECT * FROM employee_hierarchy ORDER BY level, manager_id, employee_id;
```

### Indexed Views for Performance

```sql
-- SQL Server indexed view
CREATE VIEW sales_by_category WITH SCHEMABINDING AS
SELECT
    c.category_name,
    COUNT_BIG(*) as product_count,
    SUM(p.price * s.quantity) as total_sales,
    AVG(p.price) as avg_price
FROM dbo.categories c
JOIN dbo.products p ON c.category_id = p.category_id
JOIN dbo.sales s ON p.product_id = s.product_id
WHERE s.sale_date >= '2024-01-01'
GROUP BY c.category_name;

-- Create clustered index
CREATE UNIQUE CLUSTERED INDEX idx_sales_category
ON sales_by_category (category_name);

-- Now queries against this view will be fast
SELECT * FROM sales_by_category WHERE category_name LIKE 'Electronics%';
```

---

## 🚀 Performance Optimization with Views and Indexes

### 1. Query Optimization

```sql
-- Create indexes for common query patterns
CREATE INDEX idx_orders_customer_date ON orders (customer_id, order_date);
CREATE INDEX idx_products_category_price ON products (category_id, price);

-- Create views for complex joins
CREATE VIEW order_details AS
SELECT
    o.order_id,
    o.order_date,
    o.total_amount,
    c.customer_name,
    c.email,
    p.product_name,
    oi.quantity,
    oi.unit_price
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id;

-- Query the view instead of complex joins
SELECT * FROM order_details WHERE customer_name LIKE 'John%' AND order_date >= '2024-01-01';
```

### 2. Index Maintenance

```sql
-- Rebuild fragmented indexes (SQL Server)
ALTER INDEX idx_orders_customer_date ON orders REBUILD;

-- Reorganize less fragmented indexes
ALTER INDEX idx_orders_customer_date ON orders REORGANIZE;

-- Update statistics
UPDATE STATISTICS orders;

-- MySQL index maintenance
ANALYZE TABLE orders;

-- PostgreSQL reindex
REINDEX INDEX idx_orders_customer_date;
```

### 3. Index Monitoring

```sql
-- MySQL: Index usage statistics
SELECT
    TABLE_NAME,
    INDEX_NAME,
    CARDINALITY,
    PAGES,
    FILTER_CONDITION
FROM INFORMATION_SCHEMA.STATISTICS
WHERE TABLE_SCHEMA = 'your_database'
ORDER BY TABLE_NAME, SEQ_IN_INDEX;

-- SQL Server: Index usage
SELECT
    OBJECT_NAME(i.object_id) as table_name,
    i.name as index_name,
    u.user_seeks,
    u.user_scans,
    u.user_lookups,
    u.user_updates
FROM sys.indexes i
LEFT JOIN sys.dm_db_index_usage_stats u ON i.object_id = u.object_id
    AND i.index_id = u.index_id
WHERE i.object_id > 100;
```

---

## 🛠️ Real-World Examples

### E-commerce Dashboard Views

```sql
-- Daily sales summary view
CREATE VIEW daily_sales_summary AS
SELECT
    DATE(order_date) as sale_date,
    COUNT(DISTINCT order_id) as orders_count,
    COUNT(DISTINCT customer_id) as unique_customers,
    SUM(total_amount) as total_revenue,
    AVG(total_amount) as avg_order_value,
    COUNT(order_item_id) as items_sold
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY DATE(order_date);

-- Product performance view
CREATE VIEW product_performance AS
SELECT
    p.product_id,
    p.product_name,
    p.price,
    COALESCE(s.total_sold, 0) as total_sold,
    COALESCE(s.total_revenue, 0) as total_revenue,
    COALESCE(r.avg_rating, 0) as avg_rating,
    COALESCE(r.review_count, 0) as review_count,
    CASE
        WHEN s.total_sold > 100 THEN 'Best Seller'
        WHEN s.total_sold > 50 THEN 'Good Seller'
        WHEN s.total_sold > 10 THEN 'Moderate'
        ELSE 'Slow Moving'
    END as performance_category
FROM products p
LEFT JOIN (
    SELECT product_id,
           SUM(quantity) as total_sold,
           SUM(quantity * unit_price) as total_revenue
    FROM order_items
    GROUP BY product_id
) s ON p.product_id = s.product_id
LEFT JOIN (
    SELECT product_id,
           AVG(rating) as avg_rating,
           COUNT(*) as review_count
    FROM product_reviews
    GROUP BY product_id
) r ON p.product_id = r.product_id;

-- Customer lifetime value view
CREATE VIEW customer_lifetime_value AS
SELECT
    c.customer_id,
    c.customer_name,
    c.email,
    c.registration_date,
    COALESCE(o.order_count, 0) as order_count,
    COALESCE(o.total_spent, 0) as total_spent,
    COALESCE(o.avg_order_value, 0) as avg_order_value,
    COALESCE(o.last_order_date, c.registration_date) as last_order_date,
    DATEDIFF(CURDATE(), c.registration_date) as days_since_registration,
    CASE
        WHEN COALESCE(o.total_spent, 0) > 10000 THEN 'VIP'
        WHEN COALESCE(o.total_spent, 0) > 5000 THEN 'High Value'
        WHEN COALESCE(o.total_spent, 0) > 1000 THEN 'Medium Value'
        ELSE 'Low Value'
    END as customer_segment
FROM customers c
LEFT JOIN (
    SELECT customer_id,
           COUNT(*) as order_count,
           SUM(total_amount) as total_spent,
           AVG(total_amount) as avg_order_value,
           MAX(order_date) as last_order_date
    FROM orders
    GROUP BY customer_id
) o ON c.customer_id = o.customer_id;
```

### Employee Analytics Views

```sql
-- Department productivity view
CREATE VIEW department_productivity AS
SELECT
    d.department_name,
    COUNT(e.employee_id) as total_employees,
    COUNT(CASE WHEN e.is_active THEN 1 END) as active_employees,
    AVG(e.salary) as avg_salary,
    SUM(p.budget) as total_project_budget,
    COUNT(DISTINCT pa.project_id) as active_projects,
    AVG(pr.rating) as avg_performance_rating
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id
LEFT JOIN project_assignments pa ON e.employee_id = pa.employee_id
LEFT JOIN projects p ON pa.project_id = p.project_id AND p.status = 'active'
LEFT JOIN performance_reviews pr ON e.employee_id = pr.employee_id
GROUP BY d.department_id, d.department_name;

-- Employee career progression view
CREATE VIEW employee_career_progression AS
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    e.hire_date,
    TIMESTAMPDIFF(YEAR, e.hire_date, CURDATE()) as years_experience,
    COUNT(DISTINCT s.salary_id) as salary_changes,
    COUNT(DISTINCT p.project_id) as projects_completed,
    COUNT(DISTINCT pr.review_id) as performance_reviews,
    AVG(pr.rating) as avg_rating,
    MAX(s.salary_amount) as current_salary,
    CASE
        WHEN TIMESTAMPDIFF(YEAR, e.hire_date, CURDATE()) < 2 THEN 'Junior'
        WHEN TIMESTAMPDIFF(YEAR, e.hire_date, CURDATE()) < 5 THEN 'Mid-level'
        WHEN AVG(pr.rating) > 4.5 THEN 'Senior'
        ELSE 'Experienced'
    END as career_level
FROM employees e
LEFT JOIN salaries s ON e.employee_id = s.employee_id
LEFT JOIN project_assignments pa ON e.employee_id = pa.employee_id
LEFT JOIN projects p ON pa.project_id = p.project_id AND p.status = 'completed'
LEFT JOIN performance_reviews pr ON e.employee_id = pr.employee_id
GROUP BY e.employee_id, e.first_name, e.last_name, e.hire_date;
```

---

## 📚 Practice Exercises

### Exercise 1: E-commerce Views
Create views for:
1. **Product catalog** with category and pricing info
2. **Customer order history** with totals and dates
3. **Sales performance** by product and category
4. **Inventory status** with reorder alerts
5. **Customer segmentation** based on purchase behavior

### Exercise 2: Index Optimization
For the employee database:
1. Create indexes for frequently queried columns
2. Analyze query performance with EXPLAIN
3. Create composite indexes for multi-column queries
4. Implement covering indexes for common queries
5. Monitor and maintain index health

### Exercise 3: Advanced Analytics Views
Design views for:
1. **Monthly revenue trends** with growth calculations
2. **Customer lifetime value** segmentation
3. **Product performance** analysis
4. **Employee productivity** metrics
5. **Department-wise** analytics dashboard

### Exercise 4: Security Views
Create views that:
1. Hide sensitive salary information from regular users
2. Provide department-specific data access
3. Show public product information only
4. Mask personal information for reports
5. Control access to financial data

---

## 🎯 Chapter Summary

- **Views**: Virtual tables for simplified queries and security
- **Indexes**: Data structures for faster query performance
- **B-Tree Indexes**: Default index type for most queries
- **Composite Indexes**: Multiple columns for complex conditions
- **Covering Indexes**: Include all needed columns
- **Materialized Views**: Pre-computed results for performance
- **Index Maintenance**: Regular monitoring and optimization
- **Performance**: Strategic indexing improves query speed dramatically
- **Security**: Views control data access and hide sensitive information

---

## 🚀 Next Steps
- Learn **triggers** for automatic database actions
- Master **stored procedures** for complex business logic
- Understand **transactions** for data consistency
- Practice **performance tuning** techniques
- Implement **comprehensive database solutions**
