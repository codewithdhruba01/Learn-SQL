# 🛠️ Chapter 0: Installation and Setup Guide - Getting Started with Databases

## 🎯 Why Proper Installation Matters?

**Setting up your database environment correctly** is crucial for:
- **Learning effectively**: Practice with real databases
- **Understanding concepts**: See theoretical concepts in action
- **Building projects**: Create real-world applications
- **Career preparation**: Work with industry-standard tools

---

## 🐧 Linux Installation (Ubuntu/Debian)

### MySQL Installation

```bash
# Update package list
sudo apt update

# Install MySQL Server
sudo apt install mysql-server

# Secure MySQL installation
sudo mysql_secure_installation

# Start MySQL service
sudo systemctl start mysql
sudo systemctl enable mysql

# Check MySQL status
sudo systemctl status mysql

# Login to MySQL
sudo mysql -u root -p
```

### PostgreSQL Installation

```bash
# Install PostgreSQL
sudo apt install postgresql postgresql-contrib

# Start PostgreSQL service
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Switch to postgres user
sudo -u postgres psql

# Create a new user (from psql prompt)
CREATE USER your_username WITH PASSWORD 'your_password';
ALTER USER your_username CREATEDB;
\q

# Login with new user
psql -U your_username -d postgres
```

### SQLite Installation

```bash
# SQLite comes pre-installed on most Linux distributions
# Check if installed
sqlite3 --version

# If not installed
sudo apt install sqlite3

# Install SQLite browser (GUI)
sudo apt install sqlitebrowser
```

---

## 🍎 macOS Installation

### MySQL Installation (using Homebrew)

```bash
# Install Homebrew (if not installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install MySQL
brew install mysql

# Start MySQL service
brew services start mysql

# Secure installation
mysql_secure_installation

# Login to MySQL
mysql -u root -p
```

### PostgreSQL Installation (using Homebrew)

```bash
# Install PostgreSQL
brew install postgresql

# Start PostgreSQL service
brew services start postgresql

# Initialize database
initdb /usr/local/var/postgres

# Create user and database
createuser -s your_username
createdb your_database

# Login
psql -U your_username -d your_database
```

### SQLite Installation

```bash
# Install SQLite
brew install sqlite

# Install DB Browser for SQLite (GUI)
brew install --cask db-browser-for-sqlite

# Check installation
sqlite3 --version
```

---

## 🪟 Windows Installation

### MySQL Installation

1. **Download MySQL Installer**
   - Go to: https://dev.mysql.com/downloads/installer/
   - Download the MySQL Installer for Windows

2. **Run Installer**
   - Choose "Developer Default" setup type
   - Install MySQL Server, Workbench, and Shell

3. **Configuration**
   - Set root password during installation
   - Choose authentication method (recommended: Use Strong Password Encryption)

4. **Start MySQL**
   - MySQL should start automatically after installation
   - Check services: Windows + R → `services.msc` → MySQL80

5. **Access MySQL**
   ```bash
   # Open Command Prompt as Administrator
   mysql -u root -p
   ```

### PostgreSQL Installation

1. **Download PostgreSQL**
   - Go to: https://www.postgresql.org/download/windows/
   - Download the installer

2. **Run Installer**
   - Choose components: PostgreSQL Server, pgAdmin, Command Line Tools
   - Set password for postgres user
   - Choose port (default: 5432)

3. **Configuration**
   - Installer creates default database and user
   - pgAdmin GUI is included

4. **Access PostgreSQL**
   ```bash
   # Open Command Prompt
   psql -U postgres -d postgres
   ```

### SQLite Installation

1. **Download SQLite**
   - Go to: https://www.sqlite.org/download.html
   - Download: `sqlite-tools-win32-x86-*.zip`

2. **Extract and Setup**
   - Extract to a folder (e.g., `C:\sqlite`)
   - Add to PATH environment variable

3. **GUI Tool Options**
   - **DB Browser for SQLite**: https://sqlitebrowser.org/
   - **SQLiteStudio**: https://sqlitestudio.pl/

4. **Verify Installation**
   ```bash
   sqlite3 --version
   ```

---

## 🐳 Docker Installation (Cross-Platform)

### MySQL with Docker

```bash
# Pull MySQL image
docker pull mysql:8.0

# Run MySQL container
docker run --name mysql-container \
  -e MYSQL_ROOT_PASSWORD=my-secret-pw \
  -e MYSQL_DATABASE=mydb \
  -e MYSQL_USER=myuser \
  -e MYSQL_PASSWORD=mypassword \
  -p 3306:3306 \
  -d mysql:8.0

# Connect to MySQL
docker exec -it mysql-container mysql -u root -p
```

### PostgreSQL with Docker

```bash
# Pull PostgreSQL image
docker pull postgres:15

# Run PostgreSQL container
docker run --name postgres-container \
  -e POSTGRES_PASSWORD=my-secret-pw \
  -e POSTGRES_DB=mydb \
  -e POSTGRES_USER=myuser \
  -p 5432:5432 \
  -d postgres:15

# Connect to PostgreSQL
docker exec -it postgres-container psql -U myuser -d mydb
```

### SQLite with Docker

```bash
# SQLite doesn't need a server, but you can use Alpine Linux container
docker run -it --rm alpine:latest sh

# Inside container
apk add sqlite
sqlite3 test.db
```

---

## 🖥️ GUI Tools Setup

### MySQL Workbench

1. **Download**: https://dev.mysql.com/downloads/workbench/
2. **Installation**: Run installer and follow prompts
3. **Connection Setup**:
   - Open MySQL Workbench
   - Click "+" for new connection
   - Enter: Hostname, Port (3306), Username, Password
   - Test connection

### pgAdmin

1. **Download**: https://www.pgadmin.org/download/
2. **Installation**: Run installer
3. **First Login**: Use email and password set during installation
4. **Add Server**:
   - Right-click "Servers" → Create → Server
   - Enter connection details (host: localhost, port: 5432)

### DBeaver (Universal)

1. **Download**: https://dbeaver.io/download/
2. **Installation**: Run installer
3. **Add Connection**:
   - Click "+" → Select database type
   - Enter connection details
   - Test and save connection

### VS Code Extensions

```bash
# Install VS Code extensions for database development
code --install-extension ms-mssql.mssql
code --install-extension ms-vscode.vscode-sqlite
code --install-extension cweijan.vscode-mysql-client2
```

---

## ⚙️ Database Configuration

### MySQL Configuration

```bash
# Edit MySQL configuration
sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf

# Common settings to add/modify:
[mysqld]
bind-address = 127.0.0.1
max_connections = 100
innodb_buffer_pool_size = 256M
query_cache_size = 64M
log_error = /var/log/mysql/error.log

# Restart MySQL
sudo systemctl restart mysql
```

### PostgreSQL Configuration

```bash
# Edit PostgreSQL configuration
sudo nano /etc/postgresql/15/main/postgresql.conf

# Common settings:
listen_addresses = 'localhost'
max_connections = 100
shared_buffers = 256MB
work_mem = 4MB
maintenance_work_mem = 64MB

# Restart PostgreSQL
sudo systemctl restart postgresql
```

### SQLite Configuration

```bash
# SQLite doesn't need server configuration
# But you can set pragmas for better performance

# Create database with optimized settings
sqlite3 mydatabase.db << 'EOF'
PRAGMA journal_mode = WAL;
PRAGMA synchronous = NORMAL;
PRAGMA cache_size = 1000000;
PRAGMA foreign_keys = ON;
PRAGMA temp_store = memory;
EOF
```

---

## 🔐 Security Setup

### MySQL Security

```sql
-- Login as root
mysql -u root -p

-- Create a new user
CREATE USER 'your_user'@'localhost' IDENTIFIED BY 'strong_password';

-- Grant privileges
GRANT ALL PRIVILEGES ON your_database.* TO 'your_user'@'localhost';

-- Create database
CREATE DATABASE your_database;

-- Flush privileges
FLUSH PRIVILEGES;

-- Exit
EXIT;
```

### PostgreSQL Security

```sql
-- Login as postgres
psql -U postgres

-- Create user
CREATE USER your_user WITH PASSWORD 'strong_password';

-- Create database
CREATE DATABASE your_database OWNER your_user;

-- Grant permissions
GRANT ALL PRIVILEGES ON DATABASE your_database TO your_user;

-- Exit
\q
```

### Database Backup Scripts

```bash
# MySQL backup script
mysqldump -u username -p database_name > backup.sql

# PostgreSQL backup script
pg_dump -U username -h localhost database_name > backup.sql

# SQLite backup
sqlite3 database.db ".backup 'backup.db'"
```

---

## 🧪 Testing Your Installation

### MySQL Test

```sql
-- Login to MySQL
mysql -u your_user -p your_database

-- Create test table
CREATE TABLE test_users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert test data
INSERT INTO test_users (name, email) VALUES
('John Doe', 'john@example.com'),
('Jane Smith', 'jane@example.com');

-- Query data
SELECT * FROM test_users;

-- Clean up
DROP TABLE test_users;
```

### PostgreSQL Test

```sql
-- Login to PostgreSQL
psql -U your_user -d your_database

-- Create test table
CREATE TABLE test_users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert test data
INSERT INTO test_users (name, email) VALUES
('John Doe', 'john@example.com'),
('Jane Smith', 'jane@example.com');

-- Query data
SELECT * FROM test_users;

-- Clean up
DROP TABLE test_users;
```

### SQLite Test

```bash
# Create test database
sqlite3 test.db

-- Create test table
CREATE TABLE test_users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT UNIQUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Insert test data
INSERT INTO test_users (name, email) VALUES
('John Doe', 'john@example.com'),
('Jane Smith', 'jane@example.com');

-- Query data
SELECT * FROM test_users;

-- Exit SQLite
.exit

# Clean up
rm test.db
```

---

## 🚀 Getting Started with Practice

### Sample Database Setup

```sql
-- Create a practice database
CREATE DATABASE sql_practice;

-- Use the database
USE sql_practice; -- MySQL
\c sql_practice;  -- PostgreSQL

-- Create sample tables
CREATE TABLE departments (
    id INT PRIMARY KEY AUTO_INCREMENT, -- SERIAL for PostgreSQL
    name VARCHAR(100) NOT NULL,
    location VARCHAR(100)
);

CREATE TABLE employees (
    id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    department_id INT,
    salary DECIMAL(10,2),
    hire_date DATE,
    FOREIGN KEY (department_id) REFERENCES departments(id)
);

-- Insert sample data
INSERT INTO departments (name, location) VALUES
('IT', 'Floor 3'),
('HR', 'Floor 2'),
('Finance', 'Floor 4');

INSERT INTO employees (first_name, last_name, email, department_id, salary, hire_date) VALUES
('John', 'Doe', 'john.doe@company.com', 1, 75000.00, '2023-01-15'),
('Jane', 'Smith', 'jane.smith@company.com', 2, 65000.00, '2023-02-01'),
('Bob', 'Johnson', 'bob.johnson@company.com', 1, 80000.00, '2022-11-10');
```

---

## 🆘 Troubleshooting Common Issues

### MySQL Issues

```bash
# Can't connect to MySQL server
sudo systemctl status mysql
sudo systemctl start mysql

# Access denied for user
mysql -u root -p
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'new_password';

# MySQL service not starting
sudo systemctl status mysql
sudo journalctl -u mysql -n 50
```

### PostgreSQL Issues

```bash
# Can't connect to PostgreSQL
sudo systemctl status postgresql
sudo systemctl start postgresql

# Role does not exist
sudo -u postgres createuser --interactive your_username

# Database does not exist
sudo -u postgres createdb your_database
```

### Port Conflicts

```bash
# Check what's using ports
sudo netstat -tulpn | grep :3306  # MySQL
sudo netstat -tulpn | grep :5432  # PostgreSQL

# Change default ports in configuration files
# MySQL: /etc/mysql/mysql.conf.d/mysqld.cnf
# PostgreSQL: /etc/postgresql/15/main/postgresql.conf
```

---

## 📚 Learning Resources

### Official Documentation
- **MySQL**: https://dev.mysql.com/doc/
- **PostgreSQL**: https://www.postgresql.org/docs/
- **SQLite**: https://www.sqlite.org/docs.html

### Online Learning Platforms
- **SQLZoo**: Interactive SQL learning
- **LeetCode**: Database problem sets
- **HackerRank**: SQL challenges
- **freeCodeCamp**: SQL curriculum

### Books
- "SQL for Data Scientists" by Renee M. P. Teate
- "Learning SQL" by Alan Beaulieu
- "Database System Concepts" by Silberschatz

---

## 🎯 Next Steps

1. **Install your preferred database system**
2. **Set up a GUI tool** for easier development
3. **Create a practice database** with sample data
4. **Start with Chapter 2: SQL Basics**
5. **Practice regularly** with real databases

**Remember**: The best way to learn SQL is by doing. Start simple, build gradually, and practice consistently!

---

## 📞 Support and Community

- **Stack Overflow**: sql tag for questions
- **Reddit**: r/SQL, r/database, r/mysql, r/PostgreSQL
- **GitHub**: Database-related projects and issues
- **Official Forums**: Each database has community forums

**Happy learning!** 🎉
