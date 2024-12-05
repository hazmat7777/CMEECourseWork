# My CMEE Coursework Repository

### Brief Description
Three practicals from the CMEE Computational Bootcamp module.  

### Languages
- R 4.3.3  
- Python 3.12.3  

### Dependencies
- **LaTeX**  
UNIX-based terminal installation:  
`sudo apt install texlive`  
- **tidyverse** (R)  
R installation:  
`install.packages("tidyverse")`  

### Project structure and Usage:

#### Code: 
- **Florida.R**: Calculates the correlation between temperature and year in Florida, including an estimated p-value.  
`source("Florida.R")`

- **Florida.tex**: A LaTeX script which compiles *Florida.pdf* when run in bash as below:  
`pdflatex Florida && rm *.aux *.out *.log`

- **Florida.pdf**: Summarises the results found in *Florida.R*.  

- **PP_regress.R**: Plots marine predator mass in response to prey mass, grouped by predator lifestage and the type of feeding interaction. Produces a summary table.  
`source PP_regress.R`

- **TreeHeight.R**: Script that calculates tree height from information in a table.  
`source TreeHeight.R`

#### Data
Input files for various scripts within the code directory.  

-**KeyWestAnnualMeanTemperature.Rdata**: Florida warming data from 1901-2000.  

- **EcolArchives-E089-51-D1.csv**: Marine predator-prey interactions.  

- **Trees.csv**: species, distance and height information for some trees.  

#### Results
To store files outputted from the code directory.  

### Author name and contact
Harry Trevelyan  
hjt24@ic.ac.uk