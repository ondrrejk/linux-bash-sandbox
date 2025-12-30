#!/usr/bin/env bash

# this script should output a clean, readable system report about:
# system info, cpu, memory, disk, services, network, logs
# this script should also contain output options, colors for readability and exit codes

# colors
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"

# info messages
ok()    { echo -e "${GREEN}[OK]${RESET} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${RESET} $1"; }
crit()  { echo -e "${RED}[CRIT]${RESET} $1"; }

# flags
FULL=false
SUMMARY=false
SAVE_FILE=""
EXIT_CODE=0

# how to use
usage() {
cat <<EOF
Usage: $0 [OPTIONS]

Options:
  --full            Full detailed report
  --summary         Short summary report
  --save [FILE]     Save output to [FILE]
  --help            Show this help message

Examples:
  $0 --full
  $0 --summary --save /tmp/report.txt
EOF
}

# arg parsing
while [[ $# -gt 0 ]]; do
    case "$1" in
        --full) FULL=true; shift ;;
        --summary) SUMMARY=true; shift ;;
        --save) SAVE_FILE="$2"; shift 2 ;;
        --help) usage; exit 0 ;;
        *) echo "Unknown option: $1"; usage; exit 1 ;;
    esac
done

# default: full report
if ! $FULL && ! $SUMMARY; then
    FULL=true
fi

# output wrapper
OUT=""

append() {
    OUT+="$1"$'\n' # $ before newline to mark special character '\n'
}

print_or_save() {
    if [[ -n "$SAVE_FILE" ]]; then # if SAVE_FILE is not-empty, then
        echo -e "$OUT" > "$SAVE_FILE" # save it to dest file
        echo "Saved to $SAVE_FILE"
    else
        echo -e "$OUT" # just output it
    fi
}

# system info
system_info() {
    append "===== SYSTEM INFORMATION ====="
    append "Hostname: $(hostname)"
    append "OS: $(grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '\"')"
    # cut command => -d flag is used to specify delimeter (in this case "="), -f flag is used to specify number of fields to cut the input into
    # tr is used to translate strings, -d flag = delete
    append "Kernel: $(uname -r)" # basic OS info, -r = kernel release version
    append "Uptime: $(uptime -p)" # how long the system has been running since its last reboot, -p = pretty format
    append ""
}

# cpu
cpu_info() {
    append "===== CPU ====="
    LOAD=$(awk '{print $1}' /proc/loadavg)
    append "Current Load: $LOAD"
    # reflects the demand on the CPU, including both running and waiting processes
    # 1.0 avg for single-core means full utiliziation (4.0 for quad core, etc.)
    append "Top 5 CPU Processes:"
    append "$(ps -eo pid,comm,%cpu --sort=-%cpu | head -n 6)"
    # ps -e => displays all processes system-wide
    # ps -o => select specific columns and control their order
    # sort by cpu usage by %
    # head -n[num] => show the first [num] lines
    append ""
}

# memory
memory_info() {
    append "===== MEMORY ====="
    append "$(free -h)" # free memory in human-readable format

    append "Top 5 Memory Processes:"
    append "$(ps -eo pid,comm,%mem --sort=-%mem | head -n 6)"
    append ""
}

# disk
disk_info() {
    append "===== DISK ====="
    append "$(df -h)" # free disk space in human-readable format

    while read -r line; do
        USE=$(echo "$line" | awk '{print $5}' | tr -d '%')
        MOUNT=$(echo "$line" | awk '{print $6}')
        if [[ "$USE" -gt 80 ]]; then
            append "$(crit "Partition $MOUNT at ${USE}%")"
            EXIT_CODE=1
        fi
    done < <(df -h | tail -n +2) # tail -n +2 => start output from line 2
    # <(...) = process substitution => instead of file, we input a process in this syntax
    append ""
}

# services
check_service() {
    local svc="$1" # function-local variable svc = first param
    STATUS=$(systemctl is-active "$svc" 2>/dev/null)
    # 2>/dev/null hides error messages (ex.: if the service doesn’t exist)
    if [[ "$STATUS" == "active" ]]; then
        append "$(ok "$svc is running")"
    else
        append "$(crit "$svc is NOT running")"
        EXIT_CODE=2
    fi
}

services_info() {
    append "===== SERVICES ====="
    for svc in ssh cron NetworkManager; do # checks important services if they're all up and running
        check_service "$svc"
    done
    append ""
}

# network
network_info() {
    append "===== NETWORK ====="
    append "IP Address: $(hostname -I | awk '{print $1}')"
    append "Default Gateway: $(ip route | grep default | awk '{print $3}')"
    # ip route defaults to "ip route show"
    append "Ping Test (8.8.8.8):"
    if ping -c1 -W1 8.8.8.8 >/dev/null 2>&1; then
    # -c flag stands for count
    # -W flag stands for timeout (in seconds) => if no response within 1 second, treat as failure
    # hide normal ping output to /dev/null
    # 2>&1 redirects stderr to stdout, which already redirected to /dev/null
        append "$(ok "Ping successful")"
    else
        append "$(crit "Ping failed")"
        EXIT_CODE=1
    fi

    append "DNS Test (resolving google.com):"
    if getent hosts google.com >/dev/null; then # tests the name service switch
        append "$(ok "DNS resolution OK")"
    else
        append "$(crit "DNS resolution FAILED")"
        EXIT_CODE=1
    fi

    append ""
}

# logs
logs_info() {
    append "===== LOGS ====="
    append "Last 10 syslog lines:"
    append "$(journalctl -n 10 --no-pager 2>/dev/null)"

    WARN_COUNT=$(journalctl -p warning -n 1000 2>/dev/null | wc -l)
    ERR_COUNT=$(journalctl -p err -n 1000 2>/dev/null | wc -l)
    # displays the most recent 1000 log entries sorted by priority level of "warning" or higher
    # wc -l returns the number of lines
    append "Warnings: $WARN_COUNT"
    append "Errors: $ERR_COUNT"

    if [[ "$ERR_COUNT" -gt 0 ]]; then
        EXIT_CODE=2
    elif [[ "$WARN_COUNT" -gt 0 ]]; then
        EXIT_CODE=1
    fi

    append ""
}

# summary mode
summary_report() {
    append "===== SYSTEM SUMMARY ====="
    append "Load: $(awk '{print $1}' /proc/loadavg)"
    append "Memory Used: $(free -h | awk '/Mem:/ {print $3 "/" $2}')"
    append "Disk Usage:"
    append "$(df -h --output=source,pcent | tail -n +2)"
    # --output=source,pcent is a built-in flag to output the filesystem name and the used space percentage
    append ""
}

# run
if $SUMMARY; then
    summary_report
else
    system_info
    cpu_info
    memory_info
    disk_info
    services_info
    network_info
    logs_info
fi

# output
print_or_save
exit $EXIT_CODE