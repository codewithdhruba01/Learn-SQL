# Storage, File Organization & Indexing in DBMS

## Goal
A **DBMS (Database Management System)** stores huge amounts of data efficiently.  
Its **two main goals** are:
1. **Efficient storage** (save space).
2. **Fast access** (quick search, insert, update, delete).

To achieve this, DBMS uses:
- **File Organization** → how data is physically stored.  
- **Indexing** → how DBMS finds data quickly.  
- **Buffer Management** → how data is managed between **disk** and **main memory**.

## File Organization
File organization defines **how records are arranged in the file** on disk.

### 1. Heap (Unordered) File Organization
- Records are stored in **any order** (just appended).  
- No sorting, no hashing → fastest for **insertion**.  
- Searching is **slow** (must scan all records).  
- Example: Temporary data, log files.  

**Best for:** When insertions are frequent, but queries are rare.  

### 2. Sequential / Sorted File Organization
- Records are stored in **sorted order** (usually on some key).  
- Searching using **binary search** is very fast.  
- Insertions and deletions are **slow** (because file must remain sorted).  
- Example: Student records sorted by roll number.  

**Best for:** Range queries and reports (like "students with marks between 70–90").  

### 3. Hashed File Organization
- Uses a **hash function** on a key (e.g., `hash(ID)`) → decides where record will go.  
- Very fast for **equality search** (like `WHERE ID = 1001`).  
- Not good for **range queries** (like "marks between 70–90").  
- Example: Banking system where accounts are searched by **account number**.  

**Best for:** Exact match queries.  

## Indexing
Indexes are like **book indexes** → they help DBMS find records **without scanning the whole file**.

### 1. Single-Level Index
- One index table is created.  
- Example: Index on roll numbers → stores `(roll_no, pointer_to_record)`.  
- Searching becomes faster than linear scan.  

Limitation: If data is very large, the index file itself becomes huge.

### 2. Multi-Level Index
- Index on **index**.  
- First-level index points to second-level, second-level points to actual data.  
- Works like a **tree**.  
- Reduces search time a lot.  

Example:  
- First-level index: A–E, F–J, K–O …  
- Second-level: actual roll numbers in that group.  

### 3. B+ Tree Indexing
- Most widely used in DBMS (used in MySQL, Oracle, etc.).  
- **Balanced tree structure** → keeps height small.  
- All values are stored in **leaf nodes** in sorted order.  
- Supports:
  - **Equality search** (`ID = 105`).  
  - **Range queries** (`ID between 100 and 200`).  

Very efficient for both exact and range searches.

## Buffer Management
Now, how DBMS handles **memory vs disk**:

- **Disk** is large but **slow**.  
- **RAM (Buffer)** is small but **fast**.  
- DBMS keeps frequently used pages (blocks of data) in **Buffer Pool**.  

### Steps:
1. When query requests data → DBMS first checks **buffer** (main memory).  
   - If found → **cache hit**.  
   - If not → fetch from **disk** (slow), and place it in buffer.  
2. When buffer is full → DBMS uses **replacement policies**:  
   - **LRU (Least Recently Used):** Remove the block not used for longest time.  
   - **MRU, FIFO, Clock** also possible.  
3. Modified pages in buffer must be written back to disk → called **dirty pages**.

Buffer management is crucial → reduces costly disk I/O operations.  


## Summary Table

| Concept              | Main Idea                                | Best Use Case |
|----------------------|-------------------------------------------|---------------|
| **Heap File**        | Unordered storage                        | Fast inserts |
| **Sorted File**      | Records sorted by key                    | Range queries |
| **Hashed File**      | Hash function decides location           | Exact match search |
| **Single Index**     | One index table                          | Small datasets |
| **Multi-Level Index**| Index on index                           | Large datasets |
| **B+ Tree Index**    | Balanced tree, supports ranges           | DBMS standard |
| **Buffer Management**| Manages RAM–Disk movement of pages       | Speeds up access |
