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
observed_corr <- cor(ats$Year, ats$Temp, method = "pearson") 
print(paste("Observed correlation is", observed_corr))
cor.test(ats$Year, ats$Temp, method = "pearson") # invalid p value!
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

# find 10000 random correlation coefficients
n <- 10000
random_corrs <- replicate(n, shuffle_and_find_cor(ats$Year, ats$Temp))

# counting the correlation coefficients which exceed the observed correlation
print(paste("Out of", n, "random correlations", sum(random_corrs >= observed_corr), "were greater than the observed correlation."))

#finding the fraction of correlation coeffiecients greater than observed
approx_p_value <- sum(random_corrs > observed_corr)/length(random_corrs)
print(paste("The approximate p value is", approx_p_value))

####################

# presenting results
library(ggplot2)

temp_vs_year <- ggplot(ats, aes(x = Year, y = Temp))+
    geom_point()+
    geom_smooth(method = "lm", se = FALSE)+
    labs(x="Year", y="Temperature (°C)") +
    theme_classic()

random_corr_hist <- ggplot(as.data.frame(random_corrs), aes(x=random_corrs)) +
    geom_histogram(colour="white", fill="dodgerblue") +
    geom_vline(xintercept = observed_corr, colour = "red", linewidth=1) +
    geom_vline(xintercept = 0, colour = "black", linewidth=0.5) +
    annotate("text", 
           x = observed_corr - 0.018,
           y = 1200,
           label = paste("Observed Correlation:", round(observed_corr, 2)), 
           color = "red", 
           angle = 0, 
           hjust = 1,
           vjust = 1) +
    labs(x="Correlation Coefficient", y="Frequency") +
    xlim(-0.4,0.6) +
    theme_classic()

library(cowplot)
plots <- plot_grid(temp_vs_year, random_corr_hist, nrow=1, labels = c("A", "B"))

# save to PDF
pdf(paper = "a4r", width = 0, height = 0,"../results/Florida_plots.pdf")
print(plots)
graphics.off()

print("Results were saved to ../results/Florida_Plots.pdf")



