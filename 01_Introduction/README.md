# Introduction to SQL

## SQL Components
SQL is divided into several categories based on its functionality:

### 1. DDL (Data Definition Language) – Defines and modifies database structure
- `CREATE` – Creates a new database or table
- `ALTER` – Modifies existing table structure
- `DROP` – Deletes a table or database

### 2. DML (Data Manipulation Language) – Handles data within tables
- `INSERT` – Adds new data
- `UPDATE` – Modifies existing data
- `DELETE` – Removes data

### 3. DQL (Data Query Language) – Retrieves data
- `SELECT` – Fetches records from a table

### 4. DCL (Data Control Language) – Manages user permissions
- `GRANT` – Gives access
- `REVOKE` – Removes access

### 5. TCL (Transaction Control Language) – Manages transactions
- `COMMIT` – Saves changes
- `ROLLBACK` – Reverts changes

---

## Basic SQL Example
```sql
-- Create a table
CREATE TABLE Users (
    id INT PRIMARY KEY,
    name VARCHAR(50),
    email VARCHAR(100)
);

-- Insert data
INSERT INTO Users (id, name, email) VALUES (1, 'John Doe', 'john@example.com');

-- Retrieve data
SELECT * FROM Users;

-- Update data
UPDATE Users SET name = 'Jane Doe' WHERE id = 1;

-- Delete data
DELETE FROM Users WHERE id = 1;
```

---

## Next Steps
- Learn **Joins** to combine data from multiple tables
- Practice **Aggregate Functions** (`COUNT()`, `SUM()`, `AVG()`, etc.)
- Understand **Indexes** and **Normalization** for performance optimization
