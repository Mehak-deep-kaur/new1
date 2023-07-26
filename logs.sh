#!/bin/bash

# Create a temporary file for output
output=$(mktemp)

# Define the date format in the logs
date_format="%Y-%m-%j %H:%M:%S"

# Request the directory from the user
echo "Input directory name:"
read dir

# Request the reference date from the user
echo "Input the reference date (YYYY-MM-JJJ):"
read ref_date

# Verify if the directory exists
if [ -d "$dir" ]; then
    # Go through each text file in the directory
    for filepath in "$dir"/*.txt
    do
        if [ -f "$filepath" ]; then
            echo "Processing file: $filepath"

            # Reset flag
            append_next=false

            # Use cat and a pipe to go through each line in the file
            cat $filepath | while read line
            do
                # If line starts with Timestamp, compare with reference date
                if [[ "$line" =~ ^Timestamp: ]]; then
                    current_date=${line#*: }

                    if [[ "$current_date" > "$ref_date" ]]; then
                        append_next=true
                    else
                        append_next=false
                    fi
                # If line starts with Message and flag is true, append line to output
                elif [[ "$line" =~ ^Message: ]] && [ "$append_next" = true ]; then
                    echo "Timestamp: $current_date $line" >> "$output"
                fi
            done
        fi
    done
else
    echo "Directory $dir does not exist."
fi

# Display the results in descending order
sort -r "$output"
rm "$output" # Remove the temporary file
