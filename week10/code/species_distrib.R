# housekeeping
rm(list = ls())

# load
library(terra)     # core raster GIS package
library(sf)        # core vector GIS package
library(units)     # used for precise unit conversion

library(geodata)   # Download and load functions for core datasets
library(openxlsx)  # Reading data from Excel files

sf_use_s2(FALSE)

### Map of species of concern

# load shapefile data
MAMMALS <- st_read('../data/MAMMALS/MAMMALS.shp')

# view
str(MAMMALS)

# apply filters
mymammals <- subset(
  MAMMALS,
  order_ == "ARTIODACTYLA" &
  (category == "EN" | category == "CR") &
  marine == "false" & freshwater == "false",
  select = c(order_, category, SHAPE_Leng, SHAPE_Area, geometry, sci_name)
)

species_to_include <- c(
  "Eudorcas tilonura",
  "Gazella spekei",
  "Kobus megaceros",
  "Oryx beisa",
  "Oryx dammah",
  "Redunca fulvorufula",
  "Tragelaphus buxtoni"
)

# Subset the data frame
mymammals <- mymammals[mymammals$sci_name %in% species_to_include, ]

# View the subsetted data frame
print(mymammals)
unique(mymammals$order_)
str(mymammals) # 162 rows

# checking coord ref system
st_crs(mymammals)

# cropping data to just southern africa
sub_saharan_extent <- st_bbox(c(
  xmin = 30,
  ymin = 0,
  xmax = 55,
  ymax = 20
), crs = st_crs(mymammals))


st_agr(mymammals) <- 'constant'
sub_sah_mammals <- st_crop(mymammals, sub_saharan_extent)
sub_sah_mammals_rob <- st_transform(sub_sah_mammals, crs='ESRI:102022') # not robinson projection

str(sub_sah_mammals)
unique(sub_sah_mammals_rob$sci_name)# 7 species

ne_10 <- st_read('../../week9/data/ne_10m_admin_0_countries/ne_10m_admin_0_countries.shp')

subsah_ne_10 <- st_crop(ne_10, sub_saharan_extent)
subsah_ne_rob <- st_transform(subsah_ne_10, crs='ESRI:102022') # not robinson projection

## plot species distrib
pdf("../results/endangered_sp2.pdf")

# Plot the base map
plot(st_geometry(subsah_ne_rob), col = 'khaki', border = 'grey40')

# Overlay the mammals data with colors by species
species_colors <- as.factor(sub_sah_mammals$sci_name)
plot(st_geometry(sub_sah_mammals_rob), add = TRUE, col = adjustcolor(as.numeric(species_colors), alpha.f=0.5))

# Add a legend for the species
legend(
  "bottomright",  # Position
  legend = as.expression(lapply(levels(species_colors), function(x) bquote(italic(.(x))))),  # Italicized species names
  col = seq_along(levels(species_colors)),  # Matching colors
  pch = 15,  # Square symbols
  title = "Species",
  cex = 0.8
)

dev.off()

### attempt 3

# Create a mask for the background by subtracting the species presence
species_union <- st_union(sub_sah_mammals_rob) # Combine all species areas into one
background_mask <- st_difference(st_geometry(subsah_ne_rob), species_union) # Areas without species

# Start the plot
pdf("../results/endangered_sp_3.pdf")

# Plot the base map only in areas without species
plot(background_mask, col = 'khaki', border = 'grey40')

# Overlay the mammals data with colors by species
species_colors <- as.factor(sub_sah_mammals$sci_name)
plot(st_geometry(sub_sah_mammals_rob), add = TRUE, col = adjustcolor(as.numeric(species_colors), alpha.f = 0.6))

plot(st_geometry(subsah_ne_rob), add = TRUE, col = NA, border = 'grey40', lwd = 0.5)

# Add a legend for the species
legend(
  "bottomright",  # Position
  legend = as.expression(lapply(levels(species_colors), function(x) bquote(italic(.(x))))),  # Italicized species names
  col = seq_along(levels(species_colors)),  # Matching colors
  pch = 15,  # Square symbols
  title = "Species",
  cex = 0.8
)

dev.off()

## final one

# Load RColorBrewer for distinct color palettes
library(RColorBrewer)

# Generate distinct colors using RColorBrewer
num_species <- length(unique(sub_sah_mammals$sci_name))
species_palette <- brewer.pal(min(num_species, 8), "Set1") # Use "Set2" or other palettes

# Start the plot
pdf("../results/endangered_sp_5.pdf")

# Plot the base map (background mask without species)
plot(background_mask, col = 'khaki', border = NA)

# Overlay the species polygons with distinct colors
species_colors <- as.factor(sub_sah_mammals$sci_name)
plot(
  st_geometry(sub_sah_mammals_rob), 
  add = TRUE, 
  col = adjustcolor(species_palette[as.numeric(species_colors)], alpha.f = 0.6)
)

# Add the country borders on top
plot(st_geometry(subsah_ne_rob), add = TRUE, col = NA, border = 'grey40', lwd = 0.3)

# Add a legend for the species with distinct colors
legend(
  "bottomright",  # Position
  legend = as.expression(lapply(levels(species_colors), function(x) bquote(italic(.(x))))),  # Italicized species names
  col = species_palette,  # Matching colors
  pch = 15,  # Square symbols
  title = "Species",
  cex = 0.8,
  bty ="n"
)

dev.off()

### Map of host species- goats

# load tif
goats <- rast('../data/goats.tif')

# crop to east africa
subsah_goats <- crop(goats, sub_saharan_extent)

summary(subsah_goats)
boxplot(summary(subsah_goats))

breaks <- c(0, 100, 200, 400, 600, 800)  # Custom breaks
colors <- c("khaki", colorRampPalette(c("orange", "red"))(length(breaks) - 2)) # Matching colors
pdf("../results/goat_dens2.pdf", width = 9, height = 8)
plot(subsah_goats, 
     col = colors, 
     breaks = breaks, 
     legend = FALSE
)
legend(
  "bottomright", 
  legend = c("0", "1-200", "200-400", "400-600", "600-800"),
  fill = colors,
  title = "Goats per km²",
  cex = 0.8  # Adjust text size
)
dev.off()

# new with better breaks

breaks <- c(0, 20, 40, 60, 80, 100, 900)  # Custom breaks
colors <- c("khaki", colorRampPalette(c("orange", "darkred"))(length(breaks) - 2))  # One color per interval

# Save the plot as a PDF
pdf("../results/goat_dens3.pdf", width = 9, height = 8)

# Adjust margins: bottom, left, top, right
par(mar = c(6, 6, 6, 8)) 

# Plot the raster with the custom breaks and colors
plot(subsah_goats, 
     col = colors, 
     breaks = breaks, 
     legend = FALSE  # Suppress the default legend
)

# Add a custom legend
legend(
  "bottomright", 
  inset = c(0.05),
  legend = c("0-20", "21-40", "41-60", "61-80", "81-100", ">100"),  # Align labels with breaks
  fill = colors,  # Use the same colors for the legend
  title = "Goats per km²",
  cex = 0.8  # Adjust text size
)

# Close the PDF device
dev.off()

# new with EVEN better breaks


breaks <- c(0, 20, 40, 60, 80, 100, 200, 900)  # Custom breaks
colors <- c("khaki", colorRampPalette(c("orange", "red"))(length(breaks) - 3), "#8B0000")  # One color per interval

# Save the plot as a PDF
pdf("../results/goat_dens4.pdf", width = 9, height = 8)

# Adjust margins: bottom, left, top, right
par(mar = c(6, 6, 6, 8)) 

# Plot the raster with the custom breaks and colors
plot(subsah_goats, 
     col = colors, 
     breaks = breaks, 
     legend = FALSE  # Suppress the default legend
)

# Add a custom legend
legend(
  "bottomright", 
  inset = c(0.05),
  legend = c("0-20", "21-40", "41-60", "61-80", "81-100", "101-200", ">200"),  # Align labels with breaks
  fill = colors,  # Use the same colors for the legend
  title = "Goats per km²",
  cex = 0.8  # Adjust text size
)

# Close the PDF device
dev.off()


## vectorise the goat data

# how to define 'very high' density of goats?
ss_goats_df <- as.data.frame(subsah_goats, xy =TRUE)
str(ss_goats_df) # 51770 cells
boxplot(ss_goats_df$goats)
hist(ss_goats_df$goats)

sum(ss_goats_df$goats > 0) # 45245 above 0
sum(ss_goats_df$goats > 10) # 45245 above 10
sum(ss_goats_df$goats > 50) # 10044 above 50

sum(ss_goats_df$goats > 300) # 245 above 300
sum(ss_goats_df$goats > 200) # 701 above 200
sum(ss_goats_df$goats > 400) # 88 above 400
sum(ss_goats_df$goats > 99) # 2956 above 99

# datawrang
library(dplyr)

ss_goats_df <- ss_goats_df %>%
    mutate(
        highdens = if_else(goats > 99, 1, 0),
        meddens = if_else(goats >= 50 & goats <= 99, 1, 0),
        lowdens = if_else(goats >= 20 & goats < 50, 1, 0),
        somedens = if_else(goats>= 20, 1, 0)
    )

str(ss_goats_df)
sum(ss_goats_df$highdens + ss_goats_df$meddens + ss_goats_df$lowdens > 1) # no overlap

ss_goats_df <- ss_goats_df %>%
    filter(!is.na(goats))  # Remove rows with NA values


# Convert each density class to a raster
highdens_raster <- rast(ss_goats_df[, c("x", "y", "highdens")], type = "xyz", crs = "EPSG:4326")
meddens_raster <- rast(ss_goats_df[, c("x", "y", "meddens")], type = "xyz", crs = "EPSG:4326")
lowdens_raster <- rast(ss_goats_df[, c("x", "y", "lowdens")], type = "xyz", crs = "EPSG:4326")
somedens_raster <- rast(ss_goats_df[, c("x", "y", "somedens")], type = "xyz", crs = "EPSG:4326")

highdens_raster <- project(highdens_raster, 'ESRI:102022')
meddens_raster <- project(meddens_raster, 'ESRI:102022')
lowdens_raster <- project(lowdens_raster, 'ESRI:102022')
somedens_raster <- project(somedens_raster, 'ESRI:102022')

# Vectorize the rasters
highdens_vector <- as.polygons(highdens_raster, dissolve = TRUE)
meddens_vector <- as.polygons(meddens_raster, dissolve = TRUE)
lowdens_vector <- as.polygons(lowdens_raster, dissolve = TRUE)
somedens_vector <- as.polygons(somedens_raster, dissolve = TRUE)

# Add a 'type' column to each vector
highdens_vector$type <- "highdens"
meddens_vector$type <- "meddens"
lowdens_vector$type <- "lowdens"

# Combine the vectors
combined_vector <- rbind(highdens_vector, meddens_vector, lowdens_vector)

# Check the combined vector
unique(combined_vector$type)


# Filter polygons for highdens = 1 and highdens = 0
highdens_1 <- highdens_vector[highdens_vector$highdens == 1, ]
meddens_1 <- meddens_vector[meddens_vector$meddens == 1, ]
lowdens_1 <- lowdens_vector[lowdens_vector$lowdens == 1, ]
somedens_1 <- somedens_vector[somedens_vector$somedens == 1, ]

## Plot map
pdf("../results/goatdenslayers4.pdf")
# base
plot(st_geometry(subsah_ne_rob), col = 'khaki', border = 'grey40', main = "")

# Overlay high density polygons in red
plot(highdens_1, col = "darkred", add = TRUE)

# Overlay medium density polygons in orange
plot(meddens_1, col = "red", add = TRUE)

plot(lowdens_1, col = "orange", add = TRUE)

# LEGEND
legend("bottomright",         
       legend = c("Low (20-49/km2)", "Medium (50-99/km2)", "High (>99/km2)"),
       fill = c("orange", "red", "darkred"),   
       border = "grey40",                      
       title = " Goat density",                      
       cex = 0.9,
       inset = c(0.05),
       bty = "n") 

dev.off()












#### calculating overlap in ranges

crs(sub_sah_mammals_rob)
crs(meddens_1)

class(sub_sah_mammals_rob)

# Convert SpatVector to sf
highdens_sf <- st_as_sf(highdens_1)
meddens_sf <- st_as_sf(meddens_1)
lowdens_sf <- st_as_sf(lowdens_1)

# Function to calculate overlap and summarize
# Function to calculate overlap area and percentage
calculate_overlap_metrics <- function(species_sf, density_sf, density_label) {
    # Calculate intersection
    overlap <- st_intersection(species_sf, density_sf)
    
    # Add area of overlap in km²
    overlap$overlap_area <- st_area(overlap) / 1e6  # Convert from m² to km²
    
    # Calculate total area of each species' distribution
    species_total_area <- species_sf %>%
        group_by(sci_name) %>%
        summarize(total_area_km2 = sum(as.numeric(st_area(geometry)) / 1e6)) %>%
        st_drop_geometry()  # Remove geometry for simplicity
    
    # Summarize overlap area by species
    overlap_summary <- overlap %>%
        group_by(sci_name) %>%
        summarize(overlap_km2 = sum(as.numeric(overlap_area))) %>%
        st_drop_geometry()  # Remove geometry
    
    # Merge overlap summary with total area
    metrics_summary <- left_join(overlap_summary, species_total_area, by = "sci_name") %>%
        mutate(
            !!paste0(density_label, "_overlap_area_km2") := overlap_km2,
            !!paste0(density_label, "_overlap_percentage") := (overlap_km2 / total_area_km2) * 100
        ) %>%
        select(sci_name, 
               !!paste0(density_label, "_overlap_area_km2"), 
               !!paste0(density_label, "_overlap_percentage"))  # Keep only relevant columns
    
    return(metrics_summary)
}

# Calculate metrics for each density class
low_overlap_metrics <- calculate_overlap_metrics(sub_sah_mammals_rob, lowdens_sf, "lowdens")
med_overlap_metrics <- calculate_overlap_metrics(sub_sah_mammals_rob, meddens_sf, "meddens")
high_overlap_metrics <- calculate_overlap_metrics(sub_sah_mammals_rob, highdens_sf, "highdens")

# Combine all metrics into a single table
combined_overlap_metrics <- full_join(low_overlap_metrics, med_overlap_metrics, by = "sci_name") %>%
    full_join(high_overlap_metrics, by = "sci_name")

print(low_overlap_metrics)
print(med_overlap_metrics)
print(high_overlap_metrics)


# View the final summary table
glimpse(combined_overlap_metrics)

combined_overlap_metrics2 <- combined_overlap_metrics

# Replace all NA values with 0
combined_overlap_metrics2[is.na(combined_overlap_metrics2)] <- 0


combined_overlap_metrics2 <- combined_overlap_metrics2 %>%
  mutate(across(where(is.numeric), ~ signif(.x, 3)))



colnames(combined_overlap_metrics2) <- c("Species", "Area/km2", "%", "Area/km2", "%",  
                                        "Area/km2", "%")
glimpse(combined_overlap_metrics2)



library(knitr)
library(kableExtra)

kable_table <- kable(combined_overlap_metrics2, format = "latex", booktabs = TRUE, align = "c") %>%
  add_header_above(c(" " = 1, 
                     "Overlap with goats at low density" = 2, 
                     "Overlap with goats at medium density" = 2, 
                     "Overlap with goats at high density" = 2)) %>%
  kable_styling(latex_options = c("hold_position", "scale_down"))

# Save to a .tex file
writeLines(kable_table, "../results/combined_overlap_metrics3.tex")


#### overlap of humans with all species and goats

glimpse(sub_sah_mammals_rob)
ls()

class(top5density)

class(highpops_sf)

class(dissolved_highpops_sf)

# Calculate intersection of the geometries
overlaphum <- st_intersection(sub_sah_mammals_rob, dissolved_highpops_sf)

# Calculate the area of overlap for each scientific name
overlaphums <- overlaphum %>%
  mutate(overlap_area = as.numeric(st_area(.)) / 1e6) %>%  # Convert to numeric and scale to km²
  group_by(sci_name) %>%
  summarize(
    total_overlap_km2 = sum(overlap_area, na.rm = TRUE),  # Total overlap area in km²
    original_area_km2 = sum(as.numeric(st_area(sub_sah_mammals_rob[sub_sah_mammals_rob$sci_name == first(sci_name), ])) / 1e6),  # Original area in km²
    .groups = "drop"
  )

# Calculate percentage overlap
overlaphums <- overlaphums %>%
  mutate(
    perc_overlap = (total_overlap_km2 / original_area_km2) * 100
  )

# Convert to a clean data frame without geometry
overlaphums_table <- overlaphums %>%
  st_drop_geometry() %>%
  mutate(
    total_overlap_km2 = round(total_overlap_km2, 2),  # Round for readability
    original_area_km2 = round(original_area_km2, 2),
    perc_overlap = round(perc_overlap, 2)
  ) %>%
  as.data.frame()

# Print the clean table
glimpse(overlaphums_table)




# Create and format the LaTeX table
latex_table <- overlaphums_table %>%
  kable(format = "latex", booktabs = TRUE, col.names = c("Species", "Total Overlap (km²)", "Original Area (km²)", "Percentage Overlap (%)")) %>%
  kable_styling(latex_options = "hold_position")

# Save the LaTeX table to a file
writeLines(latex_table, "../results/overlaphums_table.tex")





names(lowdens_sf)

lowdens_sf <- st_as_sf(lowdens_vector)
# Calculate intersection of the geometries
overlap_lowdens <- st_intersection(lowdens_sf, dissolved_highpops_sf)

# Calculate the area of overlap for each feature in lowdens_sf
overlap_lowdens_table <- overlap_lowdens %>%
  mutate(overlap_area = as.numeric(st_area(.)) / 1e6) %>%  # Convert to numeric and scale to km²
  group_by(lowdens) %>%  # Replace `feature_name` with the relevant column in `lowdens_sf`
  summarize(
    total_overlap_km2 = sum(overlap_area, na.rm = TRUE),  # Total overlap area in km²
    original_area_km2 = sum(as.numeric(st_area(lowdens_sf[lowdens_sf$lowdens == first(lowdens), ])) / 1e6),  # Original area in km²
    .groups = "drop"
  )

# Calculate percentage overlap
overlap_lowdens_table <- overlap_lowdens_table %>%
  mutate(
    perc_overlap = (total_overlap_km2 / original_area_km2) * 100
  )

# Clean up for LaTeX table
overlap_lowdens_table_clean <- overlap_lowdens_table %>%
  st_drop_geometry() %>%
  mutate(
    total_overlap_km2 = round(total_overlap_km2, 2),
    original_area_km2 = round(original_area_km2, 2),
    perc_overlap = round(perc_overlap, 2)
  ) %>%
  as.data.frame()

print(overlap_lowdens_table_clean)

colnames(overlap_lowdens_table_clean)[1] <- "sci_name"

overlap_lowdens_table_clean <- overlap_lowdens_table_clean[2,]
overlap_lowdens_table_clean[1,1] <- "Domestic goat"

overlap_lowdens_table_clean



# Combine the two tables by stacking rows
combined_table <- bind_rows(overlaphums_table, overlap_lowdens_table_clean)

# View the combined table
print(combined_table)

# Save the table to a LaTeX file
latex_table2 <- combined_table %>%
  kable(format = "latex", booktabs = TRUE, col.names = c("Species", "Total Overlap (km²)", "Original Area (km²)", "Percentage Overlap (%)")) %>%
  kable_styling(latex_options = "hold_position")

writeLines(latex_table2, "../results/overlaphums_table2.tex")

























### overlap of goats with all species

pdf("../results/focalhostoverlap.pdf")

# base map
plot(st_geometry(subsah_ne_rob), col = 'khaki', border = 'grey40')

# Overlay the mammals data with colors by species
species_colors <- as.factor(sub_sah_mammals$sci_name)
plot(st_geometry(sub_sah_mammals_rob), add = TRUE, col = adjustcolor(as.numeric(species_colors), alpha.f=0.5))

# overlay goats
plot(somedens_1, col = "yellow", alpha = 0.5, add = TRUE)

# Add a legend for the species
legend(
  "bottomright",  # Position
  legend = as.expression(lapply(levels(species_colors), function(x) bquote(italic(.(x))))),  # Italicized species names
  col = seq_along(levels(species_colors)),  # Matching colors
  pch = 15,  # Square symbols
  title = "Species",
  cex = 0.8
)

dev.off()

## another method
class(somedens_1)

somedens_sf <- st_as_sf(somedens_1) # convert to sf



# Load RColorBrewer for distinct color palettes
library(RColorBrewer)

# Generate distinct colors using RColorBrewer
num_species <- length(unique(sub_sah_mammals$sci_name))
species_palette <- brewer.pal(min(num_species, 8), "Set1") # Use "Set2" or other palettes



## Plot the base map (background mask without species)
# Union the goats and species areas
goats_and_species <- st_union(st_geometry(somedens_sf), st_geometry(sub_sah_mammals_rob))

# Create the background mask for areas without goats or species
background_mask_no_goats_species <- st_difference(st_geometry(subsah_ne_rob), goats_and_species)

# Start the plot
pdf("../results/goatsvshosts2.pdf")

# Plot them all
plot(background_mask_no_goats_species, col = 'khaki', border = 'grey40') #background
plot(st_geometry(somedens_sf), add = TRUE, col = 'orange', border = NA) # goat density
plot( # host species
  st_geometry(sub_sah_mammals_rob), 
  add = TRUE, 
  col = adjustcolor(species_palette[as.numeric(species_colors)], alpha.f = 0.6)
)
plot(st_geometry(subsah_ne_rob), add = TRUE, col = NA, border = 'grey40', lwd = 0.3) # country borders

# Add a legend for the species with distinct colors
legend(
  "bottomright",  # Position
  legend = c(
    as.expression(lapply(levels(species_colors), function(x) bquote(italic(.(x))))), 
    "Goats"
  ),  # Italicized species names and "Goats" in normal text
  col = c(species_palette, "orange"),  # Matching colors
  pch = 15,  # Square symbols
  title = "Species ranges",
  cex = 0.8,
  bty = "n"
)

dev.off()

#### overlap with human population density

pop <- rast("../data/gpw_v4_population_density_rev11_2020_15_min.tif")

print(pop)

ss_pop <- crop(pop, sub_saharan_extent)

ss_pop<- project(ss_pop, "ESRI:102022")

print(ss_pop)

# initial visual
breaks <- quantile(values(ss_pop, na.rm = TRUE), probs = seq(0, 1, by = 0.1), na.rm = TRUE)

breaks <- c(0,20, 40, 60, 80, 100, 120, 140, 160, 180, 200, 8000)

breaks <- c(0, 50, 100, 150, 200, 250, 300, 350, 400, 450, 500, 8000)

breaks <- c(0, 100, 200, 300, 400, 8000)

plot(ss_pop, breaks = breaks)

## extract popdens data

# median
sub_sah_mammals_rob$medianoverlap <- extract(ss_pop, sub_sah_mammals_rob, fun = median, ID =FALSE)

glimpse(sub_sah_mammals_rob)

glimpse(sub_sah_mammals_rob$medianoverlap[[1]])

# range
# Extract both min and max values

# define function
range <- function(values) {
  min = round(min(values)) 
  max = round(max(values))
  return(paste0(min, "-", max))
}


sub_sah_mammals_rob$humanoverlap_range <- extract(ss_pop, sub_sah_mammals_rob, fun = range, ID = FALSE)

glimpse(sub_sah_mammals_rob)
glimpse(sub_sah_mammals_rob$humanoverlap_range[[1]])


# top 5% of human density

boxplot(values(ss_pop))

top5density <- quantile(values(ss_pop), probs = 0.95, na.rm = TRUE)

print(top5density) #245

high_pops <- ifel(ss_pop >= 245, ss_pop, NA)

range(values(high_pops))
str(values(high_pops))

summary(values(ss_pop >= 245))
summary(values(high_pops))

str(ss_pop_df)

plot(high_pops)

highpops_vector <- as.polygons(high_pops, dissolve = TRUE)

# Convert to an sf object
highpops_sf <- st_as_sf(highpops_vector)

# Dissolve all polygons into one
dissolved_highpops <- st_union(highpops_sf)

# Plot the dissolved polygon
plot(dissolved_highpops, col = "red", border = "black")

## plotting 

pdf("../results/humansvsanimals1")

#par(mfrow = c(1,2))

# base map
plot(background_mask, col = 'khaki', border = NA)

# Overlay the species polygons with distinct colors
species_colors <- as.factor(sub_sah_mammals$sci_name)
plot(
  st_geometry(sub_sah_mammals_rob), 
  add = TRUE, 
  col = adjustcolor(species_palette[as.numeric(species_colors)], alpha.f = 0.6)
)

plot(dissolved_highpops, add = TRUE, col = adjustcolor("red", alpha.f = 0.5), border = "black")

# Add the country borders on top
plot(st_geometry(subsah_ne_rob), add = TRUE, col = NA, border = 'grey40', lwd = 0.3)

# Add a legend for the species with distinct colors
legend(
  "bottomright",  # Position
  legend = as.expression(lapply(levels(species_colors), function(x) bquote(italic(.(x))))),  # Italicized species names
  col = species_palette,  # Matching colors
  pch = 15,  # Square symbols
  title = "Species",
  cex = 0.8
)
dev.off()

pdf("../results/humansvsanimals6")

# for humansvsanimals5 change to set1

# sort out legend colours

# Ensure species names are factors
unique(sub_sah_mammals_rob$sci_name)

species_names <- as.factor(sub_sah_mammals_rob$sci_name)

length(levels(species_names))

print(levels(species_names))

# Generate a unique color palette for all species
species_palette <- brewer.pal(length(levels(species_names)), "Set1")

print(species_palette)
species_palette[6] <- "#00008B"


# Map the colors to the species in the data
species_colors <- species_palette[as.numeric(species_names)]


# Find overlap areas
overlap <- st_intersection(dissolved_highpops, st_geometry(sub_sah_mammals_rob))

# Calculate points within polygons instead of centroids
overlap_points <- st_point_on_surface(overlap)



# Plot everything
plot(background_mask, col = 'khaki', border = NA)
plot(dissolved_highpops, add = TRUE, col = adjustcolor("red", alpha.f = 0.5), border = "black")
plot(st_geometry(sub_sah_mammals_rob), add = TRUE, col = adjustcolor(species_colors, alpha = 0.5))
plot(st_geometry(subsah_ne_rob), add = TRUE, col = NA, border = "grey40", lwd = 0.5)
plot(overlap_points, add = TRUE, col = "black", pch = 4, lwd = 2.5, cex = 1.5)

# Add corrected legend

length(species_palette)

species_colors_transparent <- adjustcolor(species_palette, alpha.f = 0.5)

# Add the legend
legend(
  "bottomright",
  legend = c(as.expression(lapply(levels(species_names), function(x) bquote(italic(.(x))))), 
             "High Human Density", "Overlap Points"),
  col = c(species_colors_transparent, adjustcolor("red", alpha.f = 0.5), "black"),
  pch = c(rep(15, length(species_palette)), 15, 4), # 15 for polygons, 4 for overlap points
  title = "Legend",
  cex = 0.8,
  bty = "n"
)

dev.off()

print(levels(species_colors))  # Check species levels
print(as.numeric(species_colors))  # Check numeric mapping


# Count points in each polygon
overlap_counts <- st_within(overlap_points, sub_sah_mammals_rob) # Spatial relationship

# Initialize a vector of counts for all polygons
point_counts <- rep(0, nrow(sub_sah_mammals_rob)) # Default count is 0

# Fill in counts for polygons with points
for (i in seq_along(overlap_counts)) {
  polygon_index <- overlap_counts[[i]] # Get the index of the polygon containing the point
  if (length(polygon_index) > 0) {
    point_counts[polygon_index] <- point_counts[polygon_index] + 1
  }
}

# Add the counts as a new column in the polygons
sub_sah_mammals_rob$count <- point_counts

# Inspect the updated polygons
print(sub_sah_mammals_rob$count)

tail(sub_sah_mammals_rob$sci_name)

#### same for goats
pdf("../results/focalhumanoverlap1.pdf")

# Convert SpatVector objects to sf objects (if not already converted)
dissolved_highpops_sf <- st_as_sf(dissolved_highpops)  # Ensure it's in sf format
highdens_1_sf <- st_as_sf(highdens_1)  # Ensure it's in sf format

# Ensure both layers have the same CRS (reproject if necessary)
dissolved_highpops_sf <- st_transform(dissolved_highpops_sf, st_crs(highdens_1_sf))

# Plot the result
plot(st_geometry(subsah_ne_rob), col = "khaki", border = "grey40")
plot(st_geometry(dissolved_highpops_sf), col = adjustcolor("red", alpha.f = 0.5), border = "black", add = TRUE)
plot(st_geometry(highdens_1_sf), col = adjustcolor("orange", alpha.f = 0.5), border = "black", add = TRUE)
plot(st_geometry(overlapgoat), add = TRUE, col = "purple", border = "black")

legend(
  "bottomright",
  legend = c("High Human Density (top 5%)", "High Goat Density (>100/km2)", "Overlap Area"),
  fill = c("red", "orange", "purple"),
  border = c("black", "black", "black"),
  title = "Legend",
  bty = "n",
  cex = 0.8 # Adjust text size
)
dev.off()









pdf("../results/goathumananimalbigoverlap4.pdf")

overlapgoatsimp <- st_simplify(overlapgoat, dTolerance = 0.001)
sub_sah_mammals_robsimp <- st_simplify(sub_sah_mammals_rob, dTolerance = 0.001)


# Convert SpatVector objects to sf objects (if not already converted)
dissolved_highpops_sf <- st_as_sf(dissolved_highpops)  # Ensure it's in sf format
highdens_1_sf <- st_as_sf(highdens_1)  # Ensure it's in sf format

# Ensure both layers have the same CRS (reproject if necessary)
dissolved_highpops_sf <- st_transform(dissolved_highpops_sf, st_crs(highdens_1_sf))

# Plot the result
plot(background_mask, col = 'khaki', border = "grey")
plot(st_geometry(dissolved_highpops_sf), col = adjustcolor("red", alpha.f = 0.4), border = "black", add = TRUE)
plot(st_geometry(sub_sah_mammals_robsimp), add = TRUE, col = adjustcolor(species_colors, alpha = 0.35))
plot(st_geometry(highdens_1_sf), col = adjustcolor("orange", alpha.f = 0.4), border = "black", add = TRUE)
plot(st_geometry(overlapgoatsimp), add = TRUE, col = "purple", border = NA)

# plot points
# Find overlap areas
overlapall3 <- st_intersection(sub_sah_mammals_rob, st_geometry(overlapgoat))

# Calculate points within polygons instead of centroids
overlap_pts <- st_point_on_surface(overlapall3)

plot( #points
  st_geometry(overlap_pts), 
  add = TRUE, 
  pch = 24,           # Triangle pointing up
  col = "black",      # Border color
  bg = "#39FF14",     # Fill color (bright green)
  lwd = 2.5,          # Line width for the border
  cex = 1.5           # Size of the triangles
)

# Create a new legend
legend(
  "topright", # Position of the legend
  legend = as.expression(lapply(levels(species_names), function(x) bquote(italic(.(x))))), # Species names,
  col =  adjustcolor(species_palette, alpha.f = 0.35), # Transparent species colors
  pch = rep(15, length(species_palette)), # Squares for species
  pt.bg = adjustcolor(species_palette, alpha.f = 0.35), # Transparent species colors
  cex = 0.8,
  inset = c(0, -2.0),
  bty = "o",       # Draw a box around the legend
  box.col = "black", # Black border color
  bg = "white"
)

legend(
  "bottomright", # Position of the legend
  legend = c("Human density", "Goat density", "Human-goat overlap", "Hotspots"), # Species names,
  col =  c(
            adjustcolor("red", alpha.f = 0.4),
            adjustcolor("orange", alpha.f = 0.4),
            "purple",
            "black"
  ),
  pch = c(rep(15, 3),24), # Squares for species
  pt.bg = c(
            adjustcolor("red", alpha.f = 0.4),
            adjustcolor("orange", alpha.f = 0.4),
            "purple",
            "#39FF14"
  ),
  title = "",
  cex = 0.8,
  bty = "n" # No box around the legend
)


dev.off()