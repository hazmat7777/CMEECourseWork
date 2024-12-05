# Week 8

### Brief Description
High Performance Computing exercises.

### Languages
- R 4.3.3

### Dependencies and Installation

- **tidyverse**  
  R installation:  
  `install.packages("tidyverse")`
  
### Project structure and Usage:

#### Code:  
Scripts, their descriptions, and how to run them in a terminal.

- **Demographic.R**: contains functions to initialise populations and run deterministic/stochastic simulations on them.

- **hjt24_HPC_2024_demographic_cluster.R**: runs a stochastic demographic model for different initial population conditions across 100 parallel cluster tasks.  
  Submit the job to the cluster using the provided shell script:  
  `qsub -J 1-100 run_script.sh`

- **hjt24_HPC_2024_main.R**: Runs a stochastic demographic model and neutral theory simulation.

- **hjt24_HPC_2024_neutral_cluster.R**: Not yet started!

- **hjt24_HPC_2024_test.R**: Sandbox file for testing functions.

- **run_script.sh**: shell script to run *hjt24_HPC_2024_demographic_cluster.R*

#### Results
To store files outputted from the code directory.

### Author name and contact
Harry Trevelyan  
hjt24@ic.ac.uk
