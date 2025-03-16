# Database Queries

Database-related queries refer to the operations performed on a database to retrieve, insert, update, or delete data. These queries are typically written in **SQL (Structured Query Language)** and interact with a database management system (DBMS) such as MySQL, PostgreSQL, MongoDB (NoSQL), or SQLite.

## Types of Database Queries

### 1. Data Retrieval Queries (SELECT Queries)
Used to fetch data from a database.
```sql
SELECT * FROM customers;
SELECT name, email FROM users WHERE age > 25;
```

### 2. Data Manipulation Queries (DML)
Used to modify data in the database.

- **INSERT:** Adds new records.
  ```sql
  INSERT INTO users (name, email, age) VALUES ('John Doe', 'john@example.com', 30);
  ```
  
- **UPDATE:** Modifies existing records.
  ```sql
  UPDATE users SET age = 31 WHERE name = 'John Doe';
  ```
  
- **DELETE:** Removes records.
  ```sql
  DELETE FROM users WHERE age < 18;
  ```

### 3. Data Definition Queries (DDL)
Used to define or modify database structure.

- **CREATE:** Creates a new table or database.
  ```sql
  CREATE TABLE employees (
      id INT PRIMARY KEY,
      name VARCHAR(100),
      salary DECIMAL(10,2)
  );
  ```

- **ALTER:** Modifies an existing table.
  ```sql
  ALTER TABLE employees ADD COLUMN department VARCHAR(50);
  ```

- **DROP:** Deletes a table or database.
  ```sql
  DROP TABLE employees;
  ```

### 4. Data Control Queries (DCL)
Used to manage user permissions.

- **GRANT:** Provides access to users.
  ```sql
  GRANT SELECT, INSERT ON employees TO 'user1';
  ```

- **REVOKE:** Removes access from users.
  ```sql
  REVOKE INSERT ON employees FROM 'user1';
  ```

### 5. Transaction Control Queries (TCL)
Used to manage transactions in a database.

- **COMMIT:** Saves all changes permanently.
  ```sql
  COMMIT;
  ```

- **ROLLBACK:** Reverts changes made in the current transaction.
  ```sql
  ROLLBACK;
  ```

- **SAVEPOINT:** Creates a point to which you can roll back later.
  ```sql
  SAVEPOINT save1;
  ```

### 6. Joins and Complex Queries
Used to retrieve data from multiple tables.

- **INNER JOIN:**
  ```sql
  SELECT users.name, orders.amount 
  FROM users 
  INNER JOIN orders ON users.id = orders.user_id;
  ```

- **LEFT JOIN:**
  ```sql
  SELECT customers.name, orders.amount 
  FROM customers 
  LEFT JOIN orders ON customers.id = orders.customer_id;
  ```
