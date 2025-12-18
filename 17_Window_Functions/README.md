# 📊 Chapter 17: Window Functions - Advanced SQL Analytics

## 🎯 What are Window Functions?

**Window Functions** perform calculations across a set of rows that are related to the current row, without collapsing the result set like aggregate functions do. They provide powerful analytics capabilities while maintaining row-level detail.

---

## 📋 Window Function Syntax

```sql
window_function() OVER (
    [PARTITION BY partition_column]
    [ORDER BY order_column [ASC|DESC]]
    [ROWS|RANGE frame_clause]
)
```

### Key Components:
- **Window Function**: ROW_NUMBER(), RANK(), SUM(), AVG(), etc.
- **PARTITION BY**: Groups rows into partitions
- **ORDER BY**: Orders rows within each partition
- **Frame Clause**: Defines the window frame (ROWS/RANGE)

---

## 🔢 Ranking Functions

### ROW_NUMBER()
Assigns a unique sequential number to each row within a partition.

```sql
-- Basic row numbering
SELECT
    employee_id,
    first_name,
    salary,
    ROW_NUMBER() OVER (ORDER BY salary DESC) as row_num
FROM employees;

-- Row numbering by department
SELECT
    department,
    first_name,
    salary,
    ROW_NUMBER() OVER (PARTITION BY department ORDER BY salary DESC) as dept_row_num
FROM employees;
```

### RANK()
Assigns ranks with gaps for ties.

```sql
-- Rank employees by salary
SELECT
    first_name,
    salary,
    RANK() OVER (ORDER BY salary DESC) as salary_rank
FROM employees;

-- Department-wise ranking
SELECT
    department,
    first_name,
    salary,
    RANK() OVER (PARTITION BY department ORDER BY salary DESC) as dept_rank
FROM employees;
```

### DENSE_RANK()
Assigns ranks without gaps for ties.

```sql
-- Compare RANK vs DENSE_RANK
SELECT
    first_name,
    salary,
    RANK() OVER (ORDER BY salary DESC) as rank_with_gaps,
    DENSE_RANK() OVER (ORDER BY salary DESC) as rank_no_gaps
FROM employees
ORDER BY salary DESC;

-- Example output:
-- Alice: 80000, rank=1, dense_rank=1
-- Bob: 80000, rank=1, dense_rank=1
-- Charlie: 70000, rank=3, dense_rank=2
```

### NTILE(n)
Divides rows into n approximately equal groups.

```sql
-- Divide into quartiles
SELECT
    first_name,
    salary,
    NTILE(4) OVER (ORDER BY salary DESC) as quartile
FROM employees;

-- Performance categories
SELECT
    employee_id,
    first_name,
    performance_score,
    NTILE(3) OVER (ORDER BY performance_score DESC) as performance_tier
FROM employee_performance;
```

---

## 📈 Aggregate Window Functions

### Running Totals with SUM()

```sql
-- Monthly running total
SELECT
    order_date,
    order_amount,
    SUM(order_amount) OVER (ORDER BY order_date) as running_total
FROM orders;

-- Department-wise running totals
SELECT
    department,
    month,
    sales_amount,
    SUM(sales_amount) OVER (PARTITION BY department ORDER BY month) as dept_running_total
FROM monthly_sales;
```

### Moving Averages with AVG()

```sql
-- 3-month moving average
SELECT
    month,
    sales_amount,
    AVG(sales_amount) OVER (ORDER BY month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) as moving_avg_3m
FROM monthly_sales;

-- 7-day moving average
SELECT
    date,
    daily_sales,
    ROUND(AVG(daily_sales) OVER (ORDER BY date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 2) as moving_avg_7d
FROM daily_sales;
```

### Cumulative Calculations

```sql
-- Cumulative percentage
SELECT
    product_name,
    sales_amount,
    SUM(sales_amount) OVER (ORDER BY sales_amount DESC) as cumulative_sales,
    ROUND(100.0 * SUM(sales_amount) OVER (ORDER BY sales_amount DESC) /
          SUM(sales_amount) OVER (), 2) as cumulative_pct
FROM product_sales;
```

---

## 🔄 Value Functions (LAG/LEAD)

### LAG() - Access Previous Row Values

```sql
-- Compare current vs previous month
SELECT
    month,
    sales_amount,
    LAG(sales_amount) OVER (ORDER BY month) as prev_month_sales,
    sales_amount - LAG(sales_amount) OVER (ORDER BY month) as month_over_month_change
FROM monthly_sales;

-- Multiple periods back
SELECT
    month,
    sales_amount,
    LAG(sales_amount, 1) OVER (ORDER BY month) as prev_month,
    LAG(sales_amount, 3) OVER (ORDER BY month) as three_months_ago
FROM monthly_sales;
```

### LEAD() - Access Next Row Values

```sql
-- Compare current vs next month
SELECT
    month,
    sales_amount,
    LEAD(sales_amount) OVER (ORDER BY month) as next_month_sales,
    LEAD(sales_amount, 2) OVER (ORDER BY month) as two_months_ahead
FROM monthly_sales;
```

### FIRST_VALUE() and LAST_VALUE()

```sql
-- Compare to first/last in partition
SELECT
    month,
    sales_amount,
    FIRST_VALUE(sales_amount) OVER (ORDER BY month) as first_month_sales,
    LAST_VALUE(sales_amount) OVER (ORDER BY month ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as last_month_sales
FROM monthly_sales;

-- Department best/worst performers
SELECT
    department,
    employee_name,
    salary,
    FIRST_VALUE(employee_name) OVER (PARTITION BY department ORDER BY salary DESC) as highest_paid,
    LAST_VALUE(employee_name) OVER (PARTITION BY department ORDER BY salary DESC
                                   ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as lowest_paid
FROM employees;
```

---

## 🎯 Frame Clauses (ROWS vs RANGE)

### ROWS Frame

```sql
-- Fixed number of rows before/after current row
SELECT
    date,
    sales,
    SUM(sales) OVER (ORDER BY date ROWS BETWEEN 2 PRECEDING AND 2 FOLLOWING) as rolling_sum_5days
FROM daily_sales;

-- Cumulative from start to current
SELECT
    date,
    sales,
    SUM(sales) OVER (ORDER BY date ROWS UNBOUNDED PRECEDING) as cumulative_sales
FROM daily_sales;
```

### RANGE Frame

```sql
-- Logical window based on values
SELECT
    employee_id,
    salary,
    AVG(salary) OVER (ORDER BY salary RANGE BETWEEN 5000 PRECEDING AND 5000 FOLLOWING) as salary_range_avg
FROM employees;

-- Same salary group
SELECT
    employee_id,
    salary,
    COUNT(*) OVER (ORDER BY salary RANGE BETWEEN 0 PRECEDING AND 0 FOLLOWING) as same_salary_count
FROM employees;
```

### Frame Boundaries

| Boundary | Description | Example |
|----------|-------------|---------|
| `UNBOUNDED PRECEDING` | From partition start | `ROWS UNBOUNDED PRECEDING` |
| `n PRECEDING` | n rows before current | `ROWS 2 PRECEDING` |
| `CURRENT ROW` | Current row | `ROWS CURRENT ROW` |
| `n FOLLOWING` | n rows after current | `ROWS 2 FOLLOWING` |
| `UNBOUNDED FOLLOWING` | To partition end | `ROWS UNBOUNDED FOLLOWING` |

---

## 📊 Advanced Analytics Examples

### Customer Purchase Analysis

```sql
-- Customer lifetime analysis
SELECT
    customer_id,
    order_date,
    order_amount,
    SUM(order_amount) OVER (PARTITION BY customer_id ORDER BY order_date) as lifetime_value,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date) as order_number,
    LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) as prev_order_date,
    DATEDIFF(order_date, LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date)) as days_since_last_order
FROM orders;
```

### Employee Performance Trends

```sql
-- Performance ranking over time
SELECT
    employee_id,
    review_date,
    performance_score,
    RANK() OVER (PARTITION BY review_date ORDER BY performance_score DESC) as period_rank,
    LAG(performance_score) OVER (PARTITION BY employee_id ORDER BY review_date) as prev_score,
    performance_score - LAG(performance_score) OVER (PARTITION BY employee_id ORDER BY review_date) as score_change
FROM performance_reviews;
```

### Product Sales Analysis

```sql
-- Product performance with moving averages
SELECT
    product_id,
    month,
    sales_amount,
    AVG(sales_amount) OVER (PARTITION BY product_id ORDER BY month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) as moving_avg_3m,
    sales_amount - LAG(sales_amount) OVER (PARTITION BY product_id ORDER BY month) as mom_change,
    NTILE(4) OVER (PARTITION BY month ORDER BY sales_amount DESC) as monthly_rank
FROM product_monthly_sales;
```

### Stock Market Analysis

```sql
-- Stock price analysis with technical indicators
SELECT
    date,
    close_price,
    AVG(close_price) OVER (ORDER BY date ROWS BETWEEN 19 PRECEDING AND CURRENT ROW) as sma_20,
    close_price - LAG(close_price) OVER (ORDER BY date) as price_change,
    ROW_NUMBER() OVER (ORDER BY date) as day_number,
    NTILE(5) OVER (ORDER BY close_price) as price_percentile
FROM stock_prices;
```

---

## 🚀 Performance Optimization

### Indexing for Window Functions

```sql
-- Create indexes for window function columns
CREATE INDEX idx_orders_customer_date ON orders (customer_id, order_date);
CREATE INDEX idx_sales_date ON sales (sale_date);
CREATE INDEX idx_employees_dept_salary ON employees (department_id, salary);

-- Composite indexes for complex partitions
CREATE INDEX idx_emp_perf ON employee_performance (employee_id, review_date, performance_score);
```

### Choosing the Right Window Function

```sql
-- Use ROW_NUMBER for unique ranking
SELECT * FROM (
    SELECT *, ROW_NUMBER() OVER (ORDER BY score DESC) as rn
    FROM test_scores
) t WHERE rn <= 10;

-- Use RANK for traditional ranking with gaps
SELECT name, score, RANK() OVER (ORDER BY score DESC) as rank
FROM test_scores;

-- Use DENSE_RANK for ranking without gaps
SELECT category, sales, DENSE_RANK() OVER (ORDER BY sales DESC) as dense_rank
FROM category_sales;
```

### Avoiding Common Mistakes

```sql
-- Wrong: Using aggregate in SELECT with window function
-- This won't work as expected
SELECT department,
       COUNT(*) as dept_count,
       AVG(salary) OVER (PARTITION BY department) as dept_avg
FROM employees
GROUP BY department; -- ERROR: Mixing aggregate and window functions

-- Correct: Use window functions without GROUP BY
SELECT department,
       COUNT(*) OVER (PARTITION BY department) as dept_count,
       AVG(salary) OVER (PARTITION BY department) as dept_avg
FROM employees;
```

---

## 📚 Practice Exercises

### Exercise 1: Basic Window Functions
Create queries for:

1. **Employee Rankings**: Rank employees by salary within departments
2. **Running Totals**: Calculate cumulative sales by month
3. **Moving Averages**: 3-month moving average of product sales
4. **Previous/Next Values**: Compare current vs previous month performance

### Exercise 2: Advanced Analytics
Design analytics for:

1. **Customer Segmentation**: Lifetime value quartiles and purchase frequency
2. **Trend Analysis**: Month-over-month growth with moving averages
3. **Performance Tracking**: Employee ranking changes over time
4. **Market Analysis**: Stock price percentiles and ranking

### Exercise 3: Complex Business Cases
Implement window functions for:

1. **E-commerce**: Product recommendations based on purchase patterns
2. **Finance**: Risk assessment with percentile rankings
3. **HR**: Performance trends and career progression analysis
4. **Retail**: Inventory turnover with ranking and moving averages

---

## 🎯 Chapter Summary

- **Window Functions**: Calculate across related rows without collapsing results
- **Ranking Functions**: ROW_NUMBER(), RANK(), DENSE_RANK(), NTILE()
- **Aggregate Functions**: SUM(), AVG(), COUNT() with OVER clause
- **Value Functions**: LAG(), LEAD(), FIRST_VALUE(), LAST_VALUE()
- **Frame Clauses**: ROWS vs RANGE for defining calculation windows
- **PARTITION BY**: Groups data for separate calculations
- **ORDER BY**: Defines sequence for window calculations

### Key Concepts:
- **Partitioning**: Data grouping for window calculations
- **Framing**: Defining which rows to include in calculations
- **Ranking vs Row Numbering**: Different ranking strategies
- **Running Totals**: Cumulative calculations
- **Moving Calculations**: Rolling averages and sums

---

## 🚀 Next Steps
- Master **Common Table Expressions (CTEs)** for complex queries
- Learn **performance tuning** techniques
- Practice **advanced SQL techniques** like recursion and pivoting
- Build **comprehensive analytics dashboards**
- Explore **real-time analytics** with window functions
