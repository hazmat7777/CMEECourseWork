## Creating a panelled figure with representative plots- figure 2
rm(list = ls())

library(ggplot2)
library(dplyr)
library(gridExtra)
library(grid)

# load
fitted_df <- read.csv("../results/fitted_df_final.csv")
data <- as_tibble(read.csv("../data/cleaned_data_final.csv"))

# Logistic subplot (ID_num: 22)
p1 <- ggplot(data %>% filter(ID_num == 22), aes(x = Time, y = logPopBio)) +
  geom_point(size = 3) +
  geom_line(data = fitted_df %>% filter(ID_num == 22), aes(x = Time, y = logPopBiofit, col = model), size = 1) +
  theme_bw() +
  theme(aspect.ratio = 1, legend.position = "none", 
        axis.title.x = element_blank(), axis.title.y = element_blank()) +  # Remove axis titles, keep ticks
  ggtitle(paste("a) Logistic model best (ID 22)")) +
  annotate("text", x = 2, y = 6, label = "N_0: 0.126\nK: 7.661\nr_max: 0.149", size = 4, hjust = 0, col  = "blue")

# Gompertz (ID_num: 54) 
p2 <- ggplot(data %>% filter(ID_num == 54), aes(x = Time, y = logPopBio)) +
  geom_point(size = 3) +
  geom_line(data = fitted_df %>% filter(ID_num == 54), aes(x = Time, y = logPopBiofit, col = model), size = 1) +
  theme_bw() +
  theme(aspect.ratio = 1, legend.position = "none", 
        axis.title.x = element_blank(), axis.title.y = element_blank()) +  # Remove axis titles, keep ticks
  ggtitle(paste("b) Gompertz model best (ID 54)")) +
  annotate("text", x = 50, y = 3.5, label = "N_0: 1.005\nK: 4.258\nr_max: 0.136\nt_lag: 326.005", size = 4, hjust = 0, col = "darkgreen")

# Biphasic (ID_num: 198) 
p3 <- ggplot(data %>% filter(ID_num == 198), aes(x = Time, y = logPopBio)) +
  geom_point(size = 3) +
  geom_line(data = fitted_df %>% filter(ID_num == 198), aes(x = Time, y = logPopBiofit, col = model), size = 1) +
  theme_bw() +
  theme(aspect.ratio = 1, legend.position = "none", 
        axis.title.x = element_blank(), axis.title.y = element_blank()) +  # Remove axis titles, keep ticks
  ggtitle(paste("c) Biphasic model best (ID 198)")) +
  annotate("text", x = 200, y = -4, label = "N_0: -0.727\nK: -2.070\nr_max: 0.006\nD: 4.599\nmu:0.0297", size = 4, hjust = 0, col = "red")

# Linear (ID_num: 253)
p4 <- ggplot(data %>% filter(ID_num == 253), aes(x = Time, y = logPopBio)) +
  geom_point(size = 3) +
  geom_line(data = fitted_df %>% filter(ID_num == 253), aes(x = Time, y = logPopBiofit, col = model), size = 1) +
  theme_bw() +
  theme(aspect.ratio = 1, legend.position = "none", 
        axis.title.x = element_blank(), axis.title.y = element_blank()) +  # Remove axis titles, keep ticks
  ggtitle(paste("d) Linear model best (ID 253)"))

# Quadratic (ID_num: 248)
p5 <- ggplot(data %>% filter(ID_num == 248), aes(x = Time, y = logPopBio)) +
  geom_point(size = 3) +
  geom_line(data = fitted_df %>% filter(ID_num == 248), aes(x = Time, y = logPopBiofit, col = model), size = 1) +
  theme_bw() +
  theme(aspect.ratio = 1, legend.position = "none", 
        axis.title.x = element_blank(), axis.title.y = element_blank()) +  # Remove axis titles, keep ticks
  ggtitle(paste("e) Quadratic model best (ID 248)"))

# Cubic (ID_num: 247)
p6 <- ggplot(data %>% filter(ID_num == 247), aes(x = Time, y = logPopBio)) +
  geom_point(size = 3) +
  geom_line(data = fitted_df %>% filter(ID_num == 247), aes(x = Time, y = logPopBiofit, col = model), size = 1) +
  theme_bw() +
  theme(aspect.ratio = 1, legend.position = "none", 
        axis.title.x = element_blank(), axis.title.y = element_blank()) +  # Remove axis titles, keep ticks
  ggtitle(paste("f) Cubic model best (ID 247)"))

# Arrange the plots in a 3x2 grid
final_plot <- grid.arrange(p1, p2, p3, p4, p5, p6, ncol = 2, nrow = 3,
             # Shared y-axis label
             left = textGrob("log(Abundance)", rot = 90, just = "center"),
             # Shared x-axis label
             bottom = textGrob("Time (Hours)", just = "center"))

# Create a blank plot with just the legend
legend_plot <- ggplot(fitted_df, aes(x = 1, y = 1, col = model)) +
  geom_point() +  # Just create points (no plot data)
  theme_void() +  # Minimal theme to remove unnecessary elements
  theme(
    legend.position = "bottom",  # Position the legend at the bottom
    legend.title = element_text(size = 14),
    legend.text = element_text(size = 12),
    axis.title = element_blank(),  # Remove axis titles
    axis.text = element_blank(),   # Remove axis text
    axis.ticks = element_blank(),  # Remove axis ticks
    panel.grid = element_blank()   # Remove grid lines
  ) +
  labs(color = "Model Types")  # Add a label for the legend

# Extract the legend as a grob (graphical object)
legend_grob <- ggplotGrob(legend_plot)$grobs[[which(sapply(ggplotGrob(legend_plot)$grobs, function(x) x$name) == "guide-box")]]

# Combined subplots with legend
combined_plot <- grid.arrange(final_plot, legend_grob, ncol = 1, nrow = 2, heights = c(10, 1))  # Adjust height ratio for spacing

ggsave("../results/Figure2.pdf", plot = combined_plot, width = 8, height = 12.0, dpi = 600, limitsize = FALSE)

