#!/bin/bash

# Array of CSV files
csv_files=("File1-BirdStrikesData-V3-copy.csv" "File2-BirdStrikesData-V3-copy.csv" "File3-BirdStrikesData-V3-copy.csv" "File4-BirdStrikesData-V3-copy.csv" "File5-BirdStrikesData-V3-copy.csv")

# Loop over CSV files and start R processes concurrently
for csv_file in "${csv_files[@]}"
do
    echo $csv_file
    Rscript LokeshaC.CS5200.Txn.Sp24.R "$csv_file" False &  # Replace 1 with the desired delay in seconds
done

# Wait for all R processes to finish
wait

# End of script
