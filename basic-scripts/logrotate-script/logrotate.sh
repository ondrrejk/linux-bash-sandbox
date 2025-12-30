#!/usr/bin/env bash

## this script will have following capabilities:
# -> the script should accept a directory containing logs.
# -> support flags: --compress, --days N, --delete M, --dry-run, --help
# -> the script should: find logs older than N days, compress them (if --compress is used), move them to an archive directory, delete logs older than M days, log its own actions, handle errors, use colors for readability

# initialize colors
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"

# log file
LOGFILE="logrotate.log"
# log message into logfile
log() {
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') $1" >> "$LOGFILE"
}

# feedback + log messages
info()
    { echo -e "${GREEN}[OK]${RESET} $1"; log "[OK] $1"; }
warn()
    { echo -e "${YELLOW}[WARN]${RESET} $1"; log "[WARN] $1"; }
error()
    { echo -e "${RED}[ERROR]${RESET} $1"; log "[ERROR] $1"; }

# default values
COMPRESS=false
DAYS=0
DELETE_DAYS=0
DRY_RUN=false

# how to use
usage() {
    cat <<EOF
Usage: $0 [OPTIONS] <log_directory>

Options:
  --compress        Compress rotated logs (.gz)
  --days N          Rotate logs older than N days
  --delete M        Delete logs older than M days
  --dry-run         Show actions without executing
  --help            Show this help message

Example:
  $0 --compress --days 7 /var/log/myapp
EOF
}

# argument parsing
POSITIONAL=()

while [[ $# -gt 0 ]]; do # while num of params is greater than 0, do
    case "$1" in # important to keep the proper order of options
        --compress)
            COMPRESS=true
            shift
            ;;
        --days)
            DAYS="$2"
            shift 2
            ;;
        --delete)
            DELETE_DAYS="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --help)
            usage
            exit 0
            ;;
        -*)
            error "Invalid flag: $1"
            usage
            exit 1
            ;;
        *)
            POSITIONAL+=("$1")
            shift
            ;;
    esac
done

# reset the positional parameters to the specified list of arguments.
set -- "${POSITIONAL[@]}"

# set first param as the log directory
LOG_DIR="$1"

# validation
if [[ -z "$LOG_DIR" ]]; then # if LOG_DIR.length is zero, then
    error "No log directory provided"
    usage
    exit 1
fi

if [[ ! -d "$LOG_DIR" ]]; then # if LOG_DIR isnt a dir, then
    error "Directory does not exist: $LOG_DIR"
    exit 1
fi

# create archive dir name
ARCHIVE_DIR="$LOG_DIR/archive"

# run func + dry run wrapper
run() {
    if $DRY_RUN; then # if something is in DRY_RUN, then
        echo "[DRY RUN] $*" # "$*" = all params
    else
        # takes one or more arguments, concatenates them into a single string, and then interprets and executes that string as a shell command
        eval "$@" # treat every arg as a separate element, and run it
    fi
}

# create archive dir if it doesnt exist already
if [[ ! -d "$ARCHIVE_DIR" ]]; then
    info "Creating archive directory: $ARCHIVE_DIR"
    run "mkdir -p \"$ARCHIVE_DIR\""
fi

# rotate logs
if [[ "$DAYS" -gt 0 ]]; then
    info "Rotating logs older than $DAYS days"

    FILES=$(find "$LOG_DIR" -maxdepth 1 -type f -mtime +"$DAYS")
    # -maxdepth 1 because we want to rotate only logs in the log dir, in case there were other folders in the log dir
    # -type f specifies we want only files
    # -mtime +DAYS to search for time of last modification

    if [[ -z "$FILES" ]]; then
        warn "No logs older than $DAYS days found" # we can safely continue without exiting
    else
        for f in $FILES; do
            BASENAME=$(basename "$f") # only the name of the file, not the whole path
            TARGET="$ARCHIVE_DIR/$BASENAME"

            info "Moving $BASENAME to archive"
            run "mv \"$f\" \"$TARGET\"" # move f to the target dest

            if $COMPRESS; then # if something is in COMPRESS, then
                info "Compressing $TARGET"
                run "gzip -f \"$TARGET\""
            fi
        done
    fi
fi

# delete old logs
if [[ "$DELETE_DAYS" -gt 0 ]]; then
    info "Deleting logs older than $DELETE_DAYS days"

    if $DRY_RUN; then
        find "$ARCHIVE_DIR" -type f -mtime +"$DELETE_DAYS" -print
    else
        find "$ARCHIVE_DIR" -type f -mtime +"$DELETE_DAYS" -delete
    fi
fi

# successful info message + log
info "Log rotation completed successfully"
exit 0