# 📊 Chapter 3: Data Types and Operators in SQL

## 🎯 Understanding Data Types

**Data types** define the kind of data that can be stored in a column. Choosing the right data type is crucial for:
- **Storage efficiency**
- **Data integrity**
- **Query performance**
- **Memory usage**

---

## 🔢 Numeric Data Types

### Integer Types

| Data Type | Range | Storage | Description |
|-----------|-------|---------|-------------|
| `TINYINT` | -128 to 127 | 1 byte | Very small integers |
| `SMALLINT` | -32,768 to 32,767 | 2 bytes | Small integers |
| `MEDIUMINT` | -8M to 8M | 3 bytes | Medium integers |
| `INT` | -2B to 2B | 4 bytes | Standard integers |
| `BIGINT` | -9Q to 9Q | 8 bytes | Large integers |

```sql
-- Examples
CREATE TABLE products (
    id INT PRIMARY KEY,
    stock_quantity SMALLINT,
    total_sales BIGINT
);
```

### Decimal Types

| Data Type | Description | Example |
|-----------|-------------|---------|
| `DECIMAL(M,D)` | Fixed precision decimal | `DECIMAL(10,2)` |
| `FLOAT` | Single precision floating point | `FLOAT(7,4)` |
| `DOUBLE` | Double precision floating point | `DOUBLE(15,8)` |

```sql
-- Examples
CREATE TABLE financial (
    account_id INT,
    balance DECIMAL(15,2),    -- Stores 9999999999999.99
    interest_rate FLOAT,      -- Approximate values
    exchange_rate DOUBLE      -- High precision
);
```

---

## 📝 String/Text Data Types

### Character Types

| Data Type | Max Length | Description | Example |
|-----------|------------|-------------|---------|
| `CHAR(n)` | 255 chars | Fixed length | `CHAR(10)` |
| `VARCHAR(n)` | 65,535 chars | Variable length | `VARCHAR(255)` |
| `TINYTEXT` | 255 chars | Small text | Blog titles |
| `TEXT` | 65,535 chars | Medium text | Articles |
| `MEDIUMTEXT` | 16M chars | Large text | Book chapters |
| `LONGTEXT` | 4G chars | Very large text | Novels |

```sql
-- Examples
CREATE TABLE users (
    username VARCHAR(50) NOT NULL,
    email VARCHAR(255) UNIQUE,
    bio TEXT,
    profile_picture_url VARCHAR(500)
);
```

### Binary Types

| Data Type | Description | Use Case |
|-----------|-------------|----------|
| `BINARY(n)` | Fixed binary data | Hashes, UUIDs |
| `VARBINARY(n)` | Variable binary data | Images, files |
| `BLOB` | Binary Large Object | Documents, media |

```sql
-- Example
CREATE TABLE files (
    id INT PRIMARY KEY,
    filename VARCHAR(255),
    file_data BLOB,
    file_hash BINARY(32)
);
```

---

## 📅 Date and Time Data Types

| Data Type | Format | Range | Example |
|-----------|--------|-------|---------|
| `DATE` | YYYY-MM-DD | 1000-01-01 to 9999-12-31 | `2024-01-15` |
| `TIME` | HH:MM:SS | -838:59:59 to 838:59:59 | `14:30:45` |
| `DATETIME` | YYYY-MM-DD HH:MM:SS | 1000-01-01 to 9999-12-31 | `2024-01-15 14:30:45` |
| `TIMESTAMP` | YYYY-MM-DD HH:MM:SS | 1970-01-01 to 2038-01-19 | `2024-01-15 14:30:45` |
| `YEAR` | YYYY | 1901 to 2155 | `2024` |

```sql
-- Examples
CREATE TABLE events (
    event_id INT PRIMARY KEY,
    event_name VARCHAR(100),
    event_date DATE,
    start_time TIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    event_year YEAR
);
```

---

## 🔍 Special Data Types

### Boolean/Enum Types

```sql
-- ENUM: Limited set of values
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    status ENUM('pending', 'processing', 'shipped', 'delivered'),
    payment_method ENUM('cash', 'card', 'upi', 'netbanking')
);

-- BOOLEAN: True/False values
CREATE TABLE settings (
    setting_id INT PRIMARY KEY,
    is_active BOOLEAN DEFAULT TRUE,
    notifications_enabled BOOLEAN DEFAULT FALSE
);
```

### JSON Type (MySQL 5.7.8+, PostgreSQL)

```sql
-- MySQL
CREATE TABLE user_preferences (
    user_id INT PRIMARY KEY,
    preferences JSON
);

-- PostgreSQL
CREATE TABLE user_data (
    id SERIAL PRIMARY KEY,
    metadata JSONB
);
```

---

## ⚡ SQL Operators

### Arithmetic Operators

| Operator | Description | Example | Result |
|----------|-------------|---------|---------|
| `+` | Addition | `5 + 3` | `8` |
| `-` | Subtraction | `5 - 3` | `2` |
| `*` | Multiplication | `5 * 3` | `15` |
| `/` | Division | `5 / 3` | `1.6667` |
| `%` | Modulo | `5 % 3` | `2` |
| `DIV` | Integer Division | `5 DIV 3` | `1` |

```sql
-- Examples
SELECT
    salary,
    salary + 5000 as increased_salary,
    salary * 1.1 as bonus_salary,
    salary % 1000 as remainder
FROM employees;
```

### Comparison Operators

| Operator | Description | Example |
|----------|-------------|---------|
| `=` | Equal to | `age = 25` |
| `!=` or `<>` | Not equal to | `age != 25` |
| `<` | Less than | `age < 25` |
| `>` | Greater than | `age > 25` |
| `<=` | Less than or equal | `age <= 25` |
| `>=` | Greater than or equal | `age >= 25` |
| `BETWEEN` | Within range | `age BETWEEN 20 AND 30` |
| `IN` | In list | `city IN ('Delhi', 'Mumbai')` |
| `LIKE` | Pattern matching | `name LIKE 'A%'` |
| `IS NULL` | Is null value | `email IS NULL` |

```sql
-- Examples
SELECT * FROM employees
WHERE salary BETWEEN 50000 AND 100000
  AND department IN ('IT', 'HR', 'Finance')
  AND name LIKE 'A%';
```

### Logical Operators

| Operator | Description | Example |
|----------|-------------|---------|
| `AND` | Both conditions true | `age > 20 AND salary > 50000` |
| `OR` | Either condition true | `age > 20 OR experience > 5` |
| `NOT` | Negates condition | `NOT (age < 18)` |

```sql
-- Examples
SELECT * FROM employees
WHERE (department = 'IT' AND salary > 60000)
   OR (department = 'HR' AND experience > 3);
```

### String Operators

| Operator | Description | Example |
|----------|-------------|---------|
| `||` or `CONCAT()` | Concatenation | `'Hello' || ' World'` |
| `LIKE` | Pattern matching | `name LIKE 'A%'` |
| `NOT LIKE` | Pattern not matching | `name NOT LIKE 'A%'` |

```sql
-- Examples
SELECT
    CONCAT(first_name, ' ', last_name) as full_name,
    email
FROM users
WHERE email LIKE '%@gmail.com';
```

---

## 🔧 Type Conversion (Casting)

### Implicit Conversion
```sql
-- Automatic conversion
SELECT 1 + '2';  -- Result: 3 (string '2' converted to int)
SELECT '2024' + 1;  -- Result: 2025
```

### Explicit Conversion
```sql
-- CAST function
SELECT CAST('123' AS INT) as number;
SELECT CAST(123.45 AS DECIMAL(10,2)) as decimal_num;

-- CONVERT function (MySQL)
SELECT CONVERT('2024-01-01', DATE) as date_value;

-- PostgreSQL casting
SELECT '123'::INTEGER as number;
SELECT 123.45::DECIMAL(10,2) as decimal_num;
```

---

## 📋 Data Type Selection Guidelines

### 1. Choose Appropriate Size
```sql
-- Good: Right-sized
CREATE TABLE users (
    age TINYINT,        -- 0-127 years
    zip_code VARCHAR(10) -- Varies by country
);

-- Bad: Over-sized
CREATE TABLE users (
    age BIGINT,         -- Wasteful for age
    zip_code VARCHAR(1000) -- Too large
);
```

### 2. Consider Performance
- Smaller data types = faster queries
- Fixed-length (CHAR) vs Variable-length (VARCHAR)
- Indexing considerations

### 3. Future-Proofing
- Consider potential data growth
- Don't assume current limits will always suffice

---

## 🛠️ Practical Examples

### Complete Table Creation
```sql
CREATE TABLE employees (
    -- Primary key
    employee_id INT PRIMARY KEY AUTO_INCREMENT,

    -- Personal information
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(20),

    -- Employment details
    hire_date DATE NOT NULL,
    salary DECIMAL(12,2),
    is_active BOOLEAN DEFAULT TRUE,

    -- Additional data
    department ENUM('IT', 'HR', 'Finance', 'Marketing'),
    manager_id INT,

    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    -- Foreign key
    FOREIGN KEY (manager_id) REFERENCES employees(employee_id)
);
```

---

## 📚 Practice Exercises

### Exercise 1: Data Type Selection
Design a table for an e-commerce system with appropriate data types:
- Product information (name, description, price, stock)
- Customer details (name, email, phone, address)
- Order information (order date, total amount, status)

### Exercise 2: Operator Practice
Write queries using various operators:
1. Find employees earning between 40K-80K
2. Find customers whose names start with 'A' or 'B'
3. Find orders placed in the last 30 days
4. Find products with stock less than 10 OR price > 1000

### Exercise 3: Type Conversion
Convert string dates to proper DATE format and calculate age.

---

## 🎯 Chapter Summary

- Choose data types based on data characteristics and usage
- Numeric, string, date/time, and special types available
- Operators enable data manipulation and filtering
- Type conversion helps handle different data formats
- Performance and storage efficiency depend on proper type selection
- Always consider future data growth and query patterns

---

## 🚀 Next Steps
- Master **DDL commands** (CREATE, ALTER, DROP)
- Learn **DML operations** (INSERT, UPDATE, DELETE)
- Practice with **real datasets**
- Understand **constraints and relationships**
