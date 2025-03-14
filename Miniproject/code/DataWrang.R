# housekeeping
rm(list = ls())

# Load packages
library(tidyverse)

# Load metadata
meta <- read.csv("../data/LogisticGrowthMetaData.csv")
print(meta)

# Load data
data <- read.csv("../data/LogisticGrowthData.csv")
cat("Loaded", ncol(data), "columns.\n")

print(colnames(data)) # Print column names

head(data)  # View first few rows

# Check unique values for specific columns
unique(data$PopBio_units) # Units of the response variable
unique(data$Time_units)   # Units of the independent variable

# Create an ID column for each growth curve
data <- data %>%
  mutate(ID = paste(Species, Temp, Medium, Citation, Rep, sep = "_"))

length(unique(data$ID)) # 305 unique IDs

# ID column of numbers
data <- data %>%
  mutate(ID_num = as.integer(factor(ID)))  %>% 
  select(ID_num, everything())  # Moves ID_num to the first column

# log pop data
data <- data %>%
  mutate(logPopBio = log(PopBio))  # Create a new column with log-transformed PopBio

# filter nonsense values
data <- data  %>% 
    filter(!is.na(logPopBio))

data <- data  %>% 
    filter(!is.infinite(logPopBio))

data <- data  %>% 
    filter(Time >= 0)

# only include plots with 10 datapoints
data <- data %>%
  group_by(ID_num) %>%
  filter(n() >= 10) %>%
  ungroup()

# inspect and remove poor data (i.e. data w excessive noise or evident systematic errors in data collection)
for (s in unique(data$ID_num)) {
  # Subset the data for the current ID_num
  data_subset <- data %>%
    filter(ID_num == s)

  # Create the plot
  p <- ggplot(data_subset, aes(x = Time, y = PopBio)) +
    geom_point(size = 3) +
    theme_bw() +  # make the background white
    theme(aspect.ratio = 1) +  # make the plot square
    labs(x = "Time", y = "log(Abundance)") +
    ggtitle(paste("ID_num:", s))  # Add a title with the ID_num
  
  # Save the plot with a unique filename
  plot_filename <- paste("../sandbox/growthcurves/plot_ID_", s, ".png", sep = "")
  ggsave(plot_filename, plot = p)  # Save the plot to the specified filename
}

data <- data %>%
  filter(!ID_num %in% c(59, 64, 71, 72, 77, 82, 87, 107, 111, 134, 286, 289)) # based on inspection of plots

# arrange all data by ID and time
data <- data  %>% 
    arrange(ID_num, Time)
head(data)

# write to csv
write.csv(x = data, file = "../data/cleaned_data_final.csv", row.names = FALSE)

