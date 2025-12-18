# ⚡ Chapter 13: Database Triggers - Automatic Actions

## 🎯 What are Triggers?

**Triggers** are special stored procedures that automatically execute when specific events occur in the database. They enforce business rules, maintain audit trails, and automate complex operations.

---

## 📋 Trigger Components

### Basic Trigger Structure

```sql
CREATE TRIGGER trigger_name
{BEFORE | AFTER} {INSERT | UPDATE | DELETE}
ON table_name
FOR EACH ROW
BEGIN
    -- Trigger logic here
END;
```

### Trigger Types by Timing

#### 1. BEFORE Triggers
Execute **before** the triggering event occurs. Used for:
- Data validation and modification
- Setting default values
- Preventing invalid operations

```sql
-- BEFORE INSERT: Set default values
CREATE TRIGGER set_employee_defaults
BEFORE INSERT ON employees
FOR EACH ROW
BEGIN
    IF NEW.hire_date IS NULL THEN
        SET NEW.hire_date = CURDATE();
    END IF;
    IF NEW.created_at IS NULL THEN
        SET NEW.created_at = NOW();
    END IF;
END;

-- BEFORE UPDATE: Prevent salary reduction
CREATE TRIGGER prevent_salary_reduction
BEFORE UPDATE ON employees
FOR EACH ROW
BEGIN
    IF NEW.salary < OLD.salary THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Salary cannot be reduced';
    END IF;
END;
```

#### 2. AFTER Triggers
Execute **after** the triggering event completes. Used for:
- Audit logging
- Cascading updates
- Business rule enforcement
- Notifications

```sql
-- AFTER INSERT: Log new employee
CREATE TRIGGER log_new_employee
AFTER INSERT ON employees
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (table_name, operation, record_id, changed_by, changed_at)
    VALUES ('employees', 'INSERT', NEW.employee_id, USER(), NOW());
END;

-- AFTER UPDATE: Track salary changes
CREATE TRIGGER track_salary_changes
AFTER UPDATE ON employees
FOR EACH ROW
BEGIN
    IF OLD.salary != NEW.salary THEN
        INSERT INTO salary_history (employee_id, old_salary, new_salary, changed_at)
        VALUES (NEW.employee_id, OLD.salary, NEW.salary, NOW());
    END IF;
END;
```

---

## 🎯 Trigger Types by Event

### INSERT Triggers

```sql
-- Log all new orders
CREATE TRIGGER audit_order_creation
AFTER INSERT ON orders
FOR EACH ROW
BEGIN
    INSERT INTO order_audit (order_id, action, performed_by, performed_at)
    VALUES (NEW.order_id, 'CREATED', USER(), NOW());
END;

-- Update product stock on order
CREATE TRIGGER update_stock_on_order
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
    UPDATE products
    SET stock_quantity = stock_quantity - NEW.quantity
    WHERE product_id = NEW.product_id;
END;
```

### UPDATE Triggers

```sql
-- Track all column changes
CREATE TRIGGER audit_employee_updates
AFTER UPDATE ON employees
FOR EACH ROW
BEGIN
    -- Log only actual changes
    IF OLD.first_name != NEW.first_name OR OLD.last_name != NEW.last_name OR
       OLD.salary != NEW.salary OR OLD.department_id != NEW.department_id THEN
        INSERT INTO employee_change_log (
            employee_id, field_changed, old_value, new_value, changed_by, changed_at
        ) VALUES
        (NEW.employee_id, 'first_name', OLD.first_name, NEW.first_name, USER(), NOW()),
        (NEW.employee_id, 'last_name', OLD.last_name, NEW.last_name, USER(), NOW()),
        (NEW.employee_id, 'salary', OLD.salary, NEW.salary, USER(), NOW()),
        (NEW.employee_id, 'department_id', OLD.department_id, NEW.department_id, USER(), NOW());
    END IF;
END;

-- Maintain denormalized data
CREATE TRIGGER update_department_stats
AFTER UPDATE ON employees
FOR EACH ROW
BEGIN
    -- Update old department stats
    IF OLD.department_id != NEW.department_id THEN
        UPDATE department_stats
        SET employee_count = employee_count - 1
        WHERE department_id = OLD.department_id;
    END IF;

    -- Update new department stats
    UPDATE department_stats
    SET employee_count = employee_count + 1,
        total_salary = total_salary + NEW.salary - OLD.salary
    WHERE department_id = NEW.department_id;
END;
```

### DELETE Triggers

```sql
-- Prevent deletion of active employees
CREATE TRIGGER prevent_active_employee_deletion
BEFORE DELETE ON employees
FOR EACH ROW
BEGIN
    IF OLD.is_active = TRUE THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot delete active employee';
    END IF;
END;

-- Archive deleted records
CREATE TRIGGER archive_deleted_orders
AFTER DELETE ON orders
FOR EACH ROW
BEGIN
    INSERT INTO orders_archive (
        order_id, customer_id, order_date, total_amount,
        deleted_at, deleted_by
    ) VALUES (
        OLD.order_id, OLD.customer_id, OLD.order_date, OLD.total_amount,
        NOW(), USER()
    );
END;
```

---

## 🔄 Advanced Trigger Concepts

### Row-Level vs Statement-Level Triggers

```sql
-- Row-level trigger (FOR EACH ROW) - executes once per affected row
CREATE TRIGGER row_level_audit
AFTER UPDATE ON products
FOR EACH ROW
BEGIN
    INSERT INTO product_audit (product_id, old_price, new_price, changed_at)
    VALUES (NEW.product_id, OLD.price, NEW.price, NOW());
END;

-- Statement-level trigger - executes once per statement
CREATE TRIGGER statement_level_log
AFTER UPDATE ON products
BEGIN
    INSERT INTO batch_update_log (table_name, operation, records_affected, performed_at)
    VALUES ('products', 'UPDATE', ROW_COUNT(), NOW());
END;
```

### Conditional Triggers

```sql
-- Trigger with WHEN condition
CREATE TRIGGER salary_increase_audit
AFTER UPDATE ON employees
FOR EACH ROW
WHEN (NEW.salary > OLD.salary * 1.1) -- Only for >10% increases
BEGIN
    INSERT INTO significant_changes (
        employee_id, change_type, old_value, new_value, approved_by
    ) VALUES (
        NEW.employee_id, 'LARGE_SALARY_INCREASE',
        OLD.salary, NEW.salary, USER()
    );
END;

-- Complex conditions
CREATE TRIGGER business_hours_orders
BEFORE INSERT ON orders
FOR EACH ROW
BEGIN
    IF HOUR(NOW()) NOT BETWEEN 9 AND 17 OR DAYOFWEEK(NOW()) IN (1,7) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Orders can only be placed during business hours';
    END IF;
END;
```

---

## 🎭 Trigger Chaining and Recursion

### Managing Trigger Chains

```sql
-- Trigger A: Update product stock
CREATE TRIGGER update_stock
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
    UPDATE products SET stock_quantity = stock_quantity - NEW.quantity
    WHERE product_id = NEW.product_id;
END;

-- Trigger B: Check low stock (triggered by Trigger A)
CREATE TRIGGER check_low_stock
AFTER UPDATE ON products
FOR EACH ROW
BEGIN
    IF NEW.stock_quantity <= NEW.reorder_level THEN
        INSERT INTO low_stock_alerts (product_id, current_stock, reorder_level, alerted_at)
        VALUES (NEW.product_id, NEW.stock_quantity, NEW.reorder_level, NOW());
    END IF;
END;

-- Prevent infinite loops
DELIMITER //
CREATE TRIGGER prevent_recursive_updates
BEFORE UPDATE ON employees
FOR EACH ROW
BEGIN
    -- Check if this update is from a trigger
    IF @trigger_depth IS NULL THEN
        SET @trigger_depth = 1;
    ELSE
        SET @trigger_depth = @trigger_depth + 1;
    END IF;

    IF @trigger_depth > 5 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Too many recursive updates';
    END IF;
END;
//
DELIMITER ;
```

### Controlling Trigger Execution

```sql
-- Disable specific trigger
ALTER TABLE employees DISABLE TRIGGER prevent_salary_reduction;

-- Disable all triggers on table
ALTER TABLE employees DISABLE TRIGGER ALL;

-- Enable triggers back
ALTER TABLE employees ENABLE TRIGGER prevent_salary_reduction;
ALTER TABLE employees ENABLE TRIGGER ALL;

-- MySQL way
SET @DISABLE_TRIGGERS = 1;
-- Perform operations
SET @DISABLE_TRIGGERS = NULL;
```

---

## 🛠️ Real-World Trigger Examples

### Audit Trail System

```sql
-- Generic audit table
CREATE TABLE audit_trail (
    audit_id INT PRIMARY KEY AUTO_INCREMENT,
    table_name VARCHAR(50) NOT NULL,
    record_id INT NOT NULL,
    operation VARCHAR(10) NOT NULL,
    old_values JSON,
    new_values JSON,
    changed_by VARCHAR(50),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Dynamic audit trigger function
DELIMITER //
CREATE PROCEDURE create_audit_trigger(IN table_name VARCHAR(50))
BEGIN
    SET @sql = CONCAT('
        CREATE TRIGGER audit_', table_name, '
        AFTER INSERT, UPDATE, DELETE ON ', table_name, '
        FOR EACH ROW
        BEGIN
            DECLARE operation VARCHAR(10);
            DECLARE old_vals JSON DEFAULT NULL;
            DECLARE new_vals JSON DEFAULT NULL;

            IF INSERTING THEN
                SET operation = ''INSERT'';
                SET new_vals = JSON_OBJECT(''data'', ROW_TO_JSON(NEW));
            ELSEIF UPDATING THEN
                SET operation = ''UPDATE'';
                SET old_vals = JSON_OBJECT(''data'', ROW_TO_JSON(OLD));
                SET new_vals = JSON_OBJECT(''data'', ROW_TO_JSON(NEW));
            ELSE
                SET operation = ''DELETE'';
                SET old_vals = JSON_OBJECT(''data'', ROW_TO_JSON(OLD));
            END IF;

            INSERT INTO audit_trail (table_name, record_id, operation, old_values, new_values, changed_by)
            VALUES (''', table_name, ''', COALESCE(NEW.id, OLD.id), operation, old_vals, new_vals, USER());
        END
    ');

    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END;
//
DELIMITER ;

-- Create audit triggers for tables
CALL create_audit_trigger('employees');
CALL create_audit_trigger('orders');
```

### Business Rules Enforcement

```sql
-- Credit limit validation
CREATE TRIGGER validate_credit_limit
BEFORE INSERT ON orders
FOR EACH ROW
BEGIN
    DECLARE customer_credit DECIMAL(10,2);
    DECLARE customer_balance DECIMAL(10,2);

    SELECT credit_limit, current_balance INTO customer_credit, customer_balance
    FROM customers WHERE customer_id = NEW.customer_id;

    IF customer_balance + NEW.total_amount > customer_credit THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Order exceeds customer credit limit';
    END IF;
END;

-- Age validation for certain products
CREATE TRIGGER age_restricted_products
BEFORE INSERT ON order_items
FOR EACH ROW
BEGIN
    DECLARE customer_age INT;
    DECLARE product_age_restriction INT;

    SELECT FLOOR(DATEDIFF(CURDATE(), c.date_of_birth)/365.25), p.age_restriction
    INTO customer_age, product_age_restriction
    FROM customers c
    CROSS JOIN products p
    WHERE c.customer_id = (SELECT customer_id FROM orders WHERE order_id = NEW.order_id)
    AND p.product_id = NEW.product_id;

    IF customer_age < product_age_restriction THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Customer does not meet age requirement for this product';
    END IF;
END;
```

### Automated Calculations

```sql
-- Update order totals automatically
CREATE TRIGGER calculate_order_total
AFTER INSERT, UPDATE, DELETE ON order_items
FOR EACH ROW
BEGIN
    -- Recalculate total for affected order
    UPDATE orders
    SET total_amount = (
        SELECT COALESCE(SUM(quantity * unit_price), 0)
        FROM order_items
        WHERE order_id = COALESCE(NEW.order_id, OLD.order_id)
    )
    WHERE order_id = COALESCE(NEW.order_id, OLD.order_id);
END;

-- Maintain inventory levels
CREATE TRIGGER inventory_management
AFTER INSERT, UPDATE, DELETE ON order_items
FOR EACH ROW
BEGIN
    DECLARE qty_change INT;

    -- Calculate quantity change
    IF INSERTING THEN
        SET qty_change = -NEW.quantity;
    ELSEIF UPDATING THEN
        SET qty_change = OLD.quantity - NEW.quantity;
    ELSE
        SET qty_change = OLD.quantity; -- DELETE: restore stock
    END IF;

    -- Update inventory
    UPDATE products
    SET stock_quantity = stock_quantity + qty_change,
        last_updated = NOW()
    WHERE product_id = COALESCE(NEW.product_id, OLD.product_id);
END;
```

### Notifications and Alerts

```sql
-- Low stock alerts
CREATE TRIGGER low_stock_notification
AFTER UPDATE ON products
FOR EACH ROW
BEGIN
    IF NEW.stock_quantity <= NEW.reorder_level AND OLD.stock_quantity > OLD.reorder_level THEN
        INSERT INTO notifications (
            notification_type, message, recipient, created_at
        ) VALUES (
            'LOW_STOCK',
            CONCAT('Product ', NEW.product_name, ' is low on stock (', NEW.stock_quantity, ' remaining)'),
            'inventory_manager@company.com',
            NOW()
        );
    END IF;
END;

-- Order status change notifications
CREATE TRIGGER order_status_notifications
AFTER UPDATE ON orders
FOR EACH ROW
BEGIN
    IF OLD.status != NEW.status THEN
        INSERT INTO customer_notifications (
            customer_id, order_id, notification_type, message, sent_at
        ) VALUES (
            NEW.customer_id,
            NEW.order_id,
            'STATUS_UPDATE',
            CONCAT('Your order #', NEW.order_id, ' status changed to: ', NEW.status),
            NOW()
        );
    END IF;
END;
```

---

## 🔧 Trigger Management

### Viewing Triggers

```sql
-- MySQL: Show triggers
SHOW TRIGGERS;
SHOW TRIGGERS FROM database_name;
SHOW CREATE TRIGGER trigger_name;

-- SQL Server: View triggers
SELECT * FROM sys.triggers;
SELECT OBJECT_DEFINITION(OBJECT_ID('trigger_name'));

-- PostgreSQL: View triggers
SELECT * FROM pg_trigger;
SELECT pg_get_triggerdef(oid) FROM pg_trigger WHERE tgname = 'trigger_name';
```

### Dropping Triggers

```sql
-- Drop specific trigger
DROP TRIGGER trigger_name;
DROP TRIGGER database_name.trigger_name;

-- Drop trigger if exists
DROP TRIGGER IF EXISTS trigger_name;

-- Drop all triggers on table
-- (Need to drop each individually)
```

### Modifying Triggers

```sql
-- MySQL: Recreate trigger
DROP TRIGGER IF EXISTS trigger_name;
CREATE TRIGGER trigger_name
-- ... new definition

-- Or use ALTER TRIGGER (limited support)
```

---

## ⚠️ Trigger Best Practices

### 1. Keep Triggers Simple

```sql
-- Good: Simple, focused trigger
CREATE TRIGGER update_last_modified
BEFORE UPDATE ON products
FOR EACH ROW
BEGIN
    SET NEW.updated_at = NOW();
END;

-- Avoid: Complex business logic in triggers
CREATE TRIGGER complex_business_logic
AFTER INSERT ON orders
FOR EACH ROW
BEGIN
    -- Calculate taxes
    -- Update inventory
    -- Send notifications
    -- Update customer stats
    -- Generate reports
    -- ... (too much in one trigger)
END;
```

### 2. Avoid Trigger Chains

```sql
-- Prefer: Single-purpose triggers
CREATE TRIGGER update_inventory
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
    UPDATE products SET stock_quantity = stock_quantity - NEW.quantity
    WHERE product_id = NEW.product_id;
END;

CREATE TRIGGER check_reorder
AFTER UPDATE ON products
FOR EACH ROW
BEGIN
    IF NEW.stock_quantity <= NEW.reorder_level THEN
        INSERT INTO reorder_alerts (product_id, current_stock)
        VALUES (NEW.product_id, NEW.stock_quantity);
    END IF;
END;
```

### 3. Handle Errors Properly

```sql
-- Good: Proper error handling
CREATE TRIGGER validate_order
BEFORE INSERT ON orders
FOR EACH ROW
BEGIN
    DECLARE customer_balance DECIMAL(10,2);

    SELECT balance INTO customer_balance
    FROM customers WHERE customer_id = NEW.customer_id;

    IF customer_balance < NEW.total_amount THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Insufficient customer balance';
    END IF;
END;

-- Avoid: Silent failures
CREATE TRIGGER risky_trigger
AFTER UPDATE ON accounts
FOR EACH ROW
BEGIN
    UPDATE related_table SET value = value + 1; -- What if this fails?
END;
```

### 4. Performance Considerations

```sql
-- Good: Efficient triggers
CREATE TRIGGER efficient_audit
AFTER INSERT ON orders
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (table_name, record_id, operation)
    VALUES ('orders', NEW.order_id, 'INSERT');
    -- Only log essential data
END;

-- Avoid: Expensive operations in triggers
CREATE TRIGGER slow_trigger
AFTER UPDATE ON large_table
FOR EACH ROW
BEGIN
    -- Complex calculations
    -- Multiple table updates
    -- External API calls
    -- Heavy computations
END;
```

---

## 📚 Practice Exercises

### Exercise 1: Audit System
Create triggers for:
1. **Complete audit trail** for employee table
2. **Salary change tracking** with approval workflow
3. **Login/logout tracking** for user sessions
4. **Data change notifications** for sensitive tables

### Exercise 2: Business Rules
Implement triggers for:
1. **Credit limit validation** for orders
2. **Age restrictions** for certain products
3. **Business hours validation** for transactions
4. **Stock level monitoring** with automatic reordering

### Exercise 3: Automated Calculations
Design triggers that:
1. **Update order totals** when items are added/modified
2. **Maintain inventory levels** automatically
3. **Calculate customer rankings** based on purchases
4. **Update department statistics** when employees change

### Exercise 4: Notifications and Alerts
Create triggers for:
1. **Low stock alerts** to inventory managers
2. **Order status updates** to customers
3. **Security alerts** for suspicious activities
4. **Performance alerts** for system monitoring

---

## 🎯 Chapter Summary

- **Triggers**: Automatic procedures executed on database events
- **BEFORE/AFTER**: Timing of trigger execution
- **INSERT/UPDATE/DELETE**: Events that fire triggers
- **Row-level triggers**: Execute per affected row
- **Statement-level triggers**: Execute once per statement
- **Audit trails**: Track all data changes automatically
- **Business rules**: Enforce complex validation logic
- **Performance**: Keep triggers simple and efficient
- **Management**: Proper error handling and maintenance

---

## 🚀 Next Steps
- Master **stored procedures** for complex business logic
- Learn **transaction management** for data consistency
- Practice **performance tuning** techniques
- Implement **complete database solutions**
- Build **enterprise-level applications**
