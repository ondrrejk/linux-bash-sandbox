#!/bin/bash

# simple backup script => backs up files
# Usage: ./backup.sh [source_file] [destination_dir]

# color palette - ansi escape codes (30-37=foreground colors)
RED="\e[31m" # m signifies end of line
GREEN="\e[32m"
YELLOW="\e[33m"
RESET="\e[0m" # resets all attributes

if [[ "$1 == --help" || "$1 == -h" ]] then;
    echo -e "${YELLOW}Usage:${RESET}"
    echo "  Usage: ./backup.sh [source_file] [destination_dir]"
    echo
    echo -e "${YELLOW}Description:${RESET}"
    echo "  Creates a compressed backup (.tar.gz) of the source directory"
    echo "  and stores it in the destination directory with a timestamp."
    echo
    echo -e "${YELLOW}Options:${RESET}"
    echo "  --help, -h Show this help menu"
    exit 0
fi

# --exclude flag
EXCLUDE=""
if [["$1" == "--exclude"]]; then
    EXCLUDE="$2"
    shift 2
fi

if [$# -ne 2]; then # if number of params -not equals 2 then
    echo "${RED}Error: You must provide a source file and a destination directory."
    echo "${YELLOW}Usage: ./backup.sh [source_file] [destination_dir]${RESET}"
    exit 1 # exit with an error
fi # end of if statement

SOURCE=$1 # first param = source
DEST=$2 # second param = destination

echo "Source: $SOURCE"
echo "Destination: $DEST"

if [! -d "$SOURCE"]; then # if directory source doesnt exist then
    echo "${RED}Error: Source directory '$SOURCE' does not exist."
    exit 1
fi

if [! -d "$DEST"]; then # if directory destination doesnt exist then
    echo "${YELLOW}Destination directory '$DEST' does not exist. Creating it...${RESET}"
    mkdir -p "$DEST" # make full directory path with the name "$DEST"
fi

# create timestamp
TIMESTAMP=$(date +"%Y/%m/%d_%H:%M:%S")

# create backup name
BACKUP_NAME="backup_$TIMESTAMP.tar.gz" # tar = tape archive, .gz = GNU zip => make the backup file an archive file and compress it

# create the archive
echo "${YELLOW}Creating backup...${RESET}"
if [-n "$EXCLUDE"]; then # if EXCLUDE contains anything, then
    echo -e "${YELLOW}Excluding: '$EXCLUDE'${RESET}"
    tar -czf "$DEST/$BACKUP_NAME" --exclude "$EXCLUDE" "$SOURCE"
else
    tar -czf "$DEST/$BACKUP_NAME" "$SOURCE" # tar: (c)reate g(z)ip (v)erbose (f)ilename [filename.tar.gz] [contents]
fi

# print success / error
if [-f "$DEST/$BACKUP_NAME"]; then # if backup file is a file, then
    echo "${GREEN}Backup created: $DEST/$BACKUP_NAME" # success
else
    echo "${RED}Error: Backup failed.${RESET}" # error
    exit 1
fi

# show backup size
BACKUP_SIZE=(du -h "$DEST/$BACKUP_NAME" | awk '{print $1}') # backup size = disk usage of "$DEST/$BACKUP_NAME" in a human-readable format -> pipe that into awk - first column
echo "${YELLOW}Backup file size: $BACKUP_SIZE"