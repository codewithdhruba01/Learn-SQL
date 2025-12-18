# 📚 Chapter 2: SQL Basics - Foundation of Database Queries

## 🎯 What is SQL?

**SQL (Structured Query Language)** is the standard language for managing and manipulating relational databases. It allows you to:

- **Create** databases and tables
- **Insert** data into tables
- **Update** existing data
- **Delete** data from tables
- **Query** and retrieve data
- **Manage** database permissions and security

---

## 🔧 SQL Statement Categories

### 1. DDL (Data Definition Language)
Used to **define and modify** database structure.

```sql
-- Creating a database
CREATE DATABASE school_management;

-- Creating a table
CREATE TABLE students (...);

-- Modifying table structure
ALTER TABLE students ADD COLUMN email VARCHAR(100);

-- Deleting a table
DROP TABLE students;
```

### 2. DML (Data Manipulation Language)
Used to **manipulate data** within tables.

```sql
-- Inserting data
INSERT INTO students VALUES (1, 'Rahul', 20);

-- Updating data
UPDATE students SET age = 21 WHERE id = 1;

-- Deleting data
DELETE FROM students WHERE id = 1;
```

### 3. DQL (Data Query Language)
Used to **retrieve data** from databases.

```sql
-- Basic SELECT
SELECT * FROM students;

-- SELECT with conditions
SELECT name, age FROM students WHERE age > 18;

-- SELECT with sorting
SELECT * FROM students ORDER BY age DESC;
```

### 4. DCL (Data Control Language)
Used to **control access** to data.

```sql
-- Grant permissions
GRANT SELECT, INSERT ON students TO 'user1'@'localhost';

-- Revoke permissions
REVOKE INSERT ON students FROM 'user1'@'localhost';
```

### 5. TCL (Transaction Control Language)
Used to **manage transactions**.

```sql
-- Start transaction
BEGIN;

-- Save changes
COMMIT;

-- Undo changes
ROLLBACK;

-- Create savepoint
SAVEPOINT my_savepoint;
```

---

## 📝 SQL Syntax Rules

### 1. Case Sensitivity
- **SQL keywords** are NOT case-sensitive (`SELECT` = `select`)
- **Table/Column names** depend on database system
- **String values** are case-sensitive (`'John'` ≠ `'john'`)

### 2. Statement Termination
- SQL statements end with a **semicolon (`;`)**

### 3. Comments
```sql
-- Single line comment

/* Multi-line
   comment */

/* Another way */
# MySQL style comment
```

### 4. Naming Conventions
- Use **meaningful names**
- Avoid **reserved keywords**
- Use **snake_case** or **camelCase**
- Keep names **concise but descriptive**

---

## 🏗️ Database Structure Hierarchy

```
Database Server
├── Database (school_management)
    ├── Tables
    │   ├── students
    │   ├── teachers
    │   └── courses
    ├── Views
    ├── Indexes
    ├── Triggers
    └── Stored Procedures
```

---

## 📋 SQL Best Practices

### 1. Code Formatting
```sql
-- Good: Properly formatted
SELECT
    student_id,
    first_name,
    last_name,
    age
FROM students
WHERE age >= 18
ORDER BY last_name;

-- Bad: Poor formatting
select student_id,first_name,last_name,age from students where age>=18 order by last_name;
```

### 2. Use Meaningful Names
```sql
-- Good
CREATE TABLE student_records (
    student_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50)
);

-- Bad
CREATE TABLE s (
    i INT PRIMARY KEY,
    f VARCHAR(50),
    l VARCHAR(50)
);
```

### 3. Avoid SELECT *
```sql
-- Good: Specify columns
SELECT first_name, last_name, email FROM students;

-- Bad: Selects all columns
SELECT * FROM students;
```

### 4. Use Proper Indentation
- Indent subqueries and complex conditions
- Align similar elements
- Use consistent spacing

---

## 🔍 Common SQL Mistakes to Avoid

### 1. Forgetting WHERE Clause
```sql
-- Dangerous: Updates all records
UPDATE students SET status = 'inactive';

-- Safe: Updates specific records
UPDATE students SET status = 'inactive' WHERE graduation_year < 2020;
```

### 2. Not Using Transactions for Multiple Operations
```sql
-- Good: Use transactions for related operations
BEGIN;
INSERT INTO orders (customer_id, total) VALUES (1, 100.00);
UPDATE inventory SET stock = stock - 1 WHERE product_id = 1;
COMMIT;
```

### 3. Incorrect String Handling
```sql
-- Wrong: Missing quotes
SELECT * FROM students WHERE name = John;

-- Correct: Proper quotes
SELECT * FROM students WHERE name = 'John';
```

---

## 🛠️ Essential SQL Tools

### Database Management Systems
- **MySQL**: Popular open-source RDBMS
- **PostgreSQL**: Advanced open-source RDBMS
- **SQLite**: Lightweight, file-based database
- **Oracle**: Enterprise-grade RDBMS
- **SQL Server**: Microsoft's RDBMS

### GUI Tools
- **phpMyAdmin**: Web-based MySQL management
- **MySQL Workbench**: Official MySQL GUI
- **DBeaver**: Universal database tool
- **pgAdmin**: PostgreSQL management
- **SQL Developer**: Oracle's tool

---

## 📚 Practice Exercises

### Exercise 1: Basic SQL Commands
Write SQL statements to:
1. Create a database named `company_db`
2. Create a table `employees` with columns: id, name, salary, department
3. Insert 3 sample employees
4. Select all employees earning more than 50000
5. Update salary of employee with id=1 to 60000

### Exercise 2: Query Analysis
Analyze this query and identify potential issues:
```sql
select * from employees where department = 'IT' order by salary
```

---

## 🎯 Chapter Summary

- SQL is the language for managing relational databases
- Five main categories: DDL, DML, DQL, DCL, TCL
- Follow proper syntax rules and best practices
- Use appropriate tools for database management
- Always test queries on sample data first
- Practice regularly to master SQL concepts

---

## 🚀 Next Steps
- Learn about **data types** and **operators**
- Practice with **real database** using MySQL/PostgreSQL
- Start with **simple SELECT queries**
- Gradually move to **complex joins** and **aggregations**
