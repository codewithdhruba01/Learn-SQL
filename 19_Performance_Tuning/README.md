# ⚡ Chapter 19: Performance Tuning - Optimizing SQL Queries

## 🎯 Why Performance Tuning Matters?

**Performance tuning** is crucial for:
- **Scalability**: Handle growing data volumes
- **User Experience**: Fast response times
- **Resource Efficiency**: Optimal hardware utilization
- **Cost Reduction**: Lower infrastructure costs
- **Business Success**: Reliable application performance

---

## 🔍 Understanding Query Execution

### Execution Plan Analysis

```sql
-- MySQL: EXPLAIN query
EXPLAIN SELECT * FROM employees WHERE department = 'IT' AND salary > 50000;

-- PostgreSQL: EXPLAIN query
EXPLAIN SELECT * FROM employees WHERE department = 'IT' AND salary > 50000;

-- SQL Server: Display execution plan
SET SHOWPLAN_ALL ON;
SELECT * FROM employees WHERE department = 'IT' AND salary > 50000;
SET SHOWPLAN_ALL OFF;
```

### Key Execution Plan Components

```
Query Execution Plan:
├── Table Scan/Index Scan
├── Index Seek
├── Nested Loops Join
├── Merge Join
├── Hash Join
├── Sort Operation
├── Filter Operation
└── Cost Estimation
```

### Reading Execution Plans

```sql
-- Example EXPLAIN output analysis
EXPLAIN SELECT e.name, d.dept_name, AVG(e.salary) as avg_salary
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
WHERE e.salary > 50000
GROUP BY e.dept_id, d.dept_name;

-- Key metrics to check:
-- 1. Table access method (scan vs seek)
-- 2. Join algorithm used
-- 3. Estimated vs actual rows
-- 4. Cost of operations
-- 5. Use of indexes
```

---

## 📊 Index Optimization

### Index Usage Analysis

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
ORDER BY TABLE_NAME;

-- PostgreSQL: Index usage
SELECT
    schemaname,
    tablename,
    indexname,
    idx_scan,
    idx_tup_read,
    idx_tup_fetch
FROM pg_stat_user_indexes
ORDER BY idx_scan DESC;

-- SQL Server: Index usage stats
SELECT
    OBJECT_NAME(i.object_id) as table_name,
    i.name as index_name,
    u.user_seeks,
    u.user_scans,
    u.user_lookups,
    u.user_updates
FROM sys.indexes i
LEFT JOIN sys.dm_db_index_usage_stats u
    ON i.object_id = u.object_id AND i.index_id = u.index_id;
```

### Index Creation Strategies

```sql
-- 1. Index foreign keys (always!)
CREATE INDEX idx_employee_dept ON employees (department_id);
CREATE INDEX idx_order_customer ON orders (customer_id);

-- 2. Index WHERE clause columns
CREATE INDEX idx_emp_salary_dept ON employees (salary, department_id);

-- 3. Index JOIN columns
CREATE INDEX idx_dept_mgr ON departments (manager_id);

-- 4. Composite indexes for multiple conditions
CREATE INDEX idx_orders_cust_date ON orders (customer_id, order_date);

-- 5. Partial indexes for selective data
CREATE INDEX idx_high_salary ON employees (salary) WHERE salary > 100000;

-- 6. Covering indexes (include all needed columns)
CREATE INDEX idx_order_summary ON orders (customer_id, order_date, total_amount);

-- 7. Function-based indexes
CREATE INDEX idx_upper_name ON employees (UPPER(last_name));
```

### Index Maintenance

```sql
-- Rebuild fragmented indexes
ALTER INDEX idx_orders_customer_date ON orders REBUILD;

-- Reorganize less fragmented indexes
ALTER INDEX idx_orders_customer_date ON orders REORGANIZE;

-- Update statistics
UPDATE STATISTICS orders;

-- MySQL specific
ANALYZE TABLE orders;

-- PostgreSQL reindex
REINDEX INDEX idx_orders_customer_date;

-- Drop unused indexes
DROP INDEX idx_old_unused_index ON table_name;
```

---

## 🔧 Query Optimization Techniques

### SELECT Statement Optimization

```sql
-- AVOID: Select all columns
SELECT * FROM employees;  -- Bad: Retrieves unnecessary data

-- BETTER: Select specific columns
SELECT employee_id, first_name, last_name FROM employees;  -- Good

-- AVOID: Functions on indexed columns
SELECT * FROM employees WHERE YEAR(hire_date) = 2024;  -- Bad: Can't use index

-- BETTER: Use range conditions
SELECT * FROM employees WHERE hire_date >= '2024-01-01' AND hire_date < '2025-01-01';

-- AVOID: Negative conditions
SELECT * FROM employees WHERE department != 'IT';  -- Bad: Can't use index efficiently

-- BETTER: Use positive conditions
SELECT * FROM employees WHERE department IN ('HR', 'Finance', 'Sales');
```

### JOIN Optimization

```sql
-- AVOID: Cartesian products
SELECT * FROM employees, departments;  -- Bad: Creates huge result set

-- BETTER: Explicit JOINs
SELECT e.name, d.dept_name
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id;

-- AVOID: JOIN order doesn't matter (myth!)
-- Optimizer chooses order, but you can influence with hints

-- BETTER: Use appropriate JOIN types
-- INNER JOIN for matching rows
-- LEFT JOIN for optional relationships
-- EXISTS for existence checks
```

### Subquery vs JOIN Performance

```sql
-- AVOID: Inefficient subqueries
SELECT * FROM employees e
WHERE salary > (SELECT AVG(salary) FROM employees);  -- Executes for each row

-- BETTER: Use JOIN or window functions
SELECT e.* FROM employees e
JOIN (SELECT AVG(salary) as avg_sal FROM employees) avg_table
ON e.salary > avg_table.avg_sal;

-- EVEN BETTER: Use window functions
SELECT * FROM (
    SELECT *, AVG(salary) OVER () as company_avg
    FROM employees
) t WHERE salary > company_avg;
```

---

## 📈 Advanced Optimization Techniques

### Query Rewriting

```sql
-- Original slow query
SELECT * FROM orders o
WHERE EXISTS (
    SELECT 1 FROM customers c
    WHERE c.customer_id = o.customer_id
    AND c.region = 'North'
);

-- Optimized version
SELECT o.* FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
WHERE c.region = 'North';

-- Complex CASE optimization
SELECT
    product_id,
    CASE
        WHEN price > 1000 THEN 'Expensive'
        WHEN price > 100 THEN 'Moderate'
        ELSE 'Cheap'
    END as price_category
FROM products;

-- Optimized with UNION ALL
SELECT product_id, 'Expensive' as price_category
FROM products WHERE price > 1000
UNION ALL
SELECT product_id, 'Moderate' as price_category
FROM products WHERE price BETWEEN 101 AND 1000
UNION ALL
SELECT product_id, 'Cheap' as price_category
FROM products WHERE price <= 100;
```

### Partitioning for Large Tables

```sql
-- Range partitioning
CREATE TABLE sales (
    sale_id INT,
    sale_date DATE,
    customer_id INT,
    amount DECIMAL(10,2)
)
PARTITION BY RANGE (YEAR(sale_date)) (
    PARTITION p2020 VALUES LESS THAN (2021),
    PARTITION p2021 VALUES LESS THAN (2022),
    PARTITION p2022 VALUES LESS THAN (2023),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);

-- List partitioning
CREATE TABLE orders (
    order_id INT,
    customer_id INT,
    region VARCHAR(20),
    order_date DATE
)
PARTITION BY LIST (region) (
    PARTITION p_north VALUES IN ('North', 'Northeast'),
    PARTITION p_south VALUES IN ('South', 'Southeast'),
    PARTITION p_west VALUES IN ('West', 'Southwest'),
    PARTITION p_east VALUES IN ('East', 'Northwest')
);

-- Hash partitioning for even distribution
CREATE TABLE user_sessions (
    session_id INT,
    user_id INT,
    login_time TIMESTAMP,
    logout_time TIMESTAMP
)
PARTITION BY HASH (user_id) PARTITIONS 16;
```

### Materialized Views

```sql
-- MySQL: Simulate with tables and triggers
CREATE TABLE monthly_sales_summary (
    month DATE PRIMARY KEY,
    total_sales DECIMAL(15,2),
    order_count INT,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- PostgreSQL: Native materialized views
CREATE MATERIALIZED VIEW monthly_sales_summary AS
SELECT
    DATE_TRUNC('month', order_date) as month,
    SUM(total_amount) as total_sales,
    COUNT(*) as order_count
FROM orders
GROUP BY DATE_TRUNC('month', order_date);

-- Refresh materialized view
REFRESH MATERIALIZED VIEW monthly_sales_summary;

-- SQL Server: Indexed views
CREATE VIEW sales_summary WITH SCHEMABINDING AS
SELECT
    YEAR(order_date) as order_year,
    MONTH(order_date) as order_month,
    COUNT_BIG(*) as order_count,
    SUM(total_amount) as total_sales
FROM dbo.orders
GROUP BY YEAR(order_date), MONTH(order_date);

-- Create clustered index
CREATE UNIQUE CLUSTERED INDEX idx_sales_summary
ON sales_summary (order_year, order_month);
```

---

## 🔍 Performance Monitoring

### System Performance Metrics

```sql
-- MySQL: Show process list
SHOW PROCESSLIST;

-- MySQL: Global status
SHOW GLOBAL STATUS LIKE 'Queries';
SHOW GLOBAL STATUS LIKE 'Com_select';
SHOW GLOBAL STATUS LIKE 'Innodb_rows_read';

-- PostgreSQL: Active queries
SELECT pid, query, state, waiting, query_start
FROM pg_stat_activity
WHERE state = 'active';

-- SQL Server: Active queries
SELECT r.session_id, r.status, r.command, t.text
FROM sys.dm_exec_requests r
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) t;
```

### Slow Query Log Analysis

```sql
-- MySQL: Enable slow query log
SET GLOBAL slow_query_log = 'ON';
SET GLOBAL long_query_time = 2;  -- Log queries > 2 seconds
SET GLOBAL slow_query_log_file = '/var/log/mysql/mysql-slow.log';

-- PostgreSQL: Log slow queries
ALTER SYSTEM SET log_min_duration_statement = 1000;  -- 1 second
SELECT pg_reload_conf();

-- Analyze slow queries
-- Look for patterns:
-- - Full table scans
-- - Missing indexes
-- - Inefficient JOINs
-- - Complex subqueries
```

### Index Usage Monitoring

```sql
-- Find unused indexes
SELECT
    object_name(i.object_id) as table_name,
    i.name as index_name,
    u.user_seeks,
    u.user_scans,
    u.user_lookups
FROM sys.indexes i
LEFT JOIN sys.dm_db_index_usage_stats u
    ON i.object_id = u.object_id AND i.index_id = u.index_id
WHERE u.user_seeks + u.user_scans + u.user_lookups = 0
    AND i.name IS NOT NULL;

-- Find most used indexes
SELECT
    object_name(i.object_id) as table_name,
    i.name as index_name,
    u.user_seeks + u.user_scans + u.user_lookups as total_usage
FROM sys.indexes i
LEFT JOIN sys.dm_db_index_usage_stats u
    ON i.object_id = u.object_id AND i.index_id = u.index_id
ORDER BY total_usage DESC;
```

---

## 🚀 Database Configuration Tuning

### MySQL Configuration

```ini
# my.cnf optimizations
[mysqld]
# Memory settings
innodb_buffer_pool_size = 2G          # 70-80% of RAM for dedicated DB server
innodb_log_file_size = 256M           # Redo log size
query_cache_size = 256M               # Query cache for repeated queries

# Connection settings
max_connections = 200                 # Maximum concurrent connections
wait_timeout = 28800                  # Connection timeout

# Performance settings
tmp_table_size = 128M                 # Temporary table size
max_heap_table_size = 128M            # Memory table size

# Index settings
innodb_adaptive_hash_index = ON       # Adaptive hash index
```

### PostgreSQL Configuration

```ini
# postgresql.conf optimizations
# Memory settings
shared_buffers = 256MB                # Shared memory buffers
work_mem = 4MB                        # Memory per operation
maintenance_work_mem = 64MB           # Maintenance operations

# Connection settings
max_connections = 100                 # Maximum connections
tcp_keepalives_idle = 60              # TCP keepalive

# Query planning
random_page_cost = 1.1                # SSD optimization
effective_cache_size = 1GB            # OS cache size

# Logging
log_min_duration_statement = 1000     # Log slow queries
```

---

## 🔧 Query Refactoring Techniques

### Complex Query Optimization

```sql
-- Original complex query
SELECT c.customer_name,
       (SELECT COUNT(*) FROM orders o WHERE o.customer_id = c.customer_id) as order_count,
       (SELECT SUM(amount) FROM payments p WHERE p.customer_id = c.customer_id) as total_paid,
       (SELECT MAX(order_date) FROM orders o WHERE o.customer_id = c.customer_id) as last_order
FROM customers c
WHERE c.customer_id IN (
    SELECT customer_id FROM orders
    WHERE order_date >= '2024-01-01'
);

-- Optimized version with JOINs
SELECT c.customer_name,
       COALESCE(o.order_count, 0) as order_count,
       COALESCE(p.total_paid, 0) as total_paid,
       o.last_order
FROM customers c
LEFT JOIN (
    SELECT customer_id, COUNT(*) as order_count, MAX(order_date) as last_order
    FROM orders
    WHERE order_date >= '2024-01-01'
    GROUP BY customer_id
) o ON c.customer_id = o.customer_id
LEFT JOIN (
    SELECT customer_id, SUM(amount) as total_paid
    FROM payments
    GROUP BY customer_id
) p ON c.customer_id = p.customer_id;
```

### Temporary Tables for Complex Calculations

```sql
-- Use temporary tables for multi-step calculations
CREATE TEMPORARY TABLE temp_customer_stats AS
SELECT customer_id,
       COUNT(*) as order_count,
       SUM(total_amount) as total_spent,
       AVG(total_amount) as avg_order_value,
       MAX(order_date) as last_order_date
FROM orders
GROUP BY customer_id;

-- Use the temp table for further analysis
SELECT c.customer_name,
       cs.order_count,
       cs.total_spent,
       cs.avg_order_value,
       DATEDIFF(CURDATE(), cs.last_order_date) as days_since_last_order,
       CASE
           WHEN cs.total_spent > 10000 THEN 'VIP'
           WHEN cs.order_count > 10 THEN 'Regular'
           ELSE 'New'
       END as customer_segment
FROM customers c
LEFT JOIN temp_customer_stats cs ON c.customer_id = cs.customer_id;

-- Clean up
DROP TEMPORARY TABLE temp_customer_stats;
```

---

## 📊 Performance Benchmarking

### Query Performance Testing

```sql
-- MySQL: Profile query execution
SET profiling = 1;
SELECT * FROM large_table WHERE complex_condition;
SHOW PROFILES;

-- PostgreSQL: Explain with timing
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM large_table WHERE complex_condition;

-- Benchmark multiple approaches
DELIMITER //
CREATE PROCEDURE benchmark_queries()
BEGIN
    DECLARE start_time TIMESTAMP;
    DECLARE end_time TIMESTAMP;

    -- Test approach 1
    SET start_time = NOW();
    SELECT COUNT(*) FROM orders o
    WHERE EXISTS (SELECT 1 FROM customers c WHERE c.customer_id = o.customer_id AND c.region = 'North');
    SET end_time = NOW();
    SELECT TIMESTAMPDIFF(MICROSECOND, start_time, end_time) as approach1_time;

    -- Test approach 2
    SET start_time = NOW();
    SELECT COUNT(*) FROM orders o
    INNER JOIN customers c ON o.customer_id = c.customer_id
    WHERE c.region = 'North';
    SET end_time = NOW();
    SELECT TIMESTAMPDIFF(MICROSECOND, start_time, end_time) as approach2_time;
END //
DELIMITER ;
```

---

## 📚 Practice Exercises

### Exercise 1: Index Analysis
Analyze and optimize indexes for:

1. **E-commerce database**: Products, orders, customers tables
2. **Employee management**: Complex reporting queries
3. **Analytics dashboard**: Multiple aggregation queries
4. **Search functionality**: Text-based searches

### Exercise 2: Query Optimization
Rewrite and optimize these queries:

1. **Complex subqueries** → JOINs
2. **Multiple aggregations** → Window functions
3. **Recursive operations** → Iterative approaches
4. **Full table scans** → Indexed queries

### Exercise 3: Performance Monitoring
Set up monitoring for:

1. **Slow query identification** and analysis
2. **Index usage statistics** and recommendations
3. **Memory and CPU utilization** tracking
4. **Connection pool management**

### Exercise 4: Configuration Tuning
Optimize database configuration for:

1. **High-read workload** (reporting, analytics)
2. **High-write workload** (transaction processing)
3. **Mixed workload** (OLTP + OLAP)
4. **Limited resources** (small servers, containers)

---

## 🎯 Chapter Summary

- **Execution Plans**: Analyze query performance with EXPLAIN
- **Index Strategy**: Create appropriate indexes for query patterns
- **Query Rewriting**: Optimize SQL for better performance
- **Configuration Tuning**: Adjust database settings for workload
- **Monitoring**: Track performance metrics and slow queries
- **Partitioning**: Split large tables for better performance
- **Materialized Views**: Pre-compute expensive calculations

### Performance Tuning Checklist:
- [ ] Analyze execution plans for slow queries
- [ ] Create indexes on WHERE, JOIN, and ORDER BY columns
- [ ] Rewrite subqueries as JOINs where appropriate
- [ ] Use appropriate data types and sizes
- [ ] Partition large tables
- [ ] Monitor and tune database configuration
- [ ] Regularly update statistics
- [ ] Remove unused indexes

---

## 🚀 Next Steps
- Master **advanced SQL techniques** like pivoting and dynamic SQL
- Learn **database administration** and maintenance
- Explore **NoSQL databases** for specific use cases
- Study **distributed systems** and scalability
- Practice **real-world performance tuning** scenarios
