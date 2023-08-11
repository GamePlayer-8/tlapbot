#!/bin/bash

if [ -z "$1" ]; then
    echo "Missing patches!"
    exit 1
fi

if [ -z "$2" ]; then
    echo "Missing the combine!"
    exit 2
fi

for X in $(find "$1" -name '*.patch' -type f); do
    rm -rf "$X"
done

for X in $(find "$1" -type f); do
    diff -u "$X" "$2"/"$(basename "$X")" > "$1"/"$(basename "$X")".patch
    patch "$2"/"$(basename "$X")" < "$1"/"$(basename "$X")".patch
    rm -f "$1"/"$(basename "$X")".patch
done