#!/bin/sh

# Check if exactly one argument is provided
if [ $# -ne 1 ]; then
    echo "Error: Please provide exactly one file."
    exit 1
fi

# Check if the argument is a valid file
if [ ! -f "$1" ]; then
    echo "Error: Input must be a valid file."
    exit 1
fi

# Create a space-delimited version of the file
echo "Creating a space-delimited version of $1 ..."
cat "$1" | tr -s "," " " >> "$1.ssv"

echo "Done!"


