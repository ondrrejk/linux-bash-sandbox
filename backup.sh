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
    echo "  --help, -h  Show this help menu"
    echo "  --restore [directory_path]   Option to restore backup file into a directory"
    echo "  --fast  Enables low compression, faster"
    echo "  --max   Enables high compression, slower"
    echo "  --exclude [directory_path]   Excludes directory from backup"
    exit 0
fi

spinner(){
    local pid=$!
    local delay=0.1
    local spin='|/-\'
    while kill -0 $pid 2>/dev/null; do # if process isn't killed, continue, else hide any error output (error code 2 = user-side error, redirect that into /dev/null)
        for i in {0..3}; do # for spin.length times
            printf "\r${YELLOW}Processing... ${spin:$i:1}${RESET}" # spin -> specified at $i position -> extracts 1 character
            sleep $delay # wait for [delay] seconds
        done
    done
    printf "\r${GREEN}Done!${RESET}\n"
}

# create timestamp
TIMESTAMP=$(date +"%Y/%m/%d_%H:%M:%S") # date => current date in default format, you can add custom format by prefix + and [format string]

# setup logging
LOGFILE="backup.log"
log(){
    echo "$TIMESTAMP - $1" >> "$LOGFILE" # logs current timestamp and provided message (first parameter)
}

# restore option
if [["$1" == "--restore"]]; then
    BACKUP_FILE=$2
    RESTORE_DIR=$3

    # unexisting file error catch
    if [[ ! -f "$BACKUP_FILE"]]; then
        echo -e "${RED}Error: Backup file not found.${RESET}"
        exit 1
    fi

    # create directory for restored file
    mkdir -p "$RESTORE_DIR"
    
    echo -e "${YELLOW}Restoring backup...${RESET}"
    log "Restoring $BACKUP_FILE to $RESTORE_DIR"

    # tar -> extract zip file
    tar -xzf "$BACKUP_FILE" -C "$RESTORE_DIR" & # -C flag is used for specifying destination directory
    spinner # show spinner when extracting

    echo -e "${GREEN}Backup successfully restored.${RESET}"
    log "Restore complete"

    exit 0
fi

# compression options
COMPRESSION=""
if [["$1" == --fast]]; then
    COMPRESSION="--fast"
    shift
elif [["$1" == --max]]; then
    COMPRESSION="--max"
    shift
fi

# --exclude flag
EXCLUDES=()
while [["$1" == "--exclude"]]; do
    EXCLUDES+=("$2")
    shift 2
done

if [$# -ne 2]; then # if number of params -not equals 2 then
    echo "${RED}Error: You must provide a source file and a destination directory."
    echo "${YELLOW}Usage: ./backup.sh [source_file] [destination_dir]${RESET}"
    exit 1 # exit with an error
fi # end of if statement

SOURCE=$1 # first param = source
DEST=$2 # second param = destination

echo "Source: $SOURCE"
echo "Destination: $DEST"
# log backup source and destination
log "Backup started. Source: $SOURCE, Destination: $DEST"

if [! -d "$SOURCE"]; then # if directory source doesnt exist then
    echo "${RED}Error: Source directory '$SOURCE' does not exist."
    exit 1
fi

if [! -d "$DEST"]; then # if directory destination doesnt exist then
    echo "${YELLOW}Destination directory '$DEST' does not exist. Creating it...${RESET}"
    mkdir -p "$DEST" # make full directory path with the name "$DEST"
fi

# create backup name
BACKUP_NAME="backup_$TIMESTAMP.tar.gz" # tar = tape archive, .gz = GNU zip => make the backup file an archive file and compress it

# create the archive
echo "${YELLOW}Creating backup...${RESET}"
# log creating backup
log "Creating backup archive..."

# tar: (c)reate g(z)ip (v)erbose (f)ilename [filename.tar.gz] [contents]
# check for exclusions
TAR_EXCLUDES=() # from dir names in EXCLUDES to true exclusions in TAR_EXCLUDES
for EX in "${EXCLUDES[@]}"; do # for each element in EXCLUDES, treat it as a seperate word and do
    TAR_EXCLUDES+=(--exclude="$EX") # add --excludes=[excluded_file] to TAR_EXCLUDES array
    echo -e "${YELLOW}Excluding: $EX${RESET}"
    # log backup exclusion
    log "Excluding: $EX"
done
# compression options
if [[ "$COMPRESSION" == "--fast" ]]; then
    TAR_OPTIONS="-1"
elif [[ "$COMPRESSION" == "--max" ]]; then
    TAR_OPTIONS="-9"
else
    TAR_OPTIONS=""
fi
# apply tar options and exclusions to tar and create backup
tar -czf "$DEST/$BACKUP_NAME" "$TAR_OPTIONS" ${TAR_EXCLUDES[@]} "$SOURCE" & # treat every element in TAR_EXCLUDES as a separate element
spinner # show spinner when zipping

# print success / error
if [-f "$DEST/$BACKUP_NAME"]; then # if backup file is a file, then
    echo "${GREEN}Backup created: $DEST/$BACKUP_NAME" # success
    # log backup success
    log "Backup completed successfully: $DEST/$BACKUP_NAME"
else
    echo "${RED}Error: Backup failed.${RESET}" # error
    # log backup fail
    log "Backup failed."
    exit 1
fi

# show backup size
BACKUP_SIZE=(du -h "$DEST/$BACKUP_NAME" | awk '{print $1}') # backup size = disk usage of "$DEST/$BACKUP_NAME" in a human-readable format -> pipe that into awk - first column
echo "${YELLOW}Backup file size: $BACKUP_SIZE"
# log backup size
log "Backup size: $SIZE"