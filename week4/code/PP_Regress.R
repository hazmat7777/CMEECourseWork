# housekeeping
rm(list = ls())

# load and inspect data
MyDF <- read.csv("../data/EcolArchives-E089-51-D1.csv")
str(MyDF)
require(tidyverse)
glimpse(MyDF)

## Data wrangling

# Creating a column of prey mass in grams
str(MyDF$Prey.mass)
unique(MyDF$Prey.mass.unit)

library(dplyr)
MyDF <- MyDF %>%
    mutate(Prey.mass.grams = case_when(
        Prey.mass.unit == "g" ~ Prey.mass,
        Prey.mass.unit == "mg" ~ Prey.mass/1000,
        TRUE ~ NA_real_ # if none of the above conds met, pmg is NA
    ))

# converting TOFI to factor to use  as grouping variable
MyDF$Type.of.feeding.interaction <- as.factor(MyDF$Type.of.feeding.interaction)

## Plotting

# making plot
require(ggplot2)

plot <- ggplot(MyDF, aes(x = Prey.mass.grams, y = Predator.mass,
    colour = Predator.lifestage)) +
    geom_point(shape = 3, size = 1) +
    geom_smooth(method = "lm", se = TRUE, fullrange = TRUE) +
    scale_x_log10() +
    scale_y_log10() +
    facet_wrap( ~ Type.of.feeding.interaction, ncol = 1,
        strip.position = "right") + # separate plots for each fi
    labs(y = "Predator mass in grams", x = " Prey Mass in grams") +
    theme_bw() +
    theme(legend.position = "bottom",
        plot.margin = margin(50,150,50,150),
        legend.text = element_text(size = 8),
        legend.title = element_text(size = 10))+
    guides(colour = guide_legend(nrow = 1))

# saving plot
pdf("../results/PP_Regress_Plot.pdf")
print(plot)
dev.off()

## Finding regression results
require(dplyr)
str(MyDF)

results <- MyDF %>%
    group_by(Predator.lifestage, Type.of.feeding.interaction) %>%
    group_modify(function(.x, .y) { # .x is the current group, .y is the group key (group ID). Function within group_modify returns a dataframe for each group, then joins them together.
        if (nrow(.x) >= 3) { # only report coefficients for large groups
            # Linear model summary
            lm_summary <- summary(lm(log(Predator.mass) ~ log(Prey.mass.grams), data = .x)) # object from which I can extract coefficients 
            
            # Extract coefficients and round to 3dp
            Intercept <- round(lm_summary$coefficients["(Intercept)", "Estimate"], digits = 3)
            Slope <- round(lm_summary$coefficients["Prey.mass.grams", "Estimate"], digits = 3)
            R_squared <- round(lm_summary$r.squared, digits = 3)
            P_value <- lm_summary$coefficients["Prey.mass.grams", "Pr(>|t|)"]
            P_value <- ifelse(
                P_value < 0.001, 
                "< 0.001",
                as.character(round(P_value, digits = 3))) # prevents values of 0.000
            F_statistic <- round(lm_summary$fstatistic["value"], digits = 3)
            
            # Return results as a data frame
            data.frame(
                n = nrow(.x),
                Intercept = Intercept,
                Slope = Slope,
                R_squared = R_squared,
                P_value = P_value,
                F_statistic = F_statistic,
                Comment = NA
            )
        } else { # Handle small groups
            data.frame(
                n = nrow(.x),
                Intercept = NA,
                Slope = NA,
                R_squared = NA,
                P_value = NA,
                F_statistic = NA,
                Comment = "Fewer than 3 datapoints"
            )
        }
    })

view(results)

# write the results to a csv file
write.csv(results, "../results/PP_Regress_Results.csv", row.names = TRUE)
