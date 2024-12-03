#!/bin/bash

# Run pdflatex once to check for bibliography
pdflatex $1.tex

# Check if the .aux file contains the string "bibliography"
if grep -qi "\\bibliography{" "$1.aux"; then
    # If the bibliography is present, run bibtex
    bibtex $1
    # Run pdflatex again to include the bibliography
    pdflatex $1.tex
    pdflatex $1.tex
else
    # If no bibliography, just run pdflatex twice
    pdflatex $1.tex
    pdflatex $1.tex
fi

# Open the resulting PDF with evince
evince $1.pdf &

# Cleanup auxiliary files
rm *.aux
rm *.log
rm *.bbl
rm *.blg
