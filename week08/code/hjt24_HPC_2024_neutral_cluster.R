# CMEE 2024 HPC exercises R code pro forma
# For neutral model cluster run

rm(list=ls()) # good practice
graphics.off() # Turn off graphics devices
source("hjt24_HPC_2024_main.R")  # Load necessary functions

# Read job number from cluster
iter <- as.numeric(Sys.getenv("PBS_ARRAY_INDEX"))

# For local testing (comment out before running on cluster)
#iter <- 1  

# Ensure each parallel job has a unique random seed
set.seed(iter)

# Determine community size based on iter
if(iter <= 25){
    size <- 500
} else if(iter > 25 && iter <= 50){
    size <- 1000
} else if(iter > 50 && iter <= 75){
    size <- 2500
} else if(iter > 75 && iter <= 100){
    size <- 5000
}

# Generate output filename
output_file_name <- paste0("result_", iter, ".rda")

# Run the simulation
neutral_cluster_run(speciation_rate = 0.002595, size = size, wall_time = 690, 
                    interval_rich = 1, interval_oct = size/10, burn_in_generations = 8*size, 
                    output_file_name = output_file_name)

