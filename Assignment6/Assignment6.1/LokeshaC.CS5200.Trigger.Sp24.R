library(RSQLite)

# Connect to database
dbfile <- "MediaDB.db"
connStr <- dbConnect(RSQLite::SQLite(), dbfile)

# Check if the column already exists
result <- dbGetQuery(connStr, "PRAGMA table_info(albums)")
print(result)

if (!"play_time" %in% result$name) {
  # Add the column if it doesn't exist
  dbExecute(connStr, "ALTER TABLE albums ADD COLUMN play_time NUMERIC CHECK (play_time >= 0);")
}

dbExecute(connStr, "UPDATE albums
SET play_time = (
  SELECT COALESCE(SUM(Milliseconds) / (1000 * 60), 0) AS total_play_time
  FROM tracks
  WHERE albums.AlbumId = tracks.AlbumId
);");

result <- dbGetQuery(connStr, "Select * from albums LIMIT 10")
print(result)

triggerName <- "tr_after_insert_track"
dbExecute(connStr, paste("DROP TRIGGER IF EXISTS", triggerName, ";"))

dbExecute(connStr, "
          Create Trigger tr_after_insert_track
          After Insert ON tracks
          for EACH ROW
          BEGIN
            UPDATE albums
            SET play_time = (
        SELECT COALESCE(SUM(Milliseconds) / (1000 * 60), 0) AS total_play_time
        FROM tracks
        WHERE albums.AlbumId = tracks.AlbumId
    )
    WHERE AlbumId = NEW.AlbumId;
          END;
          ")

triggerName <- "tr_after_update_track"

dbExecute(connStr, paste("DROP TRIGGER IF EXISTS", triggerName, ";"))

dbExecute(connStr, "
          Create Trigger tr_after_update_track
          After update ON tracks
          for EACH ROW
          BEGIN
            UPDATE albums
            SET play_time = (
        SELECT COALESCE(SUM(Milliseconds) / (1000 * 60), 0) AS total_play_time
        FROM tracks
        WHERE albums.AlbumId = tracks.AlbumId
    )
    WHERE AlbumId = AlbumId;
          END;
          ")


triggerName <- "tr_after_delete_track"
dbExecute(connStr, paste("DROP TRIGGER IF EXISTS", triggerName, ";"))

dbExecute(connStr, "
          Create Trigger tr_after_delete_track
          After delete ON tracks
          for EACH ROW
          BEGIN
            UPDATE albums
            SET play_time = (
        SELECT COALESCE(SUM(Milliseconds) / (1000 * 60), 0) AS total_play_time
        FROM tracks
        WHERE albums.AlbumId = tracks.AlbumId
    )
    WHERE AlbumId = AlbumId;
          END;
          ")

# Close the connection
dbDisconnect(connStr)

## Testing

# Connect to database
dbfile <- "MediaDB.db"
connStr <- dbConnect(RSQLite::SQLite(), dbfile)

# Display albums information before making changes
before_result <- dbGetQuery(connStr, "SELECT * FROM albums WHERE albumId = 1")
print("Albums Information Before Changes:")
# Expected Values:
# AlbumId                                 Title ArtistId play_time
# 1       1 For Those About To Rock We Salute You        1        40
print(before_result)

# Delete the track with TrackId 15920 if it exists
dbExecute(connStr, "DELETE FROM tracks WHERE TrackId = 15920 AND EXISTS (SELECT 1 FROM tracks WHERE TrackId = 15920)")

# Insert a new track with TrackId 15920
dbExecute(connStr, "INSERT INTO tracks (TrackId, Name, AlbumId, MediaTypeId, GenreId, Composer, Milliseconds, Bytes, UnitPrice) VALUES (15920, 'cool song', 1, 1, 1, 'FunkyBass', 500000, 11894433, 1.1)")

# Display albums information after inserting a new track
after_insert_result <- dbGetQuery(connStr, "SELECT * FROM albums WHERE albumId = 1")
print("Albums Information After Insert:")
# AlbumId                                 Title ArtistId play_time
# 1       1 For Those About To Rock We Salute You        1        48
print(after_insert_result)

# Update Milliseconds for the track with TrackId 15920
dbExecute(connStr, "UPDATE tracks SET Milliseconds = 2000000 WHERE TrackId = 15920")

# Display albums information after updating Milliseconds
after_update_result <- dbGetQuery(connStr, "SELECT * FROM albums WHERE albumId = 1")
print("Albums Information After Update:")
# Expected values:
# AlbumId                                 Title ArtistId play_time
# 1       1 For Those About To Rock We Salute You        1        73
print(after_update_result)

# Delete the track with TrackId 15920
dbExecute(connStr, "DELETE FROM tracks WHERE TrackId = 15920")

# Display albums information after deleting the track
after_delete_result <- dbGetQuery(connStr, "SELECT * FROM albums WHERE albumId = 1")
print("Albums Information After Delete:")
# Expected values:
# AlbumId                                 Title ArtistId play_time
# 1       1 For Those About To Rock We Salute You        1        40
print(after_delete_result)

# Close the connection
dbDisconnect(connStr)
