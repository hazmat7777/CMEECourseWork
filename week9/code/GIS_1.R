# install packages
install.packages('terra')    # Core raster GIS data package
install.packages('sf')       # Core vector GIS data package
install.packages('raster')   # Older raster GIS package required by some packages
install.packages('geodata')  # Data downloader

install.packages('sp')        # Older vector GIS package - replaced by sf in most cases
install.packages('rgdal')     # Interface to the Geospatial Data Abstraction Library
install.packages('lwgeom')    # Lightweight geometry engine

install.packages('openxlsx')   # Read data from Excel 
install.packages('ggplot2')    # Plotting package
install.packages('gridExtra')  # Extensions to ggplot

# load packages
library(terra)     # core raster GIS package
library(sf)        # core vector GIS package
library(units)     # used for precise unit conversion

library(geodata)   # Download and load functions for core datasets
library(openxlsx)  # Reading data from Excel files

sf_use_s2(FALSE)

### vector data

# create a pop density map for the British Isles
pop_dens <- data.frame(
     n_km2 = c(260, 67,151, 4500, 133), 
     country = c('England','Scotland', 'Wales', 'London', 'Northern Ireland')
)
print(pop_dens)

# Create coordinates  for each country 
    # this creates a matrix of pairs of coordinates forming the edge of the polygon. 
    # note that they have to close: the first and last coordinate must be the same.
scotland <- rbind(c(-5, 58.6), c(-3, 58.6), c(-4, 57.6), 
                  c(-1.5, 57.6), c(-2, 55.8), c(-3, 55), 
                  c(-5, 55), c(-6, 56), c(-5, 58.6))
england <- rbind(c(-2,55.8),c(0.5, 52.8), c(1.6, 52.8), 
                  c(0.7, 50.7), c(-5.7,50), c(-2.7, 51.5), 
                  c(-3, 53.4),c(-3, 55), c(-2,55.8))
wales <- rbind(c(-2.5, 51.3), c(-5.3,51.8), c(-4.5, 53.4),
                  c(-2.8, 53.4),  c(-2.5, 51.3))
ireland <- rbind(c(-10,51.5), c(-10, 54.2), c(-7.5, 55.3),
                  c(-5.9, 55.3), c(-5.9, 52.2), c(-10,51.5))

# Convert these coordinates into feature geometries
    # these are simple coordinate sets with no projection information
scotland <- st_polygon(list(scotland)) #sf function to make polygon
england <- st_polygon(list(england))
wales <- st_polygon(list(wales))
ireland <- st_polygon(list(ireland))

# Combine geometries into a simple feature column
uk_eire_sfc <- st_sfc(wales, england, scotland, ireland, crs=4326)
plot(uk_eire_sfc, asp=1)

# create point locations for capital cities
uk_eire_capitals <- data.frame(
     long= c(-0.1, -3.2, -3.2, -6.0, -6.25),
     lat=c(51.5, 51.5, 55.8, 54.6, 53.30),
     name=c('London', 'Cardiff', 'Edinburgh', 'Belfast', 'Dublin')
)

# Indicate which fields in the data frame contain the coordinates
uk_eire_capitals <- st_as_sf(uk_eire_capitals, coords=c('long','lat'), crs=4326)
print(uk_eire_capitals)

## vector geometry operations

# set London as anywhere within a 1/4 degree from st pauls cathedral
st_pauls <- st_point(x=c(-0.098056, 51.513611))
london <- st_buffer(st_pauls, 0.25) # circle

# remove Lon from england polygon
england_no_london <- st_difference(england, london)

# lengths() shows no. components in a polygon and no. pts per component
lengths(scotland) # 1 component, 18 pts
lengths(england_no_london) # 2 rings. 18 external, 242 internal

# tidy up wales
wales <- st_difference(wales, england)

# A rough polygon that includes Northern Ireland and surrounding sea.
    # note the alternative way of providing the coordinates
ni_area <- st_polygon(list(cbind(x=c(-8.1, -6, -5, -6, -8.1), y=c(54.4, 56, 55, 54, 54.4))))

northern_ireland <- st_intersection(ireland, ni_area) # overlap
eire <- st_difference(ireland, ni_area) # ROI

# Combine the final geometries
uk_eire_sfc <- st_sfc(wales, england_no_london, scotland, london, northern_ireland, eire, crs=4326) # crs- coordinate reference system

## features and geometries

# compare six Polygon features with one Multipolygon feature
print(uk_eire_sfc)

# make the UK into a single feature
uk_country <- st_union(uk_eire_sfc[-6]) # merges them
print(uk_country)

# plot them
par(mfrow=c(1, 2), mar=c(3,3,1,1))
plot(uk_eire_sfc, asp=1, col=rainbow(6))
plot(st_geometry(uk_eire_capitals), add=TRUE)
plot(uk_country, asp=1, col='lightblue')

## vector data and attributes
uk_eire_sf <- st_sf(name=c('Wales', 'England','Scotland', 'London', 
                        'Northern Ireland', 'Eire'),
                    geometry=uk_eire_sfc) #  sf = spatial data frame

print(uk_eire_sf)

# plot by name
plot(uk_eire_sf['name'], asp=1)

# add attributes to sf
uk_eire_sf$capital <- c('Cardiff', 'London', 'Edinburgh', 
                        NA, 'Belfast','Dublin')
print(uk_eire_sf)

# less error prone technique for ^- use merge()
uk_eire_sf <- merge(uk_eire_sf, pop_dens, by.x='name', by.y = 'country', all.x=TRUE)
print(uk_eire_sf)

## spatial attributes

# finding centroids
uk_eire_centroids <- st_centroid(uk_eire_sf)
st_coordinates(uk_eire_centroids)

# area
uk_eire_sf$area <- st_area(uk_eire_sf)

# To calculate a 'length' of a polygon, you have to convert it to a LINESTRING or a MULTILINESTRING. Using MULTILINESTRING will automatically include all perimeter of a polygon (including holes).
uk_eire_sf$length <- st_length(st_cast(uk_eire_sf, 'MULTILINESTRING'))
    # st_cast() geometries from one type to another

# Look at the result
print(uk_eire_sf)

# You can change units in a neat way
uk_eire_sf$area <- set_units(uk_eire_sf$area, 'km^2')
uk_eire_sf$length <- set_units(uk_eire_sf$length, 'km')
print(uk_eire_sf)

# And it won't let you make silly error like turning a length into weight
uk_eire_sf$area <- set_units(uk_eire_sf$area, 'kg')

# Or you can simply convert the `units` version to simple numbers
uk_eire_sf$length <- as.numeric(uk_eire_sf$length)

# closest distance between geometries:
st_distance(uk_eire_sf)

st_distance(uk_eire_centroids)

## plotting sf objects

# plotting by density
plot(uk_eire_sf['n_km2'], asp=1, logz=TRUE, key.pos=4) # log scale with key on the right

## reprojecting vector data

# reprojection- transforming data from one set of coords to another
# currently using 4236 which is code for WGS24
# can convert from geographic coord system (degrees) to projected coord system (linear units)

# reproject onto British National Grid (ESPG:27700)
uk_eire_BNG <- st_transform(uk_eire_sf, 27700)

# UTM50N (EPSG:32650)
uk_eire_UTM50N <- st_transform(uk_eire_sf, 32650)

# The bounding boxes of the data shows the change in units
st_bbox(uk_eire_sf) # degrees
st_bbox(uk_eire_BNG) # m

# Plot the results
par(mfrow=c(1, 3), mar=c(3,3,1,1))
plot(st_geometry(uk_eire_sf), asp=1, axes=TRUE, main='WGS 84')
plot(st_geometry(uk_eire_BNG), axes=TRUE, main='OSGB 1936 / BNG')
plot(st_geometry(uk_eire_UTM50N), axes=TRUE, main='UTM 50N') # unsuitable for UK

# note BNG buffered London is distorted
# because as lines of long converge towards a pole, the physical length of a degree decreases

# At London's latitude, a degree longitude is 69km

# Set up some points separated by 1 degree latitude and longitude from St. Pauls
st_pauls <- st_sfc(st_pauls, crs=4326)
one_deg_west_pt <- st_sfc(st_pauls - c(1, 0), crs=4326) # near Goring
one_deg_north_pt <-  st_sfc(st_pauls + c(0, 1), crs=4326) # near Peterborough

# Calculate the distance between St Pauls and each point
st_distance(st_pauls, one_deg_west_pt)
st_distance(st_pauls, one_deg_north_pt)

st_distance(st_transform(st_pauls, 27700), 
            st_transform(one_deg_west_pt, 27700))

## redoing London as a 25km buffer around st pauls

# transform St Pauls to BNG and buffer using 25 km
london_bng <- st_buffer(st_transform(st_pauls, 27700), 25000)

# In one line, transform england to BNG and cut out London
england_not_london_bng <- st_difference(st_transform(st_sfc(england, crs=4326), 27700), london_bng)

# project the other features and combine everything together
others_bng <- st_transform(st_sfc(eire, northern_ireland, scotland, wales, crs=4326), 27700)

corrected <- c(others_bng, london_bng, england_not_london_bng)

# Plot that and marvel at the nice circular feature around London
par(mar=c(3,3,1,1))
plot(corrected, main='25km radius London', axes=TRUE)

### Rasters

# Create an empty raster object covering UK and Eire
uk_raster_WGS84 <- rast(xmin=-11,  xmax=2,  ymin=49.5, ymax=59, 
                        res=0.5, crs="EPSG:4326")
hasValues(uk_raster_WGS84) # empty

# Add data to the raster - just use the cell numbers
values(uk_raster_WGS84) <- cells(uk_raster_WGS84)
print(uk_raster_WGS84) # 494 cells

plot(uk_raster_WGS84) # diff colours for diff latitudes (?)
plot(st_geometry(uk_eire_sf), add=TRUE, border = 'black', lwd = 2, col = '#FFFFFF44') # note ADD = TRUE

## changing raster resolution

# Define a simple 4 x 4 square raster
m <- matrix(c(1, 1, 3, 3,
              1, 2, 4, 3,
              5, 5, 7, 8,
              6, 6, 7, 7), ncol=4, byrow=TRUE)
square <- rast(m)

plot(square, legend=NULL)
text(square, digits=2)

# Average values
square_agg_mean <- aggregate(square, fact=2, fun=mean) # factor- aggregate blocks of 2x2 cells
plot(square_agg_mean, legend=NULL)
text(square_agg_mean, digits=2)

 # Maximum values
square_agg_max <- aggregate(square, fact=2, fun=max)
plot(square_agg_max, legend=NULL)
text(square_agg_max, digits=2)

# Modal values for categories
square_agg_modal <- aggregate(square, fact=2, fun='modal')
plot(square_agg_modal, legend=NULL)
text(square_agg_modal, digits=2)

## disaggregating rasters

# factor- square root of number of cells to create from each parent cell

# Simply duplicate the nearest parent value
square_disagg <- disagg(square, fact=2, method='near') 
plot(square_disagg, legend=NULL)
text(square_disagg, digits=2)

# Use bilinear interpolation (not for categorical variables)
square_interp <- disagg(square, fact=2, method='bilinear')
plot(square_interp, legend=NULL)
text(square_interp, digits=1)

## (resampling not covered here = aligning raster datasets with the same projection but different origins and resolutions)

## reprojecting a raster

# make two simple `sfc` objects containing points in  the lower left and top right of the two grids
uk_pts_WGS84 <- st_sfc(st_point(c(-11, 49.5)), st_point(c(2, 59)), crs=4326)
uk_pts_BNG <- st_sfc(st_point(c(-2e5, 0)), st_point(c(7e5, 1e6)), crs=27700)

#  Use st_make_grid to quickly create a polygon grid with the right cellsize
uk_grid_WGS84 <- st_make_grid(uk_pts_WGS84, cellsize=0.5) # 0.5 degree cells
uk_grid_BNG <- st_make_grid(uk_pts_BNG, cellsize=1e5) # 1000km cells

# Reproject BNG grid into WGS84
uk_grid_BNG_as_WGS84 <- st_transform(uk_grid_BNG, 4326)

# Plot the features. Everything is in WGS84
par(mar=c(0,0,0,0))
plot(uk_grid_WGS84, asp=1, border='grey', xlim=c(-13,4))
plot(st_geometry(uk_eire_sf), add=TRUE, border='darkgreen', lwd=2)
plot(uk_grid_BNG_as_WGS84, border='red', add=TRUE) # overlay reprojected BNG grid

# Create the target raster- a reference for reprojecting uk_raster_WGS84 to align it with the BNG
uk_raster_BNG <- rast(xmin=-200000, xmax=700000, ymin=0, ymax=1000000, res=100000, crs='+init=EPSG:27700') #BNG 

# reproject the rasters to match CRS and resolution of target raster
uk_raster_BNG_interp <- project(uk_raster_WGS84, uk_raster_BNG, method='bilinear')
uk_raster_BNG_near <- project(uk_raster_WGS84, uk_raster_BNG, method='near')

# plotting BNG rasters reprojected with 2 methods
par(mfrow=c(1,2), mar=c(0,0,0,0))
plot(uk_raster_BNG_interp, main='Interpolated', axes=FALSE, legend=FALSE)
text(uk_raster_BNG_interp, digit=1)
plot(uk_raster_BNG_near, main='Nearest Neighbour',axes=FALSE, legend=FALSE)
text(uk_raster_BNG_near)

### copnverting between vector and raster data types

## vector to raster = rasterising

# Create the target raster 
uk_20km <- rast(xmin=-200000, xmax=650000, ymin=0, ymax=1000000, 
                res=20000, crs='+init=EPSG:27700')

# Rasterizing polygons
uk_eire_poly_20km  <- rasterize(uk_eire_BNG, uk_20km, field='name')

plot(uk_eire_poly_20km)

    # telling sf that attributes of the original geometry apply to the altered geometries
    uk_eire_BNG$name <- as.factor(uk_eire_BNG$name)
    st_agr(uk_eire_BNG) <- 'constant'

# Rasterizing lines.
uk_eire_BNG_line <- st_cast(uk_eire_BNG, 'LINESTRING')
uk_eire_line_20km <- rasterize(uk_eire_BNG_line, uk_20km, field='name')

plot(uk_eire_line_20km)

# Rasterizing points 
    # This isn't quite as neat as there are two steps in the casting process:
    # Polygon -> Multipoint -> Point
uk_eire_BNG_point <- st_cast(st_cast(uk_eire_BNG, 'MULTIPOINT'), 'POINT')
uk_eire_point_20km <- rasterize(uk_eire_BNG_point, uk_20km, field='name')

plot(uk_eire_point_20km)

# Plotting those different outcomes
    # Use the hcl.colors function to create a nice plotting palette
color_palette <- hcl.colors(6, palette='viridis', alpha=0.5)

# Plot each raster
par(mfrow=c(1,3), mar=c(1,1,1,1))
plot(uk_eire_poly_20km, col=color_palette, legend=FALSE, axes=FALSE)
plot(st_geometry(uk_eire_BNG), add=TRUE, border='red')

plot(uk_eire_line_20km, col=color_palette, legend=FALSE, axes=FALSE)
plot(st_geometry(uk_eire_BNG), add=TRUE, border='red')

plot(uk_eire_point_20km, col=color_palette, legend=FALSE, axes=FALSE)
plot(st_geometry(uk_eire_BNG), add=TRUE, border='red')

## raster to vector

# dissolved polygons- cell w identical values -> larger polygons

# Get a set of dissolved polygons (the default) including NA cells
poly_from_rast <- as.polygons(uk_eire_poly_20km, na.rm=FALSE)

# Get individual cells (no dissolving)
cells_from_rast <- as.polygons(uk_eire_poly_20km, dissolve=FALSE)

# Get individual points
points_from_rast <- as.points(uk_eire_poly_20km)

print(st_as_sf(poly_from_rast)) # 6 rows

print(st_as_sf(cells_from_rast)) # 817 rows

print(st_as_sf(points_from_rast))

# Plot the outputs - using key.pos=NULL to suppress the key
par(mfrow=c(1,3), mar=c(1,1,1,1))
plot(poly_from_rast, key.pos = NULL)
plot(cells_from_rast, key.pos = NULL)
plot(points_from_rast, key.pos = NULL, pch=4)

### Using data in files

## saving vector data

# as shapefiles = most common
st_write(uk_eire_sf, '../data/uk/uk_eire_WGS84.shp')
st_write(uk_eire_BNG, '../data/uk/uk_eire_BNG.shp')

# as geojson or gropackage
st_write(uk_eire_sf, '../data/uk/uk_eire_WGS84.geojson')
st_write(uk_eire_sf, '../data/uk/uk_eire_WGS84.gpkg')

## saving raster data

# as geoTIFF = most common
writeRaster(uk_raster_BNG_interp, '../data/uk/uk_raster_BNG_interp.tif')

# As ASCII format file: human readable text. 
    # Note that this format also creates also aux.xml and .prj
writeRaster(uk_raster_BNG_near, '../data/uk/uk_raster_BNG_ngb.asc', filetype='AAIGrid')

## loading vector data

# Load a vector shapefile
ne_110 <- st_read('../data/ne_110m_admin_0_countries/ne_110m_admin_0_countries.shp')

# Also load some WHO data on 2016 life expectancy
# see: http://apps.who.int/gho/athena/api/GHO/WHOSIS_000001?filter=YEAR:2016;SEX:BTSX&format=csv
life_exp <- read.csv(file = "../data/WHOSIS_000001.csv")

### plotting global GDP and 2016 life expectancy on a world map

# view data
str(ne_110)
str(life_exp)

## GDP vs country
plot(ne_110['GDP_MD'],  asp=1, main='Global GDP', logz=TRUE, key.pos=4)

## life expectancy vs country

# merge life exp with GIS data
life_exp_countries <- merge(x = ne_110, y = life_exp, by.x = 'ISO_A3_EH', by.y = 'COUNTRY', all.x = TRUE)

# make plot
plot(life_exp_countries['Numeric'], asp = 1, main = "Global 2016 LE", key.pos = 4, pal = hcl.colors, breaks = seq(50,85, by = 2.5))

## loading XY vector data

# i.e. a table with coordinates in it
    # long and lat, or X,Y

# Read in Southern Ocean example data
so_data <- read.csv('../data/Southern_Ocean.csv', header=TRUE)

# Convert the data frame to an sf object
so_data <- st_as_sf(so_data, coords=c('long', 'lat'), crs=4326)
print(so_data)

## Loading Raster data

# load data
etopo_25 <- rast('../data/etopo_25.tif')

# Look at the data content
print(etopo_25)
    # 0.25 degree resoln
    # topography data- note min and max

# Plot it 
plot(etopo_25, plg=list(ext=c(190, 210, -90, 90))) # plg = plot legend

## changing colour scheme

# Define a sequence of 65 breakpoints along an elevation gradient from -10 km to 6 km.
breaks <- seq(-10000, 6000, by=250)
    # There are 64 intervals between these breaks and each interval will be assigned a colour

land_pal<- colorRampPalette(colors = c("tan", "green")) # returns a fn that spits out n of those colours
land_cols <- land_pal(24) # need 24 land colors as top 24/64 is above sea level

sea_pal <- colorRampPalette(c('darkslateblue', 'steelblue', 'paleturquoise'))
sea_cols <- sea_pal(40)

# Plot the raster providing the breaks and combining the two colour sequences to give 64 colours that switch from sea to land colour schems at 0m.
plot(etopo_25, axes=FALSE, breaks=breaks,
     col=c(sea_cols, land_cols), type='continuous',
     plg=list(ext=c(190, 200, -90, 90))
)

# ^ shitty colours I made myself, use a readymade palette
land_cols  <- terrain.colors(24)
plot(etopo_25, axes=FALSE, breaks=breaks,
     col=c(sea_cols, land_cols), type='continuous',
     plg=list(ext=c(190, 200, -90, 90))
)

## Raster stacks

# stacks of info for each cell in grid

# Download bioclim data: global maximum temperature at 10 arc minute resolution
tmax <- worldclim_global(var='tmax', res=10, path='../data')
# The data has 12 layers, one for each month
print(tmax)

# Extract  January and July data and the annual maximum by location.
tmax_jan <- tmax[[1]]
tmax_jul <- tmax[[7]]
tmax_max <- max(tmax)

# plot those maps
par(mfrow=c(2,2), mar=c(2,2,1,1))
bks <- seq(-50, 50, length=101)
pal <- colorRampPalette(c('lightblue','grey', 'firebrick'))
cols <- pal(100)
plg <- list(ext=c(190, 200, -90, 90))

plot(tmax_jan, col=cols, breaks=bks, 
     main='January maximum temperature', type='continuous', plg=plg)
plot(tmax_jul, col=cols, breaks=bks, 
     main='July maximum temperature', type='continuous', plg=plg)
plot(tmax_max, col=cols, breaks=bks, 
     main='Annual maximum temperature', type='continuous', plg=plg)


### Overlaying raster and vector data

## cropping data

# if you are only interested in a subset of the area in a GIS sf
so_extent <- ext(-60,-20,-65,-45)
    # southern ocean

# The crop function for raster data...
so_topo <- crop(etopo_25, so_extent)

# ... and the st_crop function for vector data
ne_10 <- st_read('../data/ne_10m_admin_0_countries/ne_10m_admin_0_countries.shp')
st_agr(ne_10) <- 'constant'
so_ne_10 <- st_crop(ne_10, so_extent)

## plotting Southern Ocean chlorophyll

# plot underlying searfloor
breaks = seq(-7700, 1500, by = 100)
length(breaks)
pallete_bw <- gray.colors(n = 100)
plot(so_topo, breaks = breaks, col = pallete_bw, type = 'continuous')

# add contours
contour(so_topo, levels = c(-2000, -4000, -6000), add = TRUE, col = 'grey80')

# add the land
plot(st_geometry(so_ne_10), add = TRUE, col = 'khaki', border = 'grey40')

# show sampling sites
plot(st_geometry(so_data), add=TRUE, pch=4, cex=2, col='white', lwd=3)

### Spatial joins and raster data extraction

# spatially merge data into an sf object

# extract africa from ne_110 data and keep certain cols
set.seed(1)
africa <- subset(ne_110, CONTINENT=='Africa', select=c('ADMIN', 'POP_EST'))

# transform to the Robinson projection
africa <- st_transform(africa, crs='ESRI:54030')

# create a random sample of points
mosquito_points <- st_sample(africa, 1000)

# Create the plot
plot(st_geometry(africa), col='khaki')
plot(mosquito_points, col='firebrick', add=TRUE)

# turning mosquitopoints into a full sf dataframe so it can have attributes and we can add countryname ontp points
mosquito_points <- st_sf(mosquito_points)
mosquito_points <- st_join(mosquito_points, africa['ADMIN'])

plot(st_geometry(africa), col='khaki')

# Add points coloured by country
plot(mosquito_points['ADMIN'], add=TRUE)

# aggregate points within countries
mosquito_points_agg <- aggregate(
     mosquito_points, 
     by=list(country=mosquito_points$ADMIN), FUN=length
)
names(mosquito_points_agg)[2] <-'n_outbreaks' # rename 2nd col
print(mosquito_points_agg)

# Merge the number of outbreaks back onto the sf data
africa <- st_join(africa, mosquito_points_agg)
africa$area <- as.numeric(st_area(africa))
print(africa)

# Plot the results
par(mfrow=c(1,2), mar=c(3,3,1,1), mgp=c(2,1, 0))
plot(n_outbreaks ~ POP_EST, data=africa, log='xy', 
     ylab='Number of outbreaks', xlab='Population size')
plot(n_outbreaks ~ area, data=africa, log='xy',
     ylab='Number of outbreaks', xlab='Area (m2)')

## Alien invasion

# Load the data and convert to a sf object
alien_xy <- read.csv('../data/aliens.csv')
alien_xy <- st_as_sf(alien_xy, coords=c('long','lat'), crs=4326)

# Add country information and find the total number of aliens per country
alien_xy <- st_join(alien_xy, ne_110['ADMIN'])
aliens_by_country <- aggregate(n_aliens ~ ADMIN, data=alien_xy, FUN=sum)

# Add the alien counts into the country data 
ne_110 <- merge(ne_110, aliens_by_country, all.x=TRUE)
ne_110$people_per_alien <- with(ne_110,  POP_EST / n_aliens )

# Find which countries are in danger
ne_110$in_danger <- ne_110$people_per_alien < 1000

# Plot the danger map
plot(ne_110['in_danger'], pal=c('grey', 'red'), key.pos=4)

## extracting data from Rasters

# getting some elevation data
uk_eire_etopo <- rast('../data/uk/etopo_uk.tif')

# ignore bathymetry, just land
uk_eire_detail <- subset(ne_10, ADMIN %in% c('United Kingdom', "Ireland"))
uk_eire_detail_raster <- rasterize(uk_eire_detail, uk_eire_etopo)
uk_eire_elev <- mask(uk_eire_etopo, uk_eire_detail_raster)

par(mfrow=c(1,2), mar=c(3,3,1,1), mgp=c(2,1,0))
plot(uk_eire_etopo, plg=list(ext=c(3,4, 50, 59)))
plot(uk_eire_elev, plg=list(ext=c(3,4, 50, 59)))
plot(st_geometry(uk_eire_detail), add=TRUE, border='grey')

## raster cell statistics and locations

# global() allows you to find summary stats of data in a raster

uk_eire_elev >= 1195
global(uk_eire_elev, max, na.rm = TRUE)
global(uk_eire_elev, quantile, na.rm=TRUE)

# Which is the highest cell
where.max(uk_eire_elev)

# Which cells are above 1100m
high_points <- where.max(uk_eire_elev >= 1100, value=FALSE)
xyFromCell(uk_eire_elev, high_points[,2])

## plotting highest point and areas below sea level
max_cell <- where.max(uk_eire_elev)
max_xy <- xyFromCell(uk_eire_elev, max_cell[2])
max_sfc<- st_sfc(st_point(max_xy), crs=4326)

bsl_cell <- where.max(uk_eire_elev < 0, values=FALSE)
bsl_xy <- xyFromCell(uk_eire_elev, bsl_cell[,2])
bsl_sfc <- st_sfc(st_multipoint(bsl_xy), crs=4326)

plot(uk_eire_elev)
plot(max_sfc, add=TRUE, pch=24, bg='red')
plot(bsl_sfc, add=TRUE, pch=25, bg='lightblue', cex=0.6)

## extract function makes it easier to get at raster data

# extract(x,y): x = raster source of data, y = points/lines/polygons
uk_eire_capitals$elev <- extract(uk_eire_elev, uk_eire_capitals, ID=FALSE)
print(uk_eire_capitals)
    # elev values in etopo_uk, idk why

    class(uk_eire_capitals)
    class(uk_eire_elev)

# with polygons
etopo_by_country <- extract(uk_eire_elev, uk_eire_sf['name']) # returns df of all the elevs in each country
head(etopo_by_country)

# summary stats
aggregate(etopo_uk ~ ID, data=etopo_by_country, FUN='mean', na.rm=TRUE)

# or use zonal()
zones <- rasterize(st_transform(uk_eire_sf, 4326), uk_eire_elev, field='name')
etopo_by_country <- zonal(uk_eire_elev, zones, fun='mean', na.rm=TRUE)

print(etopo_by_country)

### extracting values under linestrings: elevation transect along pennine way

# view data
st_layers('../data/uk/National_Trails_Pennine_Way.gpx') # diff GIS datasets in a single source (feature of GPX files)

# load the data, showing how to use SQL queries to load subsets of the data
pennine_way <- st_read('../data/uk/National_Trails_Pennine_Way.gpx',
                      query="select * from routes where name='Pennine Way'")

# reproject data
pennine_way_BNG <- st_transform(pennine_way, crs = 27700)

# create target raster and project elev data onto it
bng_2km <- rast(xmin=-200000, xmax=700000, ymin=0, ymax=1000000, 
                res=2000, crs='EPSG:27700') # 2km resoln
uk_eire_elev_BNG <- project(uk_eire_elev, bng_2km, method='cubic')

# Simplify the data (as its too detailed for this exercise)
pennine_way_BNG_simple <- st_simplify(pennine_way_BNG,  dTolerance=100)

# Zoom in to the whole route and plot the data
par(mfrow=c(1,2), mar=c(1,1,1,1))

plot(uk_eire_elev_BNG, xlim=c(3e5, 5e5), ylim=c(3.8e5, 6.3e5),
     axes=FALSE, legend=FALSE)
plot(st_geometry(pennine_way_BNG), add=TRUE, col='black')
plot(st_geometry(pennine_way_BNG_simple), add=TRUE, col='darkred')

# Add a zoom box and use that to create a new plot
zoom <- ext(3.78e5, 3.84e5, 4.72e5, 4.80e5)
plot(zoom, add=TRUE, border='red')

# Zoomed in plot
plot(uk_eire_elev_BNG, ext=zoom, axes=FALSE, legend=FALSE)
plot(st_geometry(pennine_way_BNG), add=TRUE, col='black')
plot(st_geometry(pennine_way_BNG_simple), add=TRUE, col='darkred')

## finding elevations, cell IDs and XY coords of cells on the route

# Extract the elev data
pennine_way_trans <-  extract(uk_eire_elev_BNG, pennine_way_BNG_simple, xy=TRUE, ID = FALSE)
head(pennine_way_trans) 

# Now we can use Pythagoras to find the distance along the transect
pennine_way_trans$dx <- c(0, diff(pennine_way_trans$x)) # diff between consecutive x coords
pennine_way_trans$dy <- c(0, diff(pennine_way_trans$y))
pennine_way_trans$distance_from_last <- with(pennine_way_trans, sqrt(dx^2 + dy^2))
pennine_way_trans$distance <- cumsum(pennine_way_trans$distance_from_last) / 1000

# plot elevation profile
plot( etopo_uk ~ distance, data=pennine_way_trans, type='l', 
     ylab='Elevation (m)', xlab='Distance (km)')

#### Mini projects

## total annual precipitation transexct for New Guinea

# load
library(terra)     # core raster GIS package
library(sf)        # core vector GIS package
library(units)     # used for precise unit conversion

library(geodata)   # Download and load functions for core datasets
library(openxlsx)  # Reading data from Excel files

library(geodata) # for worldclim_tile function

sf_use_s2(FALSE)


# WGS84 transect 
transect_long <- c(132.3, 135.2, 146.4, 149.3)
transect_lat <- c(-1, -3.9, -7.7, -9.8)

# convert transect into a vector line
transect_coords <- cbind(transect_long, transect_lat)
transect <- vect(transect_coords, type = "lines", crs = "EPSG:4326")

# get precipitation data for new guinea
ng_prec <- worldclim_tile(var='prec', res=0.5, lon=140, lat=-10, path='data') # this tile covers a big area- see below
ext(ng_prec) # a 30 x 30 square

# Reduce to the extent of New Guinea - crop early to avoid unnecessary processing!
ng_extent <- ext(130, 150, -10, 0) # a 20 x 10 rectangle
ng_prec <- crop(ng_prec, ng_extent)

# find annual prec
ng_annual_prec <- sum(ng_prec)
ng_annual_prec # per tile

# reproject onto UTM 54S
ng_extent_poly <- st_as_sfc(st_bbox(ng_extent, crs=4326))
ng_extent_utm <- ext(-732000, 1506000, 8874000, 10000000)

# create the target raster and reproject the data
ng_template_utm <- rast(ng_extent_utm, res=1000, crs="+init=EPSG:32754") # target raster
ng_annual_prec_utm <- project(ng_annual_prec, ng_template_utm)

# Create and reproject the transect and then segmentize it to 1000m
transect <-  st_linestring(cbind(x=transect_long, y=transect_lat))
transect <- st_sfc(transect, crs=4326)
transect_utm <- st_transform(transect, crs=32754)
transect_utm <- st_segmentize(transect_utm, dfMaxLength=1000)# dfMaxLength- max segment length = 1km. Means there are enough sampling points and approximates curved edges

# Extract the transect data
transect_data <- extract(ng_annual_prec_utm, st_sf(transect_utm), xy=TRUE)

# Now we can use Pythagoras to find the distance along the transect
transect_data$dx <- c(0, diff(transect_data$x))
transect_data$dy <- c(0, diff(transect_data$y))
transect_data$distance_from_last <- with(transect_data, sqrt(dx^2 + dy^2))
transect_data$distance <- cumsum(transect_data$distance_from_last) / 1000

# Get the natural earth high resolution coastline.
ne_10_ng  <- st_crop(ne_10, ng_extent_poly)
ne_10_ng_utm <-  st_transform(ne_10_ng, crs=32754)

# plot
par(mfrow=c(2,1), mar=c(3,3,1,1), mgp=c(2,1,0))

plot(ng_annual_prec_utm, plg=list(ext=c(1700000, 1800000, 8950000, 9950000)))
    # numbers are where the legend box will be positioned, in utm coords
plot(st_geometry(ne_10_ng_utm), add=TRUE, col=NA, border='grey50') # high res coastline
plot(transect_utm, add=TRUE) # transect

par(mar=c(3,3,1,1))
plot( sum ~ distance, data=transect_data, type='l', 
     ylab='Annual precipitation (mm)', xlab='Distance (km)')

### fishing pressure in fiji

# cost distance analysis
    # use a raster to define cost surface:
    # moving between cells has a cost defined by a raster value

# Download the GADM data for Fiji, convert to sf and then extract Kadavu
fiji <- gadm(country='FJI', level=2, path='../data/fiji') # gadm() from geodata package downloads boundary data
fiji <- st_as_sf(fiji)
kadavu <- subset(fiji, NAME_2 == 'Kadavu')

# Load the villages and sites and convert to sf
villages <- readWorkbook('../data/fiji/FishingPressure.xlsx', 'Villages')
villages <- st_as_sf(villages, coords=c('long','lat'), crs=4326)
sites <- readWorkbook('../data/fiji/FishingPressure.xlsx', 'Field sites', startRow=3)
sites <- st_as_sf(sites, coords=c('Long','Lat'), crs=4326)

# Reproject the data UTM60S
kadavu <- st_transform(kadavu, 32760)
villages <- st_transform(villages, 32760)
sites <- st_transform(sites, 32760)

# Map to check everything look right.
plot(st_geometry(sites), axes=TRUE, col='blue', pch=4)
plot(st_geometry(villages), add=TRUE, col='red')
plot(st_geometry(kadavu), add=TRUE)

## create cost surface- uniform cost of moving through sea, infinite cost (NA) of moving over land

# Create a template raster covering the whole study area, at a given resolution
res <- 100
r <- rast(xmin=590000, xmax=670000, ymin=7870000, ymax=7940000, crs='EPSG:32760', res=res)

# Rasterize the island as a POLYGON to get cells that cannot be traversed
kadavu_poly <- rasterize(kadavu, r, field=1, background=0)

# Rasterize the main island as a MULTILINESTRING to get the coastal 
# cells that _can_ be traversed
coast <- st_cast(kadavu, 'MULTILINESTRING')
kadavu_lines <- rasterize(coast, r, field=1, background=0)

# Combine those to give cells that are in the sea (kadavu_poly=0) or 
# on the coast (kadavu_lines=1)
sea_r <- (! kadavu_poly) | kadavu_lines

# Set the costs
sea_r[sea_r == 0] <- NA
sea_r[! is.na(sea_r)] <- 1

# Plot the map and then zoom in to show that the coastal cells can
# be travelled through
par(mfrow=c(1,2), mar=c(2,2,1,1))
plot(sea_r, col='lightblue')
zoom <- ext(599000, 602000, 7884000, 7887000)
plot(zoom, add=TRUE)

plot(sea_r, ext=zoom, col='lightblue')
plot(st_geometry(kadavu), add=TRUE)

# Find the nearest points on the coast to each village (as some are on land)
village_coast <- st_nearest_points(villages, coast)

# Extract the end point on the coast and convert from MULTIPOINT to POINT
launch_points <- st_line_sample(village_coast, sample=1)
launch_points <- st_cast(launch_points, 'POINT')

# Zoom in to a bay on Kadavu
par(mar=c(0,0,0,0))
plot(st_geometry(kadavu), xlim=c(616000, 618000), ylim=c(7889000, 7891000), col='khaki')

# Plot the villages, lines to the nearest coast and the launch points.
plot(st_geometry(villages), add=TRUE, col='firebrick', lwd=2)
plot(village_coast, add=TRUE, col='black')
plot(launch_points, add=TRUE, col='darkgreen', lwd=2)

# add to our villages object
villages$launch_points <- launch_points
st_geometry(villages) <- 'launch_points'

## find distances

# example:
r <- rast(xmin=0, ymin=0, xmax=50, ymax=50, res=10, crs='EPSG:32760')

    # Set cell values:
    values(r) <- 1  # Set all cells to be non-NA
    r[3,3] <- 0     # This is a target cell
    r[4,4] <- NA    # Set one NA cell

    # Calculate and plot distances
    d <- gridDist(r)
    plot(d, legend=NULL)
    text(d, digits=1)

# scaling up to give example for a single site
    # Make a copy of the sea map
    dist <- sea_r # sea_r was the cells on the coast or not on the land

    # Find the location of a site and make that the target
    site_idx <- 49
    village_cell <- cellFromXY(dist, st_coordinates(villages[site_idx,]))
    dist[village_cell] <- 0

    # Now we can calculate the cost distance for each launch point to each site...
    costs <- gridDist(dist)

    plot(costs, plg=list(ext=c(672000, 674000, 7870000, 7940000)))
    plot(st_geometry(villages[site_idx,]), add=TRUE, pch=4)
    plot(st_geometry(sites), add=TRUE)

    # And grab the costs at each fishing site
    distances_to_site <- extract(costs, sites)
    print(distances_to_site)

    # and find the smallest distance
    nearest_site <- which.min(distances_to_site$layer)

## put that process in a loop to find nearest site for each village

# Create fields to hold the nearest fishing site data
villages$nearest_site_index <- NA
villages$nearest_site_name <- NA

# Loop over the sites
for (site_idx in seq(nrow(villages))) {

    # Make a copy of the sea map
    dist <- sea_r

    # Find the location of a site and make that the target
    village_cell <- cellFromXY(dist, st_coordinates(villages[site_idx,]))
    dist[village_cell] <- 0

    # Now we can calculate the cost distance for each launch point to each site...
    costs <- gridDist(dist)
    
    # And find the nearest site
    distances_to_site <- extract(costs, sites)
    nearest_site <- which.min(distances_to_site$layer)
    
    # Find the index and name of the lowest distance in each row
    villages$nearest_site_index[site_idx] <- nearest_site
    villages$nearest_site_name[site_idx] <- sites$Name[nearest_site]

}

## Find the total number of buildings  per site and merge that data into the sites object
site_load <- aggregate(building_count ~ nearest_site_name, data=villages, FUN=sum)
sites_with_load <- merge(sites, site_load, by.x='Name', by.y='nearest_site_name', all.x=TRUE)

# Now build up a complex plot
par(mar=c(0,0,0,0))
plot(st_geometry(kadavu))

# add the villages, colouring by nearest site and showing the village 
# size using the symbol size (cex)
plot(villages['nearest_site_name'], add=TRUE, pch=20, cex=log10(villages$building_count))

# Add the sites
plot(st_geometry(sites_with_load), add=TRUE, col='red', pch=4, lwd=4)

print(sites_with_load)


#### Using ggplot to make maps

# simple eg
library(ggplot2)
ggplot(ne_110) +
       geom_sf() +
       theme_bw()

# bad example
europe <- st_crop(ne_110, ext(-10,40,35,75))
ggplot(europe) +
       geom_sf(aes(fill=GDP_MD)) +
       scale_fill_viridis_c() +
       theme_bw() + 
       geom_sf_text(aes(label = ADMIN), colour = "white")
    # poor data scale
    # produces warnings about lat/log data
    # how to make a projected map with better labels

## european life expectancy

# Calculate the extent in the LAEA projection of the cropped data
europe_crop_laea <- st_transform(europe, 3035)

# Reproject all of the country data and _then_ crop to the previous extent
europe_laea <- st_transform(ne_110, 3035)
europe_laea <- st_crop(europe_laea, europe_crop_laea)

# Plot the two maps
p1 <- ggplot(europe_crop_laea) +
       geom_sf(aes(fill=log(GDP_MD))) +
       scale_fill_viridis_c() +
       theme_bw() + 
       theme(legend.position="bottom") +
       geom_sf_text(aes(label = ADM0_A3), colour = "grey20")

p2 <- ggplot(europe_laea) +
       geom_sf(aes(fill=log(GDP_MD))) +
       coord_sf(expand=FALSE) +
       scale_fill_viridis_c() +
       theme_bw() + 
       theme(legend.position="bottom") +
       geom_sf_text(aes(label = ADM0_A3), colour = "grey20")

library(gridExtra)
grid.arrange(p1, p2, ncol=2)

### colour palettes

# rainbow, heat, terrain.colors, topo.colors, cm.colors

# hcl.colors()

# viridis

# brewer:
library(RColorBrewer)
display.brewer.all()

display.brewer.all(colorblindFriendly = TRUE)