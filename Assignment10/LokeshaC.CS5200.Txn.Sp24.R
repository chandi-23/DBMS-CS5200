library(DBI)
library(RMySQL)
library(lubridate)
library(dplyr)

birdStrikeDBCon = dbConnect(RMySQL::MySQL(),
                            dbname='sql5694564',
                            host='sql5.freemysqlhosting.net',
                            port=3306,
                            user='sql5694564',
                            password='wd6xs7ESMR')

strikes_data <- dbGetQuery(birdStrikeDBCon, "SELECT * FROM strikes;")
print(nrow(strikes_data)) # 12779


## Functions from the Practicum 1

## Insert the data into airports table

# Function: insert_airports
# Description: This function inserts airport data into the 'airports' table.
#
# Parameters:
#   df - Dataframe containing airport information.
#   dbconn - database connection string
insert_airports <- function(dbconn, df) {
  # Transform and clean data if needed
  
  df <- df[, c("airport", "origin")]
  
  df$airport <- trimws(df$airport)
  
  colnames(df) <- c("airportName", "airportState")
  
  # Create a unique set of airports
  unique_airports <- unique(df)
  
  # Insert data into the 'airports' table
  dbWriteTable(dbconn, "airports", unique_airports, append = TRUE, row.names = FALSE)
}


## Insert the data into flights table

# Function: insert_flights
# Description: Inserts flight data into the 'flights' table.
#
# Parameters:
#   conn - Database connection.
#   df - Dataframe containing flight information.
insert_flights <- function(conn, df) {
  # Transform and clean data if needed
  # print(df)
  df <- df[, c("airline", "flight_date", "origin",  "aircraft", "heavy_flag")]
  colnames(df) <- c("airlineName", "date", "origin",  "aircraftType", "isHeavy")
  #print(df)
  df$date <- as.Date(df$date)  # Convert date to Date type
  
  # Map 'isHeavy' values to boolean
  df$isHeavy <- tolower(df$isHeavy) == "yes"
  
  # Map 'originAirport' values to corresponding 'aid' values from the 'airports' table
  airports_mapping <- dbGetQuery(conn, "SELECT * FROM airports")
  df$originAirport <- airports_mapping$aid[match(df$origin, airports_mapping$airportState)]
  
  df$origin <- NULL
  
  # Create a unique set of flights
  unique_flights <- unique(df)
  
  # Insert data into the 'flights' table
  dbWriteTable(conn, "flights", unique_flights, append = TRUE, row.names = FALSE)
}


## Inserting into conditions table
# Function: insert_conditions
# Description: Inserts sky conditions data into the 'conditions' table.
#
# Parameters:
#   conn - Database connection.
#   df - Dataframe containing sky conditions information.

insert_conditions <- function(conn, df) {
  # Transform and clean data if needed
  df <- df[, c("sky_conditions")]
  
  # Create a data frame with the desired column name
  unique_conditions <- unique(data.frame(sky_condition = df))
  
  # Add an empty 'explanation' column
  unique_conditions$explanation <- NA
  
  # Insert data into the 'conditions' table
  dbWriteTable(conn, "conditions", unique_conditions, append = TRUE, row.names = FALSE)
}


### inserting into strikes table

# Function: insert_strikes
# Description: Inserts bird strike data into the 'strikes' table.
#
# Parameters:
#   conn - Database connection.
#   df - Dataframe containing bird strike information.

insert_strikes <- function(conn, df) {
  
  df <- df[, c("flight_date","wildlife_size_numeric", "impact", "damage", "altitude_ft", "sky_conditions", "aircraft", "airline", "heavy_flag", "origin")]
  colnames(df) <- c("date","numbirds", "impact", "damage", "altitude", "conditions", "aircraft", "airline", "isHeavy", "origin")
  
  df$isHeavy <- tolower(df$isHeavy) == "yes"
  
  # Map 'damage' values to boolean
  df$damage <- tolower(df$damage) == "damage"
  
  
  # Convert altitude to integer
  df$altitude <- as.integer(df$altitude)
  
  # Map 'airport' to corresponding 'fid' values from the 'flights' table
  flights_mapping <- dbGetQuery(conn, "SELECT * from flights")
  
  df$fid <- flights_mapping$fid[match(
    df$date, flights_mapping$date)]
  
  # Map 'sky_conditions' to corresponding 'cid' values from the 'conditions' table
  conditions_mapping <- dbGetQuery(conn, "SELECT * FROM conditions")
  df$conditions <- conditions_mapping$cid[match(df$conditions, conditions_mapping$sky_condition)]
  
  # Create a unique set of strikes
  unique_strikes <- (df)
  # Remove 'date', 'aircraft', and 'airlineName' columns before inserting into the 'strikes' table
  columns_to_remove <- c("date", "aircraft", "airline", "isHeavy", "origin")
  unique_strikes <- unique_strikes[, !(names(unique_strikes) %in% columns_to_remove)]
  
  # Insert data into the 'strikes' table
  dbWriteTable(conn, "strikes", unique_strikes, append = TRUE, row.names = FALSE)
}





# Function to remove existing data from the "strikes" table
remove_existing_strikes <- function(con) {
  query <- "DELETE FROM strikes"
  dbExecute(con, query)
}

# Remove existing data from the "strikes" table
# remove_existing_strikes(birdStrikeDBCon)

# Function to start a SQL transaction and add all new bird strikes from the CSV to the database
add_bird_strikes <- function(con, csv_file_path, delay_seconds, use_transactions) {
  # Begin transaction
  if (use_transactions) {
    dbBegin(con)
    print("Using Transaction: Begin...")
  }
  
  # Read CSV file
  bird_strikes <- read.csv(csv_file_path, header = TRUE, sep = ",")
  
  # Preprocessing
  # Convert date format
  bird_strikes$flight_date<- parse_date_time(bird_strikes$flight_date, orders=c("m-d-y H:M","m/d/y H:M"))
  bird_strikes$flight_date <- format(bird_strikes$flight_date,"%Y-%m-%d")
  # Convert altitude_ft column to integer
  bird_strikes$altitude_ft <- as.integer(gsub(",", "", bird_strikes$altitude_ft))  # Remove commas and convert to integer
  size_mapping <- c("Small" = 1, "Medium" = 2, "Large" = 3)
  bird_strikes$wildlife_size_numeric <- size_mapping[bird_strikes$wildlife_size]
  bird_strikes <- bird_strikes[which(bird_strikes$airport!='' & bird_strikes$model!='' & bird_strikes$origin!='' ),]
  
  # Loop through the data and insert into "strikes" table within the transaction
  for (i in 1:nrow(bird_strikes)) {
    strike.raw <- bird_strikes[i, ]
    
    # Prerequites
    # Insert data into the 'airports' table
    insert_airports(birdStrikeDBCon, strike.raw)
    # insert into flights
    insert_flights(birdStrikeDBCon, strike.raw)
    # insert into conditions
    insert_conditions(birdStrikeDBCon, strike.raw)
    
    # inserting into STRIKES:
    insert_strikes(birdStrikeDBCon, strike.raw)
    
    Sys.sleep(delay_seconds)
  }
  
  if (use_transactions) {
  # Commit or rollback the transaction
  tryCatch({
    dbCommit(con)
    message("Transaction committed successfully.")
  }, error = function(e) {
    dbRollback(con)
    warning("Transaction rolled back due to errors.")
  })
    }
}

# Main function
main <- function() {
  # Get command-line arguments
  args <- commandArgs(trailingOnly = TRUE)
  
  # Check if a CSV file name and transaction flag are provided as command-line arguments
  if (length(args) != 2) {
    stop("Usage: Rscript script.R <csv_file> <use_transactions>")
  }
  
  # Extract CSV file name and use_transactions flag from command-line arguments
  csv_file <- args[1]
  use_transactions <- as.logical(args[2])
  delay_seconds <- 1
  # Add new bird strikes from the CSV to the database
  add_bird_strikes(birdStrikeDBCon, csv_file, delay_seconds, use_transactions)
  
  # Close the database connection
  dbDisconnect(birdStrikeDBCon)
}

strikes_data <- dbGetQuery(birdStrikeDBCon, "SELECT * FROM strikes;")
print(nrow(strikes_data)) # 12829

main()

