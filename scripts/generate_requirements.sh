#!/bin/sh

SCRIPT_PATH="$(dirname "$(realpath "$0")")"

if [ -z "$1" ]; then
    echo "Missing setup.py file!"
    exit 1
fi

if [ -z "$2" ]; then
    echo "Missing output file!"
    exit 2
fi

# Extract the list of dependencies using awk
list=$(awk -F"'" '/install_requires=/,/\]/ {if ($0~/^[ \t]*'\''.*'\'',?$/) print $2}' "$1")

# Loop through each element and write to requirements.txt
echo "$list" | while IFS= read -r element; do
    echo "$element" >> "$2"
done
