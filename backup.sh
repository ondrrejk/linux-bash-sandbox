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

if [! -d "$SOURCE"]; then # if directory source doesnt exist then
    echo "Error: Source directory '$SOURCE' does not exist."
    exit 1
fi

if [! -d "$DEST"]; then # if directory destination doesnt exist then
    echo "Destination directory '$DEST' does not exist. Creating it..."
    mkdir -p "$DEST" # make full directory path with the name "$DEST"
fi

# create timestamp
TIMESTAMP=$(date +"%Y/%m/%d_%H:%M:%S")

# create backup name
BACKUP_NAME="backup_$TIMESTAMP.tar.gz" # tar = tape archive, .gz = GNU zip => make the backup file an archive file and compress it

# create the archive
echo "Creating backup..."
tar -czf "$DEST/$BACKUP_NAME" "$SOURCE" # tar: (c)reate g(z)ip (v)erbose (f)ilename [filename.tar.gz] [contents]

# print success / error
if [-f "$DEST/$BACKUP_NAME"]; then # if backup file is a file, then
    echo "Backup created: $DEST/$BACKUP_NAME" # success
else
    echo "Error: Backup failed." # error
    exit 1
fi

# show backup size
BACKUP_SIZE=(du -h "$DEST/$BACKUP_NAME" | awk '{print $1}') # backup size = disk usage of "$DEST/$BACKUP_NAME" in a human-readable format -> pipe that into awk - first column
echo "Backup file size: $BACKUP_SIZE"