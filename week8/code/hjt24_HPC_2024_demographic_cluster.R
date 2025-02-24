# CMEE 2024 HPC exercises R code pro forma
# For stochastic demographic model cluster run

# housekeeping
rm(list=ls())

# load functions
source("Demographic.R")

# find the job number
iter <- as.numeric(Sys.getenv("PBS_ARRAY_INDEX")) # each task gets a unique number
    # I will set this as 1-100 when I run the cluster:
        # qsub -j 1-100

# give all runs a unique seed
set.seed(iter)

# intial conditions
large_pop_adults <- state_initialise_adult(4,100)
small_pop_adults <- state_initialise_adult(4,10)
large_pop_spread <- state_initialise_spread(4,100)
small_pop_spread <- state_initialise_spread(4,10)

# setting parameters for model
growth_matrix <- matrix(c(0.1, 0.0, 0.0, 0.0,
                        0.5, 0.4, 0.0, 0.0,
                        0.0, 0.4, 0.7, 0.0,
                        0.0, 0.0, 0.25, 0.4),
                        nrow=4, ncol=4, byrow=T)
reproduction_matrix <- matrix(c(0.0, 0.0, 0.0, 2.6,
                        0.0, 0.0, 0.0, 0.0,
                        0.0, 0.0, 0.0, 0.0,
                        0.0, 0.0, 0.0, 0.0),
                        nrow=4, ncol=4, byrow=T)
clutch_distribution <- c(0.06,0.08,0.13,0.15,0.16,0.18,0.15,0.06,0.03)

# making a list to contain results
results <- vector("list", 150) # preallocate a results list

# run the simulation 150 times
for(i in 1:150){
    if(iter <= 25){
        results[[i]] <- stochastic_simulation(large_pop_adults, growth_matrix,
        reproduction_matrix, clutch_distribution,
        simulation_length = 120)
    } else if(iter > 25 && iter <= 50){
        results[[i]] <- stochastic_simulation(small_pop_adults, growth_matrix,
        reproduction_matrix, clutch_distribution,
        simulation_length = 120)
    } else if(iter > 50 && iter <= 75){
        results[[i]] <- stochastic_simulation(large_pop_spread, growth_matrix,
        reproduction_matrix, clutch_distribution,
        simulation_length = 120)
    } else if(iter > 75 && iter <= 100){
        results[[i]] <- stochastic_simulation(small_pop_spread, growth_matrix,
        reproduction_matrix, clutch_distribution,
        simulation_length = 120)
    }
}

# save each output with a unique filename
save(results, file=paste0("../results/rda_files/output_",iter, ".rda"))


