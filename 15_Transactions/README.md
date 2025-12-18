# 🔐 Chapter 15: Transaction Management - Data Consistency & Integrity

## 🎯 What are Transactions?

**Transactions** are logical units of work that must be executed entirely or not at all. They ensure data integrity and consistency in multi-user database environments through the **ACID properties**.

---

## 🔠 ACID Properties

### Atomicity
**All-or-nothing**: Either all operations in a transaction succeed, or none of them do.

```sql
-- Example: Bank transfer
START TRANSACTION;

-- Debit sender account
UPDATE accounts SET balance = balance - 1000 WHERE account_id = 1;

-- Credit receiver account
UPDATE accounts SET balance = balance + 1000 WHERE account_id = 2;

-- Log transaction
INSERT INTO transaction_log (from_account, to_account, amount) VALUES (1, 2, 1000);

COMMIT; -- All operations succeed together

-- If any operation fails, all are rolled back
ROLLBACK;
```

### Consistency
**Database integrity**: Transactions transform the database from one valid state to another.

```sql
START TRANSACTION;

-- Check business rules before changes
SELECT balance FROM accounts WHERE account_id = 1 FOR UPDATE;

-- Ensure balance doesn't go negative
UPDATE accounts
SET balance = balance - 1000
WHERE account_id = 1 AND balance >= 1000;

-- If insufficient funds, transaction will fail
IF ROW_COUNT() = 0 THEN
    ROLLBACK;
    SELECT 'Insufficient funds' as error;
ELSE
    COMMIT;
END IF;
```

### Isolation
**Concurrent transactions**: Each transaction appears to execute in isolation from others.

```sql
-- Isolation levels prevent issues like:
-- Dirty reads: Reading uncommitted changes
-- Non-repeatable reads: Same query returns different results
-- Phantom reads: New rows appear/disappear between queries

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
START TRANSACTION;

-- This transaction sees a consistent snapshot
SELECT balance FROM accounts WHERE account_id = 1;

COMMIT;
```

### Durability
**Committed changes persist**: Even if the system crashes, committed transactions survive.

```sql
START TRANSACTION;

-- Critical business operation
UPDATE inventory SET stock = stock - 1 WHERE product_id = 123;
INSERT INTO sales_log (product_id, sold_at) VALUES (123, NOW());

COMMIT; -- Changes are permanently saved to disk

-- Even if power fails now, the sale is recorded
```

---

## 🚦 Transaction Control Commands

### Basic Transaction Management

```sql
-- Start transaction explicitly
START TRANSACTION;
-- or
BEGIN;

-- Execute SQL statements
UPDATE accounts SET balance = balance - 100 WHERE id = 1;
INSERT INTO transactions (account_id, amount, type) VALUES (1, -100, 'debit');

-- Commit changes
COMMIT;

-- Or rollback changes
ROLLBACK;
```

### Savepoints for Partial Rollbacks

```sql
START TRANSACTION;

-- First operation
INSERT INTO orders (customer_id, total) VALUES (1, 500);
SAVEPOINT order_created;

-- Second operation
UPDATE inventory SET stock = stock - 1 WHERE product_id = 123;
SAVEPOINT inventory_updated;

-- Third operation (might fail)
UPDATE payments SET amount = amount + 500 WHERE customer_id = 1;

-- If payment update fails, rollback to inventory state
ROLLBACK TO SAVEPOINT inventory_updated;

-- Continue with alternative payment processing
INSERT INTO pending_payments (customer_id, amount) VALUES (1, 500);

COMMIT;
```

### Autocommit Mode

```sql
-- Check current autocommit setting
SELECT @@autocommit; -- MySQL

-- Disable autocommit (each statement becomes a transaction)
SET autocommit = 0;

-- Now you need explicit COMMIT
UPDATE accounts SET balance = balance - 100 WHERE id = 1;
COMMIT;

-- Re-enable autocommit
SET autocommit = 1;
```

---

## 🎯 Isolation Levels

### Read Uncommitted (Lowest Isolation)
**Allows dirty reads** - transactions can see uncommitted changes from other transactions.

```sql
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

START TRANSACTION;

-- Can see changes from other transactions that haven't committed yet
SELECT balance FROM accounts WHERE id = 1; -- Might see uncommitted changes

COMMIT;
```

### Read Committed (Default for most DBs)
**Prevents dirty reads** - only committed changes are visible.

```sql
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

START TRANSACTION;

-- Only sees committed changes
SELECT balance FROM accounts WHERE id = 1;

-- Other transactions can modify and commit between our queries
SELECT balance FROM accounts WHERE id = 1; -- Might see different values

COMMIT;
```

### Repeatable Read
**Prevents dirty reads and non-repeatable reads** - same query always returns same results within transaction.

```sql
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

START TRANSACTION;

-- First read
SELECT balance FROM accounts WHERE id = 1; -- Returns 1000

-- Other transaction modifies and commits
-- Our transaction still sees 1000

-- Same query returns same result
SELECT balance FROM accounts WHERE id = 1; -- Still returns 1000

COMMIT;
```

### Serializable (Highest Isolation)
**Prevents all concurrency issues** - transactions execute as if they were run serially.

```sql
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

START TRANSACTION;

-- Complete isolation - no other transactions can modify accessed data
SELECT * FROM accounts WHERE balance > 1000;

-- This prevents phantom reads (new rows appearing)
-- and ensures true serializable execution

COMMIT;
```

### Isolation Level Comparison

| Isolation Level | Dirty Reads | Non-Repeatable Reads | Phantom Reads | Performance |
|-----------------|-------------|---------------------|---------------|-------------|
| Read Uncommitted | ✅ Allowed | ✅ Allowed | ✅ Allowed | Fastest |
| Read Committed | ❌ Prevented | ✅ Allowed | ✅ Allowed | Fast |
| Repeatable Read | ❌ Prevented | ❌ Prevented | ✅ Allowed | Medium |
| Serializable | ❌ Prevented | ❌ Prevented | ❌ Prevented | Slowest |

---

## 🔒 Locking Mechanisms

### Shared Locks (Read Locks)
Allow multiple transactions to read data simultaneously but prevent writes.

```sql
-- Explicit shared lock
START TRANSACTION;

SELECT * FROM products WHERE category = 'Electronics' LOCK IN SHARE MODE;

-- Other transactions can read but not modify these rows
-- until we commit or rollback

COMMIT;
```

### Exclusive Locks (Write Locks)
Prevent all other access (read or write) to locked data.

```sql
START TRANSACTION;

-- Exclusive lock for update
SELECT * FROM accounts WHERE id = 1 FOR UPDATE;

-- No other transaction can read or modify this account
UPDATE accounts SET balance = balance - 100 WHERE id = 1;

COMMIT;
```

### Lock Types and Granularity

```sql
-- Row-level locking (most granular)
START TRANSACTION;
SELECT * FROM employees WHERE id = 1 FOR UPDATE; -- Locks only one row
COMMIT;

-- Table-level locking (coarsest)
LOCK TABLES employees WRITE; -- Locks entire table
-- Perform operations
UNLOCK TABLES;

-- Page-level locking (between row and table)
-- Automatically managed by database engine
```

### Deadlock Prevention

```sql
-- Deadlock scenario (avoid this pattern)
-- Transaction 1:
START TRANSACTION;
UPDATE accounts SET balance = balance - 100 WHERE id = 1;
UPDATE accounts SET balance = balance + 100 WHERE id = 2;
COMMIT;

-- Transaction 2 (runs simultaneously):
START TRANSACTION;
UPDATE accounts SET balance = balance - 50 WHERE id = 2; -- Waits for T1
UPDATE accounts SET balance = balance + 50 WHERE id = 1; -- Deadlock!
COMMIT;

-- Prevention: Always access resources in same order
START TRANSACTION;
-- Always lock lower ID first
UPDATE accounts SET balance = balance - 100 WHERE id = 1;
UPDATE accounts SET balance = balance + 100 WHERE id = 2;
COMMIT;
```

---

## 🛠️ Real-World Transaction Examples

### E-commerce Order Processing

```sql
DELIMITER //
CREATE PROCEDURE process_order(IN customer_id INT, IN product_list JSON)
BEGIN
    DECLARE order_id INT;
    DECLARE total_amount DECIMAL(10,2) DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Order processing failed. All changes rolled back.' as error;
    END;

    START TRANSACTION;

    -- Create order header
    INSERT INTO orders (customer_id, order_date, status)
    VALUES (customer_id, NOW(), 'processing');
    SET order_id = LAST_INSERT_ID();

    -- Process each product in JSON array
    -- (Simplified - in real app you'd parse JSON)

    -- For demonstration, assume we have product data
    INSERT INTO order_items (order_id, product_id, quantity, unit_price)
    VALUES (order_id, 1, 2, 29.99);

    -- Update inventory
    UPDATE products SET stock_quantity = stock_quantity - 2 WHERE product_id = 1;

    -- Calculate total
    SELECT SUM(quantity * unit_price) INTO total_amount
    FROM order_items WHERE order_id = order_id;

    UPDATE orders SET total_amount = total_amount WHERE order_id = order_id;

    -- Process payment (simplified)
    INSERT INTO payments (order_id, amount, payment_method, status)
    VALUES (order_id, total_amount, 'credit_card', 'completed');

    -- Update order status
    UPDATE orders SET status = 'confirmed' WHERE order_id = order_id;

    COMMIT;
    SELECT CONCAT('Order processed successfully. Order ID: ', order_id) as message;

END //
DELIMITER ;
```

### Banking Transfer System

```sql
DELIMITER //
CREATE PROCEDURE transfer_funds(
    IN from_account INT,
    IN to_account INT,
    IN transfer_amount DECIMAL(10,2),
    IN description VARCHAR(255)
)
BEGIN
    DECLARE from_balance DECIMAL(10,2);
    DECLARE from_customer_id INT;
    DECLARE to_customer_id INT;
    DECLARE transaction_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Transfer failed. Please try again.' as error;
    END;

    -- Input validation
    IF transfer_amount <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Transfer amount must be positive';
    END IF;

    START TRANSACTION;

    -- Lock both accounts to prevent concurrent modifications
    SELECT balance, customer_id INTO from_balance, from_customer_id
    FROM accounts WHERE account_id = from_account FOR UPDATE;

    SELECT customer_id INTO to_customer_id
    FROM accounts WHERE account_id = to_account FOR UPDATE;

    -- Business rule checks
    IF from_balance < transfer_amount THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient funds';
    END IF;

    -- Perform transfer
    UPDATE accounts SET balance = balance - transfer_amount
    WHERE account_id = from_account;

    UPDATE accounts SET balance = balance + transfer_amount
    WHERE account_id = to_account;

    -- Record transaction
    INSERT INTO transactions (
        from_account, to_account, amount, transaction_type,
        description, performed_by, transaction_date
    ) VALUES (
        from_account, to_account, transfer_amount, 'transfer',
        description, USER(), NOW()
    );
    SET transaction_id = LAST_INSERT_ID();

    -- Update account summaries
    UPDATE account_summary
    SET last_transaction_date = NOW(),
        transaction_count = transaction_count + 1
    WHERE account_id IN (from_account, to_account);

    COMMIT;

    SELECT CONCAT('Transfer completed successfully. Transaction ID: ', transaction_id) as message,
           transfer_amount as transferred_amount;

END //
DELIMITER ;
```

### Inventory Management with Transactions

```sql
DELIMITER //
CREATE PROCEDURE adjust_inventory(
    IN product_id INT,
    IN adjustment_type ENUM('receive', 'ship', 'adjust', 'return'),
    IN quantity INT,
    IN reason VARCHAR(255),
    IN reference_number VARCHAR(50)
)
BEGIN
    DECLARE current_stock INT;
    DECLARE new_stock INT;
    DECLARE adjustment_qty INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Inventory adjustment failed.' as error;
    END;

    START TRANSACTION;

    -- Get current stock with lock
    SELECT stock_quantity INTO current_stock
    FROM products
    WHERE product_id = product_id
    FOR UPDATE;

    -- Calculate adjustment quantity
    CASE adjustment_type
        WHEN 'receive' THEN SET adjustment_qty = quantity;
        WHEN 'ship' THEN SET adjustment_qty = -quantity;
        WHEN 'adjust' THEN SET adjustment_qty = quantity - current_stock;
        WHEN 'return' THEN SET adjustment_qty = quantity;
        ELSE SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid adjustment type';
    END CASE;

    -- Validate adjustment
    SET new_stock = current_stock + adjustment_qty;
    IF new_stock < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stock cannot go negative';
    END IF;

    -- Apply adjustment
    UPDATE products
    SET stock_quantity = new_stock,
        last_inventory_update = NOW()
    WHERE product_id = product_id;

    -- Log adjustment
    INSERT INTO inventory_adjustments (
        product_id, adjustment_type, quantity_changed,
        previous_stock, new_stock, reason, reference_number,
        adjusted_by, adjusted_at
    ) VALUES (
        product_id, adjustment_type, adjustment_qty,
        current_stock, new_stock, reason, reference_number,
        USER(), NOW()
    );

    -- Check reorder level
    IF new_stock <= (SELECT reorder_level FROM products WHERE product_id = product_id) THEN
        INSERT INTO reorder_alerts (product_id, current_stock, alert_date)
        VALUES (product_id, new_stock, NOW());
    END IF;

    COMMIT;

    SELECT CONCAT('Inventory adjusted successfully. New stock: ', new_stock) as message;

END //
DELIMITER ;
```

---

## 🚨 Error Handling and Recovery

### Transaction Error Handling

```sql
DELIMITER //
CREATE PROCEDURE robust_operation()
BEGIN
    DECLARE operation_status VARCHAR(20) DEFAULT 'success';
    DECLARE error_message TEXT DEFAULT NULL;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            error_message = MESSAGE_TEXT;

        ROLLBACK;
        SET operation_status = 'failed';

        -- Log the error
        INSERT INTO error_log (
            operation_name, error_message, occurred_at, performed_by
        ) VALUES (
            'robust_operation', error_message, NOW(), USER()
        );
    END;

    START TRANSACTION;

    -- Perform multiple operations
    INSERT INTO users (email, name) VALUES ('user@example.com', 'New User');
    UPDATE settings SET value = value + 1 WHERE setting_name = 'user_count';
    INSERT INTO audit_log (action, table_name, record_id) VALUES ('INSERT', 'users', LAST_INSERT_ID());

    COMMIT;

    SELECT operation_status as status, error_message as error;

END //
DELIMITER ;
```

### Deadlock Detection and Handling

```sql
DELIMITER //
CREATE PROCEDURE safe_update_with_retry(
    IN table_name VARCHAR(50),
    IN record_id INT,
    IN max_retries INT DEFAULT 3
)
BEGIN
    DECLARE retry_count INT DEFAULT 0;
    DECLARE deadlock_detected BOOLEAN DEFAULT FALSE;

    DECLARE EXIT HANDLER FOR 1213 -- Deadlock error code
    BEGIN
        SET deadlock_detected = TRUE;
    END;

    retry_loop: WHILE retry_count < max_retries DO
        SET deadlock_detected = FALSE;

        START TRANSACTION;

        -- Attempt the operation
        SET @sql = CONCAT('UPDATE ', table_name, ' SET updated_at = NOW() WHERE id = ', record_id);
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        IF NOT deadlock_detected THEN
            COMMIT;
            SELECT 'Update successful' as result;
            LEAVE retry_loop;
        ELSE
            ROLLBACK;
            SET retry_count = retry_count + 1;

            -- Exponential backoff
            DO SLEEP(POW(2, retry_count) * 0.1);
        END IF;
    END WHILE;

    IF deadlock_detected THEN
        SELECT 'Update failed after maximum retries' as result;
    END IF;

END //
DELIMITER ;
```

---

## 📊 Monitoring Transactions

### Transaction Monitoring Queries

```sql
-- Check active transactions (MySQL)
SELECT * FROM information_schema.innodb_trx;

-- Check locks
SELECT * FROM information_schema.innodb_lock_waits;

-- Transaction isolation level
SELECT @@transaction_isolation;

-- Autocommit setting
SELECT @@autocommit;

-- Active connections
SHOW PROCESSLIST;
```

### Performance Monitoring

```sql
-- Transaction performance metrics
SELECT
    trx_id,
    trx_state,
    trx_started,
    TIMESTAMPDIFF(SECOND, trx_started, NOW()) as duration_seconds,
    trx_rows_locked,
    trx_rows_modified
FROM information_schema.innodb_trx
ORDER BY duration_seconds DESC;

-- Long-running transactions alert
SELECT
    trx_id,
    trx_mysql_thread_id,
    TIMESTAMPDIFF(MINUTE, trx_started, NOW()) as minutes_running
FROM information_schema.innodb_trx
WHERE TIMESTAMPDIFF(MINUTE, trx_started, NOW()) > 5; -- Running > 5 minutes
```

---

## 📚 Practice Exercises

### Exercise 1: Basic Transactions
Implement transactions for:
1. **Bank account transfers** with proper validation
2. **Order processing** with inventory management
3. **Employee salary updates** with audit trails
4. **Product price changes** with rollback capability

### Exercise 2: Isolation Levels
Create scenarios demonstrating:
1. **Dirty reads** and how to prevent them
2. **Non-repeatable reads** in concurrent transactions
3. **Phantom reads** with range queries
4. **Serializable isolation** for complex operations

### Exercise 3: Locking Strategies
Design systems with:
1. **Row-level locking** for high concurrency
2. **Table-level locking** for batch operations
3. **Optimistic locking** with version columns
4. **Deadlock prevention** strategies

### Exercise 4: Error Handling
Build robust procedures with:
1. **Comprehensive error handling** and logging
2. **Retry mechanisms** for transient failures
3. **Graceful degradation** when operations fail
4. **Transaction compensation** for failed operations

---

## 🎯 Chapter Summary

- **ACID Properties**: Atomicity, Consistency, Isolation, Durability
- **Transaction Control**: START, COMMIT, ROLLBACK, SAVEPOINT
- **Isolation Levels**: Read Uncommitted to Serializable
- **Locking**: Shared locks, exclusive locks, deadlock prevention
- **Real-World Applications**: Banking, e-commerce, inventory systems
- **Error Handling**: Proper rollback and recovery mechanisms
- **Performance**: Balance consistency with concurrency needs
- **Monitoring**: Track transaction health and performance

---

## 🚀 Final Thoughts

**Transaction management** is the foundation of reliable database applications. Understanding and properly implementing transactions ensures:

- **Data Integrity**: Business rules are maintained
- **Consistency**: Database remains in valid states
- **Reliability**: Operations complete successfully or fail safely
- **Performance**: Optimal concurrency without conflicts

Master these concepts, and you'll build robust, enterprise-grade database applications that can handle real-world complexity and scale effectively.

**Congratulations on completing your comprehensive SQL learning journey!** 🎉

Keep practicing, build real projects, and continue exploring advanced database concepts like replication, sharding, and NoSQL databases for different use cases.
