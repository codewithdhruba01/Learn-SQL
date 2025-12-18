# 🏗️ Chapter 4: DDL Commands - Database Structure Management

## 🎯 What is DDL?

**DDL (Data Definition Language)** consists of SQL commands used to **define, modify, and delete** database structures like databases, tables, indexes, and views.

DDL commands are:
- **Auto-committed** (changes are permanent)
- **Cannot be rolled back**
- Used by **database administrators** and **developers**

---

## 🗄️ Database Operations

### CREATE DATABASE

```sql
-- Basic database creation
CREATE DATABASE company_db;

-- With character set and collation (MySQL)
CREATE DATABASE company_db
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

-- Check if not exists
CREATE DATABASE IF NOT EXISTS company_db;

-- PostgreSQL with options
CREATE DATABASE company_db
WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'en_US.UTF-8'
    LC_CTYPE = 'en_US.UTF-8';
```

### ALTER DATABASE

```sql
-- MySQL: Change character set
ALTER DATABASE company_db
CHARACTER SET utf8
COLLATE utf8_general_ci;

-- PostgreSQL: Rename database
ALTER DATABASE company_db RENAME TO enterprise_db;
```

### DROP DATABASE

```sql
-- Drop database (⚠️ DANGER: Deletes all data)
DROP DATABASE company_db;

-- Safe drop with existence check
DROP DATABASE IF EXISTS company_db;
```

---

## 📋 Table Operations

### CREATE TABLE - Basic Syntax

```sql
CREATE TABLE table_name (
    column1 datatype [constraints],
    column2 datatype [constraints],
    ...
    [table_constraints]
);
```

### Complete CREATE TABLE Example

```sql
CREATE TABLE employees (
    -- Primary key with auto-increment
    employee_id INT PRIMARY KEY AUTO_INCREMENT,

    -- Basic information
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,

    -- Employment details
    hire_date DATE NOT NULL,
    salary DECIMAL(10,2) CHECK (salary > 0),
    department_id INT,

    -- Status and timestamps
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    -- Foreign key constraint
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);
```

### CREATE TABLE with Advanced Features

#### Temporary Tables
```sql
-- Temporary table (exists during session)
CREATE TEMPORARY TABLE temp_employees AS
SELECT * FROM employees WHERE department_id = 1;

-- Temporary table with specific structure
CREATE TEMPORARY TABLE temp_report (
    id INT,
    name VARCHAR(100),
    total DECIMAL(10,2)
);
```

#### Table with Indexes
```sql
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2),
    category VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- Indexes for performance
    INDEX idx_name (name),
    INDEX idx_category_price (category, price),
    UNIQUE KEY uk_name_category (name, category)
);
```

#### Partitioned Tables (MySQL)
```sql
CREATE TABLE sales (
    id INT PRIMARY KEY,
    sale_date DATE,
    amount DECIMAL(10,2),
    customer_id INT
)
PARTITION BY RANGE (YEAR(sale_date)) (
    PARTITION p2020 VALUES LESS THAN (2021),
    PARTITION p2021 VALUES LESS THAN (2022),
    PARTITION p2022 VALUES LESS THAN (2023),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);
```

---

## 🔧 ALTER TABLE Operations

### Adding Columns

```sql
-- Add single column
ALTER TABLE employees
ADD COLUMN phone VARCHAR(20);

-- Add multiple columns
ALTER TABLE employees
ADD COLUMN (
    emergency_contact VARCHAR(100),
    emergency_phone VARCHAR(20),
    blood_group VARCHAR(5)
);

-- Add column with default value
ALTER TABLE employees
ADD COLUMN bonus_percentage DECIMAL(5,2) DEFAULT 0.00;
```

### Modifying Columns

```sql
-- Change data type
ALTER TABLE employees
MODIFY COLUMN salary DECIMAL(12,2);

-- Change column name and type (MySQL)
ALTER TABLE employees
CHANGE COLUMN first_name full_name VARCHAR(100) NOT NULL;

-- PostgreSQL syntax
ALTER TABLE employees
RENAME COLUMN first_name TO full_name;

ALTER TABLE employees
ALTER COLUMN salary TYPE DECIMAL(12,2);
```

### Dropping Columns

```sql
-- Drop single column
ALTER TABLE employees
DROP COLUMN phone;

-- Drop multiple columns
ALTER TABLE employees
DROP COLUMN emergency_contact,
DROP COLUMN emergency_phone;
```

### Adding Constraints

```sql
-- Add primary key
ALTER TABLE departments
ADD PRIMARY KEY (department_id);

-- Add foreign key
ALTER TABLE employees
ADD CONSTRAINT fk_dept
FOREIGN KEY (department_id) REFERENCES departments(department_id);

-- Add unique constraint
ALTER TABLE employees
ADD CONSTRAINT uk_email UNIQUE (email);

-- Add check constraint
ALTER TABLE employees
ADD CONSTRAINT ck_salary CHECK (salary > 0);

-- Add default value
ALTER TABLE employees
ALTER COLUMN is_active SET DEFAULT TRUE;
```

### Dropping Constraints

```sql
-- Drop constraint by name
ALTER TABLE employees
DROP CONSTRAINT fk_dept;

-- Drop primary key
ALTER TABLE employees
DROP PRIMARY KEY;

-- Drop unique constraint
ALTER TABLE employees
DROP INDEX uk_email;

-- Drop check constraint
ALTER TABLE employees
DROP CONSTRAINT ck_salary;
```

### Renaming Tables and Columns

```sql
-- Rename table
ALTER TABLE employees RENAME TO staff;

-- Rename column (MySQL)
ALTER TABLE employees
CHANGE COLUMN first_name given_name VARCHAR(50);

-- Rename column (PostgreSQL)
ALTER TABLE employees
RENAME COLUMN first_name TO given_name;
```

---

## 🗑️ DROP TABLE Operations

### Basic DROP TABLE

```sql
-- Drop table
DROP TABLE employees;

-- Drop with existence check
DROP TABLE IF EXISTS employees;

-- Drop multiple tables
DROP TABLE employees, departments, projects;
```

### CASCADE and RESTRICT

```sql
-- Drop table and all dependent objects (foreign keys, views, etc.)
DROP TABLE departments CASCADE;

-- Prevent drop if dependent objects exist
DROP TABLE departments RESTRICT;
```

---

## 📊 Working with Indexes

### CREATE INDEX

```sql
-- Single column index
CREATE INDEX idx_employee_name ON employees (last_name);

-- Composite index
CREATE INDEX idx_dept_salary ON employees (department_id, salary);

-- Unique index
CREATE UNIQUE INDEX idx_unique_email ON employees (email);

-- Partial index (PostgreSQL)
CREATE INDEX idx_active_employees ON employees (last_name)
WHERE is_active = true;
```

### DROP INDEX

```sql
-- Drop index
DROP INDEX idx_employee_name;

-- Drop index with existence check
DROP INDEX IF EXISTS idx_employee_name;
```

---

## 🔍 Views Management

### CREATE VIEW

```sql
-- Simple view
CREATE VIEW active_employees AS
SELECT employee_id, first_name, last_name, department_id
FROM employees
WHERE is_active = true;

-- Complex view with joins
CREATE VIEW employee_details AS
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    e.salary,
    d.department_name,
    m.first_name as manager_name
FROM employees e
JOIN departments d ON e.department_id = d.department_id
LEFT JOIN employees m ON e.manager_id = m.employee_id;
```

### ALTER VIEW

```sql
-- Replace view definition
CREATE OR REPLACE VIEW active_employees AS
SELECT employee_id, first_name, last_name, email, hire_date
FROM employees
WHERE is_active = true
ORDER BY hire_date DESC;
```

### DROP VIEW

```sql
-- Drop view
DROP VIEW active_employees;

-- Drop multiple views
DROP VIEW employee_details, department_summary;
```

---

## 📋 DDL Best Practices

### 1. Planning Database Structure

```sql
-- Good: Proper naming and relationships
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE NOT NULL,
    total_amount DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
```

### 2. Using Constraints Wisely

```sql
-- Good: Meaningful constraints
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL CHECK (price > 0),
    stock_quantity INT DEFAULT 0 CHECK (stock_quantity >= 0),
    category VARCHAR(50) NOT NULL,
    UNIQUE KEY uk_name_category (name, category)
);
```

### 3. Indexing Strategy

```sql
-- Index frequently queried columns
CREATE INDEX idx_product_category ON products (category);
CREATE INDEX idx_product_price ON products (price);
CREATE INDEX idx_order_date ON orders (order_date);
CREATE INDEX idx_customer_email ON customers (email);
```

---

## 🛠️ Advanced DDL Examples

### Complete Database Schema

```sql
-- Create database
CREATE DATABASE IF NOT EXISTS ecommerce_db;
USE ecommerce_db;

-- Create tables with relationships
CREATE TABLE categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL CHECK (price > 0),
    stock_quantity INT DEFAULT 0 CHECK (stock_quantity >= 0),
    category_id INT,
    image_url VARCHAR(500),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (category_id) REFERENCES categories(category_id),
    INDEX idx_category (category_id),
    INDEX idx_price (price),
    INDEX idx_active (is_active)
);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(20),
    address TEXT,
    city VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100) DEFAULT 'India',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    INDEX idx_email (email),
    INDEX idx_city (city)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10,2) NOT NULL,
    status ENUM('pending', 'processing', 'shipped', 'delivered', 'cancelled') DEFAULT 'pending',
    shipping_address TEXT,
    payment_method VARCHAR(50),

    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    INDEX idx_customer (customer_id),
    INDEX idx_date (order_date),
    INDEX idx_status (status)
);

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) GENERATED ALWAYS AS (quantity * unit_price) STORED,

    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    INDEX idx_order (order_id),
    INDEX idx_product (product_id)
);
```

---

## 📚 Practice Exercises

### Exercise 1: University Database
Create a complete university database schema with:
- Students table (with personal info)
- Courses table
- Enrollments table (junction table)
- Professors table
- Departments table

Include proper constraints, indexes, and relationships.

### Exercise 2: ALTER TABLE Practice
Given an existing `employees` table, perform these modifications:
1. Add a `middle_name` column
2. Change `salary` column to allow higher values
3. Add a check constraint for valid email format
4. Create indexes on frequently queried columns
5. Rename the table to `staff_members`

### Exercise 3: View Creation
Create views for:
1. Active products with category information
2. Customer order summary
3. Monthly sales report
4. Employee department details

---

## 🎯 Chapter Summary

- DDL commands define database structure
- CREATE, ALTER, DROP are main operations
- Proper planning prevents costly changes later
- Constraints ensure data integrity
- Indexes improve query performance
- Views provide simplified data access
- Always backup before major DDL changes

---

## 🚀 Next Steps
- Learn **DML commands** for data manipulation
- Practice **SELECT queries** with WHERE clauses
- Understand **relationships** and **joins**
- Master **constraints** and **data integrity**
