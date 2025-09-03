# 🔒 Security & Authorization in DBMS

Database Management System (DBMS) stores and manages critical data, so ensuring **security** and **proper authorization** is essential to protect it from unauthorized access, misuse, or corruption.

---

## 1. **Database Security**

Database Security refers to all the measures used to **protect the database** against unauthorized access, threats, and attacks.

### ✅ Objectives of Database Security:

1. **Confidentiality** – Only authorized users should be able to access sensitive data.
2. **Integrity** – Data must remain accurate and consistent without unauthorized changes.
3. **Availability** – Database should always be available to legitimate users when required.

### ⚡ Threats to Database Security:

* Unauthorized access (hackers, internal misuse)
* SQL Injection attacks
* Malware or ransomware
* Human errors (accidental deletion or modification)
* Hardware/software failures
* Denial of Service (DoS) attacks

### 🔐 Security Techniques:

* **User authentication** (username/password, biometrics, OTP)
* **Encryption** (storing data in encrypted form so it cannot be read without a key)
* **Firewall and network security**
* **Backup & recovery** (to protect from data loss)
* **Auditing and monitoring** (tracking who accessed or modified the data)

---

## 2. **Authorization in DBMS**

Authorization means **defining what each user is allowed to do** after they have been authenticated.
It ensures users only perform permitted actions on the database.

### ✅ Types of Authorization:

1. **Read Authorization** – User can only view the data.
2. **Insert Authorization** – User can insert new records.
3. **Update Authorization** – User can modify existing records.
4. **Delete Authorization** – User can remove records.
5. **Resource Authorization** – User can create new tables, views, or databases.

### 📌 Example (SQL Authorization with GRANT & REVOKE):

```sql
-- Grant SELECT permission to user1
GRANT SELECT ON Employees TO user1;

-- Grant INSERT and UPDATE permissions
GRANT INSERT, UPDATE ON Employees TO user2;

-- Revoke DELETE permission
REVOKE DELETE ON Employees FROM user2;
```

---

## 3. **Access Control Models**

There are different models to control authorization in DBMS:

1. **Discretionary Access Control (DAC)**

   * The owner of a database object decides who can access it.
   * Example: A table owner granting permissions to specific users.

2. **Mandatory Access Control (MAC)**

   * Access is based on security labels (Top Secret, Confidential, Public, etc.).
   * Used in defense or government databases.

3. **Role-Based Access Control (RBAC)**

   * Users are assigned **roles**, and roles have specific permissions.
   * Example:

     * *Admin* → Full access
     * *Manager* → Read & Update
     * *Employee* → Read only

---

## 4. **Best Practices for DBMS Security & Authorization**

* Strong password policies
* Principle of Least Privilege (give minimum required access)
* Encrypt sensitive data (at rest and in transit)
* Regular security audits
* Enable database logs to track suspicious activity
* Apply patches and updates to fix vulnerabilities

---

 **In short:**

* **Security** in DBMS = Protecting data from unauthorized access, threats, and attacks.
* **Authorization** in DBMS = Defining what an authenticated user is allowed to do with the data.
