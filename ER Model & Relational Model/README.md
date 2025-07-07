# 📘 DBMS Architecture & Data Models

This document provides a clear and concise explanation of **DBMS Architecture**, **Entity-Relationship Model**, and **Relational Model** used in database systems. Ideal for students, developers, and interview preparation.

---

## DBMS Architecture (3-Level Architecture)

The **3-level architecture** of a DBMS defines how data is viewed, processed, and stored. It improves **data abstraction**, **security**, and **independence**.

### 🔹 1. Internal Level (Physical Level)
- Describes **how data is physically stored** in the database (e.g., indexing, file structures).
- Deals with low-level storage details.
- **Invisible to end-users**.

### 🔹 2. Conceptual Level (Logical Level)
- Provides the **logical structure** of the entire database.
- Defines tables, data types, relationships, constraints.
- Hides physical storage details from users.
- Acts as a bridge between internal and external levels.

### 🔹 3. External Level (View Level)
- Provides a **customized view** of the database to each user or application.
- Ensures **data privacy and security**.
- Users can access only relevant data.

### Benefits:
- Data Abstraction
- Security & Privacy
- Data Independence (logical & physical)

---

## Data Models in DBMS

Data Models define how data is **logically structured**, **stored**, and **accessed** in a DBMS.

### 🔸 1. Hierarchical Model
- Organizes data in a **tree-like (parent-child)** structure.
- One parent → many children; child has only one parent.
- Suitable for **one-to-many** relationships.


### 🔸 2. Network Model
- Uses **graph-like structure**.
- A record can have **multiple parent and child relationships**.
- Good for handling **many-to-many** relationships.

### 🔸 3. Relational Model (Most Widely Used)
- Represents data as **tables (relations)**.
- Each table has rows (tuples) and columns (attributes).
- **SQL** is based on this model.

#### Key Concepts:
- **Relation** = Table
- **Attribute** = Column
- **Tuple** = Row
- **Primary Key** = Unique ID
- **Foreign Key** = Refers to another table’s primary key

#### Example Tables:

**Student Table**

| Student_ID | Name  | Age |
|------------|-------|-----|
| 101        | Aman  | 20  |
| 102        | Riya  | 21  |

**Course Table**

| Course_ID | Title  |
|-----------|--------|
| C101      | DBMS   |
| C102      | Java   |

**Enrollment Table**

| Student_ID | Course_ID |
|------------|-----------|
| 101        | C101      |
| 102        | C102      |

---

### 🔸 4. Entity-Relationship (ER) Model

#### Key Components:
- **Entity**: Real-world object (e.g., Student)
- **Entity Set**: Group of similar entities
- **Attribute**: Property of an entity (e.g., Name, Age)
- **Relationship**: Association between entities (e.g., Enrolls)
- **Primary Key**: Uniquely identifies an entity

#### 🔷 Example E-R Diagram:


Below is a simple E-R diagram illustrating the relationship between a `Student` and a `Course`:

```

+-----------+           +-----------+
\|  Student  |           |  Course   |
+-----------+           +-----------+
\| RollNo    |           | Course\_ID |
\| Name      |           | Title     |
\| Age       |           +-----------+
+-----------+               ▲
\|                     |
\| enrolls             |
+---------------------+
(Relationship)

```

- **Entities**: `Student`, `Course`
- **Relationship**: `enrolls`
