# 🔧 Chapter 14: Stored Procedures - Reusable Database Logic

## 🎯 What are Stored Procedures?

**Stored Procedures** are pre-compiled SQL code stored in the database that can be executed repeatedly. They encapsulate complex business logic, improve performance, and enhance security.

---

## 📋 Basic Stored Procedure Structure

### Creating Stored Procedures

```sql
-- Basic syntax
DELIMITER //
CREATE PROCEDURE procedure_name (
    IN parameter1 datatype,
    OUT parameter2 datatype,
    INOUT parameter3 datatype
)
BEGIN
    -- Procedure body
    -- SQL statements
END //
DELIMITER ;
```

### Simple Examples

```sql
-- Procedure without parameters
DELIMITER //
CREATE PROCEDURE get_all_employees()
BEGIN
    SELECT employee_id, first_name, last_name, department, salary
    FROM employees
    WHERE is_active = TRUE
    ORDER BY last_name, first_name;
END //
DELIMITER ;

-- Call the procedure
CALL get_all_employees();
```

---

## 📥 Parameters in Stored Procedures

### Parameter Types

#### 1. IN Parameters (Input only)

```sql
DELIMITER //
CREATE PROCEDURE get_employee_by_id(IN emp_id INT)
BEGIN
    SELECT * FROM employees WHERE employee_id = emp_id;
END //
DELIMITER ;

-- Usage
CALL get_employee_by_id(123);
```

#### 2. OUT Parameters (Output only)

```sql
DELIMITER //
CREATE PROCEDURE get_employee_count(OUT total_count INT)
BEGIN
    SELECT COUNT(*) INTO total_count FROM employees WHERE is_active = TRUE;
END //
DELIMITER ;

-- Usage
SET @count = 0;
CALL get_employee_count(@count);
SELECT @count as total_employees;
```

#### 3. INOUT Parameters (Input and Output)

```sql
DELIMITER //
CREATE PROCEDURE increment_counter(INOUT counter INT, IN increment_by INT)
BEGIN
    SET counter = counter + increment_by;
END //
DELIMITER ;

-- Usage
SET @my_counter = 5;
CALL increment_counter(@my_counter, 3);
SELECT @my_counter; -- Returns 8
```

---

## 🎯 Advanced Stored Procedure Features

### Variables in Stored Procedures

```sql
DELIMITER //
CREATE PROCEDURE calculate_bonus(IN emp_id INT, OUT bonus_amount DECIMAL(10,2))
BEGIN
    DECLARE base_salary DECIMAL(10,2);
    DECLARE experience_years INT;
    DECLARE bonus_rate DECIMAL(3,2) DEFAULT 0.05;

    -- Get employee data
    SELECT salary, TIMESTAMPDIFF(YEAR, hire_date, CURDATE())
    INTO base_salary, experience_years
    FROM employees
    WHERE employee_id = emp_id;

    -- Calculate bonus based on experience
    IF experience_years > 10 THEN
        SET bonus_rate = 0.15;
    ELSEIF experience_years > 5 THEN
        SET bonus_rate = 0.10;
    ELSE
        SET bonus_rate = 0.05;
    END IF;

    -- Calculate final bonus
    SET bonus_amount = base_salary * bonus_rate;
END //
DELIMITER ;
```

### Control Structures

#### IF-THEN-ELSE

```sql
DELIMITER //
CREATE PROCEDURE process_order(IN order_id INT)
BEGIN
    DECLARE order_status VARCHAR(20);
    DECLARE customer_credit DECIMAL(10,2);

    -- Get order and customer info
    SELECT o.status, c.credit_limit
    INTO order_status, customer_credit
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_id = order_id;

    -- Process based on status
    IF order_status = 'pending' THEN
        -- Approve order
        UPDATE orders SET status = 'approved', approved_at = NOW() WHERE order_id = order_id;
        SELECT 'Order approved successfully' as message;

    ELSEIF order_status = 'approved' THEN
        SELECT 'Order already approved' as message;

    ELSE
        SELECT 'Order cannot be processed' as message;

    END IF;
END //
DELIMITER ;
```

#### CASE Statements

```sql
DELIMITER //
CREATE PROCEDURE categorize_customer(IN customer_id INT)
BEGIN
    DECLARE total_orders INT;
    DECLARE total_spent DECIMAL(10,2);
    DECLARE category VARCHAR(20);

    -- Get customer statistics
    SELECT COUNT(*), SUM(total_amount)
    INTO total_orders, total_spent
    FROM orders
    WHERE customer_id = customer_id AND status != 'cancelled';

    -- Categorize customer
    CASE
        WHEN total_spent > 10000 AND total_orders > 20 THEN SET category = 'VIP';
        WHEN total_spent > 5000 OR total_orders > 10 THEN SET category = 'Gold';
        WHEN total_spent > 1000 OR total_orders > 3 THEN SET category = 'Silver';
        ELSE SET category = 'Bronze';
    END CASE;

    -- Update customer category
    UPDATE customers SET customer_category = category WHERE customer_id = customer_id;

    SELECT CONCAT('Customer categorized as: ', category) as result;
END //
DELIMITER ;
```

#### Loops

```sql
-- WHILE Loop
DELIMITER //
CREATE PROCEDURE bulk_update_salaries(IN department_id INT, IN percentage DECIMAL(5,2))
BEGIN
    DECLARE done BOOLEAN DEFAULT FALSE;
    DECLARE emp_id INT;
    DECLARE cur CURSOR FOR SELECT employee_id FROM employees WHERE department_id = department_id;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    update_loop: LOOP
        FETCH cur INTO emp_id;
        IF done THEN
            LEAVE update_loop;
        END IF;

        UPDATE employees
        SET salary = salary * (1 + percentage / 100),
            updated_at = NOW()
        WHERE employee_id = emp_id;

    END LOOP;

    CLOSE cur;
    SELECT 'Salary update completed' as message;
END //
DELIMITER ;

-- REPEAT Loop
DELIMITER //
CREATE PROCEDURE process_pending_orders()
BEGIN
    DECLARE order_count INT DEFAULT 0;

    REPEAT
        -- Process one order
        UPDATE orders
        SET status = 'processing', processed_at = NOW()
        WHERE status = 'pending'
        ORDER BY order_date ASC
        LIMIT 1;

        SET order_count = order_count + ROW_COUNT();

    UNTIL order_count >= 10 -- Process max 10 orders at a time
    END REPEAT;

    SELECT CONCAT(order_count, ' orders processed') as result;
END //
DELIMITER ;
```

---

## 🛠️ Cursors for Row-by-Row Processing

### Basic Cursor Usage

```sql
DELIMITER //
CREATE PROCEDURE process_employee_reviews()
BEGIN
    DECLARE done BOOLEAN DEFAULT FALSE;
    DECLARE emp_id INT;
    DECLARE emp_name VARCHAR(100);
    DECLARE review_count INT;

    -- Declare cursor
    DECLARE emp_cursor CURSOR FOR
        SELECT employee_id, CONCAT(first_name, ' ', last_name)
        FROM employees
        WHERE hire_date < DATE_SUB(CURDATE(), INTERVAL 1 YEAR);

    -- Handler for when no more rows
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- Open cursor
    OPEN emp_cursor;

    -- Process each employee
    read_loop: LOOP
        FETCH emp_cursor INTO emp_id, emp_name;

        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Count reviews for this employee
        SELECT COUNT(*) INTO review_count
        FROM performance_reviews
        WHERE employee_id = emp_id;

        -- Create review reminder if needed
        IF review_count = 0 THEN
            INSERT INTO review_reminders (employee_id, employee_name, reminder_type, created_at)
            VALUES (emp_id, emp_name, 'ANNUAL_REVIEW_OVERDUE', NOW());
        END IF;

    END LOOP;

    -- Close cursor
    CLOSE emp_cursor;

    SELECT 'Review processing completed' as message;
END //
DELIMITER ;
```

### Cursor with Error Handling

```sql
DELIMITER //
CREATE PROCEDURE safe_bulk_update()
BEGIN
    DECLARE done BOOLEAN DEFAULT FALSE;
    DECLARE emp_id INT;
    DECLARE current_salary DECIMAL(10,2);
    DECLARE error_count INT DEFAULT 0;

    DECLARE emp_cursor CURSOR FOR
        SELECT employee_id, salary FROM employees WHERE department_id = 1;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        SET error_count = error_count + 1;
        -- Log error and continue
        INSERT INTO error_log (error_message, occurred_at)
        VALUES ('Error in bulk update', NOW());
    END;

    OPEN emp_cursor;

    update_loop: LOOP
        FETCH emp_cursor INTO emp_id, current_salary;

        IF done THEN
            LEAVE update_loop;
        END IF;

        -- Attempt to update salary
        UPDATE employees
        SET salary = salary * 1.05,
            last_updated = NOW()
        WHERE employee_id = emp_id;

    END LOOP;

    CLOSE emp_cursor;

    SELECT CONCAT('Bulk update completed. Errors encountered: ', error_count) as result;
END //
DELIMITER ;
```

---

## 🔄 Transactions in Stored Procedures

### Transaction Management

```sql
DELIMITER //
CREATE PROCEDURE safe_transfer_funds(
    IN from_account INT,
    IN to_account INT,
    IN transfer_amount DECIMAL(10,2)
)
BEGIN
    DECLARE from_balance DECIMAL(10,2);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Transfer failed. Transaction rolled back.' as message;
    END;

    START TRANSACTION;

    -- Check sender balance
    SELECT balance INTO from_balance
    FROM accounts
    WHERE account_id = from_account
    FOR UPDATE; -- Lock the row

    IF from_balance < transfer_amount THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient funds';
    END IF;

    -- Debit sender
    UPDATE accounts
    SET balance = balance - transfer_amount,
        last_updated = NOW()
    WHERE account_id = from_account;

    -- Credit receiver
    UPDATE accounts
    SET balance = balance + transfer_amount,
        last_updated = NOW()
    WHERE account_id = to_account;

    -- Log transaction
    INSERT INTO transaction_log (
        from_account, to_account, amount, transaction_type, performed_at
    ) VALUES (
        from_account, to_account, transfer_amount, 'TRANSFER', NOW()
    );

    COMMIT;
    SELECT 'Transfer completed successfully' as message;
END //
DELIMITER ;
```

---

## 📊 Complex Business Logic Procedures

### Employee Performance Analysis

```sql
DELIMITER //
CREATE PROCEDURE analyze_employee_performance(
    IN emp_id INT,
    OUT performance_score DECIMAL(5,2),
    OUT recommendation TEXT
)
BEGIN
    DECLARE avg_rating DECIMAL(3,2);
    DECLARE total_projects INT;
    DECLARE years_experience INT;
    DECLARE attendance_rate DECIMAL(5,2);
    DECLARE salary_hike_pct DECIMAL(5,2);

    -- Get employee metrics
    SELECT AVG(pr.rating), COUNT(DISTINCT pa.project_id), TIMESTAMPDIFF(YEAR, e.hire_date, CURDATE())
    INTO avg_rating, total_projects, years_experience
    FROM employees e
    LEFT JOIN performance_reviews pr ON e.employee_id = pr.employee_id
    LEFT JOIN project_assignments pa ON e.employee_id = pa.employee_id
    WHERE e.employee_id = emp_id;

    -- Calculate attendance rate
    SELECT (SUM(CASE WHEN status = 'present' THEN 1 ELSE 0 END) / COUNT(*)) * 100
    INTO attendance_rate
    FROM attendance
    WHERE employee_id = emp_id
    AND attendance_date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH);

    -- Calculate performance score (weighted average)
    SET performance_score = (
        COALESCE(avg_rating, 0) * 0.4 +           -- 40% weight on reviews
        LEAST(total_projects / 5, 1) * 100 * 0.3 + -- 30% weight on projects (max 5 projects = 100)
        attendance_rate * 0.3                       -- 30% weight on attendance
    );

    -- Generate recommendation
    IF performance_score >= 90 THEN
        SET recommendation = 'Outstanding performance. Consider for promotion and significant raise.';
        SET salary_hike_pct = 15.0;
    ELSEIF performance_score >= 75 THEN
        SET recommendation = 'Good performance. Eligible for standard raise.';
        SET salary_hike_pct = 8.0;
    ELSEIF performance_score >= 60 THEN
        SET recommendation = 'Average performance. Needs improvement in some areas.';
        SET salary_hike_pct = 3.0;
    ELSE
        SET recommendation = 'Performance needs significant improvement. Consider performance plan.';
        SET salary_hike_pct = 0.0;
    END IF;

    -- Log analysis
    INSERT INTO performance_analysis_log (
        employee_id, performance_score, recommendation, analyzed_at
    ) VALUES (
        emp_id, performance_score, recommendation, NOW()
    );

END //
DELIMITER ;

-- Usage
SET @score = 0;
SET @rec = '';
CALL analyze_employee_performance(123, @score, @rec);
SELECT @score as performance_score, @rec as recommendation;
```

### Inventory Management

```sql
DELIMITER //
CREATE PROCEDURE manage_inventory(
    IN product_id INT,
    IN operation VARCHAR(10), -- 'ADD', 'REMOVE', 'ADJUST'
    IN quantity INT,
    IN reason VARCHAR(100)
)
BEGIN
    DECLARE current_stock INT;
    DECLARE new_stock INT;
    DECLARE reorder_level INT;

    -- Start transaction
    START TRANSACTION;

    -- Get current inventory
    SELECT stock_quantity, reorder_level
    INTO current_stock, reorder_level
    FROM products
    WHERE product_id = product_id
    FOR UPDATE;

    -- Calculate new stock level
    CASE operation
        WHEN 'ADD' THEN SET new_stock = current_stock + quantity;
        WHEN 'REMOVE' THEN
            IF current_stock < quantity THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient stock';
            END IF;
            SET new_stock = current_stock - quantity;
        WHEN 'ADJUST' THEN SET new_stock = quantity;
        ELSE
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid operation';
    END CASE;

    -- Update inventory
    UPDATE products
    SET stock_quantity = new_stock,
        last_inventory_update = NOW()
    WHERE product_id = product_id;

    -- Log inventory change
    INSERT INTO inventory_log (
        product_id, operation, quantity_changed, previous_stock,
        new_stock, reason, performed_by, performed_at
    ) VALUES (
        product_id, operation, quantity, current_stock,
        new_stock, reason, USER(), NOW()
    );

    -- Check for low stock alert
    IF new_stock <= reorder_level AND current_stock > reorder_level THEN
        INSERT INTO inventory_alerts (
            product_id, alert_type, message, created_at
        ) VALUES (
            product_id, 'LOW_STOCK',
            CONCAT('Product stock is low (', new_stock, '). Reorder level: ', reorder_level),
            NOW()
        );
    END IF;

    COMMIT;
    SELECT CONCAT('Inventory updated successfully. New stock level: ', new_stock) as message;

END //
DELIMITER ;
```

---

## 🔧 Stored Procedure Management

### Viewing Procedures

```sql
-- List all procedures
SHOW PROCEDURE STATUS;

-- Show procedure definition
SHOW CREATE PROCEDURE procedure_name;

-- Get procedure information
SELECT * FROM information_schema.routines
WHERE routine_type = 'PROCEDURE'
AND routine_schema = 'your_database';
```

### Modifying Procedures

```sql
-- Drop and recreate (MySQL)
DROP PROCEDURE IF EXISTS procedure_name;
CREATE PROCEDURE procedure_name -- ... new definition

-- Alter procedure (limited support in MySQL)
-- Usually need to drop and recreate
```

### Best Practices

```sql
-- Use meaningful names
CREATE PROCEDURE calculate_monthly_sales_report() -- Good
CREATE PROCEDURE proc1()                          -- Bad

-- Add comments
DELIMITER //
CREATE PROCEDURE complex_business_logic(
    IN param1 INT,
    OUT result VARCHAR(100)
)
BEGIN
    /*
    Purpose: This procedure performs complex business logic
    Author: Developer Name
    Created: 2024-01-15
    Parameters:
        param1: Input parameter description
        result: Output parameter description
    */

    -- Implementation here
END //
DELIMITER ;

-- Handle errors properly
DELIMITER //
CREATE PROCEDURE safe_operation()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Operation failed' as error_message;
    END;

    START TRANSACTION;
    -- Operations here
    COMMIT;
END //
DELIMITER ;
```

---

## 📚 Practice Exercises

### Exercise 1: Basic Procedures
Create procedures for:
1. **Employee search** by name, department, salary range
2. **Order processing** with validation and inventory update
3. **Customer registration** with duplicate checking
4. **Product catalog** management (add, update, delete)

### Exercise 2: Complex Business Logic
Design procedures for:
1. **Monthly sales reporting** with trend analysis
2. **Employee performance reviews** with automated scoring
3. **Inventory optimization** with reorder calculations
4. **Customer segmentation** based on purchase history

### Exercise 3: Transaction Management
Implement procedures for:
1. **Bank transfers** with proper locking and rollback
2. **Order fulfillment** with inventory and payment processing
3. **Employee salary updates** with audit trails
4. **Bulk data operations** with error handling

### Exercise 4: Advanced Features
Create procedures using:
1. **Cursors** for complex row-by-row processing
2. **Dynamic SQL** for flexible queries
3. **Temporary tables** for intermediate results
4. **Recursive operations** for hierarchical data

---

## 🎯 Chapter Summary

- **Stored Procedures**: Pre-compiled SQL code for reusability
- **Parameters**: IN, OUT, INOUT for data exchange
- **Control Structures**: IF-ELSE, CASE, loops for logic
- **Cursors**: Row-by-row processing capabilities
- **Transactions**: ACID compliance for data integrity
- **Error Handling**: Proper exception management
- **Performance**: Reduced network traffic and compiled execution
- **Security**: Controlled access to database operations

---

## 🚀 Next Steps
- Master **transaction management** for data consistency
- Learn **performance optimization** techniques
- Practice **complete database application development**
- Implement **enterprise-level database solutions**
- Build **scalable and maintainable systems**
