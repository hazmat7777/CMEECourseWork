#!/bin/bash
pdflatex $1.tex
bibtex $1
pdflatex $1.tex
pdflatex $1.tex
evince $1.pdf & #opens the evince pdf viewer

##cleanup
rm *.aux
rm *.log
rm *.bbl
rm *.blg
