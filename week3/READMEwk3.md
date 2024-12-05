# Week 3

### Brief Description
R scripts demonstrating key functionalities.

### Languages
- R 4.3.3
- Python 3.12.3

### Dependencies and Installation
- **Jupyter**
Python installation:
`pip install jupyter`
- **tidyverse**
R installation:
`install.packages("tidyverse")`
  
### Project structure and Usage:

#### Code:  
Scripts, their descriptions, and how to run them in a terminal.
  
- **apply1.R**: Calculates statistics on a random matrix.  
  `source("apply1.R")`
  
- **apply2.R**: Defines a function and applies it to a matrix.  
  `source("apply2.R")`
  
- **basic_io.R**: Reads and writes CSV files.  
  `source("basic_io.R")`
  
- **boilerplate.R**: Function combining two arguments and returning a vector.  
  `source("boilerplate.R")`
  
- **break.R**: Demonstrates breaking out of a `WHILE` loop.  
  `source("break.R")`
  
- **browse.R**: For debugging purposes.  
  `source("browse.R")`
  
- **control_flow.R**: Shows control structures, including conditionals, `for` and `while` loops.  
  `source("control_flow.R")`
  
- **DataWrang.R**: Wrangles the PoundHill dataset.  
  `source("DataWrang.R")`
  
- **Girko.R**: Visualizes eigenvalues of a random matrix, illustrating Girko's Circular Law.  
  `source("Girko.R")`
  
- **MyBars.R**: Creates a bar chart from `Results.txt` and saves it as a PDF.  
  `source("MyBars.R")`
  
- **MyFirstJupyterNB.ipynb**: Jupyter Notebook showing simple functionalities.  
  `jupyter notebook MyFirstJupyterNB.ipynb`
  
- **next.R**: `For` loop illustrating the use of `next`.  
  `source("next.R")`
  
- **plotLin.R**: Creates a linear regression plot and saves as PDF.  
  `source("plotLin.R")`
  
- **PoundHill.R**: Loads a CSV as a dataframe and converts it to a matrix.  
  `source("PoundHill.R")`
  
- **preallocate.R**: Compares functions with and without vector preallocation.  
  `source("preallocate.R")`
  
- **R_conditionals.R**: Contains three functions using conditionals to check number properties.  
  `source("R_conditionals.R")`
  
- **sample.R**: Computes the mean of random samples, comparing looped and vectorized sampling.  
  `source("sample.R")`
  
- **TestR.py**: Runs an R script (`TestR.R`) using `subprocess`, redirects output and errors.  
  `python3 TestR.py`
  
- **TestR.R**: Prints "Hello, this is R!"  
  `source("TestR.R")`
  
- **try.R**: Simulates sampling from a population, calculating the mean if 30 or more unique samples are obtained.  
  `source("try.R")`
  
- **Vectorize1.R**: Demonstrates the higher computational speed of using vectorization versus nested loops with big data.  
  `source("Vectorize1.R")`

#### Data
Input files for various scripts within the code directory.

- **EcolArchives-E089-51-D1.csv**: Marine predator-prey interactions.

- **PoundhillData.csv**: Species counts under different cultivation treatments- see *PoundHillMetaData.csv*.

- **PoundHillMetaData.csv**: metadata for the above.

- **Trees.csv**: species, distance and height information for some trees.

#### Results
To store files outputted from the code directory.

### Author name and contact
Harry Trevelyan
hjt24@ic.ac.uk
