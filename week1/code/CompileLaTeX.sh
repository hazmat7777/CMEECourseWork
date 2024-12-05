#!/bin/bash

# Check input
if [ $# -ne 1 ]; then
    echo "Error: Please provide exactly one .tex file without the extension."
    exit 1
fi

# Store the input file name (without extension)
basename="$1"
texfile="$basename.tex"

# Run pdflatex once to generate the .aux file
pdflatex "$texfile"
if [ $? -ne 0 ]; then
    echo "Error: pdflatex failed on the first run."
    exit 1
fi

# Check if the .aux file contains the string "bibliography"
if grep -qi "\\bibliography{" "$basename.aux"; then
    # Run bibtex
    bibtex "$basename"
    if [ $? -ne 0 ]; then
        echo "Error: bibtex failed."
        exit 1
    fi
fi

# Run pdflatex again to include the bibliography
pdflatex "$texfile"
if [ $? -ne 0 ]; then
    echo "Error: pdflatex failed on the second run."
    exit 1
fi

# Run pdflatex one more time to ensure references are updated
pdflatex "$texfile"
if [ $? -ne 0 ]; then
    echo "Error: pdflatex failed on the third run."
    exit 1
fi

# Open the resulting PDF with evince
evince "$basename.pdf" &

# Cleanup auxiliary files related to this document
rm -f "$basename.aux" "$basename.bbl" "$basename.blg" "$basename.log"

echo "Done!"
