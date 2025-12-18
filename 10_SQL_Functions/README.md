# 🔧 Chapter 10: SQL Functions - Data Transformation & Manipulation

## 🎯 Why Functions Matter?

**SQL functions** transform and manipulate data during query execution. They enable:
- **Data formatting** and **cleaning**
- **Calculations** and **computations**
- **String manipulation** and **text processing**
- **Date/time operations** and **calculations**
- **NULL value handling**
- **Conditional logic** and **decision making**

---

## 📝 String Functions

### Case Conversion

```sql
-- Convert to uppercase
SELECT UPPER('hello world') as upper_case;  -- 'HELLO WORLD'

-- Convert to lowercase
SELECT LOWER('HELLO WORLD') as lower_case;  -- 'hello world'

-- Capitalize first letter
SELECT CONCAT(UPPER(LEFT(first_name, 1)), LOWER(SUBSTRING(first_name, 2)))
FROM employees;

-- Real example
SELECT first_name, last_name,
       CONCAT(UPPER(LEFT(first_name, 1)), LOWER(SUBSTRING(first_name, 2)), ' ',
              UPPER(LEFT(last_name, 1)), LOWER(SUBSTRING(last_name, 2))) as proper_name
FROM employees;
```

### String Length and Position

```sql
-- Get string length
SELECT LENGTH('Hello') as str_length;  -- 5
SELECT CHAR_LENGTH('Hello') as char_length;  -- 5

-- Find position of substring
SELECT POSITION('world' IN 'hello world') as position;  -- 7
SELECT LOCATE('world', 'hello world') as location;  -- 7

-- Find position from specific location
SELECT LOCATE('l', 'hello world', 4) as position_from_4;  -- 4 (finds 'l' in 'lo w...')
```

### Substring Operations

```sql
-- Extract substring
SELECT SUBSTRING('hello world', 7, 5) as substring;  -- 'world'
SELECT SUBSTR('hello world', 7) as from_position;  -- 'world'
SELECT LEFT('hello world', 5) as left_part;  -- 'hello'
SELECT RIGHT('hello world', 5) as right_part;  -- 'world'

-- Extract parts of names
SELECT first_name,
       LEFT(first_name, 3) as first_3_chars,
       SUBSTRING(last_name, -3) as last_3_chars
FROM employees;
```

### String Replacement and Trimming

```sql
-- Replace text
SELECT REPLACE('hello world', 'world', 'universe') as replaced;  -- 'hello universe'

-- Remove spaces
SELECT TRIM('  hello world  ') as trimmed;  -- 'hello world'
SELECT LTRIM('  hello') as left_trim;  -- 'hello'
SELECT RTRIM('hello  ') as right_trim;  -- 'hello'

-- Replace multiple spaces with single space
SELECT REPLACE(REPLACE(REPLACE(address, '  ', ' '), '  ', ' '), '  ', ' ') as clean_address
FROM customers;
```

### String Concatenation

```sql
-- Basic concatenation
SELECT CONCAT('Hello', ' ', 'World') as greeting;  -- 'Hello World'

-- Concatenate columns
SELECT CONCAT(first_name, ' ', last_name) as full_name FROM employees;

-- Concatenate with separators
SELECT CONCAT_WS(', ', city, state, country) as location FROM addresses;

-- Handle NULL values in concatenation
SELECT CONCAT(COALESCE(first_name, ''), ' ', COALESCE(last_name, '')) as full_name
FROM employees;
```

---

## 📅 Date and Time Functions

### Current Date/Time

```sql
-- Current date and time
SELECT CURDATE() as current_date;        -- 2024-01-15
SELECT NOW() as current_datetime;        -- 2024-01-15 14:30:45
SELECT CURTIME() as current_time;        -- 14:30:45

-- Current date/time components
SELECT YEAR(NOW()) as current_year;      -- 2024
SELECT MONTH(NOW()) as current_month;    -- 1
SELECT DAY(NOW()) as current_day;        -- 15
SELECT HOUR(NOW()) as current_hour;      -- 14
SELECT MINUTE(NOW()) as current_minute;  -- 30
SELECT SECOND(NOW()) as current_second;  -- 45
```

### Date Formatting

```sql
-- Format dates (MySQL)
SELECT DATE_FORMAT(hire_date, '%M %d, %Y') as formatted_date FROM employees;
-- January 15, 2024

SELECT DATE_FORMAT(NOW(), '%W, %M %e, %Y') as full_date;
-- Monday, January 15, 2024

-- Common format codes:
-- %Y - Year (2024)
-- %y - Year (24)
-- %M - Month name (January)
-- %m - Month number (01)
-- %D - Day with suffix (15th)
-- %d - Day (15)
-- %W - Weekday name (Monday)
-- %w - Weekday number (0=Sunday)
-- %H - Hour (24-hour)
-- %h - Hour (12-hour)
-- %i - Minutes
-- %s - Seconds
```

### Date Calculations

```sql
-- Add/subtract days
SELECT DATE_ADD(hire_date, INTERVAL 30 DAY) as review_date FROM employees;
SELECT DATE_SUB(NOW(), INTERVAL 1 YEAR) as one_year_ago;

-- Add/subtract months/years
SELECT DATE_ADD(hire_date, INTERVAL 6 MONTH) as six_months_later FROM employees;
SELECT DATE_SUB(birth_date, INTERVAL 18 YEAR) as adult_date FROM users;

-- Date differences
SELECT DATEDIFF(CURDATE(), hire_date) as days_employed FROM employees;
SELECT TIMESTAMPDIFF(YEAR, birth_date, CURDATE()) as age FROM users;
SELECT TIMESTAMPDIFF(MONTH, hire_date, CURDATE()) as months_employed FROM employees;

-- Day of week/month
SELECT DAYOFWEEK(hire_date) as day_of_week FROM employees;  -- 1=Sunday, 2=Monday
SELECT DAYOFMONTH(hire_date) as day_of_month FROM employees;
SELECT DAYOFYEAR(hire_date) as day_of_year FROM employees;
```

### Date Validation and Extraction

```sql
-- Check if date is valid
SELECT hire_date FROM employees
WHERE hire_date IS NOT NULL
AND hire_date >= '2000-01-01'
AND hire_date <= CURDATE();

-- Extract date parts for grouping
SELECT
    YEAR(order_date) as order_year,
    MONTH(order_date) as order_month,
    COUNT(*) as monthly_orders
FROM orders
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY order_year, order_month;

-- Find records from last 30 days
SELECT * FROM orders
WHERE order_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY);
```

---

## 🔢 Numeric Functions

### Mathematical Functions

```sql
-- Basic math
SELECT ABS(-5) as absolute;           -- 5
SELECT ROUND(3.14159, 2) as rounded;  -- 3.14
SELECT CEIL(3.1) as ceiling;          -- 4
SELECT FLOOR(3.9) as floor_val;       -- 3
SELECT POWER(2, 3) as power_val;      -- 8
SELECT SQRT(16) as square_root;       -- 4

-- Salary calculations
SELECT first_name, salary,
       ROUND(salary * 1.05, 2) as five_percent_raise,
       CEIL(salary / 1000) * 1000 as next_thousand
FROM employees;
```

### Random Numbers and Statistics

```sql
-- Random values
SELECT RAND() as random_number;  -- Between 0 and 1

-- Random records
SELECT * FROM employees
ORDER BY RAND()
LIMIT 5;

-- Statistical functions
SELECT GREATEST(10, 20, 30) as greatest_val;  -- 30
SELECT LEAST(10, 20, 30) as least_val;       -- 10

-- Safe division (avoid divide by zero)
SELECT sales_amount / NULLIF(total_sales, 0) as sales_ratio FROM products;
```

---

## 🔍 NULL Handling Functions

### COALESCE and ISNULL

```sql
-- Replace NULL with default value
SELECT COALESCE(phone, 'Not provided') as contact_phone FROM customers;
SELECT COALESCE(middle_name, '') as middle_name FROM employees;

-- Multiple fallbacks
SELECT COALESCE(phone1, phone2, phone3, 'No phone') as primary_phone FROM contacts;

-- Safe calculations with NULL
SELECT first_name, salary,
       COALESCE(bonus, 0) as bonus,
       salary + COALESCE(bonus, 0) as total_compensation
FROM employees;
```

### NULLIF

```sql
-- Return NULL if values are equal
SELECT NULLIF(salary, 0) as valid_salary FROM employees;

-- Avoid division by zero
SELECT sales / NULLIF(total_sales, 0) as conversion_rate FROM campaigns;

-- Compare values safely
SELECT CASE
    WHEN NULLIF(new_price, old_price) IS NOT NULL THEN 'Price changed'
    ELSE 'Price unchanged'
END as price_status FROM products;
```

### IFNULL (MySQL specific)

```sql
-- MySQL NULL handling
SELECT IFNULL(phone, 'N/A') as contact_info FROM customers;
SELECT IFNULL(commission, 0) + salary as total_pay FROM salespeople;
```

---

## 🎯 Conditional Functions

### CASE Statements

```sql
-- Simple CASE
SELECT product_name,
       CASE category
           WHEN 'Electronics' THEN '📱'
           WHEN 'Clothing' THEN '👕'
           WHEN 'Books' THEN '📚'
           ELSE '❓'
       END as category_icon
FROM products;

-- Searched CASE
SELECT employee_name, salary,
       CASE
           WHEN salary >= 80000 THEN 'Senior'
           WHEN salary >= 60000 THEN 'Mid-level'
           WHEN salary >= 40000 THEN 'Junior'
           ELSE 'Entry-level'
       END as level
FROM employees;

-- CASE in calculations
SELECT order_id, total_amount,
       CASE
           WHEN total_amount > 1000 THEN total_amount * 0.9
           WHEN total_amount > 500 THEN total_amount * 0.95
           ELSE total_amount
       END as discounted_amount
FROM orders;
```

### IF Function (MySQL)

```sql
-- Simple IF
SELECT product_name,
       IF(stock_quantity > 10, 'In Stock', 'Low Stock') as stock_status
FROM products;

-- Nested IF
SELECT salary,
       IF(salary > 70000, 'High',
          IF(salary > 50000, 'Medium', 'Low')) as salary_category
FROM employees;
```

---

## 🔧 Advanced String Functions

### Regular Expressions

```sql
-- MySQL regex
SELECT * FROM customers
WHERE email REGEXP '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';

-- PostgreSQL regex
SELECT * FROM customers
WHERE email ~ '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';

-- Extract domain from email
SELECT email,
       SUBSTRING_INDEX(SUBSTRING_INDEX(email, '@', -1), '.', 1) as domain
FROM customers;
```

### String Aggregation

```sql
-- MySQL: GROUP_CONCAT
SELECT department,
       GROUP_CONCAT(employee_name ORDER BY employee_name SEPARATOR ', ') as employees
FROM employees
GROUP BY department;

-- PostgreSQL: STRING_AGG
SELECT department,
       STRING_AGG(employee_name, ', ' ORDER BY employee_name) as employees
FROM employees
GROUP BY department;
```

---

## 📊 Real-World Function Examples

### Customer Data Cleaning

```sql
-- Clean and standardize customer data
SELECT
    customer_id,
    TRIM(UPPER(first_name)) as clean_first_name,
    TRIM(UPPER(last_name)) as clean_last_name,
    LOWER(TRIM(email)) as clean_email,
    CONCAT(
        UPPER(LEFT(TRIM(first_name), 1)),
        LOWER(SUBSTRING(TRIM(first_name), 2)),
        ' ',
        UPPER(LEFT(TRIM(last_name), 1)),
        LOWER(SUBSTRING(TRIM(last_name), 2))
    ) as full_name_proper,
    CASE
        WHEN LENGTH(TRIM(COALESCE(phone, ''))) < 10 THEN NULL
        ELSE TRIM(REPLACE(REPLACE(REPLACE(phone, '(', ''), ')', ''), '-', ''))
    END as clean_phone
FROM raw_customers;
```

### Sales Analytics

```sql
-- Monthly sales report with formatting
SELECT
    DATE_FORMAT(order_date, '%Y-%m') as month,
    CONCAT('$', FORMAT(SUM(total_amount), 2)) as total_sales,
    CONCAT(FORMAT(AVG(total_amount), 2)) as avg_order_value,
    COUNT(*) as order_count,
    CONCAT(
        ROUND(
            (COUNT(*) - LAG(COUNT(*)) OVER (ORDER BY DATE_FORMAT(order_date, '%Y-%m'))) /
            NULLIF(LAG(COUNT(*)) OVER (ORDER BY DATE_FORMAT(order_date, '%Y-%m')), 0) * 100,
        1), '%'
    ) as monthly_growth
FROM orders
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY month;
```

### Employee Report Generation

```sql
-- Comprehensive employee report
SELECT
    employee_id,
    CONCAT(first_name, ' ', COALESCE(middle_name, ''), ' ', last_name) as full_name,
    DATE_FORMAT(hire_date, '%M %d, %Y') as hire_date_formatted,
    CONCAT('$', FORMAT(salary, 0)) as salary_formatted,
    TIMESTAMPDIFF(YEAR, hire_date, CURDATE()) as years_of_service,
    CASE
        WHEN TIMESTAMPDIFF(YEAR, hire_date, CURDATE()) >= 10 THEN '🏆 Veteran'
        WHEN TIMESTAMPDIFF(YEAR, hire_date, CURDATE()) >= 5 THEN '⭐ Senior'
        WHEN TIMESTAMPDIFF(YEAR, hire_date, CURDATE()) >= 2 THEN '🟢 Experienced'
        ELSE '🟡 New'
    END as experience_level,
    COALESCE(department, 'Unassigned') as department,
    CASE
        WHEN salary > (SELECT AVG(salary) FROM employees) THEN 'Above Average'
        WHEN salary = (SELECT AVG(salary) FROM employees) THEN 'Average'
        ELSE 'Below Average'
    END as salary_comparison
FROM employees
ORDER BY hire_date;
```

---

## 🚀 Performance Considerations

### 1. Function Performance Impact

```sql
-- Avoid functions on indexed columns in WHERE
-- Bad: Function prevents index usage
SELECT * FROM employees WHERE YEAR(hire_date) = 2024;

-- Good: Use range comparison
SELECT * FROM employees WHERE hire_date >= '2024-01-01' AND hire_date < '2025-01-01';

-- Bad: Function in JOIN condition
SELECT * FROM employees e
JOIN departments d ON UPPER(e.department) = d.name;

-- Good: Store clean data or use computed columns
ALTER TABLE employees ADD COLUMN department_clean VARCHAR(50) GENERATED ALWAYS AS (UPPER(department));
```

### 2. Efficient String Operations

```sql
-- Use appropriate string functions
-- LEFT/RIGHT for fixed positions
-- SUBSTRING for variable positions
-- LOCATE/POSITION for finding substrings

-- Cache computed values
CREATE TABLE employee_search AS
SELECT employee_id,
       LOWER(CONCAT(first_name, ' ', last_name)) as search_name,
       SOUNDEX(CONCAT(first_name, ' ', last_name)) as soundex_name
FROM employees;
```

---

## 📚 Practice Exercises

### Exercise 1: Data Cleaning
Create queries to:
1. Clean and standardize customer names
2. Format phone numbers consistently
3. Validate email addresses
4. Remove extra spaces and special characters
5. Standardize address formats

### Exercise 2: Date Analytics
Write functions for:
1. Calculate age from birth dates
2. Find business days between dates
3. Generate monthly calendars
4. Calculate tenure and anniversaries
5. Find seasonal patterns

### Exercise 3: String Manipulation
Design queries for:
1. Extract domain names from emails
2. Generate usernames from names
3. Format currency values
4. Create search-friendly text
5. Generate slugs for URLs

---

## 🎯 Chapter Summary

- **String functions** manipulate text data (UPPER, LOWER, CONCAT, SUBSTRING)
- **Date functions** handle temporal data (NOW, DATE_FORMAT, DATEDIFF)
- **Numeric functions** perform calculations (ROUND, ABS, POWER)
- **NULL functions** handle missing data (COALESCE, NULLIF)
- **CASE statements** provide conditional logic
- Functions can impact performance - use wisely
- Combine functions for complex data transformations
- Always consider data quality and consistency

---

## 🚀 Next Steps
- Master **constraints** for data integrity
- Learn **views, indexes, and triggers**
- Understand **stored procedures** and **functions**
- Practice **transaction management**
- Build **complete real-world applications**
