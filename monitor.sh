#!/bin/bash

# Simple system monitoring script
# i want this thing to refresh every second and show CPU, RAM, and disk usage as output.

# so let's start with creating an infinite loop, that can be interrupted anytime:
while true; do
clear # ill add clear so the output refreshes itself

echo "---SYSTEM MONITOR---" # main title
echo "Current time: $(date)" # show the current date...
echo # echo blank line

## CPU USAGE:
echo "CPU usage:" # cpu title
# run top in batch mode -> pipe that into grep -> pipe those occurences into awk that combines columns 1 and 3 (2 and 4 when counting the "Cpu(s)" column) and appends % symbol
top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4 "%"}'
echo # echo blank line

## RAM USAGE:
echo "RAM usage:" # ram title
free -h | grep "Mem" | awk '{print $1 " " $3 "/" $2}' # "free -> grep -> awk" pipeline
echo # echo blank line

## DISK USAGE:
echo "Disk usage:" # disk title
# ...
echo # echo blank line

done