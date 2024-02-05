## ---------------------------
## Script name:  LokeshaC.CRDB.CS5200.R
## Purpose of script: To create a SQLite database
## Author: Chandresh Lokesha
## Date Submitted: 2024-02-05
## ---------------------------
## Notes: To create a SQLite db and then perform querying to 
## test(PFA: LokeshaCTestScript.R) the db
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

