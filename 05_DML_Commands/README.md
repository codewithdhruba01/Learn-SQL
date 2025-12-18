# 📝 Chapter 5: DML Commands - Data Manipulation Language

## 🎯 What is DML?

**DML (Data Manipulation Language)** consists of SQL commands used to **manipulate data** within database tables. DML commands:

- **INSERT**: Add new records
- **UPDATE**: Modify existing records
- **DELETE**: Remove records
- **SELECT**: Query/retrieve data (covered in next chapter)

DML operations can be **rolled back** using transactions.

---

## ➕ INSERT Command

### Basic INSERT Syntax

```sql
-- Single row insert
INSERT INTO table_name (column1, column2, ...)
VALUES (value1, value2, ...);

-- Multiple rows insert
INSERT INTO table_name (column1, column2, ...)
VALUES (value1, value2, ...),
       (value3, value4, ...),
       (value5, value6, ...);
```

### Complete INSERT Examples

```sql
-- Create sample table
CREATE TABLE employees (
    employee_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(255) UNIQUE,
    salary DECIMAL(10,2),
    department VARCHAR(50),
    hire_date DATE,
    is_active BOOLEAN DEFAULT TRUE
);

-- Single employee insert
INSERT INTO employees (first_name, last_name, email, salary, department, hire_date)
VALUES ('Rahul', 'Sharma', 'rahul.sharma@company.com', 75000.00, 'IT', '2023-01-15');

-- Multiple employees insert
INSERT INTO employees (first_name, last_name, email, salary, department, hire_date)
VALUES
    ('Priya', 'Patel', 'priya.patel@company.com', 65000.00, 'HR', '2023-02-01'),
    ('Amit', 'Kumar', 'amit.kumar@company.com', 70000.00, 'Finance', '2023-01-20'),
    ('Sneha', 'Singh', 'sneha.singh@company.com', 55000.00, 'Marketing', '2023-03-10');
```

### INSERT with Default Values

```sql
-- Insert with some default values
INSERT INTO employees (first_name, last_name, email, department)
VALUES ('Vikram', 'Gupta', 'vikram.gupta@company.com', 'IT');
-- salary, hire_date, is_active will use defaults

-- Insert all columns (not recommended)
INSERT INTO employees
VALUES (6, 'Anjali', 'Verma', 'anjali.verma@company.com', 60000.00, 'Sales', '2023-04-01', TRUE);
```

### INSERT with SELECT (Copy Data)

```sql
-- Create backup table
CREATE TABLE employees_backup AS
SELECT * FROM employees WHERE 1=0; -- Copy structure only

-- Copy data from one table to another
INSERT INTO employees_backup
SELECT * FROM employees WHERE department = 'IT';

-- Insert with calculations
INSERT INTO employee_salary_history (employee_id, salary, effective_date)
SELECT employee_id, salary * 1.1, CURDATE()
FROM employees
WHERE department = 'IT';
```

### INSERT with ON DUPLICATE KEY UPDATE

```sql
-- MySQL: Upsert operation
INSERT INTO employees (employee_id, first_name, last_name, email, salary)
VALUES (1, 'Rahul', 'Sharma', 'rahul.sharma@company.com', 80000.00)
ON DUPLICATE KEY UPDATE
    salary = VALUES(salary),
    updated_at = NOW();
```

---

## 🔄 UPDATE Command

### Basic UPDATE Syntax

```sql
UPDATE table_name
SET column1 = value1, column2 = value2, ...
WHERE condition;
```

### UPDATE Examples

```sql
-- Update single column
UPDATE employees
SET salary = 80000.00
WHERE employee_id = 1;

-- Update multiple columns
UPDATE employees
SET salary = salary * 1.05,
    department = 'Senior IT'
WHERE employee_id = 1;

-- Update with CASE statement
UPDATE employees
SET department = CASE
    WHEN salary > 80000 THEN 'Senior Management'
    WHEN salary > 60000 THEN 'Management'
    ELSE 'Staff'
END;

-- Update with JOIN (MySQL/PostgreSQL)
UPDATE employees e
JOIN departments d ON e.department = d.name
SET e.department_id = d.id;
```

### Safe UPDATE Practices

```sql
-- Always use WHERE clause to avoid updating all records
-- Bad: Updates all employees!
UPDATE employees SET salary = 100000;

-- Good: Update specific employees
UPDATE employees SET salary = 100000 WHERE employee_id = 1;

-- Even better: Use transactions for safety
BEGIN;
UPDATE employees SET salary = salary * 1.1 WHERE department = 'IT';
-- Check results before committing
COMMIT;
```

### UPDATE with Subqueries

```sql
-- Update based on another table
UPDATE employees
SET salary = (SELECT AVG(salary) FROM employees WHERE department = 'IT')
WHERE department = 'HR';

-- Update with correlated subquery
UPDATE employees e
SET bonus = (SELECT SUM(amount) FROM bonuses b WHERE b.employee_id = e.employee_id);
```

---

## 🗑️ DELETE Command

### Basic DELETE Syntax

```sql
DELETE FROM table_name WHERE condition;
```

### DELETE Examples

```sql
-- Delete specific record
DELETE FROM employees WHERE employee_id = 1;

-- Delete multiple records
DELETE FROM employees WHERE department = 'Temp' AND hire_date < '2023-01-01';

-- Delete with subquery
DELETE FROM employees
WHERE employee_id IN (
    SELECT employee_id FROM inactive_employees
);

-- Delete all records (be careful!)
DELETE FROM employees; -- Dangerous!

-- Safe way to delete all records
TRUNCATE TABLE employees; -- Faster, cannot be rolled back
```

### DELETE vs TRUNCATE

| Feature | DELETE | TRUNCATE |
|---------|--------|----------|
| **Rollback** | Can be rolled back | Cannot be rolled back |
| **WHERE clause** | Supported | Not supported |
| **Triggers** | Fired | Not fired |
| **Performance** | Slower for large tables | Faster |
| **Identity reset** | No | Yes (auto-increment) |

---

## 🔄 Advanced DML Scenarios

### Handling Large Data Operations

```sql
-- Process data in batches to avoid locks
DECLARE @batch_size INT = 1000;
DECLARE @processed INT = 0;

WHILE @processed < (SELECT COUNT(*) FROM large_table WHERE status = 'pending')
BEGIN
    UPDATE TOP (@batch_size) large_table
    SET status = 'processed', processed_at = GETDATE()
    WHERE status = 'pending';

    SET @processed = @processed + @batch_size;

    -- Add delay to reduce load
    WAITFOR DELAY '00:00:01';
END
```

### UPSERT Operations (INSERT OR UPDATE)

```sql
-- MySQL approach
INSERT INTO user_stats (user_id, login_count, last_login)
VALUES (1, 1, NOW())
ON DUPLICATE KEY UPDATE
    login_count = login_count + 1,
    last_login = NOW();

-- PostgreSQL approach
INSERT INTO user_stats (user_id, login_count, last_login)
VALUES (1, 1, NOW())
ON CONFLICT (user_id)
DO UPDATE SET
    login_count = user_stats.login_count + 1,
    last_login = NOW();

-- SQL Server approach
MERGE user_stats AS target
USING (VALUES (1, 1, GETDATE())) AS source (user_id, login_count, last_login)
ON target.user_id = source.user_id
WHEN MATCHED THEN
    UPDATE SET
        login_count = target.login_count + 1,
        last_login = source.last_login
WHEN NOT MATCHED THEN
    INSERT (user_id, login_count, last_login)
    VALUES (source.user_id, source.login_count, source.last_login);
```

---

## 🔒 Transaction Management with DML

### ACID Properties in DML Operations

```sql
-- Complete transaction example
BEGIN;

-- Insert new department
INSERT INTO departments (name, budget) VALUES ('Data Science', 500000);

-- Get the new department ID
SET @dept_id = LAST_INSERT_ID();

-- Insert employees for the new department
INSERT INTO employees (first_name, last_name, department_id, salary)
VALUES
    ('Alice', 'Johnson', @dept_id, 85000),
    ('Bob', 'Smith', @dept_id, 80000);

-- Update department budget based on salaries
UPDATE departments
SET budget = budget - (SELECT SUM(salary) FROM employees WHERE department_id = @dept_id)
WHERE department_id = @dept_id;

-- Check if everything is correct
SELECT * FROM departments WHERE department_id = @dept_id;
SELECT * FROM employees WHERE department_id = @dept_id;

COMMIT; -- Or ROLLBACK if something is wrong
```

### Error Handling

```sql
-- MySQL stored procedure with error handling
DELIMITER //

CREATE PROCEDURE safe_salary_update(IN emp_id INT, IN new_salary DECIMAL(10,2))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Error occurred. Transaction rolled back.' AS message;
    END;

    START TRANSACTION;

    -- Check if employee exists
    IF NOT EXISTS (SELECT 1 FROM employees WHERE employee_id = emp_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Employee not found';
    END IF;

    -- Update salary
    UPDATE employees SET salary = new_salary WHERE employee_id = emp_id;

    -- Log the change
    INSERT INTO salary_history (employee_id, old_salary, new_salary, changed_at)
    SELECT emp_id, salary, new_salary, NOW() FROM employees WHERE employee_id = emp_id;

    COMMIT;
    SELECT 'Salary updated successfully' AS message;
END //

DELIMITER ;
```

---

## 📊 Bulk Data Operations

### Bulk INSERT from CSV/File

```sql
-- MySQL LOAD DATA
LOAD DATA INFILE '/path/to/employees.csv'
INTO TABLE employees
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS -- Skip header
(first_name, last_name, email, salary, department, @hire_date)
SET hire_date = STR_TO_DATE(@hire_date, '%Y-%m-%d');

-- PostgreSQL COPY
COPY employees (first_name, last_name, email, salary, department, hire_date)
FROM '/path/to/employees.csv'
WITH CSV HEADER;

-- SQL Server BULK INSERT
BULK INSERT employees
FROM 'C:\data\employees.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2 -- Skip header
);
```

### Efficient Bulk Updates

```sql
-- Update multiple records efficiently
UPDATE employees
SET department = 'IT'
WHERE employee_id IN (1, 3, 5, 7, 9);

-- Update based on another table
UPDATE e
SET e.salary = e.salary * 1.1
FROM employees e
INNER JOIN promotions p ON e.employee_id = p.employee_id
WHERE p.promotion_date >= '2024-01-01';
```

---

## 📋 DML Best Practices

### 1. Always Use Transactions for Related Operations

```sql
-- Good: Use transactions
BEGIN;
INSERT INTO orders (customer_id, total) VALUES (1, 100.00);
UPDATE inventory SET stock = stock - 1 WHERE product_id = 1;
COMMIT;

-- Avoid: Separate operations
INSERT INTO orders (customer_id, total) VALUES (1, 100.00);
UPDATE inventory SET stock = stock - 1 WHERE product_id = 1;
```

### 2. Validate Data Before Operations

```sql
-- Check constraints before insert
IF NOT EXISTS (SELECT 1 FROM departments WHERE name = 'New Dept') THEN
    INSERT INTO departments (name) VALUES ('New Dept');
END IF;

-- Validate foreign keys
INSERT INTO employees (first_name, last_name, department_id)
SELECT 'John', 'Doe', d.id
FROM departments d
WHERE d.name = 'IT';
```

### 3. Use Proper WHERE Clauses

```sql
-- Good: Specific conditions
DELETE FROM logs WHERE created_at < DATE_SUB(NOW(), INTERVAL 1 YEAR);

-- Bad: No conditions (deletes everything!)
DELETE FROM logs;
```

### 4. Consider Performance Impact

```sql
-- Good: Use indexes for updates
UPDATE employees SET status = 'active' WHERE department = 'IT';

-- Add index if needed
CREATE INDEX idx_dept_status ON employees (department, status);
```

---

## 🛠️ Practical Examples

### Complete E-commerce Order Processing

```sql
-- Sample tables
CREATE TABLE products (id INT PRIMARY KEY, name VARCHAR(100), stock INT, price DECIMAL(10,2));
CREATE TABLE orders (id INT PRIMARY KEY AUTO_INCREMENT, customer_id INT, total DECIMAL(10,2));
CREATE TABLE order_items (order_id INT, product_id INT, quantity INT, price DECIMAL(10,2));

DELIMITER //

CREATE PROCEDURE place_order(
    IN customer_id INT,
    IN product_list JSON -- [{"product_id": 1, "quantity": 2}, ...]
)
BEGIN
    DECLARE order_id INT;
    DECLARE total DECIMAL(10,2) DEFAULT 0;
    DECLARE i INT DEFAULT 0;
    DECLARE product_data JSON;

    -- Start transaction
    START TRANSACTION;

    -- Create order
    INSERT INTO orders (customer_id, order_date) VALUES (customer_id, NOW());
    SET order_id = LAST_INSERT_ID();

    -- Process each product
    WHILE i < JSON_LENGTH(product_list) DO
        SET product_data = JSON_EXTRACT(product_list, CONCAT('$[', i, ']'));
        SET @prod_id = JSON_EXTRACT(product_data, '$.product_id');
        SET @qty = JSON_EXTRACT(product_data, '$.quantity');

        -- Check stock
        IF (SELECT stock FROM products WHERE id = @prod_id) < @qty THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient stock';
        END IF;

        -- Add order item
        INSERT INTO order_items (order_id, product_id, quantity, price)
        SELECT order_id, @prod_id, @qty, price FROM products WHERE id = @prod_id;

        -- Update stock
        UPDATE products SET stock = stock - @qty WHERE id = @prod_id;

        -- Calculate total
        SET total = total + (@qty * (SELECT price FROM products WHERE id = @prod_id));

        SET i = i + 1;
    END WHILE;

    -- Update order total
    UPDATE orders SET total = total WHERE id = order_id;

    COMMIT;
    SELECT CONCAT('Order placed successfully. Order ID: ', order_id) AS message;

EXCEPTION:
    ROLLBACK;
    SELECT 'Order failed. Transaction rolled back.' AS message;
END //

DELIMITER ;
```

---

## 📚 Practice Exercises

### Exercise 1: Employee Management System
Create DML operations for:
1. Insert new employees with validation
2. Update employee salaries with approval workflow
3. Transfer employees between departments
4. Deactivate employees (soft delete)
5. Bulk import employees from temporary table

### Exercise 2: Inventory Management
Implement:
1. Product stock updates when orders are placed
2. Low stock alerts generation
3. Product price updates with history tracking
4. Batch stock adjustments for seasonal changes

### Exercise 3: Data Migration
Write DML scripts to:
1. Migrate data from old schema to new schema
2. Update foreign key references after migration
3. Clean up orphaned records
4. Validate data integrity after migration

---

## 🎯 Chapter Summary

- DML commands manipulate table data
- INSERT adds new records, UPDATE modifies data, DELETE removes records
- Always use transactions for data consistency
- Validate data before operations
- Consider performance impact of bulk operations
- Use proper error handling and rollback mechanisms
- Test operations on development data first

---

## 🚀 Next Steps
- Master **SELECT queries** with complex conditions
- Learn **JOIN operations** for multi-table queries
- Understand **aggregate functions** and **GROUP BY**
- Practice with **real-world scenarios** and **large datasets**
