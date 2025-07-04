# 📘 Chapter: Normalization & Functional Dependencies

## 🧩 Functional Dependencies

Functional dependencies (FDs) describe the relationship between attributes in a relational database. An FD, denoted as `X → Y`, implies that if two tuples have the same value for attribute X, they must also have the same value for attribute Y.

### ✅ Key Concepts
- **Trivial FD:** `A → A` or `AB → A` (always true).
- **Non-Trivial FD:** `A → B` where B is not a subset of A.
- **Transitive FD:** If `A → B` and `B → C`, then `A → C`.
- **Closure of Attribute Set:** Set of attributes that can be functionally determined from a given set.

## 📚 Normalization

Normalization is the process of organizing data in a database to reduce redundancy and improve data integrity.

### 🔢 Normal Forms

| Normal Form | Description | Goal |
|-------------|-------------|------|
| **1NF (First Normal Form)** | Removes repeating groups in tables | Atomic values only |
| **2NF (Second Normal Form)** | Removes partial dependencies | Every non-prime attribute is fully functionally dependent on the primary key |
| **3NF (Third Normal Form)** | Removes transitive dependencies | Attributes only depend on the key |
| **BCNF (Boyce-Codd Normal Form)** | Stricter version of 3NF | Every determinant is a candidate key |
| **4NF (Fourth Normal Form)** | Removes multi-valued dependencies | Eliminates independent multivalued facts |
| **5NF (Fifth Normal Form)** | Removes join dependencies | Ensures lossless join decomposition |

### 🔍 Example

Consider a table:

| StudentID | Course | Instructor |
|-----------|--------|------------|
| 101       | Math   | Mr. Roy    |
| 101       | Physics| Ms. Sen    |

This table violates 1NF because it has multiple rows for the same `StudentID`. Normalization would split this into separate tables for **Students**, **Courses**, and **Instructors** with proper keys and references.

---

## 💡 Why Normalize?

- Reduces data redundancy
- Prevents update anomalies
- Simplifies data maintenance
- Enhances data integrity

