library(RSQLite)

# Connect to database
dbfile <- "MediaDB.db"
connStr <- dbConnect(RSQLite::SQLite(), dbfile)

# Display albums information before making changes
before_result <- dbGetQuery(connStr, "SELECT * FROM albums WHERE albumId = 1")
print("Albums Information Before Changes:")
print(before_result)

# Delete a track with TrackId 15920
dbExecute(connStr, "DELETE FROM tracks WHERE TrackId = 15920")

# Insert a new track with TrackId 15920
dbExecute(connStr, "INSERT INTO tracks (TrackId, Name, AlbumId, MediaTypeId, GenreId, Composer, Milliseconds, Bytes, UnitPrice) VALUES (15920, 'cool song', 1, 1, 1, 'FunkyBass', 500000, 11894433, 1.1)")

# Display albums information after inserting a new track
after_insert_result <- dbGetQuery(connStr, "SELECT * FROM albums WHERE albumId = 1")
print("Albums Information After Insert:")
print(after_insert_result)

# Update Milliseconds for the track with TrackId 15920
dbExecute(connStr, "UPDATE tracks SET Milliseconds = 2000000 WHERE TrackId = 15920")

# Display albums information after updating Milliseconds
after_update_result <- dbGetQuery(connStr, "SELECT * FROM albums WHERE albumId = 1")
print("Albums Information After Update:")
print(after_update_result)

# Delete the track with TrackId 15920
dbExecute(connStr, "DELETE FROM tracks WHERE TrackId = 15920")

# Display albums information after deleting the track
after_delete_result <- dbGetQuery(connStr, "SELECT * FROM albums WHERE albumId = 1")
print("Albums Information After Delete:")
print(after_delete_result)

# Close the connection
dbDisconnect(connStr)
