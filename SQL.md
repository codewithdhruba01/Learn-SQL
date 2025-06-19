## What is SQL?
SQL (Structured Query Language) is a standard language used to **create, read, update, and delete** data in relational database systems.

---

## SQL Command Categories

### 1. DDL (Data Definition Language)
Used to define and modify the **structure** of database objects like tables.

| Command | Description |
|---------|-------------|
| `CREATE` | Creates new tables or databases |
| `DROP` | Deletes existing tables or databases |
| `ALTER` | Modifies the structure of an existing table |

**Examples:**
```sql
CREATE TABLE students (
  id INT PRIMARY KEY,
  name VARCHAR(100),
  age INT
);

ALTER TABLE students ADD email VARCHAR(100);
DROP TABLE students;
````

---

### 2. DML (Data Manipulation Language)

Used to manipulate the **data inside tables**.

| Command  | Description               |
| -------- | ------------------------- |
| `INSERT` | Adds new records          |
| `UPDATE` | Modifies existing records |
| `DELETE` | Removes records           |

**Examples:**

```sql
INSERT INTO students (id, name, age) VALUES (1, 'Dhruba', 22);
UPDATE students SET age = 23 WHERE id = 1;
DELETE FROM students WHERE id = 1;
```

---

### 3. DQL (Data Query Language)

Used to **fetch and filter** data from tables.

| Command    | Description          |
| ---------- | -------------------- |
| `SELECT`   | Retrieves data       |
| `WHERE`    | Filters records      |
| `GROUP BY` | Groups similar data  |
| `HAVING`   | Filters grouped data |

**Examples:**

```sql
SELECT name, age FROM students WHERE age > 20;

SELECT age, COUNT(*) 
FROM students 
GROUP BY age 
HAVING COUNT(*) > 1;
```

---

### 4. DCL (Data Control Language)

Used to manage **access permissions** to the database.

| Command  | Description               |
| -------- | ------------------------- |
| `GRANT`  | Gives access privileges   |
| `REVOKE` | Removes access privileges |

**Examples:**

```sql
GRANT SELECT, INSERT ON students TO 'user1';
REVOKE INSERT ON students FROM 'user1';
```

---

### 5. TCL (Transaction Control Language)

Used to manage **database transactions** to ensure data integrity.

| Command     | Description                             |
| ----------- | --------------------------------------- |
| `COMMIT`    | Saves all changes made in a transaction |
| `ROLLBACK`  | Undoes changes since the last COMMIT    |
| `SAVEPOINT` | Creates a point to rollback to later    |

**Examples:**

```sql
BEGIN;

INSERT INTO students VALUES (2, 'Alex', 21);
SAVEPOINT sp1;

UPDATE students SET age = 22 WHERE id = 2;
ROLLBACK TO sp1;

COMMIT;
```

---

## Summary

| Category | Purpose             | Commands                                |
| -------- | ------------------- | --------------------------------------- |
| DDL      | Define structure    | `CREATE`, `DROP`, `ALTER`               |
| DML      | Manage data         | `INSERT`, `UPDATE`, `DELETE`            |
| DQL      | Query data          | `SELECT`, `WHERE`, `GROUP BY`, `HAVING` |
| DCL      | Control access      | `GRANT`, `REVOKE`                       |
| TCL      | Manage transactions | `COMMIT`, `ROLLBACK`, `SAVEPOINT`       |
