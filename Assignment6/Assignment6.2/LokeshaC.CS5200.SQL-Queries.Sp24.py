import sqlite3

try:
    # Connect to the SQLite database file 'MediaDB.db'
    dbcon = sqlite3.connect('MediaDB.db')
    
    # Create a cursor object to interact with the database
    cursor = dbcon.cursor()
    
    # Print a message indicating successful connection
    print("Connection successful")

    # Define the SQL query to select specific columns from the 'employees' table, ordered by LastName
    sql = "SELECT FirstName, LastName, Title, HireDate FROM employees ORDER BY LastName;"

    # Execute the SQL query
    cursor.execute(sql)
    
    # Fetch all the rows returned by the query
    rs = cursor.fetchall()
    
    # Print the result set
    print(rs)
    
    # Close the cursor
    cursor.close()

except sqlite3.Error as error:
    # Handle any errors that may occur during the database connection or query execution
    print("Can't connect:", error)
    
finally:
    # Ensure that the database connection is closed, whether an exception occurred or not
    if dbcon:
        dbcon.close()
        print("Connection closed")
