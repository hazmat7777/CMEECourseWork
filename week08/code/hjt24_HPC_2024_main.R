# CMEE 2024 HPC exercises R code main pro forma
# You don't HAVE to use this but it will be very helpful.
# If you opt to write everything yourself from scratch please ensure you use
# EXACTLY the same function and parameter names and beware that you may lose
# marks if it doesn't work properly because of not using the pro-forma.

name <- "Harry Trevelyan"
preferred_name <- "Harry"
email <- "hjt24@imperial.ac.uk"
username <- "hjt24"

# Please remember *not* to clear the work space here, or anywhere in this file.
# If you do, it'll wipe out your username information that you entered just
# above, and when you use this file as a 'toolbox' as intended it'll also wipe
# away everything you're doing outside of the toolbox.  For example, it would
# wipe away any automarking code that may be running and that would be annoying!

# Section One: Stochastic demographic population model

source("Demographic.R")

# Question 0

state_initialise_adult <- function(num_stages,initial_size){
  state_vector <- c(rep(0, times = num_stages-1), initial_size)
  return(state_vector)
}

state_initialise_spread <- function(num_stages,initial_size){
    state_vector <- c(rep(floor(initial_size/num_stages),
        times = num_stages))
    remainder <- initial_size - sum(state_vector) # if initial_size not divisible by num_stages
    if(remainder > 0) {
        state_vector[1:remainder] <- state_vector[1:remainder] + 1
    }
    return(state_vector)
}

# Question 1
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
    png(filename="../results/question_1", width = 600, height = 400)
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

# Question 2
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
    png(filename="../results/question_2", width = 600, height = 400)
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

# Questions 3 and 4 involve writing code elsewhere to run your simulations on the cluster

# Question 5
question_5 <- function(){ # bar graph of proportion of extinctions
  
  # define a function which returns TRUE if a pop went extinct
  isextinct <- function(x) {
    x[121] == 0 # checks if the pop size at last time step is 0
  }

  # countextinctions from file list
  countextinctionsfromfile<- function(filelist){
    extinctioncount <- 0
    for(i in filelist) {
      load(paste0("../results/demographic_output/output_", i, ".rda"))
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
  png(filename="../results/question_5", width = 600, height = 400)
  barplot(data,
        names.arg = c("\nLarge adult\npopulation",
                      "\nSmall adult\n population", 
                      "\nLarge mixed-age\n population",
                      "\nSmall mixed-age\n population"),
        col = "blue",
        main = "Impact of Population Size and Structure on Extinction Probability",
        ylab = "Proportion of simulations which ended in extinction",
        ylim = c(0,0.2)) 
  Sys.sleep(0.1)
  dev.off()
  
  return("The graph shows the small, mixed-age population was most likely to go extinct. In a small population, random variation in birth rates, death rates and clutch sizes have a proportionally larger effect and thus populations are more likely to crash by chance. All-adult populations are less likely to go extinct because they have a higher intitial growth rate than mixed populations.")
}

# Question 6
question_6 <- function(){ # graph deviation of stochastic vs deterministic model 
  
  # Stochastic sim: find population trend = mean at each timestep
  poptrendfromfilelist <- function(filelist) {
    file_paths <- paste0("../results/demographic_output/output_", filelist, ".rda")
    
    # Initialize sum and count vectors
    total_sum <- numeric(121)  # 121 zeroes
    total_count <- 0 

    for (file in file_paths) {
      load(file)  # Load the .rda file containing 'results'

      # Convert results (list of 150 vectors) into a matrix (150 rows x 121 columns)
      results_matrix <- do.call(rbind, results)

      # Sum the values across all simulations
      file_sum <- colSums(results_matrix)

      # Initialize total_sum if first file, otherwise accumulate sum
      total_sum <- total_sum + file_sum

      # Increase count by the number of simulations in this file
      total_count <- total_count + 150 # 150 sims per file
    }

    # Compute mean across all simulations from all files
    pop_trend <- total_sum / total_count

    return(pop_trend)  # A vector of length 121
  }

  # Deterministic sim: initialise parameters
  simulation_length <- 120
  small_pop_spread <- state_initialise_spread(4,10)
  large_pop_spread <- state_initialise_spread(4,100)
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

  # run stochastic and deterministic sims
  stoc_large_pop_trend <- unlist(poptrendfromfilelist(51:75)) # unlist to convert to numeric vector (for division)
  stoc_small_pop_trend <- unlist(poptrendfromfilelist(76:100))
  det_large_pop_trend <- unlist(deterministic_simulation(large_pop_spread,projection_matrix,simulation_length))
  det_small_pop_trend <- unlist(deterministic_simulation(small_pop_spread,projection_matrix,simulation_length))

  # compute deviation of stoch/det models
  large_pop_deviation <- stoc_large_pop_trend / det_large_pop_trend
  small_pop_deviation <- stoc_small_pop_trend / det_small_pop_trend
  
  # plot graph 
  png(filename="../results/question_6", width = 600, height = 400)
  plot(small_pop_deviation, type = "l", col = "blue", 
    main = "Deviation of Stochastic Models from Deterministic Models", 
    ylab = "Deviation from Deterministic model",
    xlab = "Generation",
    ylim = c(0.995, 1.025))
  lines(large_pop_deviation, type = "l", col = "red")
  legend("bottomright", legend = c("Large population",
        "Small population"),
        col = c("red", "blue"), lty = 1, lwd = 2, bty = "n")

  Sys.sleep(0.1)
  dev.off()
  
  return("A deterministic model is more appropriate for approximating the average behavior of a stochastic model when simulating large populations rather than small populations. This is because large populations exhibit lower deviations from the deterministic model, as shown in the graph. In large populations, the average value of each life history trait more closely approximates the true mean (captured by the deterministic model) than in small populations, since averages are drawn from a larger sample size, which reduces the effect of random fluctuations.")
}


# Section Two: Individual-based ecological neutral theory simulation 

# Question 7
species_richness <- function(community){
  return(length(unique(community)))
}

# Question 8
init_community_max <- function(size){
  return(seq(1, size))
}

# Question 9
init_community_min <- function(size){
  return(rep(1, size))
}

# Question 10
choose_two <- function(max_value){
  return(sample.int(max_value, 2, replace = FALSE))
}

# Question 11
neutral_step <- function(community){
  change_indices <- choose_two(length(community)) # indices of community
  community[change_indices[1]] <- community[change_indices[2]]
  return(community)
}

# Question 12
neutral_generation <- function(community){

  # record community size
  size <- length(community)

  # make odd sizes even (adjust up or down)
  if(size %% 2 == 1){
    size <- size + sample(c(-1,1),1)
  }

  # find generation length
  generation_length <- size/2

  # simulate neutral steps for one generation
  for(i in seq_len(generation_length)){
    community <- neutral_step(community)
  }
  return(community)
}

# Question 13
neutral_time_series <- function(community,duration)  {
  
  # keep track of species richness
  richness <- numeric(duration+1) # initialise 
  richness[1] <- species_richness(community) # starting richness

  # simulate neutral generations
  for(i in 1:duration){
    community <- neutral_generation(community)
    richness[i+1] <- species_richness(community)
  }

  return(richness)
}

# Question 14
question_14 <- function() {
  
  # run simulation
  neutral_sim <- neutral_time_series(community = init_community_max(100), duration = 200)
    
  # graph
  png(filename="../results/question_14", width = 600, height = 400)
  plot(neutral_sim, type = "l",
       main = "Species Richness Over Time in a Neutral Model",
       xlab = "Generation",
       ylab = "Richness")

  Sys.sleep(0.1)
  dev.off()
  
  return("The system will always converge to a state of no diversity (species richness = 1) because, in a neutral model without immigration or speciation, species can only be stochastically lost and never gained.")
}

# Question 15
neutral_step_speciation <- function(community,speciation_rate)  {
  
  # choose species indices to change
  change_indices <- choose_two(length(community)) # indices of community

  # return 1 if speciation occurs
  speciate <- rbinom(n = 1, size = 1, p = speciation_rate)

  # in the case of speciation
  if(speciate == 1){
    community[change_indices[1]] <- max(community)+1 # assign a new species
  }
  
  # otherwise, do a neutral step
  else{
    community[change_indices[1]] <- community[change_indices[2]]
  }
  return(community)
}


# Question 16
neutral_generation_speciation <- function(community,speciation_rate)  {
  
  # record community size
  size <- length(community)

  # make odd sizes even (adjust up or down)
  if(size %% 2 == 1){
    size <- size + sample(c(-1,1),1)
  }

  # find generation length
  generation_length <- size/2

  # simulate neutral speciation steps for one generation
  for(i in seq_len(generation_length)){
    community <- neutral_step_speciation(community, speciation_rate)
  }

  return(community)
}

# Question 17
neutral_time_series_speciation <- function(community,speciation_rate,duration)  {
  
  # keep track of species richness
  richness <- numeric(duration+1) # initialise richness vector
  richness[1] <- species_richness(community) # starting richness

  # simulate neutral generations with speciation
  for(i in 1:duration){
    community <- neutral_generation_speciation(community, speciation_rate)
    richness[i+1] <- species_richness(community)
  }

  return(richness)
}


# Question 18
question_18 <- function()  {

  # run simulations
  neutral_speciation_sim_max <- neutral_time_series_speciation(community = init_community_max(100),speciation_rate = 0.1, duration = 200)
  neutral_speciation_sim_min <- neutral_time_series_speciation(community = init_community_min(100),speciation_rate = 0.1, duration = 200)

  # graph
  png(filename="../results/question_18", width = 600, height = 400)
  plot(neutral_speciation_sim_max, type = "l", col = "red",
      main = "Species Richness Over Time in a Neutral Model with Speciation",
      xlab = "Generation",
      ylab = "Richness",
      ylim = c(0,100))
  lines(neutral_speciation_sim_min, type = "l", col = "blue")
  legend("topright", legend = c("Diverse initial community",
      "Homogenous initial community"),
      col = c("red", "blue"), lty = 1, lwd = 2, bty = "n")

  Sys.sleep(0.1)
  dev.off()
  
  return("The initial conditions do not impact the long-term trend in species richness. In the initially diverse community, species richness dropped because the rate of extinction far exceeded the rate of speciation. The initially homogenous community had the opposite pattern, as speciation exceeded extinction. Therefore, the richness in each community reached and fluctuated about an equilibrium value, which was determined by the speciation rate. In our simulations with a speciation rate of 0.1, the equilibrium richness was ~20.")
}


# Question 19
species_abundance <- function(community)  {
  abundances <- table(community) # table of adundances
  return(as.vector(sort(abundances, decreasing = T)))
}



# Question 20
octaves <- function(abundance_vector) {
  if (length(abundance_vector) == 0) {
    return(numeric(0))  # Return an empty vector if no data
  }
  
  # Compute octave index for each abundance
  octave_indices <- floor(log2(abundance_vector)) + 1 # the octave bin which each abundance which would fall into
  
  # Tabulate counts per octave bin
  octave_counts <- tabulate(octave_indices)
  
  return(octave_counts)
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


# Question 22
question_22 <- function() {

  # run 200 generations to 'burn in'
  community_max <- Reduce(function(comm, .) neutral_generation_speciation(comm, speciation_rate = 0.1),
                        x = seq_len(200),
                        init = init_community_max(100))
  community_min <- Reduce(function(comm, .) neutral_generation_speciation(comm, speciation_rate = 0.1),
                        x = seq_len(200),
                        init = init_community_min(100))

  # keep track of octaves
  max_octaves_sum <- octaves(species_abundance(community_max))
  min_octaves_sum <- octaves(species_abundance(community_min))

  # run simulation, calculating and summing the octaves every 20 generations
  for(i in 1:2000){
    community_max <- neutral_generation_speciation(community_max, speciation_rate = 0.1)
    community_min <- neutral_generation_speciation(community_min, speciation_rate = 0.1)
    
    if(i %% 20 == 0){
      max_octaves_sum <- sum_vect(max_octaves_sum, octaves(species_abundance(community_max)))
      min_octaves_sum <- sum_vect(min_octaves_sum, octaves(species_abundance(community_min)))

    }
  }

  max_octaves_mean <- max_octaves_sum/100
  min_octaves_mean <- min_octaves_sum/100

  # graph
  png(filename="../results/question_22", width = 600, height = 400)
  
  par(mfrow = c(1,2), oma = c(0, 0, 3, 0))  # Increase top margin for mtext()
  
  # Bar plot for Max Initial Richness
  barplot(max_octaves_mean, col = "blue", names.arg = c(1,2,3,4,5,6), 
          main = "High Initial Richness",
          xlab = "Octave Class", ylab = "Number of Species",
          ylim = c(0,12))

  # Bar plot for Min Initial Richness
  barplot(min_octaves_mean, col = "red", names.arg = c(1,2,3,4,5,6),
          main = "Low Initial Richness", 
          xlab = "Octave Class", ylab = "Number of Species",
          ylim = c(0,12))

  mtext("Mean Species Abundance Distribution", outer = TRUE)

  Sys.sleep(0.1)
  dev.off()
  
return("The plots indicate that in our simulations, initial species richness does not influence the emergent species abundance distribution. After the 200-generation burn-in period, the system stabilizes. This stable state is characterized by many species with low abundance, likely due to high speciation.")
}


# Question 23
neutral_cluster_run <- function(speciation_rate, size, wall_time, interval_rich, interval_oct, burn_in_generations, output_file_name) {
    
  # Initialisation
  community <- init_community_min(size)
  time_series <- numeric(burn_in_generations / interval_rich)  # Preallocate for species richness tracking
  abundance_list <- vector("list")  # List to store octaves
  i <- 1  # Burn-in counter
  j <- 1  # Octave tracking counter

  # Start the timer
  start_time <- proc.time()[3]  

  # Run sim until wall_time is reached
  while ((proc.time()[3] - start_time) < (wall_time * 60)) {  

    # Perform burn-in first
    if (i <= burn_in_generations) {
      if (i %% interval_rich == 0) {
        time_series[i / interval_rich] <- species_richness(community)
      }
      community <- neutral_generation_speciation(community, speciation_rate)
      i <- i + 1  # Increment burn-in counter
    } else {
      # Run normal sim      
      if (j %% interval_oct == 0) {
        abundance_list[[j / interval_oct]] <- octaves(species_abundance(community))
      }
      community <- neutral_generation_speciation(community, speciation_rate)
      j <- j + 1  # Increment
      
    }
  }

  # Record total time taken
  total_time <- proc.time()[3] - start_time

  # Save Output to File
  save(time_series, abundance_list, community, total_time, 
       speciation_rate, size, wall_time, interval_rich, interval_oct, burn_in_generations, 
       file = output_file_name)

  return("Simulation Complete")  # Return a confirmation message
}


# Questions 24 and 25 involve writing code elsewhere to run your simulations on
# the cluster

# Question 26 
process_neutral_cluster_results <- function() {
  
  
  combined_results <- list() #create your list output here to return
  # save results to an .rda file
  
}

plot_neutral_cluster_results <- function(){

    # load combined_results from your rda file
  
    png(filename="plot_neutral_cluster_results", width = 600, height = 400)
    # plot your graph here
    Sys.sleep(0.1)
    dev.off()
    
    return(combined_results)
}


# Challenge questions - these are substantially harder and worth fewer marks.
# I suggest you only attempt these if you've done all the main questions. 

# Challenge question A
Challenge_A <- function(){
  
  png(filename="Challenge_A", width = 600, height = 400)
  # plot your graph here
  Sys.sleep(0.1)
  dev.off()
  
}

# Challenge question B
Challenge_B <- function() {
  
  png(filename="Challenge_B", width = 600, height = 400)
  # plot your graph here
  Sys.sleep(0.1)
  dev.off()
  
}

# Challenge question C
Challenge_B <- function() {
  
  png(filename="Challenge_C", width = 600, height = 400)
  # plot your graph here
  Sys.sleep(0.1)
  dev.off()

}

# Challenge question D
Challenge_D <- function() {
  
  png(filename="Challenge_D", width = 600, height = 400)
  # plot your graph here
  Sys.sleep(0.1)
  dev.off()
}

# Challenge question E
Challenge_E <- function() {
  
  png(filename="Challenge_E", width = 600, height = 400)
  # plot your graph here
  Sys.sleep(0.1)
  dev.off()
  
  return("type your written answer here")
}

