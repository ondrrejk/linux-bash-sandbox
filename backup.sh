#!/bin/bash

# simple backup script => backs up files
# Usage: ./backup.sh [source_file] [destination_dir]

if [$# -ne 2]; then # if number of params -not equals 2 then
    echo "Error: You must provide a source file and a destination directory."
    echo "Usage: ./backup.sh [source_file] [destination_dir]"
    exit 1 # exit with an error
fi # end of if statement

SOURCE=$1 # first param = source
DEST=$2 # second param = destination

echo "Source: $SOURCE"
echo "Destination: $DEST"

if [! -d "$SOURCE"]; then
    echo "Error: Source directory '$SOURCE' does not exist."
    exit 1
fi

if [! -d "$DEST"]; then
    echo "Destination directory '$DEST' does not exist. Creating it..."
    mkdir -p "$DEST"
fi