# Week 7

### Brief Description
Statistics in R assessment: designing and running a linear model.  

### Languages
- R 4.3.3  

### Dependencies and Installation

- **tidyverse**
R installation:
`install.packages("tidyverse")`  
- **sjPlot**  
R installation:  
`install.packages("sjPlot")`  
  
### Project structure and Usage:

#### Code:  
Scripts, their descriptions, and how to run them in a terminal.

- **BudburstModel.R**: Reads tree phenological data and girth measurements. Carries out data wrangling and model selection. Arrives at a mixed linear model with the time of first budburst as a response variable and tree girth as an explanatory variable, with year and treeID as random effects.  
  `source("BudburstModel.R")`

#### Data
Input files for various scripts within the code directory.  

- **girth.csv**: Girths of trees at Silwood Park between 2007 and 2019.  

- **phenology.csv**: Extent of tree budburst in Silwood park between 105 and 2023.  

- **trees.csv**: Geographic coordinates of trees in silwood park.  

#### Results
To store files outputted from the code directory.  

### Author name and contact
Harry Trevelyan  
hjt24@ic.ac.uk
