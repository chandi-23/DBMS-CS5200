-----------
## Test Script for the file LokeshaC.CRDB.CS5200.R
-----------

library(RSQLite)

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
print(result)

# Disconnect from the database
dbDisconnect(connStr)

