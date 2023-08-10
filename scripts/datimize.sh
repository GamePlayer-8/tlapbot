#!/bin/sh

# Specify the target date with dots
target_date="$1"

# Replace dots with dashes
target_date=$(echo "$target_date" | sed 's/\./-/g')

# Get the current date
current_date=$(date +%F)

# Calculate the number of seconds between the target and current dates
seconds_diff=$(($(date -d "$current_date" +%s) - $(date -d "$target_date" +%s)))

# Calculate the number of years that have passed
param_value=$((seconds_diff / (60 * 60 * 24 * 365)))

echo "$param_value"
