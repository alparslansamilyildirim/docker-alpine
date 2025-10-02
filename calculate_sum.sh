#!/bin/bash

# File path configuration
# Default input provided as `numbers.txt` in host directory
INPUT_FILE="/data/numbers.txt"
OUTPUT_DIR="/data"

# Output filename format: <date>_<time>-v<version>.txt
# date: YYYY-MM-DD, time: HH-MM-SS (safe format without colons),
# version: incremental number if file with same timestamp exists
DATE_STR=$(TZ=Europe/Istanbul date +%Y-%m-%d)
TIME_STR=$(TZ=Europe/Istanbul date +%H-%M-%S)
BASE_NAME="${DATE_STR}_${TIME_STR}"

mkdir -p "$OUTPUT_DIR"

version=1
OUTPUT_FILE="$OUTPUT_DIR/${BASE_NAME}-v${version}.txt"

# If input file doesn't exist, create empty output and exit
if [[ ! -e "$INPUT_FILE" ]]; then
    > "$OUTPUT_FILE"
    exit 0
fi

# Calculate line sums and store in array
sums=()
while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ -n "$line" ]]; then
        line_sum=0
        for number in $line; do
            if [[ "$number" =~ ^-?[0-9]+$ ]]; then
                ((line_sum += number))
            fi
        done
        sums+=("$line_sum")
    fi
done < "$INPUT_FILE"

# Check if input file ends with newline character
ends_with_newline=0
if [[ -s "$INPUT_FILE" ]]; then
    last_char=$(tail -c1 "$INPUT_FILE" 2>/dev/null || true)
    if [[ "$last_char" == $'\n' ]]; then
        ends_with_newline=1
    fi
fi

# Create result file and write array elements (with newline control for last line)
> "$OUTPUT_FILE"
total=${#sums[@]}
for idx in "${!sums[@]}"; do
    if [[ $idx -eq $((total-1)) && $ends_with_newline -eq 0 ]]; then
        printf '%s' "${sums[$idx]}" >> "$OUTPUT_FILE"
    else
        printf '%s\n' "${sums[$idx]}" >> "$OUTPUT_FILE"
    fi
done

exit 0