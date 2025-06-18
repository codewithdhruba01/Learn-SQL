# Relational Algebra & Relational Calculus

This repository contains a detailed explanation of **Relational Algebra** and **Relational Calculus**, two foundational topics in database theory and query languages.


## Relational Algebra (RA)

**Relational Algebra** is a **procedural query language** used to retrieve data from relational databases using a set of operations like selection, projection, union, etc.

### Basic Operations:
- **Selection (σ)**: Filters rows based on condition
- **Projection (π)**: Selects specific columns
- **Union (∪)**: Combines tuples from two relations
- **Set Difference (−)**
- **Cartesian Product (×)**
- **Rename (ρ)**

### Derived Operations:
- **Join** (Natural, Theta)
- **Intersection**
- **Division**


## Relational Calculus (RC)

**Relational Calculus** is a **non-procedural query language** that uses logic-based expressions to describe what data to retrieve, not how to retrieve it.

### Types:
- **Tuple Relational Calculus (TRC)**: `{ t | P(t) }`
- **Domain Relational Calculus (DRC)**: `{ <x1, x2> | P(x1, x2) }`

### 📌 Example in TRC:
```sql
{ t.Name | Student(t) ∧ t.Age > 18 }
