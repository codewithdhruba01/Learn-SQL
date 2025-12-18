# 📊 Chapter 8: GROUP BY and Aggregate Functions - Data Analysis

## 🎯 Why Aggregation Matters?

**Aggregation** transforms raw data into **meaningful insights**. Instead of seeing individual records, you get:
- **Summary statistics** (totals, averages, counts)
- **Group-wise analysis** (department performance, monthly sales)
- **Data patterns** and **trends**
- **Business intelligence** metrics

---

## 🔢 Aggregate Functions

### COUNT() - Counting Records

```sql
-- Count all records
SELECT COUNT(*) as total_employees FROM employees;

-- Count non-NULL values in a column
SELECT COUNT(email) as employees_with_email FROM employees;

-- Count distinct values
SELECT COUNT(DISTINCT department) as unique_departments FROM employees;

-- Count with conditions
SELECT COUNT(CASE WHEN salary > 50000 THEN 1 END) as high_earners FROM employees;
```

### SUM() - Total Values

```sql
-- Sum numeric columns
SELECT SUM(salary) as total_salary FROM employees;

-- Sum with conditions
SELECT SUM(CASE WHEN department = 'IT' THEN salary END) as it_total_salary FROM employees;

-- Sum multiple columns
SELECT SUM(salary) as salary_total, SUM(bonus) as bonus_total FROM employees;
```

### AVG() - Average Values

```sql
-- Simple average
SELECT AVG(salary) as avg_salary FROM employees;

-- Weighted average
SELECT SUM(salary * experience_years) / SUM(experience_years) as weighted_avg FROM employees;

-- Average with NULL handling
SELECT AVG(COALESCE(bonus, 0)) as avg_bonus FROM employees;
```

### MIN() and MAX() - Extreme Values

```sql
-- Minimum and maximum
SELECT MIN(salary) as min_salary, MAX(salary) as max_salary FROM employees;

-- Min/Max with dates
SELECT MIN(hire_date) as first_hire, MAX(hire_date) as latest_hire FROM employees;

-- Min/Max with strings (alphabetical)
SELECT MIN(first_name) as first_alphabetically, MAX(last_name) as last_alphabetically FROM employees;
```

---

## 🎯 GROUP BY Clause

### Basic GROUP BY

```sql
-- Group by single column
SELECT department, COUNT(*) as employee_count
FROM employees
GROUP BY department;

-- Group by multiple columns
SELECT department, city, COUNT(*) as count
FROM employees
GROUP BY department, city
ORDER BY department, city;
```

### GROUP BY with Aggregates

```sql
-- Complete department analysis
SELECT department,
       COUNT(*) as employee_count,
       AVG(salary) as avg_salary,
       MIN(salary) as min_salary,
       MAX(salary) as max_salary,
       SUM(salary) as total_salary
FROM employees
GROUP BY department
ORDER BY total_salary DESC;
```

### GROUP BY with JOINs

```sql
-- Department performance with manager info
SELECT d.department_name,
       COUNT(e.employee_id) as employee_count,
       AVG(e.salary) as avg_salary,
       m.first_name as manager_name
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id
LEFT JOIN employees m ON d.manager_id = m.employee_id
GROUP BY d.department_id, d.department_name, m.first_name;
```

---

## 🔍 HAVING Clause - Filter Groups

### HAVING vs WHERE

```sql
-- WHERE filters individual records BEFORE grouping
-- HAVING filters groups AFTER aggregation

SELECT department, AVG(salary) as avg_salary
FROM employees
WHERE salary > 30000  -- Filter individual employees first
GROUP BY department
HAVING AVG(salary) > 50000; -- Then filter department groups
```

### HAVING Examples

```sql
-- Departments with more than 5 employees
SELECT department, COUNT(*) as count
FROM employees
GROUP BY department
HAVING COUNT(*) > 5;

-- Departments with high average salary
SELECT department, AVG(salary) as avg_salary
FROM employees
GROUP BY department
HAVING AVG(salary) > 60000
ORDER BY avg_salary DESC;

-- Departments with salary range > 30000
SELECT department,
       MAX(salary) - MIN(salary) as salary_range
FROM employees
GROUP BY department
HAVING MAX(salary) - MIN(salary) > 30000;
```

---

## 🎨 Advanced Aggregation Techniques

### ROLLUP - Subtotal Calculations

```sql
-- Department and company totals
SELECT department, COUNT(*) as count
FROM employees
GROUP BY ROLLUP(department);

-- Multi-level rollup
SELECT department, city, COUNT(*) as count
FROM employees
GROUP BY ROLLUP(department, city);
```

### CUBE - Multi-dimensional Analysis

```sql
-- All combinations of groupings
SELECT department, city, COUNT(*) as count
FROM employees
GROUP BY CUBE(department, city);

-- Sales analysis with cube
SELECT region, product_category, SUM(sales_amount) as total_sales
FROM sales
GROUP BY CUBE(region, product_category);
```

### GROUPING SETS - Custom Groupings

```sql
-- Multiple grouping combinations
SELECT region, product_category, SUM(sales_amount) as total_sales
FROM sales
GROUP BY GROUPING SETS (
    (region),
    (product_category),
    (region, product_category),
    ()  -- Grand total
);
```

---

## 📈 Statistical Functions

### Variance and Standard Deviation

```sql
-- Variance and Std Dev (if supported by your DBMS)
SELECT
    AVG(salary) as mean_salary,
    VAR_POP(salary) as salary_variance,
    STDDEV_POP(salary) as salary_stddev
FROM employees;
```

### Percentiles and Median

```sql
-- MySQL: Percentiles
SELECT
    department,
    AVG(salary) as avg_salary,
    MIN(salary) as min_salary,
    MAX(salary) as max_salary
FROM employees
GROUP BY department;

-- PostgreSQL: Percentiles
SELECT
    percentile_cont(0.5) WITHIN GROUP (ORDER BY salary) as median_salary,
    percentile_cont(0.25) WITHIN GROUP (ORDER BY salary) as q1_salary,
    percentile_cont(0.75) WITHIN GROUP (ORDER BY salary) as q3_salary
FROM employees;
```

### Custom Aggregates with CASE

```sql
-- Conditional aggregation
SELECT
    department,
    COUNT(*) as total_employees,
    COUNT(CASE WHEN salary > 60000 THEN 1 END) as high_earners,
    COUNT(CASE WHEN salary BETWEEN 40000 AND 60000 THEN 1 END) as mid_earners,
    COUNT(CASE WHEN salary < 40000 THEN 1 END) as low_earners,
    AVG(CASE WHEN gender = 'M' THEN salary END) as male_avg_salary,
    AVG(CASE WHEN gender = 'F' THEN salary END) as female_avg_salary
FROM employees
GROUP BY department;
```

---

## 📊 Real-World Analytics Examples

### Sales Dashboard

```sql
-- Monthly sales summary
SELECT
    DATE_FORMAT(order_date, '%Y-%m') as month,
    COUNT(DISTINCT customer_id) as unique_customers,
    COUNT(order_id) as total_orders,
    SUM(total_amount) as total_revenue,
    AVG(total_amount) as avg_order_value,
    MIN(total_amount) as min_order_value,
    MAX(total_amount) as max_order_value
FROM orders
WHERE order_date >= '2024-01-01'
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY month;

-- Product performance
SELECT
    p.category,
    COUNT(DISTINCT p.product_id) as products_offered,
    COUNT(oi.order_item_id) as items_sold,
    SUM(oi.quantity) as total_quantity,
    SUM(oi.quantity * oi.unit_price) as total_revenue,
    AVG(oi.unit_price) as avg_selling_price
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
LEFT JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_date >= '2024-01-01'
GROUP BY p.category
ORDER BY total_revenue DESC;
```

### Employee Analytics

```sql
-- Department productivity metrics
SELECT
    d.department_name,
    COUNT(e.employee_id) as employee_count,
    AVG(e.salary) as avg_salary,
    COUNT(p.project_id) as projects_involved,
    AVG(p.completion_percentage) as avg_project_completion,
    SUM(p.budget) as total_project_budget
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id
LEFT JOIN project_assignments pa ON e.employee_id = pa.employee_id
LEFT JOIN projects p ON pa.project_id = p.project_id
GROUP BY d.department_id, d.department_name;

-- Salary distribution analysis
SELECT
    CASE
        WHEN salary < 40000 THEN 'Under 40K'
        WHEN salary < 60000 THEN '40K-60K'
        WHEN salary < 80000 THEN '60K-80K'
        WHEN salary < 100000 THEN '80K-100K'
        ELSE 'Over 100K'
    END as salary_range,
    COUNT(*) as employee_count,
    ROUND(AVG(salary), 2) as avg_in_range,
    ROUND(MIN(salary), 2) as min_in_range,
    ROUND(MAX(salary), 2) as max_in_range
FROM employees
GROUP BY
    CASE
        WHEN salary < 40000 THEN 'Under 40K'
        WHEN salary < 60000 THEN '40K-60K'
        WHEN salary < 80000 THEN '60K-80K'
        WHEN salary < 100000 THEN '80K-100K'
        ELSE 'Over 100K'
    END
ORDER BY avg_in_range;
```

### Customer Behavior Analysis

```sql
-- Customer segmentation
SELECT
    CASE
        WHEN total_orders > 10 THEN 'VIP'
        WHEN total_orders > 5 THEN 'Regular'
        ELSE 'New'
    END as customer_segment,
    COUNT(*) as customer_count,
    AVG(total_spent) as avg_spent_per_customer,
    AVG(total_orders) as avg_orders_per_customer,
    MIN(first_order_date) as oldest_customer,
    MAX(last_order_date) as newest_customer
FROM (
    SELECT
        customer_id,
        COUNT(order_id) as total_orders,
        SUM(total_amount) as total_spent,
        MIN(order_date) as first_order_date,
        MAX(order_date) as last_order_date
    FROM orders
    GROUP BY customer_id
) customer_summary
GROUP BY
    CASE
        WHEN total_orders > 10 THEN 'VIP'
        WHEN total_orders > 5 THEN 'Regular'
        ELSE 'New'
    END;

-- Product category preferences
SELECT
    c.customer_segment,
    p.category,
    COUNT(oi.order_item_id) as items_purchased,
    SUM(oi.quantity * oi.unit_price) as revenue_from_segment
FROM (
    SELECT customer_id,
           CASE
               WHEN total_spent > 5000 THEN 'High Value'
               WHEN total_spent > 1000 THEN 'Medium Value'
               ELSE 'Low Value'
           END as customer_segment
    FROM (
        SELECT customer_id, SUM(total_amount) as total_spent
        FROM orders
        GROUP BY customer_id
    ) spending
) c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY c.customer_segment, p.category
ORDER BY c.customer_segment, revenue_from_segment DESC;
```

---

## 🚀 Performance Optimization

### 1. Use Appropriate Indexes

```sql
-- Index columns used in GROUP BY
CREATE INDEX idx_employees_dept ON employees(department);
CREATE INDEX idx_orders_date ON orders(order_date);
CREATE INDEX idx_order_items_product ON order_items(product_id);

-- Composite indexes for multiple GROUP BY columns
CREATE INDEX idx_emp_dept_city ON employees(department, city);
```

### 2. Avoid GROUP BY on Functions

```sql
-- Bad: Function on GROUP BY column
SELECT YEAR(order_date), MONTH(order_date), SUM(total)
FROM orders
GROUP BY YEAR(order_date), MONTH(order_date);

-- Better: Pre-compute or use indexed columns
SELECT DATE_FORMAT(order_date, '%Y-%m'), SUM(total)
FROM orders
GROUP BY DATE_FORMAT(order_date, '%Y-%m');
```

### 3. Use WHERE Before GROUP BY

```sql
-- Filter early to reduce data before grouping
SELECT department, AVG(salary)
FROM employees
WHERE hire_date >= '2020-01-01'  -- Filter first
GROUP BY department
HAVING AVG(salary) > 50000;      -- Then aggregate filter
```

### 4. Consider Materialized Views

```sql
-- For frequently accessed summaries
CREATE TABLE monthly_sales_summary AS
SELECT
    DATE_FORMAT(order_date, '%Y-%m') as month,
    COUNT(*) as order_count,
    SUM(total_amount) as total_revenue
FROM orders
GROUP BY DATE_FORMAT(order_date, '%Y-%m');
```

---

## 📚 Practice Exercises

### Exercise 1: E-commerce Analytics
Analyze sales data to find:
1. Monthly revenue trends
2. Best-selling product categories
3. Customer purchase frequency distribution
4. Average order value by customer segment
5. Product performance by region

### Exercise 2: Employee Performance
Create reports showing:
1. Department-wise salary statistics
2. Employee distribution by experience levels
3. Project completion rates by department
4. Top performers in each category
5. Salary growth trends over time

### Exercise 3: Inventory Management
Design queries for:
1. Stock levels by category
2. Slow-moving vs fast-moving products
3. Supplier performance metrics
4. Seasonal demand patterns
5. Reorder point calculations

---

## 🎯 Chapter Summary

- **Aggregate functions** (COUNT, SUM, AVG, MIN, MAX) summarize data
- **GROUP BY** creates groups for analysis
- **HAVING** filters aggregated results
- **ROLLUP/CUBE** provide subtotal calculations
- Performance depends on proper indexing
- Complex analytics require multiple aggregation levels
- Always consider the business context for meaningful insights

---

## 🚀 Next Steps
- Learn **subqueries** for complex filtering and calculations
- Master **SQL functions** (string, date, numeric)
- Understand **window functions** for advanced analytics
- Practice **query optimization** techniques
- Build **comprehensive dashboards** and reports
