# 🔒 Chapter 11: Constraints and Keys - Data Integrity Management

## 🎯 Why Constraints Matter?

**Constraints** enforce **data integrity** and **business rules** in databases. They prevent invalid data entry and maintain consistency across related tables.

- **Data Integrity**: Ensure data accuracy and validity
- **Business Rules**: Enforce organizational policies
- **Relationships**: Maintain referential integrity between tables
- **Performance**: Help query optimization through indexes

---

## 🔑 Primary Key Constraints

### What is a Primary Key?
A **Primary Key** uniquely identifies each record in a table. It must be:
- **Unique** across all rows
- **Not NULL**
- **Immutable** (shouldn't change)

### Creating Primary Keys

```sql
-- Method 1: Column-level constraint
CREATE TABLE students (
    student_id INT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL
);

-- Method 2: Table-level constraint
CREATE TABLE students (
    student_id INT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    PRIMARY KEY (student_id)
);

-- Composite Primary Key
CREATE TABLE student_courses (
    student_id INT,
    course_id INT,
    semester VARCHAR(10),
    grade VARCHAR(2),
    PRIMARY KEY (student_id, course_id, semester)
);

-- Auto-increment Primary Key (MySQL)
CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2)
);

-- Auto-increment Primary Key (PostgreSQL)
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2)
);
```

### Primary Key Best Practices

```sql
-- Good: Meaningful primary key
CREATE TABLE orders (
    order_number VARCHAR(20) PRIMARY KEY, -- Business meaningful
    customer_id INT,
    order_date DATE
);

-- Avoid: Meaningless primary keys (unless necessary)
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT, -- Just a surrogate key
    email VARCHAR(255) UNIQUE NOT NULL, -- Could be natural key
    username VARCHAR(50) UNIQUE NOT NULL
);

-- Composite key when it makes business sense
CREATE TABLE flight_bookings (
    flight_number VARCHAR(10),
    passenger_id INT,
    booking_date DATE,
    seat_number VARCHAR(5),
    PRIMARY KEY (flight_number, passenger_id, booking_date)
);
```

---

## 🔗 Foreign Key Constraints

### What is a Foreign Key?
A **Foreign Key** creates a relationship between two tables by referencing a primary key in another table.

### Creating Foreign Keys

```sql
-- Basic Foreign Key
CREATE TABLE departments (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL
);

CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    department_id INT,
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

-- Foreign Key with ON DELETE/ON UPDATE actions
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- Named Foreign Key Constraint
CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    CONSTRAINT fk_order FOREIGN KEY (order_id) REFERENCES orders(order_id),
    CONSTRAINT fk_product FOREIGN KEY (product_id) REFERENCES products(product_id)
);
```

### Foreign Key Actions

| Action | Description | Use Case |
|--------|-------------|----------|
| **CASCADE** | Propagate changes to child records | Delete/update related records |
| **RESTRICT** | Prevent changes if child records exist | Maintain referential integrity |
| **SET NULL** | Set foreign key to NULL on parent change | Optional relationships |
| **SET DEFAULT** | Set foreign key to default value | Rarely used |
| **NO ACTION** | Defer constraint checking | Complex scenarios |

```sql
-- CASCADE Example
CREATE TABLE categories (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(100)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category_id INT,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
        ON DELETE CASCADE    -- Delete products when category is deleted
        ON UPDATE CASCADE    -- Update category_id when category changes
);

-- SET NULL Example
CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    manager_id INT,
    department_id INT,
    FOREIGN KEY (manager_id) REFERENCES employees(employee_id)
        ON DELETE SET NULL,  -- Employee's manager becomes NULL
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
        ON DELETE RESTRICT    -- Prevent department deletion if employees exist
);
```

---

## 🎯 Unique Constraints

### What is a Unique Constraint?
**Unique constraints** ensure that all values in a column (or combination of columns) are unique across all rows.

### Creating Unique Constraints

```sql
-- Single Column Unique
CREATE TABLE users (
    user_id INT PRIMARY KEY,
    email VARCHAR(255) UNIQUE,
    username VARCHAR(50) UNIQUE
);

-- Table-level Unique Constraint
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    sku VARCHAR(20),
    product_name VARCHAR(100),
    CONSTRAINT uk_sku UNIQUE (sku)
);

-- Composite Unique Constraint
CREATE TABLE employee_projects (
    employee_id INT,
    project_id INT,
    role VARCHAR(50),
    start_date DATE,
    PRIMARY KEY (employee_id, project_id),
    UNIQUE KEY uk_employee_role (employee_id, role) -- Employee can't have same role twice
);

-- Multiple Unique Constraints
CREATE TABLE contacts (
    contact_id INT PRIMARY KEY,
    email VARCHAR(255),
    phone VARCHAR(20),
    employee_id INT,
    UNIQUE KEY uk_email (email),
    UNIQUE KEY uk_phone (phone),
    UNIQUE KEY uk_employee_contact (employee_id, email), -- Employee can have only one email
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);
```

---

## ✅ Check Constraints

### What is a Check Constraint?
**Check constraints** validate data against a Boolean expression before allowing insertion or update.

### Creating Check Constraints

```sql
-- Basic Check Constraints
CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    age INT CHECK (age >= 18 AND age <= 65),
    salary DECIMAL(10,2) CHECK (salary > 0),
    hire_date DATE CHECK (hire_date <= CURDATE()),
    department_id INT CHECK (department_id > 0)
);

-- Named Check Constraints
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2),
    discount DECIMAL(3,2), -- 0.00 to 1.00
    stock_quantity INT,
    CONSTRAINT ck_price_positive CHECK (price > 0),
    CONSTRAINT ck_discount_range CHECK (discount BETWEEN 0.00 AND 1.00),
    CONSTRAINT ck_stock_non_negative CHECK (stock_quantity >= 0),
    CONSTRAINT ck_name_length CHECK (LENGTH(TRIM(product_name)) >= 2)
);

-- Complex Check Constraints
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    required_date DATE,
    shipped_date DATE,
    status ENUM('pending', 'processing', 'shipped', 'delivered'),
    CONSTRAINT ck_dates_order CHECK (order_date <= required_date),
    CONSTRAINT ck_shipped_after_order CHECK (shipped_date IS NULL OR shipped_date >= order_date),
    CONSTRAINT ck_status_dates CHECK (
        (status = 'pending' AND shipped_date IS NULL) OR
        (status IN ('processing', 'shipped', 'delivered') AND shipped_date IS NOT NULL)
    )
);

-- Salary validation with department-based rules
CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    department_id INT,
    salary DECIMAL(10,2),
    experience_years INT,
    CONSTRAINT ck_salary_dept_it CHECK (
        department_id != 1 OR salary >= 50000
    ), -- IT department minimum salary
    CONSTRAINT ck_salary_experience CHECK (
        experience_years < 2 OR salary >= 40000
    ), -- Experienced employees minimum salary
    CONSTRAINT ck_salary_range CHECK (salary BETWEEN 25000 AND 200000)
);
```

---

## 📊 Default Constraints

### What is a Default Constraint?
**Default constraints** specify default values for columns when no value is provided.

```sql
-- Default Values
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    account_balance DECIMAL(10,2) DEFAULT 0.00,
    user_role VARCHAR(20) DEFAULT 'user',
    last_login TIMESTAMP NULL
);

-- Default with Functions
CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'pending',
    total_amount DECIMAL(10,2) DEFAULT 0.00,
    created_by VARCHAR(50) DEFAULT USER(), -- MySQL
    created_by_pg VARCHAR(50) DEFAULT CURRENT_USER -- PostgreSQL
);

-- Default with Expressions
CREATE TABLE audit_log (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    table_name VARCHAR(50) NOT NULL,
    operation VARCHAR(10) NOT NULL,
    record_id INT NOT NULL,
    changed_by VARCHAR(50) DEFAULT USER(),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    old_value TEXT,
    new_value TEXT
);
```

---

## 🔧 Constraint Management

### Adding Constraints to Existing Tables

```sql
-- Add Primary Key
ALTER TABLE users ADD PRIMARY KEY (user_id);

-- Add Foreign Key
ALTER TABLE orders
ADD CONSTRAINT fk_customer
FOREIGN KEY (customer_id) REFERENCES customers(customer_id);

-- Add Unique Constraint
ALTER TABLE products ADD CONSTRAINT uk_sku UNIQUE (sku);

-- Add Check Constraint
ALTER TABLE employees
ADD CONSTRAINT ck_salary_positive CHECK (salary > 0);

-- Add Default Constraint
ALTER TABLE users
ALTER COLUMN is_active SET DEFAULT TRUE;
```

### Dropping Constraints

```sql
-- Drop Primary Key
ALTER TABLE users DROP PRIMARY KEY;

-- Drop Foreign Key (MySQL)
ALTER TABLE orders DROP FOREIGN KEY fk_customer;
ALTER TABLE orders DROP INDEX fk_customer; -- Sometimes required

-- Drop Foreign Key (PostgreSQL)
ALTER TABLE orders DROP CONSTRAINT fk_customer;

-- Drop Unique Constraint
ALTER TABLE products DROP INDEX uk_sku;

-- Drop Check Constraint
ALTER TABLE employees DROP CONSTRAINT ck_salary_positive;

-- Drop Default Constraint
ALTER TABLE users ALTER COLUMN is_active DROP DEFAULT;
```

### Disabling/Enabling Constraints

```sql
-- Disable Foreign Key (MySQL)
SET FOREIGN_KEY_CHECKS = 0;
-- Perform operations
SET FOREIGN_KEY_CHECKS = 1;

-- Disable Constraint (SQL Server)
ALTER TABLE orders NOCHECK CONSTRAINT fk_customer;
-- Enable back
ALTER TABLE orders CHECK CONSTRAINT fk_customer;

-- Disable All Constraints (PostgreSQL)
ALTER TABLE orders DISABLE TRIGGER ALL;
-- Enable back
ALTER TABLE orders ENABLE TRIGGER ALL;
```

---

## 📋 Constraint Best Practices

### 1. Naming Conventions

```sql
-- Good: Descriptive constraint names
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    product_id INT,
    CONSTRAINT pk_orders PRIMARY KEY (order_id),
    CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    CONSTRAINT fk_orders_product FOREIGN KEY (product_id) REFERENCES products(product_id),
    CONSTRAINT ck_orders_quantity CHECK (quantity > 0),
    CONSTRAINT uk_orders_customer_product UNIQUE (customer_id, product_id)
);

-- Avoid: Generic names
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    product_id INT,
    CONSTRAINT c1 FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    CONSTRAINT c2 CHECK (quantity > 0)
);
```

### 2. Constraint Order Matters

```sql
-- Good: Check constraints before foreign keys
CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    department_id INT,
    salary DECIMAL(10,2),
    hire_date DATE,

    -- Check constraints first (faster validation)
    CONSTRAINT ck_salary_positive CHECK (salary > 0),
    CONSTRAINT ck_hire_date_valid CHECK (hire_date <= CURDATE()),

    -- Foreign keys last (most expensive to validate)
    CONSTRAINT fk_department FOREIGN KEY (department_id) REFERENCES departments(department_id)
);
```

### 3. Performance Considerations

```sql
-- Good: Index foreign keys for performance
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    product_id INT,
    order_date DATE,
    total DECIMAL(10,2),

    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id),

    -- Indexes on foreign keys
    INDEX idx_customer_id (customer_id),
    INDEX idx_product_id (product_id),
    INDEX idx_order_date (order_date)
);

-- Good: Selective unique indexes
CREATE TABLE users (
    user_id INT PRIMARY KEY,
    email VARCHAR(255),
    username VARCHAR(50),
    phone VARCHAR(20),

    -- Unique constraints with indexes
    UNIQUE KEY uk_email (email),
    UNIQUE KEY uk_username (username),
    UNIQUE KEY uk_phone_active (phone, is_active) -- Partial unique
);
```

---

## 🛠️ Real-World Examples

### E-commerce System Constraints

```sql
CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    date_of_birth DATE,
    credit_limit DECIMAL(10,2) DEFAULT 1000.00,

    CONSTRAINT ck_email_format CHECK (email LIKE '%@%.%'),
    CONSTRAINT ck_age CHECK (date_of_birth <= CURDATE() - INTERVAL 18 YEAR),
    CONSTRAINT ck_credit_limit CHECK (credit_limit >= 0)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    sku VARCHAR(20) UNIQUE NOT NULL,
    product_name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    category_id INT,
    stock_quantity INT DEFAULT 0,
    reorder_level INT DEFAULT 10,

    CONSTRAINT ck_price_positive CHECK (price > 0),
    CONSTRAINT ck_stock_non_negative CHECK (stock_quantity >= 0),
    CONSTRAINT ck_reorder_level CHECK (reorder_level >= 0),
    CONSTRAINT fk_category FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    required_date DATE,
    shipped_date DATE,
    status ENUM('pending', 'processing', 'shipped', 'delivered', 'cancelled') DEFAULT 'pending',
    total_amount DECIMAL(10,2),

    CONSTRAINT fk_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    CONSTRAINT ck_dates_order CHECK (order_date <= required_date),
    CONSTRAINT ck_shipped_logic CHECK (
        (status IN ('pending', 'processing') AND shipped_date IS NULL) OR
        (status IN ('shipped', 'delivered') AND shipped_date IS NOT NULL AND shipped_date >= order_date)
    )
);
```

### Employee Management Constraints

```sql
CREATE TABLE departments (
    department_id INT PRIMARY KEY AUTO_INCREMENT,
    department_name VARCHAR(100) UNIQUE NOT NULL,
    budget DECIMAL(12,2),
    manager_id INT,

    CONSTRAINT ck_budget_positive CHECK (budget > 0),
    CONSTRAINT fk_manager FOREIGN KEY (manager_id) REFERENCES employees(employee_id)
);

CREATE TABLE employees (
    employee_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    department_id INT,
    manager_id INT,
    salary DECIMAL(10,2) NOT NULL,
    hire_date DATE NOT NULL,
    birth_date DATE,
    ssn VARCHAR(11) UNIQUE,

    CONSTRAINT ck_salary_range CHECK (salary BETWEEN 25000 AND 250000),
    CONSTRAINT ck_hire_date CHECK (hire_date >= '2000-01-01' AND hire_date <= CURDATE()),
    CONSTRAINT ck_birth_date CHECK (birth_date <= CURDATE() - INTERVAL 18 YEAR),
    CONSTRAINT ck_ssn_format CHECK (ssn REGEXP '^[0-9]{3}-[0-9]{2}-[0-9]{4}$'),
    CONSTRAINT fk_department FOREIGN KEY (department_id) REFERENCES departments(department_id),
    CONSTRAINT fk_manager FOREIGN KEY (manager_id) REFERENCES employees(employee_id),
    CONSTRAINT ck_no_self_manager CHECK (manager_id != employee_id),
    CONSTRAINT ck_department_salary CHECK (
        department_id != 1 OR salary >= 50000 -- IT department minimum
    )
);
```

---

## 📚 Practice Exercises

### Exercise 1: University Database Constraints
Create a university database with proper constraints:

```sql
-- Students table with constraints
CREATE TABLE students (
    student_id INT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(255) UNIQUE,
    enrollment_year YEAR,
    gpa DECIMAL(3,2),
    -- Add appropriate constraints
);

-- Courses table with constraints
CREATE TABLE courses (
    course_id INT PRIMARY KEY,
    course_code VARCHAR(10) UNIQUE,
    course_name VARCHAR(100),
    credits INT,
    department_id INT,
    -- Add appropriate constraints
);

-- Enrollments table with constraints
CREATE TABLE enrollments (
    enrollment_id INT PRIMARY KEY,
    student_id INT,
    course_id INT,
    semester VARCHAR(10),
    grade VARCHAR(2),
    -- Add appropriate constraints
);
```

### Exercise 2: E-commerce Constraints
Design constraints for an online store:

1. **Products**: Price > 0, stock >= 0, unique SKU
2. **Customers**: Valid email, age >= 18, credit limit >= 0
3. **Orders**: Order date <= required date, valid status transitions
4. **Order Items**: Quantity > 0, price matches product price
5. **Reviews**: Rating 1-5, one review per customer per product

### Exercise 3: Banking System Constraints
Create a banking database with strict constraints:

1. **Accounts**: Balance >= 0, account number format
2. **Transactions**: Amount > 0, valid account references
3. **Loans**: Interest rate 0-100%, approved amount limits
4. **Customers**: SSN format, age >= 18, credit score 300-850

---

## 🎯 Chapter Summary

- **Primary Keys**: Unique, non-null identifiers
- **Foreign Keys**: Maintain relationships between tables
- **Unique Constraints**: Ensure column value uniqueness
- **Check Constraints**: Validate data against business rules
- **Default Constraints**: Provide default values
- **Constraint Actions**: CASCADE, RESTRICT, SET NULL, NO ACTION
- **Performance**: Index foreign keys and selective constraints
- **Naming**: Use descriptive constraint names
- **Management**: Add/drop/enable/disable constraints as needed

---

## 🚀 Next Steps
- Learn **views** for simplified data access
- Master **indexes** for query performance
- Understand **triggers** for automatic actions
- Practice **stored procedures** for complex logic
- Implement **transactions** for data consistency
