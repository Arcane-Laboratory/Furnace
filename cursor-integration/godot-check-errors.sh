#!/bin/bash
# Bash script to check Godot log file for errors and warnings
# Similar to godot-error-parser.ps1 but for Linux/macOS

LOG_FILE="${1:-$HOME/.local/share/godot/app_userdata/Furnace/logs/godot.log}"

if [ ! -f "$LOG_FILE" ]; then
    echo "Error: Log file not found: $LOG_FILE" >&2
    echo "Usage: $0 [log_file_path]" >&2
    exit 1
fi

echo "Checking Godot log file: $LOG_FILE"
echo "=================================="
echo ""

ERROR_COUNT=0
WARNING_COUNT=0

# Check for errors
echo "=== ERRORS ==="
while IFS= read -r line; do
    # Format: ERROR: message at file:line
    if [[ $line =~ ^ERROR:\ (.+)\ at\ (.+):([0-9]+) ]]; then
        ERROR_COUNT=$((ERROR_COUNT + 1))
        echo "ERROR #$ERROR_COUNT"
        echo "  Message: ${BASH_REMATCH[1]}"
        echo "  File: ${BASH_REMATCH[2]}"
        echo "  Line: ${BASH_REMATCH[3]}"
        echo ""
    # Format: file:line - ERROR: message
    elif [[ $line =~ ^([^:]+):([0-9]+)\ -\ ERROR:\ (.+) ]]; then
        ERROR_COUNT=$((ERROR_COUNT + 1))
        echo "ERROR #$ERROR_COUNT"
        echo "  File: ${BASH_REMATCH[1]}"
        echo "  Line: ${BASH_REMATCH[2]}"
        echo "  Message: ${BASH_REMATCH[3]}"
        echo ""
    # Format: Simple ERROR: message
    elif [[ $line =~ ^ERROR:\ (.+) ]]; then
        ERROR_COUNT=$((ERROR_COUNT + 1))
        echo "ERROR #$ERROR_COUNT"
        echo "  Message: ${BASH_REMATCH[1]}"
        echo ""
    fi
done < <(grep -E "^ERROR" "$LOG_FILE" | tail -50)

if [ $ERROR_COUNT -eq 0 ]; then
    echo "No errors found."
fi

echo ""
echo "=== WARNINGS (last 20) ==="
while IFS= read -r line; do
    # Format: WARNING: message at file:line
    if [[ $line =~ ^WARNING:\ (.+)\ at\ (.+):([0-9]+) ]]; then
        WARNING_COUNT=$((WARNING_COUNT + 1))
        echo "WARNING #$WARNING_COUNT"
        echo "  Message: ${BASH_REMATCH[1]}"
        echo "  File: ${BASH_REMATCH[2]}"
        echo "  Line: ${BASH_REMATCH[3]}"
        echo ""
    # Format: file:line - WARNING: message
    elif [[ $line =~ ^([^:]+):([0-9]+)\ -\ WARNING:\ (.+) ]]; then
        WARNING_COUNT=$((WARNING_COUNT + 1))
        echo "WARNING #$WARNING_COUNT"
        echo "  File: ${BASH_REMATCH[1]}"
        echo "  Line: ${BASH_REMATCH[2]}"
        echo "  Message: ${BASH_REMATCH[3]}"
        echo ""
    # Format: Simple WARNING: message
    elif [[ $line =~ ^WARNING:\ (.+) ]]; then
        WARNING_COUNT=$((WARNING_COUNT + 1))
        echo "WARNING #$WARNING_COUNT"
        echo "  Message: ${BASH_REMATCH[1]}"
        echo ""
    fi
done < <(grep -E "^WARNING" "$LOG_FILE" | tail -20)

if [ $WARNING_COUNT -eq 0 ]; then
    echo "No warnings found."
fi

echo ""
echo "=================================="
echo "Summary: $ERROR_COUNT error(s), $WARNING_COUNT warning(s)"

if [ $ERROR_COUNT -gt 0 ]; then
    exit 1
else
    exit 0
fi
