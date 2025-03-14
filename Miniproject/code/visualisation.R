
rm(list = ls())

# load
library(ggplot2)

fitted_df <- read.csv("../results/fitted_df_final.csv")

length(unique(fitted_df$ID_num))

# plotting all models:
for (s in unique(fitted_df$ID_num)) {

  # Subset the data for the current ID_num
  data_subset <- data %>%
    filter(ID_num == s)

  # Subset the fitted_points_df for the current ID_num
  fitted_points_df_practice <- fitted_points_df %>%
    filter(ID_num == s)

  fitted_points_df_practice <- fitted_points_df_practice %>%
    filter(!is.na(logPopBiofit))  # Remove rows with NA values

  # Create the plot
  p <- ggplot(data_subset, aes(x = Time, y = logPopBio)) +
    geom_point(size = 3) +
    geom_line(data = fitted_points_df_practice, aes(x = Time, y = logPopBiofit, col = model), size = 1) +
    theme_bw() +  # make the background white
    theme(aspect.ratio = 1) +  # make the plot square
    labs(x = "Time", y = "log(Abundance)") +
    ggtitle(paste("ID_num:", s))  # Add a title with the ID_num
  
  # Save the plot with a unique filename
  plot_filename <- paste("../results/plot_ID_", s, ".png", sep = "")
  ggsave(plot_filename, plot = p)  # Save the plot to the specified filename
}



