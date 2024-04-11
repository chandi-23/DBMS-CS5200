import sqlite3

try:
    # Connect to the SQLite database file 'MediaDB.db'
    dbcon = sqlite3.connect('MediaDB.db')
    
    # Create a cursor object to interact with the database
    cursor = dbcon.cursor()
    
    # Print a message indicating successful connection
    print("Connection successful")

    cursor.execute("PRAGMA table_info(albums)")

    columns_info = cursor.fetchall()
    column_names = [column[1] for column in columns_info]
    
    if 'play_time' not in column_names:
        sql = "ALTER TABLE albums ADD COLUMN play_time NUMERIC CHECK (play_time >= 0);"
        cursor.execute(sql)

    # Create triggers
    sql = "UPDATE albums SET play_time = (SELECT COALESCE(SUM(Milliseconds) / (1000 * 60), 0) AS total_play_time FROM tracks WHERE albums.AlbumId = tracks.AlbumId);"
    cursor.execute(sql)

    triggerName = "tr_after_insert_track"
    cursor.execute(f"DROP TRIGGER IF EXISTS {triggerName};")
    cursor.execute("""Create Trigger tr_after_insert_track
          After Insert ON tracks
          for EACH ROW
          BEGIN
            UPDATE albums
            SET play_time = (
        SELECT COALESCE(SUM(Milliseconds) / (1000 * 60), 0) AS total_play_time
        FROM tracks
        WHERE albums.AlbumId = tracks.AlbumId )
    WHERE AlbumId = NEW.AlbumId;
          END;""")

    triggerName = "tr_after_update_track"
    cursor.execute(f"DROP TRIGGER IF EXISTS {triggerName};")
    # Create the 'AFTER UPDATE' trigger
    cursor.execute("""
    CREATE TRIGGER tr_after_update_track
    AFTER UPDATE ON tracks
    FOR EACH ROW
    BEGIN
        UPDATE albums
        SET play_time = (
            SELECT COALESCE(SUM(Milliseconds) / (1000 * 60), 0) AS total_play_time
            FROM tracks
            WHERE albums.AlbumId = tracks.AlbumId
        )
        WHERE AlbumId = NEW.AlbumId;
    END;
    """)

    # Drop the 'AFTER DELETE' trigger if it exists
    triggerName = "tr_after_delete_track"
    cursor.execute(f"DROP TRIGGER IF EXISTS {triggerName};")

    # Create the 'AFTER DELETE' trigger
    cursor.execute("""
    CREATE TRIGGER tr_after_delete_track
    AFTER DELETE ON tracks
    FOR EACH ROW
    BEGIN
        UPDATE albums
        SET play_time = (
            SELECT COALESCE(SUM(Milliseconds) / (1000 * 60), 0) AS total_play_time
            FROM tracks
            WHERE albums.AlbumId = tracks.AlbumId
        )
        WHERE AlbumId = OLD.AlbumId;
    END;
    """)
    
    dbcon.commit()

    # Close the cursor
    cursor.close()


    ### Testing ###

    # Connect to database
    dbfile = "MediaDB.db"
    connStr = sqlite3.connect(dbfile)
    cursor = connStr.cursor()

    # Display albums information before making changes
    before_result = cursor.execute("SELECT * FROM albums WHERE albumId = 1").fetchall()
    print("Albums Information Before Changes:")
    # Expected Playtime 40
    print(before_result)

    # Delete the track with TrackId 15920 if it exists
    cursor.execute("DELETE FROM tracks WHERE TrackId = 15920 AND EXISTS (SELECT 1 FROM tracks WHERE TrackId = 15920)")

    # Insert a new track with TrackId 15920
    cursor.execute("INSERT INTO tracks (TrackId, Name, AlbumId, MediaTypeId, GenreId, Composer, Milliseconds, Bytes, UnitPrice) VALUES (15920, 'cool song', 1, 1, 1, 'FunkyBass', 500000, 11894433, 1.1)")

    # Display albums information after inserting a new track
    after_insert_result = cursor.execute("SELECT * FROM albums WHERE albumId = 1").fetchall()
    print("Albums Information After Insert:")
    # Expected Playtime 48
    print(after_insert_result)

    # Update Milliseconds for the track with TrackId 15920
    cursor.execute("UPDATE tracks SET Milliseconds = 2000000 WHERE TrackId = 15920")

    # Display albums information after updating Milliseconds
    after_update_result = cursor.execute("SELECT * FROM albums WHERE albumId = 1").fetchall()
    print("Albums Information After Update:")
    # Expected Playtime 73
    print(after_update_result)

    # Delete the track with TrackId 15920
    cursor.execute("DELETE FROM tracks WHERE TrackId = 15920")

    # Display albums information after deleting the track
    after_delete_result = cursor.execute("SELECT * FROM albums WHERE albumId = 1").fetchall()
    print("Albums Information After Delete:")
    # Expected Playtime 40
    print(after_delete_result)

    connStr.commit()

except sqlite3.Error as error:
    # Handle any errors that may occur during the database connection or query execution
    print("Can't connect:", error)
    
finally:
    # Ensure that the database connection is closed, whether an exception occurred or not
    if dbcon:
        dbcon.close()
        print("Connection closed")
