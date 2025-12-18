# 🏗️ Chapter 21: Database Normalization & Functional Dependencies

## 🎯 Why Database Normalization Matters?

**Database Normalization** is the process of organizing data in a relational database to **minimize redundancy**, **eliminate anomalies**, and **ensure data integrity**. It's a fundamental concept in database design that ensures your database is efficient, maintainable, and free from data inconsistencies.

---

## 📋 Prerequisites

Before diving into normalization, ensure you understand:
- **Relational Databases**: Tables, rows, columns, relationships
- **Keys**: Primary keys, foreign keys, candidate keys
- **SQL Basics**: CREATE TABLE, ALTER TABLE, constraints
- **Data Integrity**: Ensuring accurate and consistent data

---

## 🔍 Functional Dependencies (FDs)

**Functional Dependencies** form the foundation of normalization. They describe relationships between attributes in a relation.

### Definition
A **Functional Dependency (FD)** is denoted as `X → Y`, which means:
- **If two tuples have the same value for X, they must have the same value for Y**
- **X** is called the **determinant** or **left-hand side (LHS)**
- **Y** is called the **dependent** or **right-hand side (RHS)**

### Types of Functional Dependencies

#### 1. Trivial Functional Dependencies
Dependencies that are always true due to the nature of relational databases.

```sql
-- Examples:
Employee_ID → Employee_ID          -- Reflexive (always true)
Employee_ID, Name → Employee_ID    -- Augmentation (always true)
Employee_ID, Name → Name          -- Decomposition (always true)
```

#### 2. Non-Trivial Functional Dependencies
Dependencies that provide meaningful information about the data.

```sql
-- Examples:
Employee_ID → Employee_Name        -- Employee ID determines name
Employee_ID → Department_ID        -- Employee ID determines department
Department_ID → Department_Name    -- Department ID determines name
ISBN → Book_Title                  -- ISBN uniquely identifies book
```

#### 3. Completely Non-Trivial Functional Dependencies
Neither side is a subset of the other.

```sql
-- Examples:
Student_ID → GPA                   -- Student determines GPA
Course_ID → Instructor_Name        -- Course determines instructor
Product_ID → Unit_Price           -- Product determines price
```

### Special Types of FDs

#### Transitive Functional Dependencies
If `A → B` and `B → C`, then `A → C` (transitively)

```sql
-- Example:
Employee_ID → Department_ID        -- Direct dependency
Department_ID → Department_Name    -- Direct dependency
Employee_ID → Department_Name      -- Transitive dependency (inferred)
```

#### Partial Functional Dependencies
In a composite key, some non-key attributes depend on only part of the key.

```sql
-- Composite Key: (Student_ID, Course_ID)
Student_ID, Course_ID → Grade      -- Full dependency (both parts needed)
Student_ID → Student_Name          -- Partial dependency (only Student_ID needed)
Course_ID → Course_Name           -- Partial dependency (only Course_ID needed)
```

#### Multivalued Dependencies (MVDs)
One attribute determines multiple independent values of another attribute.

```sql
-- Example: Student can have multiple hobbies and skills
Student_ID →→ Hobbies              -- Multivalued dependency
Student_ID →→ Skills               -- Multivalued dependency

-- If a student has hobbies {Reading, Swimming} and skills {Java, Python}
-- Then they must also have skills {Java, Python} for hobbies {Reading, Swimming}
```

---

## 🏗️ Database Normalization Process

**Normalization** is the step-by-step process of transforming a database design into progressively better forms (normal forms) to eliminate redundancy and dependency issues.

### Step-by-Step Normalization Process

```
1. UNF (Unnormalized Form) → 1NF
2. 1NF → 2NF
3. 2NF → 3NF
4. 3NF → BCNF (if needed)
5. BCNF → 4NF (if needed)
6. 4NF → 5NF (if needed)
```

---

## 📊 First Normal Form (1NF)

### Definition
A relation is in **1NF** if it contains **only atomic (indivisible) values** and **no repeating groups**.

### Problems Solved by 1NF
- **Repeating Groups**: Multiple values in a single cell
- **Composite Attributes**: Multi-part attributes that should be separate
- **Array/List Values**: Storing multiple values as comma-separated strings

### 1NF Transformation Rules

#### Rule 1: Eliminate Repeating Groups
```sql
-- BEFORE (Violates 1NF - repeating groups)
CREATE TABLE Student_Courses_UNF (
    Student_ID INT,
    Student_Name VARCHAR(100),
    Courses VARCHAR(500)  -- "Math101,Physics201,Chemistry301"
);

-- AFTER (1NF compliant)
CREATE TABLE Student_Courses_1NF (
    Student_ID INT,
    Student_Name VARCHAR(100),
    Course_Code VARCHAR(20),
    Course_Name VARCHAR(100)
);
```

#### Rule 2: Ensure Atomic Values
```sql
-- BEFORE (Violates 1NF - non-atomic values)
CREATE TABLE Employees_UNF (
    Emp_ID INT,
    Name VARCHAR(100),
    Address VARCHAR(200)  -- "123 Main St, New York, NY 10001"
);

-- AFTER (1NF compliant)
CREATE TABLE Employees_1NF (
    Emp_ID INT,
    First_Name VARCHAR(50),
    Last_Name VARCHAR(50),
    Street_Address VARCHAR(100),
    City VARCHAR(50),
    State VARCHAR(20),
    Zip_Code VARCHAR(10)
);
```

#### Rule 3: Primary Key Requirement
Every table must have a **primary key** that uniquely identifies each row.

```sql
-- 1NF Table with Primary Key
CREATE TABLE Order_Items_1NF (
    Order_ID INT,
    Product_Code VARCHAR(20),
    Quantity INT,
    Unit_Price DECIMAL(10,2),
    PRIMARY KEY (Order_ID, Product_Code)  -- Composite primary key
);
```

### 1NF Checklist
- [ ] All attributes contain atomic (indivisible) values
- [ ] No repeating groups or arrays
- [ ] Each row is uniquely identifiable (primary key exists)
- [ ] No multi-valued attributes in single columns

---

## 🎯 Second Normal Form (2NF)

### Definition
A relation is in **2NF** if:
1. It is in **1NF**
2. **No partial dependencies** exist (every non-key attribute is fully functionally dependent on the entire primary key)

### Understanding Partial Dependencies

#### What is a Partial Dependency?
A **partial dependency** occurs when a non-key attribute depends on only **part** of a composite primary key, rather than the entire key.

```sql
-- Example: Composite Primary Key (Student_ID, Course_ID)
CREATE TABLE Student_Enrollments_1NF (
    Student_ID INT,
    Course_ID INT,
    Student_Name VARCHAR(100),      -- Depends only on Student_ID (partial!)
    Course_Name VARCHAR(100),       -- Depends only on Course_ID (partial!)
    Instructor_Name VARCHAR(100),   -- Depends only on Course_ID (partial!)
    Grade VARCHAR(2),
    PRIMARY KEY (Student_ID, Course_ID)
);

-- Partial Dependencies Identified:
Student_ID → Student_Name          -- Partial dependency
Course_ID → Course_Name           -- Partial dependency
Course_ID → Instructor_Name       -- Partial dependency
(Student_ID, Course_ID) → Grade   -- Full dependency (correct)
```

### 2NF Transformation Process

#### Step 1: Identify Partial Dependencies
Analyze each non-key attribute against the composite primary key.

#### Step 2: Create Separate Tables
Move partially dependent attributes to separate tables.

```sql
-- AFTER 2NF Normalization

-- Students table (remove partial dependency on Student_ID)
CREATE TABLE Students_2NF (
    Student_ID INT PRIMARY KEY,
    Student_Name VARCHAR(100),
    Email VARCHAR(255),
    Phone VARCHAR(20)
);

-- Courses table (remove partial dependency on Course_ID)
CREATE TABLE Courses_2NF (
    Course_ID INT PRIMARY KEY,
    Course_Name VARCHAR(100),
    Instructor_Name VARCHAR(100),
    Credits INT,
    Department VARCHAR(50)
);

-- Enrollments table (only full dependencies remain)
CREATE TABLE Enrollments_2NF (
    Student_ID INT,
    Course_ID INT,
    Enrollment_Date DATE,
    Grade VARCHAR(2),
    PRIMARY KEY (Student_ID, Course_ID),
    FOREIGN KEY (Student_ID) REFERENCES Students_2NF(Student_ID),
    FOREIGN KEY (Course_ID) REFERENCES Courses_2NF(Course_ID)
);
```

### 2NF Benefits
- ✅ **Eliminates Redundancy**: Student names stored once, not repeated per course
- ✅ **Prevents Update Anomalies**: Change student name in one place
- ✅ **Improves Data Integrity**: Consistent student and course information
- ✅ **Better Performance**: Smaller, focused tables

### 2NF Checklist
- [ ] Table is in 1NF
- [ ] No partial dependencies exist
- [ ] Every non-key attribute depends on the entire primary key
- [ ] Composite keys are properly handled

---

## 🎖️ Third Normal Form (3NF)

### Definition
A relation is in **3NF** if:
1. It is in **2NF**
2. **No transitive dependencies** exist (non-key attributes don't depend on other non-key attributes)

### Understanding Transitive Dependencies

#### What is a Transitive Dependency?
A **transitive dependency** occurs when a non-key attribute depends on another non-key attribute, which then determines other attributes.

```sql
-- BEFORE 3NF (Contains transitive dependencies)
CREATE TABLE Employees_2NF (
    Employee_ID INT PRIMARY KEY,
    Employee_Name VARCHAR(100),
    Department_ID INT,
    Department_Name VARCHAR(100),       -- Transitive! (Dept_ID → Dept_Name)
    Department_Location VARCHAR(100),   -- Transitive! (Dept_ID → Location)
    Salary DECIMAL(10,2)
);

-- Transitive Dependencies:
Employee_ID → Department_ID           -- OK (direct)
Department_ID → Department_Name       -- OK (lookup)
Department_ID → Department_Location   -- OK (lookup)
Employee_ID → Department_Name         -- Transitive! (through Department_ID)
Employee_ID → Department_Location     -- Transitive! (through Department_ID)
```

### 3NF Transformation Process

#### Step 1: Identify Transitive Dependencies
Look for non-key attributes that depend on other non-key attributes.

#### Step 2: Remove Transitive Dependencies
Create separate tables for the transitively dependent attributes.

```sql
-- AFTER 3NF Normalization

-- Employees table (only direct dependencies)
CREATE TABLE Employees_3NF (
    Employee_ID INT PRIMARY KEY,
    Employee_Name VARCHAR(100),
    Department_ID INT,
    Salary DECIMAL(10,2),
    Hire_Date DATE,
    FOREIGN KEY (Department_ID) REFERENCES Departments_3NF(Department_ID)
);

-- Departments table (lookup information)
CREATE TABLE Departments_3NF (
    Department_ID INT PRIMARY KEY,
    Department_Name VARCHAR(100),
    Department_Location VARCHAR(100),
    Manager_ID INT,
    Budget DECIMAL(12,2),
    FOREIGN KEY (Manager_ID) REFERENCES Employees_3NF(Employee_ID)
);
```

### 3NF Benefits
- ✅ **Eliminates Transitive Dependencies**: No indirect attribute relationships
- ✅ **Prevents Update Anomalies**: Department changes affect only department table
- ✅ **Improves Data Integrity**: Department information stored centrally
- ✅ **Supports Referential Integrity**: Proper foreign key relationships

### 3NF Checklist
- [ ] Table is in 2NF
- [ ] No transitive dependencies exist
- [ ] All non-key attributes depend directly on the primary key
- [ ] Lookup tables are properly separated

---

## 👑 Boyce-Codd Normal Form (BCNF)

### Definition
A relation is in **BCNF** if:
1. It is in **3NF**
2. **Every determinant is a candidate key** (no non-trivial functional dependencies where the determinant is not a superkey)

### Understanding BCNF Violations

#### What is a BCNF Violation?
BCNF violations occur when a non-key attribute determines another non-key attribute, or when there are multiple candidate keys with overlapping attributes.

```sql
-- BCNF Violation Example
CREATE TABLE Course_Instructors_3NF (
    Course_ID INT,
    Instructor_ID INT,
    Semester VARCHAR(10),
    Room_Number VARCHAR(10),
    PRIMARY KEY (Course_ID, Instructor_ID, Semester)
);

-- Functional Dependencies:
Course_ID → Room_Number              -- BCNF Violation!
(Course_ID, Instructor_ID, Semester) → (all attributes) -- Primary Key

-- Problem: Course_ID determines Room_Number, but Course_ID is not a candidate key
-- A course is always taught in the same room, regardless of instructor or semester
```

### BCNF Transformation Process

#### Step 1: Identify BCNF Violations
Look for determinants that are not candidate keys.

#### Step 2: Decompose Violating Tables
Split tables to ensure every determinant is a candidate key.

```sql
-- AFTER BCNF Normalization

-- Courses table (Course_ID is now a candidate key)
CREATE TABLE Courses_BCNF (
    Course_ID INT PRIMARY KEY,
    Course_Name VARCHAR(100),
    Room_Number VARCHAR(10),           -- Now depends on Course_ID (candidate key)
    Department VARCHAR(50),
    Credits INT
);

-- Course_Instructors table (handles instructor assignments)
CREATE TABLE Course_Instructors_BCNF (
    Course_ID INT,
    Instructor_ID INT,
    Semester VARCHAR(10),
    Enrollment_Count INT,
    PRIMARY KEY (Course_ID, Instructor_ID, Semester),
    FOREIGN KEY (Course_ID) REFERENCES Courses_BCNF(Course_ID),
    FOREIGN KEY (Instructor_ID) REFERENCES Instructors_BCNF(Instructor_ID)
);

-- Instructors table
CREATE TABLE Instructors_BCNF (
    Instructor_ID INT PRIMARY KEY,
    Instructor_Name VARCHAR(100),
    Department VARCHAR(50),
    Email VARCHAR(255)
);
```

### BCNF vs 3NF
- **3NF**: Eliminates transitive dependencies
- **BCNF**: Stricter than 3NF, eliminates all non-trivial dependencies where determinant isn't a candidate key

### When to Use BCNF
- ✅ **Academic Settings**: Theoretical purity
- ✅ **Complex Schemas**: Multiple candidate keys
- ✅ **Data Warehousing**: Strict normalization requirements
- ⚠️ **Not Always Practical**: May lead to excessive decomposition

---

## 🔢 Fourth Normal Form (4NF)

### Definition
A relation is in **4NF** if:
1. It is in **BCNF**
2. **No multivalued dependencies** exist

### Understanding Multivalued Dependencies (MVDs)

#### What is a Multivalued Dependency?
A **multivalued dependency** `X →→ Y` means that for each value of X, there is a set of values for Y that are independent of each other.

```sql
-- 4NF Violation Example
CREATE TABLE Student_Activities_BCNF (
    Student_ID INT,
    Hobby VARCHAR(50),
    Skill VARCHAR(50),
    PRIMARY KEY (Student_ID, Hobby, Skill)
);

-- Multivalued Dependencies:
Student_ID →→ Hobby      -- Student has multiple independent hobbies
Student_ID →→ Skill      -- Student has multiple independent skills

-- The problem: If a student has hobbies {Reading, Swimming}
-- and skills {Java, Python}, then the table must contain:
-- (Student1, Reading, Java), (Student1, Reading, Python),
-- (Student1, Swimming, Java), (Student1, Swimming, Python)
```

### 4NF Transformation Process

#### Step 1: Identify Multivalued Dependencies
Look for attributes that have independent multiple values.

#### Step 2: Decompose MVDs
Split tables so each table contains only one multivalued dependency.

```sql
-- AFTER 4NF Normalization

-- Student_Hobbies table (isolates hobby MVD)
CREATE TABLE Student_Hobbies_4NF (
    Student_ID INT,
    Hobby VARCHAR(50),
    PRIMARY KEY (Student_ID, Hobby),
    FOREIGN KEY (Student_ID) REFERENCES Students_4NF(Student_ID)
);

-- Student_Skills table (isolates skill MVD)
CREATE TABLE Student_Skills_4NF (
    Student_ID INT,
    Skill VARCHAR(50),
    PRIMARY KEY (Student_ID, Skill),
    FOREIGN KEY (Student_ID) REFERENCES Students_4NF(Student_ID)
);

-- Students table (base information)
CREATE TABLE Students_4NF (
    Student_ID INT PRIMARY KEY,
    Student_Name VARCHAR(100),
    Email VARCHAR(255),
    Enrollment_Date DATE
);
```

### 4NF Benefits
- ✅ **Eliminates Redundant Data**: No forced combinations of independent attributes
- ✅ **Prevents Anomalies**: Independent attributes don't create false relationships
- ✅ **Cleaner Semantics**: Each relationship is properly represented

### When 4NF Matters
- Rare in practice, but important for:
- **Survey Data**: Multiple independent responses
- **Product Features**: Independent product attributes
- **User Preferences**: Multiple independent preference categories

---

## 🏆 Fifth Normal Form (5NF)

### Definition
A relation is in **5NF** (also called **Project-Join Normal Form**) if:
1. It is in **4NF**
2. **Every join dependency** is implied by the candidate keys

### Understanding Join Dependencies

#### What is a Join Dependency?
A **join dependency** means that a relation can be losslessly decomposed into multiple relations, and the original relation can be reconstructed by joining them back.

```sql
-- 5NF Violation Example (Lossy Decomposition)
CREATE TABLE Project_Assignments_4NF (
    Employee_ID INT,
    Project_ID INT,
    Skill_ID INT,
    Hours_Worked INT,
    PRIMARY KEY (Employee_ID, Project_ID, Skill_ID)
);

-- This might have a join dependency that can be decomposed into:
-- (Employee_ID, Project_ID, Hours_Worked)
-- (Employee_ID, Skill_ID)
-- (Project_ID, Skill_ID)
-- But reconstructing might lose information
```

### 5NF Transformation Process

#### Step 1: Identify Join Dependencies
Test if the relation can be decomposed without losing information.

#### Step 2: Apply Lossless Decomposition
Ensure that joining the decomposed relations recreates the original relation exactly.

### 5NF Practicality
- **Theoretical Importance**: Ensures perfect decomposition
- **Rarely Used in Practice**: Most real-world databases stop at 3NF or BCNF
- **Performance Considerations**: Over-normalization can hurt performance

---

## 🛠️ Normalization Tools and Techniques

### Dependency Analysis

#### 1. Finding Functional Dependencies
```sql
-- Analyze existing data to find FDs
SELECT Student_ID, COUNT(DISTINCT Student_Name) as name_count
FROM enrollments
GROUP BY Student_ID
HAVING COUNT(DISTINCT Student_Name) > 1;  -- Should be 1 if Student_ID → Student_Name
```

#### 2. Testing Normalization
```sql
-- Check for partial dependencies
-- Look for non-key attributes that depend on part of composite key

-- Check for transitive dependencies
-- Find chains of dependencies through non-key attributes
```

### Automated Normalization Tools

#### 1. Schema Design Tools
- **MySQL Workbench**: Visual schema design with normalization checking
- **pgAdmin**: PostgreSQL schema design and validation
- **ERwin**: Enterprise data modeling tool
- **ER/Studio**: Advanced normalization features

#### 2. Online Normalizers
- **Database Normalization Tool**: Web-based normalization checker
- **Normalization Calculator**: Automated dependency analysis

### Best Practices for Normalization

#### 1. Know When to Stop
```sql
-- Practical approach:
-- 1NF → 2NF → 3NF (sufficient for most applications)
-- BCNF → 4NF → 5NF (only when theoretically required)

-- Consider performance impact of over-normalization
```

#### 2. Document Your Design
```sql
-- Always document normalization decisions
/*
Normalization Decisions for Employee Database:
- Applied 1NF: Eliminated multi-valued phone numbers
- Applied 2NF: Separated employee and department info
- Applied 3NF: Removed transitive dependencies on department data
- Stopped at 3NF: Performance considerations for reporting queries
*/
```

---

## 📊 Practical Examples

### E-commerce Database Normalization

#### UNF to 1NF
```sql
-- Unnormalized (contains repeating groups)
CREATE TABLE Orders_UNF (
    Order_ID INT,
    Customer_Info VARCHAR(500),  -- "John Doe,123 Main St,555-1234"
    Products VARCHAR(1000)       -- "Laptop:999.99,Qty:1;Mouse:29.99,Qty:2"
);

-- 1NF (atomic values, no repeating groups)
CREATE TABLE Orders_1NF (
    Order_ID INT,
    Customer_Name VARCHAR(100),
    Customer_Address VARCHAR(200),
    Customer_Phone VARCHAR(20),
    Product_Name VARCHAR(100),
    Unit_Price DECIMAL(10,2),
    Quantity INT
);
```

#### 1NF to 2NF
```sql
-- 2NF (eliminate partial dependencies)
CREATE TABLE Customers_2NF (
    Customer_ID INT PRIMARY KEY,
    Customer_Name VARCHAR(100),
    Customer_Address VARCHAR(200),
    Customer_Phone VARCHAR(20)
);

CREATE TABLE Products_2NF (
    Product_ID INT PRIMARY KEY,
    Product_Name VARCHAR(100),
    Unit_Price DECIMAL(10,2),
    Category VARCHAR(50)
);

CREATE TABLE Orders_2NF (
    Order_ID INT PRIMARY KEY,
    Customer_ID INT,
    Order_Date DATE,
    FOREIGN KEY (Customer_ID) REFERENCES Customers_2NF(Customer_ID)
);

CREATE TABLE Order_Items_2NF (
    Order_ID INT,
    Product_ID INT,
    Quantity INT,
    PRIMARY KEY (Order_ID, Product_ID),
    FOREIGN KEY (Order_ID) REFERENCES Orders_2NF(Order_ID),
    FOREIGN KEY (Product_ID) REFERENCES Products_2NF(Product_ID)
);
```

#### 2NF to 3NF
```sql
-- 3NF (eliminate transitive dependencies)
CREATE TABLE Categories_3NF (
    Category_ID INT PRIMARY KEY,
    Category_Name VARCHAR(50),
    Category_Description TEXT
);

-- Update Products_3NF to reference category
ALTER TABLE Products_2NF ADD COLUMN Category_ID INT;
ALTER TABLE Products_2NF ADD FOREIGN KEY (Category_ID) REFERENCES Categories_3NF(Category_ID);

-- This eliminates the transitive dependency: Product → Category_Name
-- Now: Product → Category_ID → Category_Name (proper normalization)
```

### Library Management System

#### Complete Normalization Example
```sql
-- 1NF: Atomic values
CREATE TABLE Books_1NF (
    ISBN VARCHAR(13),
    Title VARCHAR(200),
    Author_First VARCHAR(50),
    Author_Last VARCHAR(50),
    Publisher VARCHAR(100),
    Publication_Year YEAR,
    Genre VARCHAR(50),
    Copies_Available INT
);

-- 2NF: Eliminate partial dependencies
CREATE TABLE Authors_2NF (
    Author_ID INT PRIMARY KEY AUTO_INCREMENT,
    First_Name VARCHAR(50),
    Last_Name VARCHAR(50),
    Birth_Date DATE,
    Nationality VARCHAR(50)
);

CREATE TABLE Publishers_2NF (
    Publisher_ID INT PRIMARY KEY AUTO_INCREMENT,
    Publisher_Name VARCHAR(100),
    Address TEXT,
    Phone VARCHAR(20),
    Email VARCHAR(255)
);

CREATE TABLE Books_2NF (
    ISBN VARCHAR(13) PRIMARY KEY,
    Title VARCHAR(200),
    Author_ID INT,
    Publisher_ID INT,
    Publication_Year YEAR,
    Genre VARCHAR(50),
    FOREIGN KEY (Author_ID) REFERENCES Authors_2NF(Author_ID),
    FOREIGN KEY (Publisher_ID) REFERENCES Publishers_2NF(Publisher_ID)
);

-- 3NF: Eliminate transitive dependencies
CREATE TABLE Book_Copies_3NF (
    Copy_ID INT PRIMARY KEY AUTO_INCREMENT,
    ISBN VARCHAR(13),
    Acquisition_Date DATE,
    Condition_Status VARCHAR(20),  -- Good, Damaged, Lost
    FOREIGN KEY (ISBN) REFERENCES Books_2NF(ISBN)
);

-- This separates copy-specific information from book information
-- Books can exist without physical copies (e-books, planned acquisitions)
```

---

## 📚 Practice Exercises

### Exercise 1: Identify Normal Forms
Analyze these tables and identify which normal form violations exist:

```sql
-- Table to analyze
CREATE TABLE Student_Courses (
    Student_ID INT,
    Course_ID INT,
    Student_Name VARCHAR(100),
    Course_Name VARCHAR(100),
    Instructor_Name VARCHAR(100),
    Department_Name VARCHAR(100),
    Grade VARCHAR(2),
    PRIMARY KEY (Student_ID, Course_ID)
);

-- Questions:
-- 1. Which normal form is this table in?
-- 2. What violations exist?
-- 3. How would you normalize it?
```

### Exercise 2: Normalization Process
Take this unnormalized table through all normalization steps:

```sql
-- Unnormalized table
CREATE TABLE Company_Projects (
    Company_ID INT,
    Company_Name VARCHAR(100),
    Company_Address VARCHAR(200),
    Project_ID INT,
    Project_Name VARCHAR(100),
    Project_Budget DECIMAL(12,2),
    Employee_ID INT,
    Employee_Name VARCHAR(100),
    Employee_Salary DECIMAL(10,2),
    Hours_Worked INT
);

-- Tasks:
-- 1. Convert to 1NF
-- 2. Convert to 2NF
-- 3. Convert to 3NF
-- 4. Identify if BCNF is needed
```

### Exercise 3: Functional Dependencies
Identify all functional dependencies in this schema:

```sql
CREATE TABLE Order_Processing (
    Order_ID INT,
    Customer_ID INT,
    Customer_Name VARCHAR(100),
    Customer_Type VARCHAR(20),     -- VIP, Regular, New
    Product_ID INT,
    Product_Name VARCHAR(100),
    Category_ID INT,
    Category_Name VARCHAR(50),
    Quantity INT,
    Unit_Price DECIMAL(10,2),
    Discount_Rate DECIMAL(5,4),
    PRIMARY KEY (Order_ID, Product_ID)
);

-- Identify:
-- 1. All functional dependencies
-- 2. Partial dependencies
-- 3. Transitive dependencies
-- 4. Normalization requirements
```

### Exercise 4: Real-World Application
Design and normalize a database for:

**Online Learning Platform**
- Students enroll in courses
- Courses have multiple lessons and quizzes
- Instructors create content
- Students earn certificates
- Track progress and scores

**Requirements:**
- Apply proper normalization (1NF through 3NF)
- Identify all functional dependencies
- Create appropriate tables and relationships
- Ensure data integrity

---

## 🎯 Chapter Summary

| Normal Form | Focus | Problems Solved | When to Use |
|-------------|-------|-----------------|-------------|
| **1NF** | Atomic Values | Repeating Groups | Always Required |
| **2NF** | Full Dependencies | Partial Dependencies | Most Applications |
| **3NF** | Direct Dependencies | Transitive Dependencies | Production Databases |
| **BCNF** | Candidate Keys | All Non-trivial FDs | Complex Schemas |
| **4NF** | Independent Values | Multivalued Dependencies | Specialized Cases |
| **5NF** | Perfect Decomposition | Join Dependencies | Theoretical |

### Key Takeaways:
- **Normalization** reduces redundancy and prevents anomalies
- **Functional Dependencies** guide the normalization process
- **1NF-3NF** are essential for practical database design
- **BCNF-5NF** provide theoretical completeness
- **Balance** between normalization and performance
- **Documentation** of normalization decisions is crucial

### Best Practices:
- Start with conceptual design (ER diagrams)
- Apply normalization step-by-step
- Consider performance implications
- Document all design decisions
- Test with real data scenarios
- Be prepared to denormalize for performance

---

## 🚀 Next Steps
- **ER Modeling**: Learn entity-relationship diagrams
- **Database Design**: Apply normalization in real projects
- **Performance Tuning**: Balance normalization with query performance
- **Advanced Topics**: Denormalization strategies for data warehouses
- **Case Studies**: Analyze normalization in existing systems

**Normalization is both an art and a science - practice with real scenarios to master it!** 🎨📊
