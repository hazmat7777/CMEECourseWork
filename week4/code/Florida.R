# housekeeping
rm(list=ls())

# loading data
load("../data/KeyWestAnnualMeanTemperature.RData")
ls()
class(ats)
str(ats)
head(ats)

# data visualisation
plot(ats)

# finding correlation coefficient
?cor # use pearson as data look linear
observed_correlation <- cor(ats$Year, ats$Temp, method = "pearson") 
print(observed_correlation)
cor.test(ats$Year, ats$Temp, method = "pearson") # invalid!
    # cor.test() provides a p-value assuming independent observations,
    # which is not valid here due to autocorrelation in time series.

# method
    # estimate an approximate asymptotic p-value through a permutation test:
    # compare observed correlation to a distribution of correlation values
    # from randomly shuffled data (simulating null hypothesis of no relationship)

# function to find a correlation coefficient of randomly shuffled data
shuffle_and_find_cor <- function(year, temp){
    shuffled_temp <- sample(temp) # shuffles the temperatures
    correlation <- cor(year, shuffled_temp, method = "pearson")
    return(correlation)
}

# find 1000 random correlation coefficients
corrs <- replicate(1000, shuffle_and_find_cor(ats$Year, ats$Temp))

# counting the correlation coefficients which exceed the observed correlation
sum(corrs >= observed_correlation)

#finding the fraction of correlation coeffiecients greater than observed
approx_p_value <- sum(corrs > observed_correlation)/length(corrs)
print(approx_p_value)

