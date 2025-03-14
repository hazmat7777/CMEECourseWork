# Parallelised workflow, sampling starting poarameters #

rm(list = ls())

# load packages
library(dplyr)
library(minpack.lm)
library(AICcmodavg)
library(parallel)

# load cleaned data
data <- as_tibble(read.csv("../data/cleaned_data_final.csv"))

## define the models

# define logistic model
logistic_model <- function(t, r_max, K, N_0){ # The classic logistic equation
 return(N_0 * K * exp(r_max * t)/(K + N_0 * (exp(r_max * t) - 1)))
}

# Gompertz model incorporates a time lag (which we expect in nature)
gompertz_model <- function(t, r_max, K, N_0, t_lag){ # Modified gompertz growth model (Zwietering 1990)
 return(N_0 + (K - N_0) * exp(-exp(r_max * exp(1) * (t_lag - t)/((K - N_0) * log(10)) + 1)))
}  

# Biphasic logistic model incorporates a death phase
biphasic_logistic <- function(t, r_max, K, N_0, D, mu) {
  return((K / (1 + ((K - N_0) / N_0) * exp(-r_max * t))) - D * exp(-mu * t))
}

## Defining functions to fit models and extract AIC/ fitted values

# Linear Fit Function
fit_linear_model <- function(i, data_subset, timepoints) {
    fit_linear <- lm(logPopBio ~ Time, data = data_subset)
    aic_result <- data.frame(ID_num = i, model = "Linear", AICc = AICc(fit_linear), AICc_mean = NA, AICc_sd = NA)
    predictions <- data.frame(ID_num = i, model = "Linear", Time = timepoints, logPopBiofit = predict(fit_linear, newdata = data.frame(Time = timepoints)))
    return(list(aic_result = aic_result, predictions = predictions))
}

# Quadratic Fit Function
fit_quadratic_model <- function(i, data_subset, timepoints) {
    fit_quadratic <- lm(logPopBio ~ poly(Time, 2, raw = TRUE), data = data_subset)
    aic_result <- data.frame(ID_num = i, model = "Quadratic", AICc = AICc(fit_quadratic), AICc_mean = NA, AICc_sd = NA)
    predictions <- data.frame(ID_num = i, model = "Quadratic", Time = timepoints, logPopBiofit = predict(fit_quadratic, newdata = data.frame(Time = timepoints)))
    return(list(aic_result = aic_result, predictions = predictions))
}

# Cubic Fit Function
fit_cubic_model <- function(i, data_subset, timepoints) {
    fit_cubic <- lm(logPopBio ~ poly(Time, 3, raw = TRUE), data = data_subset)
    aic_result <- data.frame(ID_num = i, model = "Cubic", AICc = AICc(fit_cubic), AICc_mean = NA, AICc_sd = NA)
    predictions <- data.frame(ID_num = i, model = "Cubic", Time = timepoints, logPopBiofit = predict(fit_cubic, newdata = data.frame(Time = timepoints)))
    return(list(aic_result = aic_result, predictions = predictions))
}

# Gompertz Fit Function with Sampled Parameters
fit_gompertz_model <- function(i, data_subset, timepoints, n_trials = 50) {
    # Naive estimates for parameters and their uncertainties
    N_0_start_mean <- min(data_subset$logPopBio, na.rm = TRUE)
    K_start_mean <- max(data_subset$logPopBio, na.rm = TRUE)
    r_max_start_mean <- max(diff(data_subset$logPopBio) / diff(data_subset$Time), na.rm = TRUE)
    t_lag_start_mean <- median(data_subset$Time, na.rm = TRUE)

    # Standard deviations for sampling
    N_0_sd <- 2 * sd(data_subset$logPopBio)  # Larger spread for N_0
    r_max_sd <- 2 * sd(diff(data_subset$logPopBio) / diff(data_subset$Time))  # Larger spread for r_max
    t_lag_sd <- 2 * sd(data_subset$Time)

    # Track all AICc values for sensitivity analysis
    aicc_values <- numeric(n_trials)

    # Function to fit the model with sampled parameters
    fit_single_trial <- function() {
        # Sample starting parameters from normal distributions
        N_0_start <- rnorm(1, mean = N_0_start_mean, sd = N_0_sd)
        K_start <- rnorm(1, mean = K_start_mean, sd = N_0_sd)
        r_max_start <- rnorm(1, mean = r_max_start_mean, sd = r_max_sd)
        t_lag_start <- rnorm(1, mean = t_lag_start_mean, sd = t_lag_sd)

        # Fit the Gompertz model with these starting parameters
        fit_gompertz <- tryCatch({
            nlsLM(logPopBio ~ gompertz_model(Time, r_max, K, N_0, t_lag), data = data_subset,
                  start = list(r_max = r_max_start, K = K_start, N_0 = N_0_start, t_lag = t_lag_start))
        }, error = function(e) return(NULL))
        
        # If fitting was successful, evaluate the model
        if (!is.null(fit_gompertz)) {
            gompertz_points <- gompertz_model(t = timepoints, 
                r_max = coef(fit_gompertz)["r_max"], 
                K = coef(fit_gompertz)["K"], 
                N_0 = coef(fit_gompertz)["N_0"], 
                t_lag = coef(fit_gompertz)["t_lag"])

            # Check if the model's predictions are reasonable
            if (max(abs(gompertz_points)) < max(abs(data_subset$logPopBio)) * 3) {
                aicc_values[trial] <<- AICc(fit_gompertz)
                return(list(aic_value = AICc(fit_gompertz), predictions = gompertz_points))
            }
        }
        return(NULL)
    }

    # Loop over multiple trials
    best_fit <- NULL
    best_aic <- Inf
    
    for (trial in 1:n_trials) {
        trial_result <- fit_single_trial()
        
        # Track the best model with the lowest AICc
        if (!is.null(trial_result) && trial_result$aic_value < best_aic) {
            best_aic <- trial_result$aic_value
            best_fit <- trial_result$predictions
        }
    }

    # Record the variation in AICc across all trials
    aicc_mean <- mean(aicc_values, na.rm = TRUE)
    aicc_sd <- sd(aicc_values, na.rm = TRUE)

    # Return the best fit with the lowest AICc and AICc variation
    if (!is.null(best_fit)) {
        return(list(aic_result = data.frame(ID_num = i, model = "Gompertz", AICc = best_aic,
                                            AICc_mean = aicc_mean, AICc_sd = aicc_sd),
                    predictions = data.frame(ID_num = i, model = "Gompertz", Time = timepoints, logPopBiofit = best_fit)))
    }
    return(NULL)
}

# Biphasic Logistic Fit Function with Larger Sampled Parameters
fit_biphasic_logistic_model <- function(i, data_subset, timepoints, n_trials = 50) {
    # Parameter estimates and their uncertainties
    N_0_start_mean <- min(data_subset$logPopBio, na.rm = TRUE)
    K_start_mean <- max(data_subset$logPopBio, na.rm = TRUE)
    r_max_start_mean <- max(diff(data_subset$logPopBio) / diff(data_subset$Time), na.rm = TRUE)
    D_start_mean <- 0.5
    mu_start_mean <- 0.01

    pop_sd <- 5 * sd(data_subset$logPopBio)  
    r_max_sd <- 5 * sd(diff(data_subset$logPopBio) / diff(data_subset$Time))
    D_sd <- range(data_subset$Time)  
    mu_sd <- 1  

    # Track all AICc values for sensitivity analysis
    aicc_values <- numeric(n_trials)

    # Initialize best fit recorders
    best_fit <- NULL
    best_aic <- Inf
    
    # Function to fit the model with sampled parameters
    fit_single_trial <- function() {
        # Sample starting parameters from normal distributions
        N_0_start <- rnorm(1, mean = N_0_start_mean, sd = pop_sd)
        K_start <- rnorm(1, mean = K_start_mean, sd = pop_sd)
        r_max_start <- rnorm(1, mean = r_max_start_mean, sd = r_max_sd)
        D_start <- rnorm(1, mean = D_start_mean, sd = D_sd)
        mu_start <- rnorm(1, mean = mu_start_mean, sd = mu_sd)

        # Fit the biphasic logistic model with these starting parameters
        fit_biphasic <- tryCatch({
            nlsLM(logPopBio ~ biphasic_logistic(Time, r_max, K, N_0, D, mu), data = data_subset,
                  start = list(r_max = r_max_start, K = K_start, N_0 = N_0_start, D = D_start, mu = mu_start))
        }, error = function(e) return(NULL))
        
        # If fitting was successful, evaluate the model
        if (!is.null(fit_biphasic)) {
            biphasic_points <- biphasic_logistic(t = timepoints,
                r_max = coef(fit_biphasic)["r_max"], 
                K = coef(fit_biphasic)["K"], 
                N_0 = coef(fit_biphasic)["N_0"], 
                D = coef(fit_biphasic)["D"],
                mu = coef(fit_biphasic)["mu"])
            
            # Check if the model's predictions are reasonable
            if (max(abs(biphasic_points)) < max(abs(data_subset$logPopBio)) * 3) {
                aic_value <- AICc(fit_biphasic)
                aicc_values[trial] <<- aic_value  # Store AICc value for sensitivity analysis
                return(list(aic_value = aic_value, predictions = biphasic_points))
            }
        }
        return(NULL)
    }

    # Loop over multiple trials
    for (trial in 1:n_trials) {
        trial_result <- fit_single_trial()
        
        # Track the best model with the lowest AICc
        if (!is.null(trial_result) && trial_result$aic_value < best_aic) {
            best_aic <- trial_result$aic_value
            best_fit <- trial_result$predictions
        }
    }
    
    # Calculate AICc variation across trials
    aicc_mean <- mean(aicc_values, na.rm = TRUE)
    aicc_sd <- sd(aicc_values, na.rm = TRUE)

    # Return the best fit with the lowest AICc and AICc variation
    if (!is.null(best_fit)) {
        return(list(aic_result = data.frame(ID_num = i, model = "Biphasic Logistic", AICc = best_aic,
                                            AICc_mean = aicc_mean, AICc_sd = aicc_sd),
                    predictions = data.frame(ID_num = i, model = "Biphasic Logistic", Time = timepoints, logPopBiofit = best_fit)))
    }
    return(NULL)
}

# Logistic Fit Function with Sampled Parameters (without internal parallelization)
fit_logistic_model <- function(i, data_subset, timepoints, n_trials = 50) {
    # Parameter estimates and their uncertainties
    N_0_start_mean <- min(data_subset$logPopBio, na.rm = TRUE)
    K_start_mean <- max(data_subset$logPopBio, na.rm = TRUE)
    r_max_start_mean <- max(diff(data_subset$logPopBio) / diff(data_subset$Time), na.rm = TRUE)
    
    pop_sd <- sd(data_subset$logPopBio) * 2
    r_sd <- sd(diff(data_subset$logPopBio) / diff(data_subset$Time)) * 2

    # Initialize best fit recorders
    best_fit <- NULL
    best_aic <- Inf
    
    # Track all AICc values for sensitivity analysis
    aicc_values <- numeric(n_trials)

    # Function to fit the model with sampled parameters
    fit_single_trial <- function() {
        # Sample starting parameters from normal distributions
        N_0_start <- rnorm(1, mean = N_0_start_mean, sd = pop_sd)
        K_start <- rnorm(1, mean = K_start_mean, sd = pop_sd)
        r_max_start <- rnorm(1, mean = r_max_start_mean, sd = r_sd)
        
        # Fit the logistic model with these starting parameters
        fit_logistic <- tryCatch({
            nlsLM(logPopBio ~ logistic_model(Time, r_max, K, N_0), data = data_subset,
                  start = list(r_max = r_max_start, N_0 = N_0_start, K = K_start))
        }, error = function(e) return(NULL))
        
        # If fitting was successful, evaluate the model
        if (!is.null(fit_logistic)) {
            logistic_points <- logistic_model(t = timepoints, 
                                              r_max = coef(fit_logistic)["r_max"], 
                                              K = coef(fit_logistic)["K"], 
                                              N_0 = coef(fit_logistic)["N_0"])
            
            # Check if the model's predictions are reasonable
            if (max(abs(logistic_points)) < max(abs(data_subset$logPopBio)) * 3) {
                aic_value <- AICc(fit_logistic)
                aicc_values[trial] <<- aic_value  # Store AICc value for sensitivity analysis
                return(list(aic_value = aic_value, predictions = logistic_points))
            }
        }
        return(NULL)
    }

    # Loop over multiple trials
    for (trial in 1:n_trials) {
        trial_result <- fit_single_trial()
        
        # Track the best model with the lowest AICc
        if (!is.null(trial_result) && trial_result$aic_value < best_aic) {
            best_aic <- trial_result$aic_value
            best_fit <- trial_result$predictions
        }
    }
    
    # Calculate AICc variation across trials
    aicc_mean <- mean(aicc_values, na.rm = TRUE)
    aicc_sd <- sd(aicc_values, na.rm = TRUE)

    # Return the best fit with the lowest AICc and AICc variation
    if (!is.null(best_fit)) {
        return(list(aic_result = data.frame(ID_num = i, model = "Logistic", AICc = best_aic,
                                            AICc_mean = aicc_mean, AICc_sd = aicc_sd),
                    predictions = data.frame(ID_num = i, model = "Logistic", Time = timepoints, logPopBiofit = best_fit)))
    }
    return(NULL)
}


# Main Function to Loop Over All Models for Each ID_num
fit_models_for_id <- function(i, data) {
    print(paste("Fitting models for ID_num:", i))
    
    # Subset the data for the current experiment
    data_subset <- data %>% filter(ID_num == i)
    timepoints <- seq(0, max(data_subset$Time), 1)

    # Initialize lists to store results for the current ID_num
    aic_temp_list <- list()
    fit_temp_list <- list()

    # Call individual model functions
    linear_results <- fit_linear_model(i, data_subset, timepoints)
    quadratic_results <- fit_quadratic_model(i, data_subset, timepoints)
    cubic_results <- fit_cubic_model(i, data_subset, timepoints)
    gompertz_results <- fit_gompertz_model(i, data_subset, timepoints)
    biphasic_results <- fit_biphasic_logistic_model(i, data_subset, timepoints)
    logistic_results <- fit_logistic_model(i, data_subset, timepoints)
    
    # Add results to lists
    if (!is.null(linear_results)) {
        aic_temp_list <- append(aic_temp_list, list(linear_results$aic_result))
        fit_temp_list <- append(fit_temp_list, list(linear_results$predictions))
    }
    if (!is.null(quadratic_results)) {
        aic_temp_list <- append(aic_temp_list, list(quadratic_results$aic_result))
        fit_temp_list <- append(fit_temp_list, list(quadratic_results$predictions))
    }
    if (!is.null(cubic_results)) {
        aic_temp_list <- append(aic_temp_list, list(cubic_results$aic_result))
        fit_temp_list <- append(fit_temp_list, list(cubic_results$predictions))
    }
    if (!is.null(gompertz_results)) {
        aic_temp_list <- append(aic_temp_list, list(gompertz_results$aic_result))
        fit_temp_list <- append(fit_temp_list, list(gompertz_results$predictions))
    }
    if (!is.null(biphasic_results)) {
        aic_temp_list <- append(aic_temp_list, list(biphasic_results$aic_result))
        fit_temp_list <- append(fit_temp_list, list(biphasic_results$predictions))
    }
    if (!is.null(logistic_results)) {
        aic_temp_list <- append(aic_temp_list, list(logistic_results$aic_result))
        fit_temp_list <- append(fit_temp_list, list(logistic_results$predictions))
    }

    # Return the results for the current ID_num
    return(list(aic_temp_list = aic_temp_list, fit_temp_list = fit_temp_list))
}

# Parallelized model fitting
results <- mclapply(unique(data$ID_num), fit_models_for_id, data = data, mc.cores = detectCores() - 1)

# Combine results after fitting
AICc_df <- do.call(rbind, lapply(results, function(x) do.call(rbind, x$aic_temp_list)))
fitted_df <- do.call(rbind, lapply(results, function(x) do.call(rbind, x$fit_temp_list)))

# Find the datasets for which all models fit successfully
AICc_df_passed <- AICc_df  %>% 
    group_by(ID_num)  %>% 
    filter(n() == 6)  %>% 
    ungroup()

# Subset fitted values df to include only those where all models fit successfully
fitted_df_passed <- fitted_df %>% 
    filter(ID_num %in% unique(AICc_df_passed$ID_num))

# Record the model(s) with the lowest AICc for each ID
model_winners_by_ID <- AICc_df_passed %>%
  group_by(ID_num) %>%  # Group by ID_num
  filter(AICc < min(AICc)+2) %>%  # Keep only the rows with the minimum AICc for each ID_num
  ungroup() # Remove grouping after counting

# Summarize how many times each model had the lowest AICc
model_count_summary <- AICc_df_passed %>%
  group_by(ID_num) %>%  # Group by ID_num
  filter(AICc == min(AICc)) %>%  # Keep only the rows with the minimum AICc for each ID_num
  count(model) %>%  # Count occurrences of each model for each ID_num
  ungroup() %>%  # Remove grouping after counting
  group_by(model) %>%  # Group by model
  summarise(count = sum(n)) %>%  # Sum the counts for each model
  arrange(desc(count)) %>%   # Arrange in descending order of count
  mutate(Percentage_success = round(count*100/154, 1))

# Summarise the sensitivity to parameters
sensitivity_summary <- AICc_df_passed %>%
  group_by(model) %>%  # Group by model
  summarise(AICc_sd = mean(AICc_sd)) %>%  # find the mean standard deviation
  arrange(desc(AICc_sd)) 

# Idea of overall model fit
sum(AICc_df$AICc) # 20794 total AICc is the lowest I've recorded

## SAVE CSVs
write.csv(AICc_df, "../results/AICc_allmodels.csv")
write.csv(model_winners_by_ID, "../results/AICc_winners_by_ID_final.csv")
write.csv(model_count_summary, "../results/AICc_winners_final.csv")
write.csv(fitted_df_passed, "../results/fitted_df_final.csv")
write.csv(sensitivity_summary, "../results/sensitivity.csv")

