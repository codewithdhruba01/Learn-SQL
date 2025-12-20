# Chapter 4: Relational Algebra & Relational Calculus

## Introduction

**Relational Algebra** and **Relational Calculus** are two fundamental pillars of relational database theory. Both are query languages used to retrieve data from relational databases. Relational Algebra is procedural while Relational Calculus is non-procedural.

---

## Section 1: Relational Algebra

### 1.1 Definition

**Relational Algebra** is a procedural query language that provides a set of operations to retrieve data from relational databases. It is based on set theory and relational mathematics.

### 1.2 Basic Concepts

#### Relations
- A relation is a table containing rows (tuples) and columns (attributes)
- Each relation has a unique name
- Each tuple in a relation is unique

#### Example Relations

```sql
-- STUDENT Relation
STUDENT (Roll_No, Name, Age, Branch, CGPA)
-----------
1, Amit, 20, CSE, 8.5
2, Priya, 19, ECE, 9.0
3, Rohan, 21, CSE, 7.8
4, Sneha, 20, MECH, 8.2

-- COURSE Relation
COURSE (Course_ID, Course_Name, Credits, Dept)
-----------
CS101, Data Structures, 4, CSE
CS102, Algorithms, 3, CSE
EC201, Digital Electronics, 4, ECE
ME301, Thermodynamics, 3, MECH
```

### 1.3 Basic Operations

#### 1.3.1 Selection (σ) - Selection
Selects rows based on a condition.

**Syntax:** σ<sub>condition</sub>(Relation)

**Example:**
```sql
-- All students above 20 years
σ_{Age > 20}(STUDENT)

-- Students from CSE branch
σ_{Branch = 'CSE'}(STUDENT)

-- Result:
Roll_No | Name  | Age | Branch | CGPA
--------|-------|-----|--------|------
3       | Rohan | 21  | CSE    | 7.8
```

#### 1.3.2 Projection (π) - Projection
Selects specific columns.

**Syntax:** π<sub>attributes</sub>(Relation)

**Example:**
```sql
-- Only name and branch
π_{Name, Branch}(STUDENT)

-- Result:
Name  | Branch
------|--------
Amit  | CSE
Priya | ECE
Rohan | CSE
Sneha | MECH
```

#### 1.3.3 Union (∪) - Union
Combines tuples from two relations. Both relations must have the same schema.

**Syntax:** Relation1 ∪ Relation2

**Example:**
```sql
-- Union of two relations
R1 ∪ R2
```

#### 1.3.4 Set Difference (-) - Set Difference
Removes tuples of second relation from first relation.

**Syntax:** Relation1 - Relation2

**Example:**
```sql
-- Remove CSE students from all students
STUDENT - σ_{Branch = 'CSE'}(STUDENT)
```

#### 1.3.5 Cartesian Product (×) - Cartesian Product
Creates Cartesian product of two relations.

**Syntax:** Relation1 × Relation2

**Example:**
```sql
STUDENT × COURSE

-- Each STUDENT tuple will be combined with each COURSE tuple
```

#### 1.3.6 Rename (ρ) - Rename
Renames a relation or attribute.

**Syntax:** ρ<sub>new_name</sub>(Relation) or ρ<sub>new_attr</sub>(old_attr, Relation)

### 1.4 Derived Operations

#### 1.4.1 Join Operations

**Natural Join (⋈)**: Automatic join on attributes with same names
```sql
-- Example: Natural join of STUDENT and ENROLLMENT relations
STUDENT ⋈ ENROLLMENT
```

**Theta Join (⋈<sub>θ</sub>)**: Join based on a condition
```sql
-- Example: STUDENT ⋈_{Branch = Dept} COURSE
STUDENT ⋈_{Branch = Dept} COURSE
```

**Left Outer Join (⟕)**, **Right Outer Join (⟖)**, **Full Outer Join (⟗)**

#### 1.4.2 Intersection (∩) - Intersection
Common tuples in both relations
```sql
Relation1 ∩ Relation2
```

#### 1.4.3 Division (÷) - Division
Divides one relation by another relation.
```sql
-- Students enrolled in all CS courses
ENROLLMENT ÷ π_{Course_ID}(σ_{Dept='CSE'}(COURSE))
```

### 1.5 Complex Examples

#### Example 1: Names of all CSE students with CGPA > 8.0
```sql
π_{Name}(σ_{Branch='CSE' ∧ CGPA>8.0}(STUDENT))
```

#### Example 2: Students who have taken at least one CS course
```sql
π_{Name}(STUDENT ⋈ ENROLLMENT ⋈ σ_{Dept='CSE'}(COURSE))
```

---

## Section 2: Relational Calculus

### 2.1 Definition

**Relational Calculus** is a non-procedural query language that uses logic-based expressions. It specifies what data to retrieve, not how to retrieve it.

### 2.2 Types

#### 2.2.1 Tuple Relational Calculus (TRC)
Uses tuple variables.

**Syntax:** { t | P(t) }
where t is a tuple variable and P(t) is a predicate.

**Examples:**
```sql
-- Names of all students
{ t.Name | STUDENT(t) }

-- Students above 20 years
{ t.Name | STUDENT(t) ∧ t.Age > 20 }

-- All CSE students
{ t | STUDENT(t) ∧ t.Branch = 'CSE' }
```

#### 2.2.2 Domain Relational Calculus (DRC)
Uses domain variables (attribute values).

**Syntax:** { <x₁, x₂, ..., xₙ> | P(x₁, x₂, ..., xₙ) }

**Examples:**
```sql
-- Names and ages of all students
{ <n, a> | ∃r, b, c (STUDENT(r, n, a, b, c)) }

-- Names of CSE students
{ <n> | ∃r, a, c (STUDENT(r, n, a, 'CSE', c)) }
```

### 2.3 Quantifiers

#### Existential Quantifier (∃)
Represents "there exists at least one".

#### Universal Quantifier (∀)
Represents "for all".

**Examples:**
```sql
-- Students enrolled in all CS courses (TRC)
{ s | STUDENT(s) ∧ ∀c (COURSE(c) ∧ c.Dept='CSE' → ENROLLED(s,c)) }

-- Courses where all students passed
{ c | COURSE(c) ∧ ∀s (STUDENT(s) → GRADE(s,c) ≥ 'D') }
```

### 2.4 TRC vs DRC Comparison

| Aspect | Tuple Relational Calculus | Domain Relational Calculus |
|--------|---------------------------|----------------------------|
| Variables | Tuple variables | Domain variables |
| Syntax | { t \| P(t) } | { <x₁,x₂> \| P(x₁,x₂) } |
| Usage | More intuitive | More formal |
| SQL Equivalent | Easy to convert | Somewhat complex |

---

## Section 3: Relational Algebra vs Relational Calculus

### 3.1 Key Differences

| Aspect | Relational Algebra | Relational Calculus |
|--------|-------------------|---------------------|
| Nature | Procedural | Non-Procedural |
| Approach | How to retrieve data | What data to retrieve |
| Foundation | Set theory operations | First-order logic |
| Usage | Query optimization | Query specification |
| Power | Equivalent power | Equivalent power |

### 3.2 Similarities
- Both are based on the relational model
- Both have equivalent expressive power
- Both are used for creating query languages

---

## Section 4: Practical Examples

### Example Database Schema

```sql
STUDENT (Roll_No, Name, Age, Branch, CGPA)
COURSE (Course_ID, Course_Name, Credits, Dept)
ENROLLMENT (Roll_No, Course_ID, Grade)
TEACHER (Teacher_ID, Name, Dept, Salary)
TEACHES (Teacher_ID, Course_ID)
```

### Query Examples

#### Query 1: Names of all students who took 'CS101' course
**Relational Algebra:**
```sql
π_{Name}(STUDENT ⋈ ENROLLMENT ⋈ σ_{Course_ID='CS101'}(ENROLLMENT))
```

**Tuple Relational Calculus:**
```sql
{ s.Name | STUDENT(s) ∧ ∃e (ENROLLMENT(e) ∧ e.Roll_No = s.Roll_No ∧ e.Course_ID = 'CS101') }
```

**SQL Equivalent:**
```sql
SELECT Name
FROM STUDENT
WHERE Roll_No IN (SELECT Roll_No FROM ENROLLMENT WHERE Course_ID = 'CS101');
```

#### Query 2: Teachers who have taught at least one CS course
**Relational Algebra:**
```sql
π_{Name}(TEACHER ⋈ TEACHES ⋈ σ_{Dept='CSE'}(COURSE))
```

**Tuple Relational Calculus:**
```sql
{ t.Name | TEACHER(t) ∧ ∃te, c (TEACHES(te) ∧ COURSE(c) ∧ te.Teacher_ID = t.Teacher_ID ∧ te.Course_ID = c.Course_ID ∧ c.Dept = 'CSE') }
```

---

## Section 5: Importance and Applications

### 5.1 Importance
1. **Query Optimization**: RA is used to optimize SQL queries internally
2. **Database Design**: Both concepts help in database design
3. **Theoretical Foundation**: Forms the foundation of RDBMS

### 5.2 Applications
1. **SQL Engines**: Use RA operations internally
2. **Query Processing**: How queries are executed
3. **Database Theory**: Basis for further research

---

## Summary

- **Relational Algebra**: Procedural, operation-based
- **Relational Calculus**: Non-procedural, logic-based
- Both have equivalent power and can be converted into each other
- These concepts form the foundation of modern RDBMS

---

## Practice Questions

1. Write RA expressions for the following relations:
   - All students with CGPA greater than 8.5
   - Courses with more than 100 enrolled students

2. Express the following in TRC:
   - Names of all teachers in CSE department
   - Students who passed all courses

3. Explain the differences between RA and RC.

---

**Next Chapter: SQL Fundamentals**
