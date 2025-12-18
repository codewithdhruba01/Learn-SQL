# 🔍 Chapter 9: Subqueries - Nested Queries for Complex Logic

## 🎯 What are Subqueries?

**Subqueries** (also called **inner queries** or **nested queries**) are SQL queries embedded within another SQL query. They allow you to:

- **Filter data** based on results from another query
- **Compare values** against dynamic result sets
- **Perform calculations** using data from related tables
- **Create complex conditions** that would be difficult with simple JOINs

---

## 📋 Subquery Types

### 1. Single-Row Subqueries
Return exactly **one value** (one row, one column).

```sql
-- Find employees earning more than the average salary
SELECT first_name, last_name, salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);

-- Find employee with highest salary
SELECT first_name, last_name, salary
FROM employees
WHERE salary = (SELECT MAX(salary) FROM employees);
```

### 2. Multi-Row Subqueries
Return **multiple rows** but typically one column.

```sql
-- Find employees in IT or HR departments
SELECT first_name, last_name, department
FROM employees
WHERE department IN (
    SELECT department_name
    FROM departments
    WHERE budget > 100000
);

-- Find employees not in certain departments
SELECT first_name, last_name
FROM employees
WHERE department_id NOT IN (
    SELECT department_id
    FROM departments
    WHERE location = 'Remote'
);
```

### 3. Correlated Subqueries
Reference columns from the **outer query**.

```sql
-- Find employees earning more than their department average
SELECT e.first_name, e.last_name, e.salary, e.department
FROM employees e
WHERE e.salary > (
    SELECT AVG(salary)
    FROM employees
    WHERE department = e.department
);

-- Find customers who have placed orders
SELECT c.customer_name
FROM customers c
WHERE EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
);
```

---

## 🎯 Subquery Usage in Different Clauses

### WHERE Clause Subqueries

```sql
-- Comparison operators (=, !=, <, >, <=, >=)
SELECT product_name, price
FROM products
WHERE price > (SELECT AVG(price) FROM products);

-- IN/NOT IN operators
SELECT employee_name
FROM employees
WHERE department_id IN (
    SELECT department_id
    FROM departments
    WHERE manager_id IS NOT NULL
);

-- EXISTS/NOT EXISTS operators
SELECT customer_name
FROM customers c
WHERE EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
    AND o.order_date >= '2024-01-01'
);
```

### FROM Clause Subqueries (Derived Tables)

```sql
-- Use subquery result as a table
SELECT dept.dept_name, dept.avg_salary, dept.employee_count
FROM (
    SELECT department as dept_name,
           AVG(salary) as avg_salary,
           COUNT(*) as employee_count
    FROM employees
    GROUP BY department
) dept
WHERE dept.avg_salary > 50000;

-- Join with derived table
SELECT e.first_name, e.salary, dept_stats.dept_avg
FROM employees e
JOIN (
    SELECT department, AVG(salary) as dept_avg
    FROM employees
    GROUP BY department
) dept_stats ON e.department = dept_stats.department;
```

### SELECT Clause Subqueries (Scalar Subqueries)

```sql
-- Subquery in SELECT list
SELECT first_name, last_name,
       salary,
       (SELECT department_name
        FROM departments d
        WHERE d.department_id = e.department_id) as department_name
FROM employees e;

-- Multiple scalar subqueries
SELECT product_name,
       price,
       (SELECT COUNT(*) FROM order_items oi WHERE oi.product_id = p.product_id) as times_ordered,
       (SELECT AVG(price) FROM products) as avg_price
FROM products p;
```

### HAVING Clause Subqueries

```sql
-- Filter aggregated results
SELECT department, AVG(salary) as avg_salary
FROM employees
GROUP BY department
HAVING AVG(salary) > (
    SELECT AVG(salary) * 1.2
    FROM employees
);
```

---

## 🔧 Advanced Subquery Techniques

### Multi-Level Subqueries

```sql
-- Three-level nesting
SELECT first_name, last_name
FROM employees
WHERE department_id IN (
    SELECT department_id
    FROM departments
    WHERE manager_id IN (
        SELECT employee_id
        FROM employees
        WHERE salary > 80000
    )
);
```

### Subqueries with Aggregates

```sql
-- Find products with above-average sales
SELECT p.product_name, SUM(oi.quantity) as total_sold
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name
HAVING SUM(oi.quantity) > (
    SELECT AVG(total_qty)
    FROM (
        SELECT SUM(quantity) as total_qty
        FROM order_items
        GROUP BY product_id
    ) product_totals
);
```

### Correlated Subqueries with Aggregates

```sql
-- Find employees with highest salary in their department
SELECT e.first_name, e.last_name, e.salary, e.department
FROM employees e
WHERE e.salary = (
    SELECT MAX(salary)
    FROM employees
    WHERE department = e.department
);

-- Rank employees within department
SELECT e.first_name, e.last_name, e.salary,
       (SELECT COUNT(*) + 1
        FROM employees e2
        WHERE e2.department = e.department
        AND e2.salary > e.salary) as dept_rank
FROM employees e
ORDER BY e.department, e.salary DESC;
```

---

## 🚀 Performance Considerations

### 1. EXISTS vs IN vs JOIN

```sql
-- EXISTS (often fastest for existence checks)
SELECT c.customer_name
FROM customers c
WHERE EXISTS (SELECT 1 FROM orders o WHERE o.customer_id = c.customer_id);

-- IN (good for small result sets)
SELECT c.customer_name
FROM customers c
WHERE c.customer_id IN (SELECT customer_id FROM orders);

-- JOIN (often fastest for large datasets)
SELECT DISTINCT c.customer_name
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id;
```

### 2. Avoid Unnecessary Subqueries

```sql
-- Less efficient
SELECT e.first_name,
       (SELECT d.department_name FROM departments d WHERE d.id = e.dept_id) as dept_name
FROM employees e;

-- More efficient
SELECT e.first_name, d.department_name
FROM employees e
JOIN departments d ON e.dept_id = d.id;
```

### 3. Use Derived Tables for Complex Aggregations

```sql
-- Complex analysis with derived tables
SELECT
    monthly_stats.month,
    monthly_stats.revenue,
    monthly_stats.orders_count,
    (monthly_stats.revenue * 100.0 / prev_month.revenue) - 100 as growth_pct
FROM (
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') as month,
        SUM(total_amount) as revenue,
        COUNT(*) as orders_count
    FROM orders
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
) monthly_stats
LEFT JOIN (
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') as month,
        SUM(total_amount) as revenue
    FROM orders
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
) prev_month ON monthly_stats.month = DATE_FORMAT(DATE_ADD(STR_TO_DATE(CONCAT(monthly_stats.month, '-01'), '%Y-%m-%d'), INTERVAL 1 MONTH), '%Y-%m')
ORDER BY monthly_stats.month;
```

---

## 📊 Real-World Subquery Examples

### E-commerce Analytics

```sql
-- Find customers who haven't ordered in 6 months
SELECT c.customer_name, c.email, c.last_order_date
FROM customers c
WHERE c.customer_id NOT IN (
    SELECT DISTINCT customer_id
    FROM orders
    WHERE order_date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
);

-- Top-selling products in each category
SELECT p.product_name, p.category,
       (SELECT SUM(oi.quantity)
        FROM order_items oi
        WHERE oi.product_id = p.product_id) as total_sold
FROM products p
WHERE (SELECT SUM(oi.quantity)
       FROM order_items oi
       WHERE oi.product_id = p.product_id) >= (
    SELECT MAX(category_total.total_sold)
    FROM (
        SELECT SUM(oi2.quantity) as total_sold
        FROM products p2
        JOIN order_items oi2 ON p2.product_id = oi2.product_id
        WHERE p2.category = p.category
        GROUP BY p2.product_id
    ) category_total
);

-- Customer lifetime value calculation
SELECT c.customer_name,
       (SELECT SUM(o.total_amount)
        FROM orders o
        WHERE o.customer_id = c.customer_id) as lifetime_value,
       (SELECT COUNT(*)
        FROM orders o
        WHERE o.customer_id = c.customer_id) as total_orders,
       (SELECT AVG(o.total_amount)
        FROM orders o
        WHERE o.customer_id = c.customer_id) as avg_order_value
FROM customers c
ORDER BY lifetime_value DESC;
```

### Employee Management

```sql
-- Find managers who manage more than 5 employees
SELECT e.first_name, e.last_name,
       (SELECT COUNT(*)
        FROM employees sub
        WHERE sub.manager_id = e.employee_id) as direct_reports
FROM employees e
WHERE (SELECT COUNT(*)
       FROM employees sub
       WHERE sub.manager_id = e.employee_id) > 5;

-- Department salary analysis
SELECT d.department_name,
       d.avg_salary,
       (SELECT COUNT(*)
        FROM employees e
        WHERE e.department_id = d.department_id
        AND e.salary > d.avg_salary) as above_avg_count,
       (SELECT COUNT(*)
        FROM employees e
        WHERE e.department_id = d.department_id) as total_employees
FROM (
    SELECT department_id, department_name, AVG(salary) as avg_salary
    FROM employees e
    JOIN departments d ON e.department_id = d.department_id
    GROUP BY department_id, department_name
) d;
```

### Inventory Management

```sql
-- Products below reorder point
SELECT p.product_name, p.current_stock,
       (SELECT SUM(oi.quantity)
        FROM order_items oi
        WHERE oi.product_id = p.product_id
        AND oi.order_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)) as sold_last_30_days
FROM products p
WHERE p.current_stock <= (
    SELECT CASE
        WHEN AVG(oi.quantity) > 10 THEN 20
        WHEN AVG(oi.quantity) > 5 THEN 15
        ELSE 10
    END
    FROM order_items oi
    WHERE oi.product_id = p.product_id
    AND oi.order_date >= DATE_SUB(CURDATE(), INTERVAL 90 DAY)
);

-- Supplier performance ranking
SELECT s.supplier_name,
       (SELECT COUNT(DISTINCT p.product_id)
        FROM products p
        WHERE p.supplier_id = s.supplier_id) as products_supplied,
       (SELECT AVG(p.rating)
        FROM products p
        WHERE p.supplier_id = s.supplier_id) as avg_product_rating,
       (SELECT COUNT(*)
        FROM orders o
        JOIN order_items oi ON o.order_id = oi.order_id
        JOIN products p ON oi.product_id = p.product_id
        WHERE p.supplier_id = s.supplier_id) as total_orders
FROM suppliers s
ORDER BY avg_product_rating DESC, total_orders DESC;
```

---

## 🔧 Common Subquery Patterns

### 1. Top-N per Group

```sql
-- Top 3 highest paid employees per department
SELECT e.first_name, e.last_name, e.salary, e.department
FROM employees e
WHERE (
    SELECT COUNT(*)
    FROM employees e2
    WHERE e2.department = e.department
    AND e2.salary >= e.salary
) <= 3
ORDER BY e.department, e.salary DESC;
```

### 2. Running Totals (without window functions)

```sql
-- Monthly running total (complex, better with window functions)
SELECT m1.month, m1.revenue,
       (SELECT SUM(m2.revenue)
        FROM monthly_sales m2
        WHERE m2.month <= m1.month) as running_total
FROM monthly_sales m1
ORDER BY m1.month;
```

### 3. Data Validation

```sql
-- Find orders with invalid product references
SELECT o.order_id, o.customer_id
FROM orders o
WHERE EXISTS (
    SELECT 1
    FROM order_items oi
    WHERE oi.order_id = o.order_id
    AND oi.product_id NOT IN (
        SELECT product_id FROM products
    )
);
```

---

## 📚 Practice Exercises

### Exercise 1: Customer Analysis
Write subqueries to find:
1. Customers who have never placed an order
2. Customers whose total spending exceeds the average
3. Products that have never been ordered
4. Customers who ordered in every month this year
5. Most valuable customers (top 10% by spending)

### Exercise 2: Employee Management
Create queries for:
1. Employees earning more than their department average
2. Departments with above-average performance
3. Managers who manage the most employees
4. Employees with no subordinates
5. Salary comparisons within departments

### Exercise 3: Inventory Optimization
Design subqueries for:
1. Products below minimum stock levels
2. Suppliers with highest quality ratings
3. Seasonal demand patterns
4. Slow-moving inventory identification
5. Optimal reorder quantities

---

## 🎯 Chapter Summary

- **Subqueries** nest queries within other queries
- **Single-row** subqueries return one value
- **Multi-row** subqueries work with IN/NOT IN
- **Correlated** subqueries reference outer query columns
- **EXISTS/NOT EXISTS** check for record existence
- **Derived tables** use subqueries in FROM clause
- Performance depends on proper indexing and query structure
- Sometimes JOINs are more efficient than subqueries

---

## 🚀 Next Steps
- Master **SQL functions** (string, date, numeric, NULL)
- Learn **window functions** for advanced analytics
- Understand **constraints** and **data integrity**
- Practice **query optimization** techniques
- Build **complex real-world applications**
