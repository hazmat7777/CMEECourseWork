# CMEE 2024 HPC excercises R code HPC run code proforma

rm(list=ls()) # good practice 
source("abc123_HPC_2024_main.R")
# it should take a faction of a second to source your file
# if it takes longer you're using the main file to do actual simulations
# it should be used only for defining functions that will be useful for your cluster run and which will be marked automatically

# do what you like here to test your functions (this won't be marked)
# for example
species_richness(c(1,4,4,5,1,6,1))
# should return 4 when you've written the function correctly for question 1

# you may also like to use this file for playing around and debugging
# but please make sure it's all tidied up by the time it's made its way into the main.R file or other files.

######################################################

state_initialise_adult <- function(num_stages,initial_size){
  state_vector <- c(rep(0, times = num_stages-1),initial_size)
  return(state_vector)
}
state_initialise_adult(5,10)

state_initialise_spread <- function(num_stages,initial_size){
    state_vector <- c(rep(floor(initial_size/num_stages),
        times = num_stages))
    remainder <- initial_size - sum(state_vector)
    if(remainder > 0) {
        state_vector[1:remainder] <- state_vector[1:remainder] + 1
    }
    return(state_vector)
}

state_initialise_spread(4,102)

# Question 1
source("Demographic.R")
question_1 <- function(){
    # setting parameters for simulation
    initial_state_1 <- state_initialise_adult(4,100)
    initial_state_2 <- state_initialise_spread(4,100)
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
    projection_matrix = reproduction_matrix + growth_matrix
        # the proportion of each age class which advance

    # running simulations
    d_sim_1 <- deterministic_simulation(initial_state_1, 
        projection_matrix, simulation_length = 24)
    d_sim_2 <- deterministic_simulation(initial_state_2, 
        projection_matrix, simulation_length = 24)
    
    # plotting graph
    png(filename="question_1", width = 600, height = 400)
    plot(d_sim_1, type = "l", col = "red", ylab = "population size",
        xlab = "time step", ylim = c(0,500))
    lines(d_sim_2, col = "blue")
    legend("topleft", legend = c("Starting population all adults",
        "Starting population with spread of ages"),
        col = c("red", "blue"), lty = 1, lwd = 2)
    Sys.sleep(0.1)
    dev.off()
    return("The initial growth rate is much higher in the population which begins with all adults (pop A) than the population which begins with a spread of ages (pop B). This is because pop A begins with a greater proportion of individuals that have reached reproductive maturity. At time step 2, pop A begins a drop in population size. This is because at this stage most individuals are in the first age class (having just been born) and 40% of these will not survive to the next time step. The growth rate increases again at time step 5 when the 'baby boomers' reach reproductive age. The fluctuation is less pronounced in pop B, as its initial bias towards adults is less strong. In both populations, the fluctuations dampen as the populations reach a stable age structure.")
}


# Question 21
sum_vect <- function(x, y) {
    if(length(x) > length (y)){ # making x the shorter vector
        tmp <- x
        x <- y
        y <- tmp
    }
    difference <- length(y) - length(x)
    if(difference>0){
        x <- append(x, rep(0, times = difference))
    }
    result <- x + y
    return(result)
}

sum_vect(c(1,0,1,1,2,3), c(1,2,3,4))

source("Demographic.R")
# question 2
question_2 <- function(){
    # setting parameters for simulation
    initial_state_1 <- state_initialise_adult(4,100)
    initial_state_2 <- state_initialise_spread(4,100)

    clutch_distribution <- c(0.06,0.08,0.13,0.15,0.16,0.18,0.15,0.06,0.03)

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

    # running simulations
    s_sim_1 <- stochastic_simulation(initial_state_1, 
        growth_matrix, reproduction_matrix, clutch_distribution, simulation_length = 24)
    s_sim_2 <- stochastic_simulation(initial_state_2, 
        growth_matrix, reproduction_matrix, clutch_distribution, simulation_length = 24)
    
    # plotting graph
    png(filename="question_2", width = 600, height = 400)
    plot(s_sim_1, type = "l", col = "red", ylab = "population size",
        xlab = "time step", ylim = c(0,500))
    lines(s_sim_2, col = "blue")
    legend("topleft", legend = c("Starting population all adults",
        "Starting population with spread of ages"),
        col = c("red", "blue"), lty = 1, lwd = 2, bty = "n")
    dev.off()
    Sys.sleep(0.1)
    
    return("The populations in the stochastic simulations (question 2) undergo more fluctuations than those in the deterministic simulations (question 1) because the former simulations incorporate random processes. Variability is introduced into the number of individuals transitioning between stages, the clutch size, and the number of adults reproducing.")
}
question_2()

stochastic_simulation <- function(initial_state,growth_matrix,reproduction_matrix,clutch_distribution,simulation_length){
  population_size <- numeric(simulation_length + 1) # population of length sim + 1
  population_size[1] = sum(initial_state) # first value sum of initial state
  recruitment_probability = stochastic_recruitment(reproduction_matrix, clutch_distribution) # recruitment probability
  
  for(i in 1:simulation_length){
    new_state = stochastic_step(initial_state, growth_matrix, reproduction_matrix, clutch_distribution, recruitment_probability) # one step of stochastic model
    population_size[i + 1] = sum(new_state) # update population time series
    if (sum(new_state) == 0){break} # stop if the population is zero
    initial_state = new_state # update for next iter
  }
  
  if (length(population_size) < simulation_length + 1){ # fill remaining entries with 0
    population_size[(length(population_size) + 1):(simulation_length + 1)]
  }
  
  return(population_size)
}

stochastic_step <- function(state,growth_matrix,reproduction_matrix,clutch_distribution,recruitment_probability){
  new_state = survival_maturation(state, growth_matrix) # survival and maturation
  total_offspring = offspring_calc(state, clutch_distribution, recruitment_probability) # number of offspring produced
  new_state[1] = new_state[1] + total_offspring # add to new state
  return(new_state)
}

survival_maturation <- function(state,growth_matrix){
  new_state <- rep(0, length(state)) # 1. new population state
  for (i in 1:length(state)){
    current_individuals <- state[i] # 2.1 individuals in life stage i
    transition_probs <- growth_matrix[,i] # 2.2 initialise probabilities from matrix
    individuals_count <- multinomial(current_individuals, transition_probs) # 2.2 individuals that remain in stage i
    new_state <- sum_vect(new_state, individuals_count)
  }
  return(new_state) # 3. return new_state
}

multinomial <- function(pool, probs) {
  if (sum(probs) > 1) { # check probability
    print("Sum of probabilities is greater than 1")
  }
  death = 1 - sum(probs) # death prob
  probd = c(probs, death) # merge them
  x = as.vector(rmultinom(n=11, pool, probd)) # sample
  return(x[1:length(probs)])
}

# Question 5
question_5 <- function(){
  
  # define a function which returns TRUE if a pop went extinct
  isextinct <- function(x) {
    x[121] == 0 # checks if the pop size at last time step is 0
  }

  # countextinctions from file list
  countextinctionsfromfile<- function(filelist){
    extinctioncount <- 0
    for(i in filelist) {
      load(paste0("../results/output_", i, ".rda"))
      extinctioncount <- extinctioncount + sum(sapply(results, isextinct))
      }
    return(extinctioncount)
  }

  # iterate through files counting extinctions
  large_adult_extinctions <- countextinctionsfromfile(1:25)
  small_adult_extinctions <- countextinctionsfromfile(26:50)
  large_spread_extinctions <- countextinctionsfromfile(51:75)
  small_spread_extinctions <- countextinctionsfromfile(76:100)

  # convert extinction count to proportion of extinctions
  l_a_extinct_prob <- large_adult_extinctions/ (15000/4)
  s_a_extinct_prob <- small_adult_extinctions/ (15000/4)
  l_s_extinct_prob <- large_spread_extinctions/ (15000/4)
  s_s_extinct_prob <- small_spread_extinctions/ (15000/4)

  # collate results
  data <- c(l_a_extinct_prob, s_a_extinct_prob, l_s_extinct_prob, s_s_extinct_prob)
  
  # plot a graph of results
  png(filename="question_5", width = 600, height = 400)
  barplot(data,
        names.arg = c("\nLarge adult\npopulation",
                      "\nSmall adult\n population", 
                      "\nLarge mixed-age\n population",
                      "\nSmall mixed-age\n population"),
        col = "blue",
        main = "Impact of Population Structure on Extinction Probability",
        ylab = "Proportion of simulations which ended in extinction",
        ylim = c(0,0.2)) 
  Sys.sleep(0.1)
  dev.off()
  
  return("type your written answer here")
}
question_5()

list.files("../results", pattern = "^output_.*", full.names = TRUE)