# Common SQL Interview Scenarios & Solutions

## Most Common Interview Scenarios

### 1. **Employee-Department Analysis**
**Problem:** Find employees earning more than their department average.

**Solution:**
```sql
SELECT e.name, e.salary, d.department_name
FROM employees e
JOIN departments d ON e.department_id = d.id
WHERE e.salary > (
    SELECT AVG(salary)
    FROM employees
    WHERE department_id = e.department_id
);
```

### 2. **Duplicate Records**
**Problem:** Find and remove duplicate email addresses.

**Solution:**
```sql
-- Find duplicates
SELECT email, COUNT(*) as count
FROM employees
GROUP BY email
HAVING COUNT(*) > 1;

-- Remove duplicates (keep earliest record)
DELETE e1 FROM employees e1
INNER JOIN employees e2
WHERE e1.id > e2.id AND e1.email = e2.email;
```

### 3. **Top N Records**
**Problem:** Find top 3 highest paid employees in each department.

**Solution:**
```sql
WITH ranked_employees AS (
    SELECT name, salary, department_name,
           ROW_NUMBER() OVER (PARTITION BY department_id ORDER BY salary DESC) as rn
    FROM employees e
    JOIN departments d ON e.department_id = d.id
)
SELECT name, salary, department_name
FROM ranked_employees
WHERE rn <= 3;
```

### 4. **Running Totals**
**Problem:** Calculate running total of salaries by hire date.

**Solution:**
```sql
SELECT name, salary, hire_date,
       SUM(salary) OVER (ORDER BY hire_date) as running_total
FROM employees
ORDER BY hire_date;
```

### 5. **Missing Data Analysis**
**Problem:** Find departments with no employees.

**Solution:**
```sql
SELECT d.department_name
FROM departments d
LEFT JOIN employees e ON d.id = e.department_id
WHERE e.id IS NULL;
```

### 6. **Date Range Analysis**
**Problem:** Find employees hired in the last 6 months.

**Solution:**
```sql
SELECT * FROM employees
WHERE hire_date >= DATE_SUB(CURRENT_DATE, INTERVAL 6 MONTH);
```

### 7. **Complex Joins**
**Problem:** Find employees and their managers' information.

**Solution:**
```sql
SELECT e.name as employee, e.salary as emp_salary,
       m.name as manager, m.salary as mgr_salary
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.id;
```

### 8. **Pivot Table**
**Problem:** Create a pivot showing department-wise salary ranges.

**Solution:**
```sql
SELECT department_name,
       SUM(CASE WHEN salary < 50000 THEN 1 ELSE 0 END) as low_salary,
       SUM(CASE WHEN salary BETWEEN 50000 AND 80000 THEN 1 ELSE 0 END) as mid_salary,
       SUM(CASE WHEN salary > 80000 THEN 1 ELSE 0 END) as high_salary
FROM employees e
JOIN departments d ON e.department_id = d.id
GROUP BY d.id, department_name;
```

### 9. **Recursive Relationships**
**Problem:** Build an organizational hierarchy.

**Solution:**
```sql
WITH RECURSIVE org_hierarchy AS (
    -- Base case: top-level managers
    SELECT id, name, manager_id, 0 as level, CAST(name AS CHAR(1000)) as path
    FROM employees
    WHERE manager_id IS NULL

    UNION ALL

    -- Recursive case: employees with managers
    SELECT e.id, e.name, e.manager_id, oh.level + 1,
           CONCAT(oh.path, ' -> ', e.name)
    FROM employees e
    JOIN org_hierarchy oh ON e.manager_id = oh.id
)
SELECT * FROM org_hierarchy ORDER BY level, name;
```

### 10. **Performance Optimization**
**Problem:** Optimize a slow query.

**Solutions:**
```sql
-- 1. Add appropriate indexes
CREATE INDEX idx_emp_dept_salary ON employees(department_id, salary);
CREATE INDEX idx_emp_hire_date ON employees(hire_date);

-- 2. Rewrite query to avoid subquery
-- Instead of:
SELECT * FROM employees WHERE department_id IN (SELECT id FROM departments WHERE budget > 300000);

-- Use JOIN:
SELECT e.* FROM employees e
JOIN departments d ON e.department_id = d.id
WHERE d.budget > 300000;

-- 3. Use LIMIT for large result sets
SELECT * FROM employees ORDER BY salary DESC LIMIT 10;
```

---

## Common Interview Questions & Quick Answers

### **Database Design Questions:**
- **Q:** How would you design a library management system?
- **A:** Books, Authors, Members, Loans tables with proper relationships.

- **Q:** How to handle many-to-many relationships?
- **A:** Create junction/intermediate table with foreign keys.

### **Performance Questions:**
- **Q:** How to optimize slow queries?
- **A:** Add indexes, rewrite queries, use EXPLAIN, denormalize if needed.

- **Q:** When to use indexes?
- **A:** WHERE clauses, JOIN columns, ORDER BY columns, but not on low-selectivity columns.

### **Data Integrity Questions:**
- **Q:** How to prevent orphaned records?
- **A:** Use foreign key constraints with CASCADE/RESTRICT options.

- **Q:** How to handle concurrent updates?
- **A:** Use transactions, optimistic/pessimistic locking.

---

## SQL Best Practices for Interviews

### **Writing Efficient Queries:**
1. **Specify columns** instead of `SELECT *`
2. **Use JOINs** instead of subqueries when possible
3. **Use EXISTS** instead of IN for large datasets
4. **Use UNION ALL** instead of UNION when duplicates are acceptable
5. **Filter early** with WHERE clauses

### **Database Design Principles:**
1. **Normalize** to reduce redundancy (usually to 3NF)
2. **Denormalize** for read performance when needed
3. **Use appropriate data types** (don't use VARCHAR for dates)
4. **Index foreign keys** automatically
5. **Use constraints** for data integrity

### **Common Mistakes to Avoid:**
1. **Cartesian products** (missing JOIN conditions)
2. **Implicit conversions** (comparing different data types)
3. **NULL handling** (using = instead of IS NULL)
4. **String operations on indexed columns**
5. **SELECT * in production code**

---

## Interview Preparation Tips

### **Before the Interview:**
- Review basic SQL syntax and concepts
- Practice writing queries on paper
- Understand EXPLAIN plans
- Know your database's specific features

### **During the Interview:**
- Explain your thought process
- Start with simple solutions, then optimize
- Ask clarifying questions
- Test your queries mentally

### **Key Topics to Master:**
- JOINs (INNER, LEFT, RIGHT, FULL OUTER)
- Subqueries and CTEs
- Window functions
- Indexing strategies
- Query optimization
- Database design principles

---

> *Remember: Communication is key! Explain your approach clearly and show you understand the business requirements behind the technical questions.*
