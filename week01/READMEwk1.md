# Week 1

### Brief description
Demonstrates usage of basic UNIX command-line and shell scripts.

### Languages
- Shell script

### Dependencies and Installation
- ImageMagick  
  `sudo apt-get install imagemagick`

- TeX Live  
  `sudo apt-get install texlive`

- Evince  
  `sudo apt-get install evince`

### Project structure and Usage
#### Code
- **boilerplate.sh**: Simple boilerplate for shell scripts.  
  `bash boilerplate.sh`

- **CompileLaTeX.sh**: Compiles .tex files in PDF format, including a bibliography when appropriate.  
  `bash CompileLaTeX.sh`

- **ConcatenateTwoFiles.sh**: Concatenates two files, checking input type.  
  `bash ConcatenateTwoFiles.sh`

- **CountLines.sh**: Counts the lines in one file.  
  `bash CountLines.sh`

- **csvtospace.sh**: Converts one csv file to ssv format.  
  `bash csvtospace.sh`

- **FirstBiblio.bib**: BibTeX citation for Verhulst 1838.

- **FirstExample.pdf**: PDF output of FirstExample.tex.

- **FirstExample.tex**: Simple LaTeX file demonstrating mathematical formulae and citations.  
To compile to a PDF:  
  `bash CompileLaTeX.sh`  

- **MyExampleScript.sh**: Basic shell script demonstrating variable assignment and the $USER special variable.  
  `bash MyExampleScript.sh`

- **tabtocsv.sh**: Converts one tsv file to csv format.  
  `bash tabtocsv.sh`

- **tiff2png.sh**: Converts all .tif files in the current working directory into png format.  
  `bash tiff2png.sh`

- **UnixPrac1.txt**: UNIX command-line tools for counting lines, sequence lengths, nucleotide occurrences, and A/T to G/C ratio in FASTA files.

- **variables.sh**: Illustrates variable assignment, special variables, and arithmetic expansion.  
  `bash variables.sh`

#### Data
- **fasta/**: DNA sequence data in fasta format.

- **Temperatures/**: Temperature data in CSV format.

- **spawannxs.txt**: List of species of marine and coastal flora.

#### Results
To store files outputted from the code directory.

### Author name and contact
Harry Trevelyan  
hjt24@ic.ac.uk
