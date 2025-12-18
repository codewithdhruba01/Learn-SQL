# 🔄 Chapter 18: Common Table Expressions (CTEs) - Advanced Query Building

## 🎯 What are CTEs?

**Common Table Expressions (CTEs)** are temporary named result sets that exist within the scope of a SQL statement. They make complex queries more readable, maintainable, and allow for recursive operations.

---

## 📋 CTE Syntax

### Basic CTE Structure

```sql
WITH cte_name [(column_list)] AS (
    -- CTE query
    SELECT ...
)
SELECT ... FROM cte_name;
```

### Multiple CTEs

```sql
WITH
    cte1 AS (SELECT ...),
    cte2 AS (SELECT ... FROM cte1),
    cte3 AS (SELECT ... FROM cte2)
SELECT * FROM cte3;
```

---

## 🏗️ Non-Recursive CTEs

### Simple CTEs

```sql
-- Basic CTE example
WITH high_salary_employees AS (
    SELECT employee_id, first_name, last_name, salary, department
    FROM employees
    WHERE salary > 75000
)
SELECT department, COUNT(*) as high_earners
FROM high_salary_employees
GROUP BY department;

-- CTE with aggregation
WITH monthly_sales AS (
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') as month,
        SUM(total_amount) as monthly_total,
        COUNT(*) as order_count
    FROM orders
    WHERE order_date >= '2024-01-01'
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
)
SELECT month, monthly_total, order_count,
       AVG(monthly_total) OVER () as avg_monthly_sales
FROM monthly_sales
ORDER BY month;
```

### Multiple CTEs

```sql
-- Department statistics
WITH dept_stats AS (
    SELECT department_id, COUNT(*) as emp_count, AVG(salary) as avg_salary
    FROM employees
    GROUP BY department_id
),
dept_budget AS (
    SELECT d.department_id, d.budget, ds.emp_count, ds.avg_salary
    FROM departments d
    JOIN dept_stats ds ON d.department_id = ds.department_id
)
SELECT department_name,
       budget,
       emp_count,
       avg_salary,
       budget / emp_count as budget_per_employee
FROM dept_budget db
JOIN departments d ON db.department_id = d.department_id;
```

### CTEs with Window Functions

```sql
-- Employee ranking by department
WITH ranked_employees AS (
    SELECT employee_id, first_name, department, salary,
           RANK() OVER (PARTITION BY department ORDER BY salary DESC) as salary_rank,
           ROW_NUMBER() OVER (PARTITION BY department ORDER BY salary DESC) as dept_row_num
    FROM employees
)
SELECT * FROM ranked_employees
WHERE salary_rank <= 3
ORDER BY department, salary_rank;
```

---

## 🔄 Recursive CTEs

### Basic Recursive Structure

```sql
WITH RECURSIVE cte_name AS (
    -- Anchor member (base case)
    SELECT ... FROM table WHERE condition

    UNION ALL

    -- Recursive member (calls itself)
    SELECT ... FROM table
    JOIN cte_name ON condition
)
SELECT * FROM cte_name;
```

### Employee Hierarchy (Organization Chart)

```sql
-- Employee hierarchy using recursive CTE
WITH RECURSIVE employee_hierarchy AS (
    -- Anchor: Top-level managers (no manager)
    SELECT employee_id, first_name, last_name, manager_id, 0 as level, CAST(first_name AS CHAR(200)) as path
    FROM employees
    WHERE manager_id IS NULL

    UNION ALL

    -- Recursive: Employees with managers
    SELECT e.employee_id, e.first_name, e.last_name, e.manager_id, eh.level + 1,
           CONCAT(eh.path, ' > ', e.first_name) as path
    FROM employees e
    JOIN employee_hierarchy eh ON e.manager_id = eh.employee_id
)
SELECT employee_id, first_name, last_name, level,
       REPEAT('  ', level) || first_name as indented_name,
       path
FROM employee_hierarchy
ORDER BY path;
```

### Category Tree (Product Categories)

```sql
-- Product category hierarchy
WITH RECURSIVE category_tree AS (
    -- Anchor: Root categories (no parent)
    SELECT category_id, category_name, parent_id, 0 as level,
           CAST(category_name AS CHAR(200)) as path
    FROM categories
    WHERE parent_id IS NULL

    UNION ALL

    -- Recursive: Subcategories
    SELECT c.category_id, c.category_name, c.parent_id, ct.level + 1,
           CONCAT(ct.path, ' > ', c.category_name) as path
    FROM categories c
    JOIN category_tree ct ON c.parent_id = ct.category_id
)
SELECT category_id, category_name,
       REPEAT('  ', level) || category_name as indented_name,
       level, path
FROM category_tree
ORDER BY path;
```

### Bill of Materials (BOM)

```sql
-- Manufacturing bill of materials
WITH RECURSIVE bom AS (
    -- Anchor: Final products
    SELECT product_id, component_id, quantity, 0 as level,
           CAST(product_id AS CHAR(50)) as assembly_path
    FROM product_components
    WHERE product_id NOT IN (SELECT DISTINCT component_id FROM product_components)

    UNION ALL

    -- Recursive: Sub-components
    SELECT pc.product_id, pc.component_id, pc.quantity * b.quantity, b.level + 1,
           CONCAT(b.assembly_path, ' > ', pc.component_id) as assembly_path
    FROM product_components pc
    JOIN bom b ON pc.component_id = b.product_id
)
SELECT b.product_id, b.component_id, b.quantity,
       REPEAT('  ', b.level) || p.product_name as component_name,
       b.level, b.assembly_path
FROM bom b
JOIN products p ON b.component_id = p.product_id
ORDER BY b.assembly_path, b.level;
```

---

## 🧮 Advanced CTE Techniques

### CTEs with Aggregation

```sql
-- Sales analysis with multiple aggregations
WITH sales_summary AS (
    SELECT
        customer_id,
        DATE_FORMAT(order_date, '%Y-%m') as month,
        SUM(total_amount) as monthly_spend,
        COUNT(*) as order_count
    FROM orders
    GROUP BY customer_id, DATE_FORMAT(order_date, '%Y-%m')
),
customer_metrics AS (
    SELECT
        customer_id,
        AVG(monthly_spend) as avg_monthly_spend,
        SUM(order_count) as total_orders,
        COUNT(DISTINCT month) as active_months
    FROM sales_summary
    GROUP BY customer_id
)
SELECT c.customer_name,
       cm.avg_monthly_spend,
       cm.total_orders,
       cm.active_months,
       CASE
           WHEN cm.avg_monthly_spend > 1000 THEN 'High Value'
           WHEN cm.total_orders > 10 THEN 'Frequent'
           ELSE 'Regular'
       END as customer_segment
FROM customer_metrics cm
JOIN customers c ON cm.customer_id = c.customer_id;
```

### CTEs for Data Modification

```sql
-- Update using CTE (PostgreSQL/SQL Server)
WITH updated_employees AS (
    UPDATE employees
    SET salary = salary * 1.05
    WHERE department = 'IT' AND performance_rating > 4.0
    RETURNING employee_id, salary as new_salary
)
SELECT ue.employee_id, e.first_name, e.last_name,
       e.salary as old_salary, ue.new_salary
FROM updated_employees ue
JOIN employees e ON ue.employee_id = e.employee_id;
```

### CTEs with Window Functions

```sql
-- Complex analytics with CTEs
WITH monthly_metrics AS (
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') as month,
        customer_id,
        SUM(total_amount) as monthly_spend,
        COUNT(*) as monthly_orders
    FROM orders
    GROUP BY DATE_FORMAT(order_date, '%Y-%m'), customer_id
),
customer_ranking AS (
    SELECT month, customer_id, monthly_spend, monthly_orders,
           RANK() OVER (PARTITION BY month ORDER BY monthly_spend DESC) as spend_rank,
           AVG(monthly_spend) OVER (PARTITION BY month) as month_avg
    FROM monthly_metrics
)
SELECT cr.month, c.customer_name,
       cr.monthly_spend, cr.monthly_orders,
       cr.spend_rank, cr.month_avg,
       ROUND(cr.monthly_spend / cr.month_avg * 100, 2) as pct_of_month_avg
FROM customer_ranking cr
JOIN customers c ON cr.customer_id = c.customer_id
WHERE cr.spend_rank <= 5
ORDER BY cr.month, cr.spend_rank;
```

---

## 🔍 Recursive CTEs for Complex Hierarchies

### File System Structure

```sql
-- Simulating file system hierarchy
WITH RECURSIVE file_tree AS (
    -- Root directories
    SELECT id, name, parent_id, 0 as depth,
           CAST(name AS CHAR(500)) as full_path,
           'directory' as type
    FROM filesystem
    WHERE parent_id IS NULL

    UNION ALL

    -- Files and subdirectories
    SELECT f.id, f.name, f.parent_id, ft.depth + 1,
           CONCAT(ft.full_path, '/', f.name) as full_path,
           f.type
    FROM filesystem f
    JOIN file_tree ft ON f.parent_id = ft.id
)
SELECT id, name,
       REPEAT('  ', depth) || name as indented_name,
       depth, full_path, type
FROM file_tree
ORDER BY full_path;
```

### Social Network Connections

```sql
-- Finding connection paths between users
WITH RECURSIVE user_connections AS (
    -- Direct connections (level 1)
    SELECT user_id, friend_id as connected_user, 1 as connection_level,
           CAST(CONCAT(user_id, ' -> ', friend_id) AS CHAR(1000)) as connection_path
    FROM friendships
    WHERE user_id = 1  -- Start from user 1

    UNION

    -- Indirect connections (levels 2+)
    SELECT uc.user_id, f.friend_id, uc.connection_level + 1,
           CONCAT(uc.connection_path, ' -> ', f.friend_id) as connection_path
    FROM user_connections uc
    JOIN friendships f ON uc.connected_user = f.user_id
    WHERE uc.connection_level < 3  -- Limit to 3 degrees of separation
)
SELECT connected_user, connection_level, connection_path,
       u.name as connected_user_name
FROM user_connections uc
JOIN users u ON uc.connected_user = u.user_id
ORDER BY connection_level, connected_user;
```

### Project Dependencies

```sql
-- Task dependency resolution
WITH RECURSIVE task_dependencies AS (
    -- Tasks with no dependencies
    SELECT task_id, task_name, 0 as dependency_level,
           CAST(task_name AS CHAR(500)) as execution_path
    FROM project_tasks
    WHERE task_id NOT IN (SELECT DISTINCT dependent_task_id FROM task_dependencies_table)

    UNION ALL

    -- Tasks that depend on completed tasks
    SELECT pt.task_id, pt.task_name, td.dependency_level + 1,
           CONCAT(td.execution_path, ' -> ', pt.task_name) as execution_path
    FROM project_tasks pt
    JOIN task_dependencies_table tdt ON pt.task_id = tdt.dependent_task_id
    JOIN task_dependencies td ON tdt.prerequisite_task_id = td.task_id
)
SELECT task_id, task_name, dependency_level, execution_path
FROM task_dependencies
ORDER BY dependency_level, task_id;
```

---

## ⚡ Performance Considerations

### CTE vs Temporary Tables vs Subqueries

```sql
-- CTE (good for readability, single execution)
WITH sales_data AS (
    SELECT customer_id, SUM(amount) as total_sales
    FROM orders GROUP BY customer_id
)
SELECT * FROM sales_data WHERE total_sales > 1000;

-- Temporary table (good for multiple uses, persists in session)
CREATE TEMPORARY TABLE temp_sales AS
SELECT customer_id, SUM(amount) as total_sales
FROM orders GROUP BY customer_id;

SELECT * FROM temp_sales WHERE total_sales > 1000;
-- Can use again: SELECT * FROM temp_sales WHERE total_sales < 500;

-- Subquery (can be less readable for complex queries)
SELECT * FROM (
    SELECT customer_id, SUM(amount) as total_sales
    FROM orders GROUP BY customer_id
) sales_data
WHERE total_sales > 1000;
```

### Indexing for Recursive CTEs

```sql
-- Create indexes for recursive CTE performance
CREATE INDEX idx_employee_manager ON employees (manager_id);
CREATE INDEX idx_category_parent ON categories (parent_id);
CREATE INDEX idx_filesystem_parent ON filesystem (parent_id);

-- For large hierarchies, consider materialized paths or nested sets
ALTER TABLE categories ADD COLUMN path VARCHAR(1000);
UPDATE categories SET path = (
    SELECT CONCAT('/', GROUP_CONCAT(ancestor.category_name ORDER BY level SEPARATOR '/'), '/', c.category_name)
    FROM (
        WITH RECURSIVE ancestors AS (
            SELECT category_id, category_name, parent_id, 1 as level
            FROM categories
            WHERE category_id = categories.category_id
            UNION ALL
            SELECT c.category_id, c.category_name, c.parent_id, a.level + 1
            FROM categories c
            JOIN ancestors a ON c.category_id = a.parent_id
        )
        SELECT * FROM ancestors ORDER BY level DESC
    ) ancestor, categories c
    WHERE ancestor.category_id = categories.category_id
);
```

### Memory and Performance Tips

```sql
-- Limit recursion depth to prevent infinite loops
WITH RECURSIVE limited_hierarchy AS (
    SELECT id, name, parent_id, 0 as level
    FROM categories
    WHERE parent_id IS NULL

    UNION ALL

    SELECT c.id, c.name, c.parent_id, lh.level + 1
    FROM categories c
    JOIN limited_hierarchy lh ON c.parent_id = lh.id
    WHERE lh.level < 10  -- Prevent excessive recursion
)
SELECT * FROM limited_hierarchy;

-- Use CTEs for complex calculations to avoid repeated subqueries
WITH complex_calc AS (
    SELECT customer_id,
           -- Complex calculation done once
           AVG(order_amount) + STDDEV(order_amount) as threshold
    FROM customer_orders
    GROUP BY customer_id
)
SELECT c.customer_name, co.order_amount, cc.threshold
FROM customers c
JOIN customer_orders co ON c.customer_id = co.customer_id
JOIN complex_calc cc ON c.customer_id = cc.customer_id
WHERE co.order_amount > cc.threshold;
```

---

## 📊 Real-World Business Cases

### Customer Journey Analysis

```sql
WITH customer_journey AS (
    SELECT customer_id, event_type, event_date,
           ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY event_date) as event_sequence
    FROM customer_events
),
journey_transitions AS (
    SELECT cj1.customer_id,
           cj1.event_type as from_event,
           cj2.event_type as to_event,
           COUNT(*) as transition_count
    FROM customer_journey cj1
    JOIN customer_journey cj2 ON cj1.customer_id = cj2.customer_id
                             AND cj1.event_sequence = cj2.event_sequence - 1
    GROUP BY cj1.customer_id, cj1.event_type, cj2.event_type
)
SELECT from_event, to_event, SUM(transition_count) as total_transitions
FROM journey_transitions
GROUP BY from_event, to_event
ORDER BY total_transitions DESC;
```

### Inventory Optimization

```sql
WITH product_metrics AS (
    SELECT product_id,
           AVG(daily_sales) as avg_daily_sales,
           STDDEV(daily_sales) as sales_volatility,
           AVG(stock_level) as avg_stock_level,
           MAX(stock_level) as max_stock_level
    FROM daily_inventory
    GROUP BY product_id
),
reorder_analysis AS (
    SELECT pm.product_id, p.product_name,
           pm.avg_daily_sales * 30 as monthly_demand,
           pm.avg_stock_level,
           CASE
               WHEN pm.sales_volatility > pm.avg_daily_sales * 0.5 THEN 'High Variability'
               WHEN pm.avg_daily_sales > pm.avg_stock_level * 0.1 THEN 'Fast Moving'
               ELSE 'Stable'
           END as demand_pattern,
           GREATEST(pm.avg_daily_sales * 45, pm.max_stock_level * 0.2) as recommended_reorder_point
    FROM product_metrics pm
    JOIN products p ON pm.product_id = p.product_id
)
SELECT * FROM reorder_analysis
ORDER BY recommended_reorder_point DESC;
```

---

## 📚 Practice Exercises

### Exercise 1: Basic CTEs
Create CTEs for:

1. **Department Statistics**: Employee count, average salary, total budget per department
2. **Monthly Sales**: Revenue trends with month-over-month growth
3. **Customer Segmentation**: Based on purchase history and frequency
4. **Product Performance**: Sales ranking with category breakdowns

### Exercise 2: Recursive CTEs
Implement recursive queries for:

1. **Employee Hierarchy**: Organization chart with management levels
2. **Category Tree**: Product categories with parent-child relationships
3. **Bill of Materials**: Manufacturing components and subassemblies
4. **Task Dependencies**: Project management with prerequisite tasks

### Exercise 3: Advanced Analytics
Design CTE-based solutions for:

1. **Customer Lifetime Value**: With cohort analysis and retention metrics
2. **Inventory Forecasting**: Based on historical patterns and seasonality
3. **Performance Attribution**: Multi-level contribution analysis
4. **Network Analysis**: Connection paths and influence metrics

### Exercise 4: Complex Business Logic
Build CTE solutions for:

1. **Dynamic Pricing**: Based on demand, competition, and inventory
2. **Risk Assessment**: Multi-factor analysis with weighted scoring
3. **Recommendation Engine**: Collaborative filtering with user preferences
4. **Fraud Detection**: Pattern recognition with historical analysis

---

## 🎯 Chapter Summary

- **CTEs**: Temporary named result sets for complex queries
- **Non-Recursive CTEs**: Improved readability for complex SELECT statements
- **Recursive CTEs**: Handle hierarchical and tree-structured data
- **Multiple CTEs**: Chain together complex data transformations
- **Performance**: Single execution plan, better than multiple subqueries
- **Readability**: Break complex queries into logical, named components

### Key Concepts:
- **Anchor Member**: Base case for recursive CTEs
- **Recursive Member**: Self-referencing part that builds hierarchy
- **Termination**: Proper conditions to prevent infinite recursion
- **Materialization**: CTEs computed once, referenced multiple times
- **Scope**: CTEs exist only for the duration of the main query

---

## 🚀 Next Steps
- Learn **performance tuning** techniques for complex queries
- Master **advanced SQL techniques** like pivoting and dynamic SQL
- Practice **recursive algorithms** for complex business problems
- Build **enterprise-level reporting** systems
- Explore **graph databases** for complex relationships
