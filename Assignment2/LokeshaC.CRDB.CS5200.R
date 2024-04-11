## ---------------------------
## Script name:  LokeshaC.CRDB.CS5200.R
## Purpose of script: To create a SQLite database
## Author: Chandresh Lokesha
## Date Submitted: 2024-02-05
## ---------------------------
## Notes: To create a SQLite db and then perform querying to 
## test the db
## ---------------------------


library(RSQLite)

# Connect to database
dbfile = "lessonDB-LokeshaC.sqlitedb"
connStr <- dbConnect(RSQLite::SQLite(), dbfile)

# Drop tables if they already exist
dbExecute(connStr, "DROP TABLE IF EXISTS Lesson")
dbExecute(connStr, "DROP TABLE IF EXISTS Module")
dbExecute(connStr, "DROP TABLE IF EXISTS Prerequisite")

# Lesson table
dbExecute(connStr, "
  CREATE TABLE Lesson (
    category INTEGER,
    number INTEGER,
    title TEXT,
    PRIMARY KEY (category, number)
  )
")

# Module table
dbExecute(connStr, "
  CREATE TABLE Module (
    mid TEXT PRIMARY KEY,
    title TEXT,
    lengthInMinutes INTEGER,
    difficulty TEXT CHECK(difficulty IN ('beginner', 
    'intermediate', 'advanced'))
  )
")

# Prerequisite table (junction table to represent many-to-many relationship)
dbExecute(connStr, "
  CREATE TABLE Prerequisite (
    category INTEGER,
    number INTEGER,
    mid TEXT,
    PRIMARY KEY (category, number, mid),
    FOREIGN KEY (category, number) REFERENCES Lesson(category, number),
    FOREIGN KEY (mid) REFERENCES Module(mid)
  )
")

# Adding in the end to avoid potential circular references during the 
# initial data loading process.
dbExecute(connStr, "PRAGMA foreign_keys = ON")

# Disconnect from the database
dbDisconnect(connStr)



## -----------
## TEST SCRIPT
## -----------

# Connect to SQLite database
dbfile = "lessonDB-LokeshaC.sqlitedb"
connStr <- dbConnect(RSQLite::SQLite(), dbname = dbfile)

dbExecute(connStr, "DELETE FROM Lesson")

# Insert test data into Lesson table
dbExecute(connStr, "
  INSERT INTO Lesson (category, number, title) VALUES
  (1, 101, 'Introduction to Programming'),
  (1, 102, 'Data Structures'),
  (2, 201, 'Database Management'),
  (2, 202, 'SQL Basics')
")

dbExecute(connStr, "DELETE FROM Module")

# Insert test data into Module table
dbExecute(connStr, "
  INSERT INTO Module (mid, title, lengthInMinutes, difficulty) VALUES
  ('M1', 'Programming Basics', 90, 'beginner'),
  ('M2', 'Database Fundamentals', 120, 'intermediate')
")

dbExecute(connStr, "DELETE FROM Prerequisite")

# Insert test data into Prerequisite table
dbExecute(connStr, "
  INSERT INTO Prerequisite (category, number, mid) VALUES
  (1, 102, 'M1'),
  (2, 202, 'M2')
")

# Enable check after insertion of data to avoid potential circular refernces
dbExecute(connStr, "PRAGMA foreign_keys = ON")

# Query to retrieve lessons and their prerequisites along with the 
# associated module title. 
query <- "
  SELECT l.category, l.number, l.title, m.title AS module_title
  FROM Lesson l
  LEFT JOIN Prerequisite p ON l.category = p.category AND l.number = p.number
  LEFT JOIN Module m ON p.mid = m.mid
"

result <- dbGetQuery(connStr, query)
if(length(result) != 4) {
  print("TestCase failed to get all the lessons and their prerequisites")
} else {
  print(result)  
}


# Disconnect from the database
dbDisconnect(connStr)