# Miniproject

### Brief description
Fits a series of models to bacterial growth curves.

### Languages
- Shell script
- R

### Dependencies and Installation
- `install.packages("dplyr")`
- `install.packages("minpack.lm")`
- `install.packages("AICcmodavg")`
- `install.packages("parallel")`
- `install.packages("ggplot2")`
- `install.packages("gridExtra")`
- `install.packages("grid")`

### Project structure and Usage
#### Code
- **DataWrang.R**: Loads and prepares bacterial growth data for analysis.

- **Miniproject.tex**: Source code for writeup. Will fail when run, as was compiled in overleaf environment. 

- **model_fitting.R**: Fits models to data.

- **visualisation.R**: Plots growth data against fitted models.

- **run_scripts.sh**: Runs the previous three scripts.
`bash run_scripts.sh`

- **Figure_2.R**: Source after run_scripts.sh to produce a composite figure comparing six time series and their fitted models.
`source Figure_2.R`

#### Data
- **LogisticGrowthData.csv**: Bacterial time series data from 10 studies.

- **LogisticGrowthMetaData.csv**: Metadata for the above.

- **cleaned_data_final.csv**: Cleaned time series data (output of DataWrang.R)

#### Results
To store files outputted from the code directory.

### Author name and contact
Harry Trevelyan  
hjt24@ic.ac.uk
