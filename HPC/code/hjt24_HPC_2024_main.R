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

  # fn to calculate the mean octave of one run
  mean_octave_from_file <- function(filenumber){ # enter file number 1-100
      octaves_sum <- 0
      load(paste0("../results/neutral_output/result_", filenumber, ".rda")) # file loaded
      for(i in 1:length(abundance_list)) {
        octaves_sum <- sum_vect(abundance_list[[i]], octaves_sum)
      }
      octave_mean <- octaves_sum / length(abundance_list)
      return(octave_mean) 
  }
  
  # fn to calculate the mean octave from each community size
  mean_octave_from_filelist <- function(filelist){ # enter vector of file numbers to average
      octaves_sum <- 0
      for(i in filelist) {
        current_octave <- mean_octave_from_file(i)
        octaves_sum <- sum_vect(current_octave, octaves_sum) # sum the means
      }
      octave_mean <- octaves_sum / length(filelist) # mean of means
      return(octave_mean)
  }
  
  # Compute mean octaves for each initial community size group
  combined_results <- list(
        "size_500"  = mean_octave_from_filelist(1:25),
        "size_1000" = mean_octave_from_filelist(26:50),
        "size_2500" = mean_octave_from_filelist(51:75),
        "size_5000" = mean_octave_from_filelist(76:100)
  )

  # Save to an .rda file
  save(combined_results, file = "../results/processed_neutral_results.rda")
}

plot_neutral_cluster_results <- function(){

    # load combined_results from rda file
    load("../results/processed_neutral_results.rda")

    ## graph
    png(filename="../results/plot_neutral_cluster_results", width = 600, height = 400)
    
    # colours
    cols <- c("red", "blue", "green", "purple")
    community_sizes <- c(500,1000,2500,5000)

    par(mfrow = c(2, 2), mgp = c(1.7, 0.5, 0))  # Reset multi-panel layout for PNG
    for (i in seq_along(combined_results)) {
        barplot(combined_results[[i]], 
                main = paste("Mean Abundance Octave\n for Community Size of", community_sizes[i]),
                xlab = "Octave Bin",
                ylab = "Mean Species Count",
                col = cols[i],
                names.arg = seq_along(combined_results[[i]]),
                cex.names = 0.85)
    }

    Sys.sleep(0.1)
    dev.off()
    
    return("All done!")
}

# Challenge questions - these are substantially harder and worth fewer marks.
# I suggest you only attempt these if you've done all the main questions. 

# Challenge question A
library(future.apply)

Challenge_A <- function() {
  
  # Preallocate dataframe
  total_rows <- 121 * 150 * 100
  population_size_df <- data.frame(
    simulation_number = integer(total_rows),
    initial_condition = character(total_rows),
    time_step = integer(total_rows),
    population_size = numeric(total_rows),
    stringsAsFactors = TRUE
  )
  
  row_index <- 0  # Track the current row position

  # Enable parallel processing
  plan(multisession, workers = parallel::detectCores() - 1)  # Use available cores

  # Parallel processing over files
  results_list <- future_lapply(1:100, function(i) {
    load(paste0("../results/demographic_output/output_", i, ".rda"))  # Load file
    
    # Process each simulation
    simulation_data <- lapply(seq_along(results), function(j) {

      # Get initial condition label
      initial_condition <- if (i <= 25) {
        "large pop adults"
      } else if (i <= 50){  
        "small pop adults"
      } else if (i <= 75){  
        "large pop spread"
      } else {
        "small pop spread"
      }
      
      # Create a dataframe for this simulation
      data.frame(
        simulation_number = (i - 1) * 150 + j,  # unique simulation ID
        initial_condition = initial_condition,
        time_step = seq_along(results[[j]]),
        population_size = results[[j]]
      )
    })
    
    do.call(rbind, simulation_data)  # Combine all simulations from this file
  })

  # Combine all results into one dataframe
  population_size_df <- do.call(rbind, results_list)

    # graph
  png(filename="../results/Challenge_A.png", width = 600, height = 400)
  # plot your graph here
  library(ggplot2)
  print(ggplot(data = population_size_df, aes(x = time_step, y = population_size, 
      group = simulation_number, colour = initial_condition)) +
      geom_line(alpha = 0.05)+
      guides(colour = guide_legend(override.aes = list(alpha = 1))))

  Sys.sleep(0.1)
  dev.off()

  # Save or return dataframe
  return(population_size_df)
}

# Challenge question B- note this may take 30 seconds
Challenge_B <- function() {

  row_number = 1000 # 1000 runs of the simulation
  num_cores <- detectCores() - 1  # Use all but one core

  # Run simulations in parallel, storing directly in a matrix
  max_richness_mat <- do.call(cbind, mclapply(1:row_number, function(i) {
    neutral_time_series_speciation(init_community_max(100), speciation_rate = 0.1, duration = 100)
  }, mc.cores = num_cores))

  min_richness_mat <- do.call(cbind, mclapply(1:row_number, function(i) {
    neutral_time_series_speciation(init_community_min(100), speciation_rate = 0.1, duration = 100)
  }, mc.cores = num_cores))

  # Compute means & confidence intervals using matrix functions
  mean_max_richness <- rowMeans(max_richness_mat, na.rm = TRUE)
  mean_min_richness <- rowMeans(min_richness_mat, na.rm = TRUE)

  sd_max_richness <- rowSds(max_richness_mat, na.rm = TRUE)
  sd_min_richness <- rowSds(min_richness_mat, na.rm = TRUE)

  t_critical <- qt(1 - (1 - 0.972) / 2, df = row_number - 1)

  ci_max <- t_critical * (sd_max_richness / sqrt(row_number))
  ci_min <- t_critical * (sd_min_richness / sqrt(row_number))

  # Construct a long-format data frame efficiently
  mean_richness_df <- data.frame(
    Generation = rep(0:100, 2),
    Mean_Richness = c(mean_max_richness, mean_min_richness),
    CI_Lower = c(mean_max_richness - ci_max, mean_min_richness - ci_min),
    CI_Upper = c(mean_max_richness + ci_max, mean_min_richness + ci_min),
    Condition = rep(c("Max", "Min"), each = 101)
  )

  # plot
  p <- ggplot(mean_richness_df, aes(x = Generation, y = Mean_Richness, color = Condition, fill = Condition)) +
    geom_ribbon(aes(ymin = CI_Lower, ymax = CI_Upper), alpha = 0.2, color = NA) +  # Confidence intervals
    geom_line(size = 0.4) +  # Mean richness lines
    labs(title = "Mean Species Richness Over Time",
         x = "Generation",
         y = "Mean Species Richness") +
    scale_color_manual(values = c("Max" = "blue", "Min" = "red")) +
    scale_fill_manual(values = c("Max" = "blue", "Min" = "red")) +
    theme_bw()  

  # Save the plot
  png(filename="../results/Challenge_B.png", width = 600, height = 400)
  print(p)

  Sys.sleep(0.1)
  dev.off()

  return("I estimate that 40 generations are needed before the system reaches dynamic equilibrium, as this is the point at which the two initial conditions have overlapping confidence intervals of richness.")  # Return ggplot object for display
}

# Challenge question C

Challenge_C <- function() {
  library(ggplot2)

  # Initialise parameters
  speciation_rate <- 0.1  # Set speciation rate
  duration <- 100  # Number of generations to simulate
  #richness_levels <- seq(10, 100, by=10)  # Different initial richness values
  richness_levels <- c(10, 20, 40, 80, 160, 320)
  runs_per_richness <- 100
  size <- 100 # size of each community

  # fn to initialise community st each indiv could be any species identity
  init_community <- function(size, richness) {
    community <- sample(1:richness, size, replace = TRUE)  # Assign each individual a species at random
  return(community)
  }

  # Store results in a data frame
  all_results <- data.frame()

  for (richness in richness_levels) {
    richness_sum <- numeric(duration + 1)  # Initialize as a numeric vector

    for (i in 1:runs_per_richness) {
      time_series <- neutral_time_series_speciation(init_community(size, richness), speciation_rate, duration)
      richness_sum <- sum_vect(richness_sum, time_series)  # Sum time series
    }

    mean_richness <- richness_sum / runs_per_richness  # Compute mean

    # Convert to long format
    temp_df <- data.frame(
      Generation = 0:duration,
      Mean_Richness = mean_richness,
      Initial_Richness = as.factor(richness)  # Convert to factor for ggplot
    )
    
    all_results <- rbind(all_results, temp_df)
  }

  # Plot using ggplot2
  p <- ggplot(all_results, aes(x = Generation, y = Mean_Richness, color = Initial_Richness)) +
    geom_line(size = 1) +
    labs(title = "Species Richness Over Time for Different Initial Richness Levels",
         x = "Generation",
         y = "Mean Species Richness") +
    scale_color_viridis_d() +  # Better color scheme for clarity
    theme_bw()+
    theme(legend.position = "none")
  
  png(filename="../results/Challenge_C.png", width = 600, height = 400)
  print(p)
  Sys.sleep(0.1)
  dev.off()

  return("Done")
}

# Challenge question D
Challenge_D <- function() {

  # fn to plot the mean richness timeseries from a filelist
  mean_time_series_from_filelist <- function(filelist){ # enter vector of file numbers to average
    richness_sum <- 0
    for(i in filelist) {
      load(paste0("../results/neutral_output/result_", i, ".rda")) # file loaded
      current_richness <- time_series
      richness_sum <- sum_vect(current_richness, richness_sum) # sum the means
    }
    mean_time_series <- richness_sum / length(filelist)
    return(mean_time_series)
  }

  # find mean time series for each size
  mts_500 <- mean_time_series_from_filelist(1:25)
  mts_1000 <- mean_time_series_from_filelist(26:50)
  mts_2500 <- mean_time_series_from_filelist(51:75)
  mts_5000 <- mean_time_series_from_filelist(76:100)

  # plot the 4 time series as 4 plots

  # trim series to same length
  target_length<- length(mts_500)
  
  length(mts_1000) <- target_length
  length(mts_2500) <- target_length
  length(mts_5000) <- target_length

  # x axis
  generations<- seq_len(target_length)

  png(filename="Challenge_D.png", width = 800, height = 600)
  
  # Plot the first time series
  plot(generations, mts_500, type = "l", col = "blue", lwd = 2, ylim = c(0, max(mts_5000)), 
       xlab = "Generation", ylab = "Mean Species Richness", main = "Species Richness Over Time")
  
  # Add the other lines
  lines(generations, mts_1000, col = "red", lwd = 2)
  lines(generations, mts_2500, col = "green", lwd = 2)
  lines(generations, mts_5000, col = "purple", lwd = 2)

  # Add legend
  legend("topright", legend = c("500", "1000", "2500", "5000"), col = c("blue", "red", "green", "purple"), lwd = 2, title = "Population Size")

  Sys.sleep(0.1)
  dev.off()
  return("Larger community sizes require more burn-in generations because they take longer to reach equilibrium richness. While all communities start with minimal diversity, larger ones have a higher equilibrium richness, meaning they need more time to stabilize.")
}

# Challenge question E
Challenge_E_helper <- function(size, speciation_rate, burn_in_generations = 200) {
  J <- size
  v <- speciation_rate

  # Initialize
  lineages <- rep(1, times = J)  # Each lineage starts with 1 individual
  abundances <- numeric()        # Store final sizes of each lineage
  N <- J                         # Track the number of lineages

  # Calculate theta
  theta <- v * (J - 1) / (1 - v)

  # Perform burn-in generations
  for(gen in 1:burn_in_generations) {
    if (N > 1) {
      ji <- sample(1:N, 2, replace = FALSE)
      j <- ji[1]
      i <- ji[2]

      randnum <- runif(1, min = 0, max = 1)
      
      if (randnum < theta / (theta + N - 1)) {
        abundances <- c(abundances, lineages[j])
      } else {
        lineages[i] <- lineages[i] + lineages[j]
      }

      # Remove the merged lineage
      lineages <- lineages[-j]
      N <- N - 1
    }
  }

  # Reset history tracking after burn-in
  history <- matrix(NA, nrow = J, ncol = J)
  history[,1] <- lineages
  generation <- 1

  while(N > 1) {
    ji <- sample(1:N, 2, replace = FALSE)
    j <- ji[1]
    i <- ji[2]

    randnum <- runif(1, min = 0, max = 1)
    
    if (randnum < theta / (theta + N - 1)) {
      abundances <- c(abundances, lineages[j])
    } else {
      lineages[i] <- lineages[i] + lineages[j]
    }

    # Remove the merged lineage
    lineages <- lineages[-j]
    N <- N - 1
    
    # Update history
    if (generation <= J) {
      history[1:N, generation + 1] <- lineages
      history[, generation + 1][is.na(history[, generation + 1])] <- 0
    }

    generation <- generation + 1
  }
  
  return(abundances)
}

