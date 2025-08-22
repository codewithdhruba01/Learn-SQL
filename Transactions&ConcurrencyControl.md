# Transactions & Concurrency Control – Detailed Explanation

---

## 🔹 1. What is a Transaction?

A **transaction** is a *logical unit of work* in a database.
It consists of multiple steps that **must execute together** to keep the data accurate.

**Example (Bank Transfer):**

1. Debit ₹5000 from Account A
2. Credit ₹5000 to Account B

 If both steps succeed, the transaction **commits** (changes are saved).
 If any step fails, the transaction **rolls back** (no changes are saved).

 **Key Point:** Transactions keep the data *consistent*.


## 2. ACID Properties (4 Rules Every Transaction Must Follow)

**A – Atomicity**

* All or nothing.
* Either all steps of the transaction happen, or none happen.

**C – Consistency**

* The transaction should always leave the data in a valid state.
* It must follow all business rules and constraints.

**I – Isolation**

* Transactions running at the same time do not interfere with each other.

**D – Durability**

* Once a transaction is committed, the changes are permanent, even if the system crashes.


## 🟢 3. What is Concurrency?

**Concurrency** means **multiple transactions executing at the same time**.

**Example:**

* User 1 is checking an account balance.
* User 2 is withdrawing money from the same account at the same time.

⚠️ Without proper concurrency control, the data could become inconsistent or incorrect.


## ⚠️ 4. Problems That Happen Due to Concurrency

| Problem                 | Description                                                                                                              |
| ----------------------- | ------------------------------------------------------------------------------------------------------------------------ |
| **Lost Update**         | Two transactions overwrite each other’s updates and one update is lost.                                                  |
| **Dirty Read**          | A transaction reads uncommitted (temporary) data from another transaction.                                               |
| **Non-repeatable Read** | A transaction reads the same row twice and gets different data because another transaction updated it in between.        |
| **Phantom Read**        | A transaction executes the same query twice but sees new rows the second time because another transaction inserted them. |


## 🛡️ 5. Concurrency Control Techniques

### 🔹 Locking

Using **locks** prevents conflicts between transactions.

* **Shared Lock (S Lock):** Allows reading but not writing.
* **Exclusive Lock (X Lock):** Allows both reading and writing.
* **Two-Phase Locking (2PL):**

  * **Growing Phase:** Transaction acquires all the locks it needs.
  * **Shrinking Phase:** Transaction releases the locks.

 Two-phase locking ensures transactions are **serializable** (executed one after another logically).


### 🔹 Timestamp Ordering

* Each transaction gets a unique timestamp.
* The database uses timestamps to decide the order of execution so conflicts can be avoided.


### 🔹 Optimistic Concurrency Control

* Transactions execute without locks.
* Before committing, the system validates whether any conflicts occurred.
* If validation fails, the transaction rolls back.
* Best used when conflicts are rare.


## 🧠 6. Isolation Levels (SQL Standards)

**Isolation levels** decide how strictly transactions are separated:

| Isolation Level      | Prevents                                      |
| -------------------- | --------------------------------------------- |
| **Read Uncommitted** | Nothing (dirty reads can happen)              |
| **Read Committed**   | Prevents dirty reads                          |
| **Repeatable Read**  | Prevents dirty and non-repeatable reads       |
| **Serializable**     | Prevents all problems including phantom reads |


## ✅ Conclusion

Transactions and concurrency control are essential in databases to:

* Maintain **data consistency**
* Avoid **conflicts**
* Ensure **reliable results**
