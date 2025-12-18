# 🚀 Chapter 16: Practice Projects - Real-World SQL Applications

## 🎯 Why Practice Projects Matter?

**Practice projects** bridge the gap between learning SQL concepts and applying them in real-world scenarios. They help you:

- **Build complete applications** from database design to complex queries
- **Solve business problems** using SQL
- **Develop problem-solving skills** with data
- **Create portfolio pieces** for job applications
- **Understand full development lifecycle**

---

## 🏗️ Project 1: E-Commerce Platform Database

### Database Schema Design

```sql
-- Create database
CREATE DATABASE ecommerce_db;
USE ecommerce_db;

-- Users and Authentication
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);

-- Product Catalog
CREATE TABLE categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    parent_category_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_category_id) REFERENCES categories(category_id)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL CHECK (price > 0),
    category_id INT NOT NULL,
    stock_quantity INT DEFAULT 0 CHECK (stock_quantity >= 0),
    image_url VARCHAR(500),
    weight_kg DECIMAL(5,2),
    dimensions_cm VARCHAR(50),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

-- Shopping Cart and Orders
CREATE TABLE shopping_cart (
    cart_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    UNIQUE KEY uk_user_product (user_id, product_id)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10,2) NOT NULL,
    status ENUM('pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled') DEFAULT 'pending',
    shipping_address TEXT NOT NULL,
    billing_address TEXT NOT NULL,
    payment_method VARCHAR(50),
    tracking_number VARCHAR(100),
    notes TEXT,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) GENERATED ALWAYS AS (quantity * unit_price) STORED,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Reviews and Ratings
CREATE TABLE product_reviews (
    review_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    user_id INT NOT NULL,
    rating TINYINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    review_text TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_verified BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- Indexes for performance
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_products_price ON products(price);
CREATE INDEX idx_orders_user ON orders(user_id);
CREATE INDEX idx_orders_date ON orders(order_date);
CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_reviews_product ON product_reviews(product_id);
```

### Sample Data Insertion

```sql
-- Insert sample categories
INSERT INTO categories (category_name, description) VALUES
('Electronics', 'Electronic devices and gadgets'),
('Clothing', 'Fashion and apparel'),
('Books', 'Books and publications'),
('Home & Garden', 'Home improvement and garden supplies');

-- Insert sample products
INSERT INTO products (product_name, description, price, category_id, stock_quantity) VALUES
('Wireless Headphones', 'High-quality wireless headphones with noise cancellation', 199.99, 1, 50),
('Smart Watch', 'Fitness tracking smartwatch with heart rate monitor', 299.99, 1, 30),
('Cotton T-Shirt', 'Comfortable 100% cotton t-shirt', 24.99, 2, 100),
('Running Shoes', 'Lightweight running shoes for athletes', 129.99, 2, 75),
('SQL Mastery Book', 'Comprehensive guide to SQL programming', 49.99, 3, 25),
('Garden Hose', '50ft expandable garden hose', 39.99, 4, 40);

-- Insert sample users
INSERT INTO users (email, password_hash, first_name, last_name, phone) VALUES
('john.doe@email.com', 'hashed_password_1', 'John', 'Doe', '+1234567890'),
('jane.smith@email.com', 'hashed_password_2', 'Jane', 'Smith', '+1234567891'),
('bob.wilson@email.com', 'hashed_password_3', 'Bob', 'Wilson', '+1234567892');
```

### Business Intelligence Queries

```sql
-- 1. Top-selling products
SELECT
    p.product_name,
    SUM(oi.quantity) as total_sold,
    SUM(oi.total_price) as total_revenue,
    COUNT(DISTINCT o.user_id) as unique_customers,
    AVG(oi.unit_price) as avg_selling_price
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
LEFT JOIN orders o ON oi.order_id = o.order_id
WHERE o.status != 'cancelled'
GROUP BY p.product_id, p.product_name
ORDER BY total_revenue DESC
LIMIT 10;

-- 2. Customer lifetime value
SELECT
    u.first_name,
    u.last_name,
    u.email,
    COUNT(o.order_id) as total_orders,
    SUM(o.total_amount) as lifetime_value,
    AVG(o.total_amount) as avg_order_value,
    MAX(o.order_date) as last_order_date,
    DATEDIFF(CURDATE(), MIN(o.order_date)) as customer_age_days
FROM users u
LEFT JOIN orders o ON u.user_id = o.user_id
WHERE o.status != 'cancelled'
GROUP BY u.user_id, u.first_name, u.last_name, u.email
ORDER BY lifetime_value DESC;

-- 3. Monthly sales trend
SELECT
    DATE_FORMAT(o.order_date, '%Y-%m') as month,
    COUNT(DISTINCT o.order_id) as orders_count,
    COUNT(DISTINCT o.user_id) as unique_customers,
    SUM(o.total_amount) as total_revenue,
    AVG(o.total_amount) as avg_order_value,
    SUM(oi.quantity) as total_items_sold
FROM orders o
LEFT JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status != 'cancelled'
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY month;

-- 4. Product performance by category
SELECT
    c.category_name,
    COUNT(DISTINCT p.product_id) as products_count,
    SUM(oi.quantity) as total_units_sold,
    SUM(oi.total_price) as total_revenue,
    AVG(p.price) as avg_product_price,
    COUNT(pr.review_id) as total_reviews,
    AVG(pr.rating) as avg_rating
FROM categories c
LEFT JOIN products p ON c.category_id = p.category_id
LEFT JOIN order_items oi ON p.product_id = oi.product_id
LEFT JOIN orders o ON oi.order_id = o.order_id AND o.status != 'cancelled'
LEFT JOIN product_reviews pr ON p.product_id = pr.product_id
GROUP BY c.category_id, c.category_name
ORDER BY total_revenue DESC;

-- 5. Inventory management alerts
SELECT
    p.product_name,
    p.stock_quantity as current_stock,
    COALESCE(SUM(oi.quantity), 0) as sold_last_30_days,
    CASE
        WHEN p.stock_quantity = 0 THEN 'Out of Stock'
        WHEN p.stock_quantity <= 10 THEN 'Critical'
        WHEN p.stock_quantity <= 25 THEN 'Low'
        ELSE 'Normal'
    END as stock_status,
    CASE
        WHEN COALESCE(SUM(oi.quantity), 0) > 0
        THEN ROUND(p.stock_quantity / (SUM(oi.quantity) / 30.0), 1)
        ELSE NULL
    END as estimated_days_remaining
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
LEFT JOIN orders o ON oi.order_id = o.order_id
    AND o.order_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
    AND o.status != 'cancelled'
GROUP BY p.product_id, p.product_name, p.stock_quantity
HAVING stock_quantity <= 25 OR stock_quantity = 0
ORDER BY stock_quantity, sold_last_30_days DESC;
```

---

## 🏢 Project 2: Employee Management System

### Database Schema

```sql
CREATE DATABASE employee_management;
USE employee_management;

CREATE TABLE departments (
    department_id INT PRIMARY KEY AUTO_INCREMENT,
    department_name VARCHAR(100) UNIQUE NOT NULL,
    manager_id INT,
    budget DECIMAL(12,2),
    location VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE employees (
    employee_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    hire_date DATE NOT NULL,
    salary DECIMAL(10,2) NOT NULL CHECK (salary > 0),
    department_id INT NOT NULL,
    manager_id INT,
    job_title VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (department_id) REFERENCES departments(department_id),
    FOREIGN KEY (manager_id) REFERENCES employees(employee_id)
);

CREATE TABLE salaries (
    salary_id INT PRIMARY KEY AUTO_INCREMENT,
    employee_id INT NOT NULL,
    salary_amount DECIMAL(10,2) NOT NULL,
    effective_date DATE NOT NULL,
    end_date DATE,
    salary_type ENUM('base', 'bonus', 'commission') DEFAULT 'base',

    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

CREATE TABLE projects (
    project_id INT PRIMARY KEY AUTO_INCREMENT,
    project_name VARCHAR(255) NOT NULL,
    description TEXT,
    start_date DATE,
    end_date DATE,
    budget DECIMAL(12,2),
    status ENUM('planning', 'active', 'completed', 'cancelled') DEFAULT 'planning',
    department_id INT,

    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

CREATE TABLE project_assignments (
    assignment_id INT PRIMARY KEY AUTO_INCREMENT,
    project_id INT NOT NULL,
    employee_id INT NOT NULL,
    role VARCHAR(100),
    allocation_percentage DECIMAL(5,2) CHECK (allocation_percentage BETWEEN 0 AND 100),
    start_date DATE,
    end_date DATE,

    FOREIGN KEY (project_id) REFERENCES projects(project_id),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    UNIQUE KEY uk_employee_project (employee_id, project_id)
);

CREATE TABLE attendance (
    attendance_id INT PRIMARY KEY AUTO_INCREMENT,
    employee_id INT NOT NULL,
    attendance_date DATE NOT NULL,
    check_in_time TIME,
    check_out_time TIME,
    hours_worked DECIMAL(4,2),
    status ENUM('present', 'absent', 'half_day', 'leave') DEFAULT 'present',

    FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    UNIQUE KEY uk_employee_date (employee_id, attendance_date)
);

-- Performance and reviews
CREATE TABLE performance_reviews (
    review_id INT PRIMARY KEY AUTO_INCREMENT,
    employee_id INT NOT NULL,
    reviewer_id INT NOT NULL,
    review_date DATE NOT NULL,
    rating DECIMAL(3,2) CHECK (rating BETWEEN 1 AND 5),
    comments TEXT,
    goals TEXT,

    FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    FOREIGN KEY (reviewer_id) REFERENCES employees(employee_id)
);
```

### Advanced Analytics Queries

```sql
-- 1. Employee performance dashboard
SELECT
    e.first_name,
    e.last_name,
    e.job_title,
    d.department_name,
    TIMESTAMPDIFF(YEAR, e.hire_date, CURDATE()) as years_of_service,
    AVG(pr.rating) as avg_performance_rating,
    COUNT(pa.project_id) as active_projects,
    SUM(pa.allocation_percentage) as total_allocation,
    AVG(a.hours_worked) as avg_daily_hours,
    COUNT(CASE WHEN a.status = 'present' THEN 1 END) / COUNT(a.attendance_id) * 100 as attendance_rate
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id
LEFT JOIN performance_reviews pr ON e.employee_id = pr.employee_id
LEFT JOIN project_assignments pa ON e.employee_id = pa.employee_id
    AND pa.end_date IS NULL
LEFT JOIN attendance a ON e.employee_id = a.employee_id
    AND a.attendance_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
WHERE e.is_active = TRUE
GROUP BY e.employee_id, e.first_name, e.last_name, e.job_title, d.department_name, e.hire_date;

-- 2. Department productivity analysis
SELECT
    d.department_name,
    COUNT(DISTINCT e.employee_id) as total_employees,
    COUNT(DISTINCT p.project_id) as active_projects,
    AVG(e.salary) as avg_salary,
    SUM(d.budget) as department_budget,
    AVG(pr.rating) as avg_performance_rating,
    COUNT(pa.assignment_id) as total_assignments,
    AVG(pa.allocation_percentage) as avg_allocation,
    COUNT(CASE WHEN a.status = 'present' THEN 1 END) / COUNT(a.attendance_id) * 100 as attendance_rate
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id AND e.is_active = TRUE
LEFT JOIN projects p ON d.department_id = p.department_id AND p.status = 'active'
LEFT JOIN performance_reviews pr ON e.employee_id = pr.employee_id
LEFT JOIN project_assignments pa ON e.employee_id = pa.employee_id
LEFT JOIN attendance a ON e.employee_id = a.employee_id
    AND a.attendance_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
GROUP BY d.department_id, d.department_name;

-- 3. Salary analysis and recommendations
WITH salary_analysis AS (
    SELECT
        e.employee_id,
        e.first_name,
        e.last_name,
        e.job_title,
        e.salary as current_salary,
        d.department_name,
        TIMESTAMPDIFF(YEAR, e.hire_date, CURDATE()) as years_experience,
        AVG(pr.rating) as performance_rating,
        AVG(s.salary_amount) as historical_avg_salary,
        ROW_NUMBER() OVER (PARTITION BY e.job_title ORDER BY e.salary DESC) as salary_rank_in_job,
        COUNT(*) OVER (PARTITION BY e.job_title) as peers_in_job
    FROM employees e
    LEFT JOIN departments d ON e.department_id = d.department_id
    LEFT JOIN performance_reviews pr ON e.employee_id = pr.employee_id
    LEFT JOIN salaries s ON e.employee_id = s.employee_id
    WHERE e.is_active = TRUE
    GROUP BY e.employee_id, e.first_name, e.last_name, e.job_title, e.salary, d.department_name, e.hire_date
)
SELECT
    *,
    CASE
        WHEN performance_rating >= 4.5 AND years_experience >= 3 THEN 'High Priority Raise'
        WHEN performance_rating >= 4.0 AND salary_rank_in_job > peers_in_job * 0.8 THEN 'Consider Raise'
        WHEN performance_rating < 3.0 THEN 'Performance Review Needed'
        ELSE 'Monitor'
    END as salary_recommendation,
    CASE
        WHEN performance_rating >= 4.5 THEN current_salary * 0.08
        WHEN performance_rating >= 4.0 THEN current_salary * 0.05
        ELSE 0
    END as recommended_raise
FROM salary_analysis
ORDER BY recommended_raise DESC;

-- 4. Project resource allocation report
SELECT
    p.project_name,
    p.status,
    p.budget,
    DATEDIFF(p.end_date, CURDATE()) as days_remaining,
    COUNT(pa.employee_id) as assigned_employees,
    SUM(pa.allocation_percentage) as total_allocation_percentage,
    AVG(e.salary * pa.allocation_percentage / 100) as avg_allocated_salary_cost,
    GROUP_CONCAT(CONCAT(e.first_name, ' ', e.last_name, ' (', pa.allocation_percentage, '%)')
                 ORDER BY pa.allocation_percentage DESC SEPARATOR ', ') as team_members
FROM projects p
LEFT JOIN project_assignments pa ON p.project_id = pa.project_id
LEFT JOIN employees e ON pa.employee_id = e.employee_id
WHERE p.status IN ('planning', 'active')
GROUP BY p.project_id, p.project_name, p.status, p.budget, p.end_date
ORDER BY days_remaining, total_allocation_percentage DESC;
```

---

## 📚 Project 3: Library Management System

### Database Design

```sql
CREATE DATABASE library_management;
USE library_management;

CREATE TABLE authors (
    author_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    birth_date DATE,
    nationality VARCHAR(50),
    biography TEXT
);

CREATE TABLE publishers (
    publisher_id INT PRIMARY KEY AUTO_INCREMENT,
    publisher_name VARCHAR(255) NOT NULL,
    address TEXT,
    phone VARCHAR(20),
    email VARCHAR(255)
);

CREATE TABLE books (
    book_id INT PRIMARY KEY AUTO_INCREMENT,
    isbn VARCHAR(20) UNIQUE,
    title VARCHAR(500) NOT NULL,
    author_id INT NOT NULL,
    publisher_id INT,
    publication_year YEAR,
    genre VARCHAR(50),
    pages INT,
    language VARCHAR(30) DEFAULT 'English',
    description TEXT,
    cover_image_url VARCHAR(500),
    total_copies INT DEFAULT 1,
    available_copies INT DEFAULT 1,
    price DECIMAL(8,2),

    FOREIGN KEY (author_id) REFERENCES authors(author_id),
    FOREIGN KEY (publisher_id) REFERENCES publishers(publisher_id)
);

CREATE TABLE members (
    member_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    address TEXT,
    membership_date DATE NOT NULL,
    membership_type ENUM('regular', 'premium', 'student') DEFAULT 'regular',
    max_books_allowed INT DEFAULT 3,
    is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE loans (
    loan_id INT PRIMARY KEY AUTO_INCREMENT,
    book_id INT NOT NULL,
    member_id INT NOT NULL,
    loan_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE,
    fine_amount DECIMAL(6,2) DEFAULT 0,
    status ENUM('active', 'returned', 'overdue') DEFAULT 'active',

    FOREIGN KEY (book_id) REFERENCES books(book_id),
    FOREIGN KEY (member_id) REFERENCES members(member_id)
);

CREATE TABLE reservations (
    reservation_id INT PRIMARY KEY AUTO_INCREMENT,
    book_id INT NOT NULL,
    member_id INT NOT NULL,
    reservation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('active', 'fulfilled', 'cancelled') DEFAULT 'active',
    expiry_date DATE,

    FOREIGN KEY (book_id) REFERENCES books(book_id),
    FOREIGN KEY (member_id) REFERENCES members(member_id),
    UNIQUE KEY uk_member_book_active (member_id, book_id, status)
);
```

### Advanced Library Queries

```sql
-- 1. Book availability and loan status
SELECT
    b.title,
    CONCAT(a.first_name, ' ', a.last_name) as author,
    b.genre,
    b.total_copies,
    b.available_copies,
    COUNT(CASE WHEN l.status = 'active' THEN 1 END) as currently_loaned,
    COUNT(CASE WHEN l.return_date IS NULL AND l.due_date < CURDATE() THEN 1 END) as overdue_copies,
    COUNT(r.reservation_id) as active_reservations,
    CASE
        WHEN b.available_copies > 0 THEN 'Available'
        WHEN COUNT(r.reservation_id) > 0 THEN 'Reserved'
        ELSE 'Not Available'
    END as availability_status
FROM books b
LEFT JOIN authors a ON b.author_id = a.author_id
LEFT JOIN loans l ON b.book_id = l.book_id AND l.status = 'active'
LEFT JOIN reservations r ON b.book_id = r.book_id AND r.status = 'active'
GROUP BY b.book_id, b.title, a.first_name, a.last_name, b.genre, b.total_copies, b.available_copies;

-- 2. Member borrowing history and fines
SELECT
    m.first_name,
    m.last_name,
    m.membership_type,
    COUNT(l.loan_id) as total_loans,
    COUNT(CASE WHEN l.return_date IS NOT NULL THEN 1 END) as books_returned,
    COUNT(CASE WHEN l.return_date IS NULL AND l.due_date < CURDATE() THEN 1 END) as overdue_books,
    SUM(l.fine_amount) as total_fines,
    AVG(DATEDIFF(COALESCE(l.return_date, CURDATE()), l.loan_date)) as avg_loan_duration,
    MAX(l.loan_date) as last_loan_date,
    CASE
        WHEN COUNT(CASE WHEN l.return_date IS NULL AND l.due_date < CURDATE() THEN 1 END) > 0
        THEN 'Has Overdue Books'
        WHEN SUM(l.fine_amount) > 10 THEN 'High Fines'
        ELSE 'Good Standing'
    END as member_status
FROM members m
LEFT JOIN loans l ON m.member_id = l.member_id
WHERE m.is_active = TRUE
GROUP BY m.member_id, m.first_name, m.last_name, m.membership_type
ORDER BY total_fines DESC, overdue_books DESC;

-- 3. Popular books and genres analysis
SELECT
    b.genre,
    COUNT(DISTINCT b.book_id) as total_books,
    SUM(b.total_copies) as total_copies,
    COUNT(l.loan_id) as total_loans,
    COUNT(DISTINCT l.member_id) as unique_borrowers,
    ROUND(COUNT(l.loan_id) / COUNT(DISTINCT b.book_id), 2) as avg_loans_per_book,
    ROUND(COUNT(l.loan_id) / COUNT(DISTINCT l.member_id), 2) as avg_loans_per_member,
    GROUP_CONCAT(DISTINCT CONCAT(a.first_name, ' ', a.last_name) LIMIT 3) as top_authors
FROM books b
LEFT JOIN authors a ON b.author_id = a.author_id
LEFT JOIN loans l ON b.book_id = l.book_id
GROUP BY b.genre
ORDER BY total_loans DESC;

-- 4. Overdue books and fine calculation
SELECT
    l.loan_id,
    m.first_name,
    m.last_name,
    m.email,
    b.title,
    CONCAT(a.first_name, ' ', a.last_name) as author,
    l.loan_date,
    l.due_date,
    DATEDIFF(CURDATE(), l.due_date) as days_overdue,
    CASE
        WHEN DATEDIFF(CURDATE(), l.due_date) <= 7 THEN 2.00
        WHEN DATEDIFF(CURDATE(), l.due_date) <= 14 THEN 5.00
        ELSE 5.00 + (DATEDIFF(CURDATE(), l.due_date) - 14) * 1.00
    END as calculated_fine,
    l.fine_amount as current_fine,
    CASE
        WHEN DATEDIFF(CURDATE(), l.due_date) > 30 THEN 'Critical'
        WHEN DATEDIFF(CURDATE(), l.due_date) > 14 THEN 'High'
        WHEN DATEDIFF(CURDATE(), l.due_date) > 7 THEN 'Medium'
        ELSE 'Low'
    END as priority_level
FROM loans l
JOIN members m ON l.member_id = m.member_id
JOIN books b ON l.book_id = b.book_id
JOIN authors a ON b.author_id = a.author_id
WHERE l.return_date IS NULL
    AND l.due_date < CURDATE()
ORDER BY days_overdue DESC, calculated_fine DESC;
```

---

## 🎯 Project 4: Student Information System

### Database Schema

```sql
CREATE DATABASE student_management;
USE student_management;

-- Basic student information
CREATE TABLE students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    date_of_birth DATE NOT NULL,
    gender ENUM('M', 'F', 'Other'),
    address TEXT,
    enrollment_date DATE NOT NULL,
    graduation_date DATE,
    status ENUM('active', 'inactive', 'graduated', 'suspended') DEFAULT 'active'
);

-- Academic structure
CREATE TABLE departments (
    department_id INT PRIMARY KEY AUTO_INCREMENT,
    department_name VARCHAR(100) UNIQUE NOT NULL,
    head_id INT,
    budget DECIMAL(12,2)
);

CREATE TABLE courses (
    course_id INT PRIMARY KEY AUTO_INCREMENT,
    course_code VARCHAR(20) UNIQUE NOT NULL,
    course_name VARCHAR(200) NOT NULL,
    department_id INT NOT NULL,
    credits INT NOT NULL CHECK (credits > 0),
    description TEXT,
    max_students INT DEFAULT 50,

    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

CREATE TABLE instructors (
    instructor_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    department_id INT NOT NULL,
    hire_date DATE NOT NULL,
    salary DECIMAL(10,2),

    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

-- Enrollment and grades
CREATE TABLE enrollments (
    enrollment_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    instructor_id INT NOT NULL,
    semester VARCHAR(20) NOT NULL,
    year YEAR NOT NULL,
    enrollment_date DATE DEFAULT (CURRENT_DATE),
    grade VARCHAR(2),
    status ENUM('enrolled', 'completed', 'dropped', 'failed') DEFAULT 'enrolled',

    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id),
    FOREIGN KEY (instructor_id) REFERENCES instructors(instructor_id),
    UNIQUE KEY uk_student_course_semester (student_id, course_id, semester, year)
);

CREATE TABLE grades (
    grade_id INT PRIMARY KEY AUTO_INCREMENT,
    enrollment_id INT NOT NULL,
    assignment_name VARCHAR(100),
    max_points DECIMAL(5,2),
    earned_points DECIMAL(5,2),
    weight DECIMAL(4,3), -- Percentage weight in final grade
    due_date DATE,
    submission_date DATE,

    FOREIGN KEY (enrollment_id) REFERENCES enrollments(enrollment_id)
);
```

### Academic Performance Queries

```sql
-- 1. Student GPA calculation
SELECT
    s.student_id,
    CONCAT(s.first_name, ' ', s.last_name) as student_name,
    COUNT(e.enrollment_id) as courses_completed,
    ROUND(AVG(
        CASE e.grade
            WHEN 'A' THEN 4.0
            WHEN 'A-' THEN 3.7
            WHEN 'B+' THEN 3.3
            WHEN 'B' THEN 3.0
            WHEN 'B-' THEN 2.7
            WHEN 'C+' THEN 2.3
            WHEN 'C' THEN 2.0
            WHEN 'C-' THEN 1.7
            WHEN 'D+' THEN 1.3
            WHEN 'D' THEN 1.0
            WHEN 'F' THEN 0.0
            ELSE NULL
        END
    ), 2) as gpa,
    SUM(c.credits) as total_credits,
    COUNT(CASE WHEN e.grade IN ('A', 'A-', 'B+', 'B') THEN 1 END) as honors_courses,
    MAX(e.year) as current_year
FROM students s
LEFT JOIN enrollments e ON s.student_id = e.student_id AND e.status = 'completed'
LEFT JOIN courses c ON e.course_id = c.course_id
WHERE s.status = 'active'
GROUP BY s.student_id, s.first_name, s.last_name
HAVING COUNT(e.enrollment_id) > 0
ORDER BY gpa DESC;

-- 2. Course performance analysis
SELECT
    c.course_code,
    c.course_name,
    d.department_name,
    CONCAT(i.first_name, ' ', i.last_name) as instructor,
    COUNT(e.enrollment_id) as enrolled_students,
    COUNT(CASE WHEN e.grade IN ('A', 'A-') THEN 1 END) as a_grades,
    COUNT(CASE WHEN e.grade IN ('B+', 'B', 'B-') THEN 1 END) as b_grades,
    COUNT(CASE WHEN e.grade IN ('C+', 'C', 'C-') THEN 1 END) as c_grades,
    COUNT(CASE WHEN e.grade IN ('D+', 'D', 'F') THEN 1 END) as d_f_grades,
    ROUND(AVG(
        CASE e.grade
            WHEN 'A' THEN 4.0 WHEN 'A-' THEN 3.7 WHEN 'B+' THEN 3.3
            WHEN 'B' THEN 3.0 WHEN 'B-' THEN 2.7 WHEN 'C+' THEN 2.3
            WHEN 'C' THEN 2.0 WHEN 'C-' THEN 1.7 WHEN 'D+' THEN 1.3
            WHEN 'D' THEN 1.0 WHEN 'F' THEN 0.0
        END
    ), 2) as avg_gpa,
    ROUND(
        COUNT(CASE WHEN e.grade IN ('A', 'A-') THEN 1 END) / COUNT(e.enrollment_id) * 100,
    1) as excellence_rate
FROM courses c
LEFT JOIN departments d ON c.department_id = d.department_id
LEFT JOIN enrollments e ON c.course_id = e.course_id AND e.status = 'completed'
LEFT JOIN instructors i ON e.instructor_id = i.instructor_id
GROUP BY c.course_id, c.course_code, c.course_name, d.department_name, i.first_name, i.last_name
ORDER BY excellence_rate DESC, enrolled_students DESC;

-- 3. Student progress tracking
WITH student_progress AS (
    SELECT
        s.student_id,
        s.first_name,
        s.last_name,
        e.semester,
        e.year,
        COUNT(e.enrollment_id) as courses_taken,
        COUNT(CASE WHEN e.status = 'completed' THEN 1 END) as courses_completed,
        SUM(CASE WHEN e.status = 'completed' THEN c.credits ELSE 0 END) as credits_earned,
        ROUND(AVG(
            CASE e.grade
                WHEN 'A' THEN 4.0 WHEN 'A-' THEN 3.7 WHEN 'B+' THEN 3.3
                WHEN 'B' THEN 3.0 WHEN 'B-' THEN 2.7 WHEN 'C+' THEN 2.3
                WHEN 'C' THEN 2.0 WHEN 'C-' THEN 1.7 WHEN 'D+' THEN 1.3
                WHEN 'D' THEN 1.0 WHEN 'F' THEN 0.0
            END
        ), 2) as semester_gpa
    FROM students s
    LEFT JOIN enrollments e ON s.student_id = e.student_id
    LEFT JOIN courses c ON e.course_id = c.course_id
    WHERE s.status = 'active'
    GROUP BY s.student_id, s.first_name, s.last_name, e.semester, e.year
)
SELECT
    student_id,
    CONCAT(first_name, ' ', last_name) as student_name,
    semester,
    year,
    courses_taken,
    courses_completed,
    credits_earned,
    semester_gpa,
    ROUND(AVG(semester_gpa) OVER (PARTITION BY student_id ORDER BY year, semester ROWS UNBOUNDED PRECEDING), 2) as cumulative_gpa,
    SUM(credits_earned) OVER (PARTITION BY student_id ORDER BY year, semester) as total_credits
FROM student_progress
ORDER BY student_id, year, semester;

-- 4. Department performance metrics
SELECT
    d.department_name,
    COUNT(DISTINCT s.student_id) as total_students,
    COUNT(DISTINCT c.course_id) as courses_offered,
    COUNT(DISTINCT i.instructor_id) as instructors,
    COUNT(e.enrollment_id) as total_enrollments,
    ROUND(AVG(
        CASE e.grade
            WHEN 'A' THEN 4.0 WHEN 'A-' THEN 3.7 WHEN 'B+' THEN 3.3
            WHEN 'B' THEN 3.0 WHEN 'B-' THEN 2.7 WHEN 'C+' THEN 2.3
            WHEN 'C' THEN 2.0 WHEN 'C-' THEN 1.7 WHEN 'D+' THEN 1.3
            WHEN 'D' THEN 1.0 WHEN 'F' THEN 0.0
        END
    ), 2) as avg_department_gpa,
    COUNT(CASE WHEN e.grade IN ('A', 'A-') THEN 1 END) / COUNT(e.enrollment_id) * 100 as excellence_rate,
    ROUND(COUNT(e.enrollment_id) / COUNT(DISTINCT c.course_id), 1) as avg_enrollment_per_course
FROM departments d
LEFT JOIN courses c ON d.department_id = c.department_id
LEFT JOIN instructors i ON d.department_id = i.department_id
LEFT JOIN enrollments e ON c.course_id = e.course_id AND e.status = 'completed'
LEFT JOIN students s ON e.student_id = s.student_id
GROUP BY d.department_id, d.department_name
ORDER BY avg_department_gpa DESC;
```

---

## 🎯 Project Implementation Steps

### Phase 1: Planning and Design
1. **Understand Requirements**: Identify business needs and user stories
2. **Database Design**: Create ER diagrams and normalize tables
3. **Define Relationships**: Establish foreign keys and constraints
4. **Plan Queries**: Design complex analytical queries upfront

### Phase 2: Development
1. **Create Database Schema**: DDL commands for tables, indexes, constraints
2. **Insert Sample Data**: Populate tables with realistic test data
3. **Implement Basic CRUD**: Create, Read, Update, Delete operations
4. **Build Complex Queries**: JOINs, subqueries, aggregations, window functions

### Phase 3: Testing and Optimization
1. **Unit Testing**: Test individual queries and functions
2. **Performance Testing**: Analyze query execution plans
3. **Index Optimization**: Add appropriate indexes for performance
4. **Data Validation**: Ensure data integrity and consistency

### Phase 4: Advanced Features
1. **Stored Procedures**: Create reusable database procedures
2. **Triggers**: Implement automatic actions on data changes
3. **Views**: Create virtual tables for simplified access
4. **Security**: Implement user roles and permissions

### Phase 5: Documentation and Deployment
1. **Code Documentation**: Comment complex queries and procedures
2. **User Documentation**: Create guides for database usage
3. **Backup Strategy**: Implement regular backup procedures
4. **Monitoring**: Set up performance monitoring and alerts

---

## 📚 Additional Practice Ideas

### Mini Projects
- **Blog/Content Management System**
- **Inventory Tracking System**
- **Appointment Scheduling System**
- **Survey/Polling System**
- **Event Management Platform**

### Advanced Challenges
- **Multi-tenant SaaS Application**
- **Real-time Analytics Dashboard**
- **Recommendation Engine**
- **Geospatial Data Analysis**
- **Time Series Data Processing**

### Industry-Specific Projects
- **Healthcare**: Patient management, medical records
- **Finance**: Banking transactions, portfolio management
- **Retail**: Point of sale, customer loyalty programs
- **Education**: Learning management systems
- **Logistics**: Supply chain, inventory optimization

---

## 🎯 Final Project Assessment

### Criteria for Success
- **Complete Schema**: Proper normalization and relationships
- **Data Integrity**: Appropriate constraints and validations
- **Query Complexity**: Advanced JOINs, subqueries, aggregations
- **Performance**: Optimized queries with proper indexing
- **Business Logic**: Real-world applicable solutions
- **Code Quality**: Clean, well-documented SQL code

### Portfolio Development
- **GitHub Repository**: Version control and documentation
- **Demo Database**: Sample data for demonstration
- **Query Documentation**: Explanation of complex queries
- **Performance Analysis**: Query execution plans and optimization
- **Use Case Documentation**: Business scenarios addressed

---

Remember: **Practice makes perfect**. Start with small projects and gradually increase complexity. Focus on writing clean, efficient SQL code and understanding the business requirements behind each query.
