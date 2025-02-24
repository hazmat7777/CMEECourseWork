################################################################
################## Wrangling the Pound Hill Dataset ############
################################################################

############# Load the dataset ###############
# header = false because the raw data don't have real headers
MyData <- as.matrix(read.csv("../data/PoundHillData.csv", header = FALSE))

# header = true because we do have metadata headers
MyMetaData <- read.csv("../data/PoundHillMetaData.csv", header = TRUE, sep = ";")

############# Inspect the dataset ###############
head(MyData)
dim(MyData) #45 rows and 60 columns (??) (see fix below)
str(MyData) #structure: 45 rows, 60 cols, character type, preview of first few entries
            #the  object has "dimnames" attributes with 2 components
                #first (rownames) is NULL
                #second (colnames) is a character vector (V1, V2..)
fix(MyData) #you can also do this- it's really good
fix(MyMetaData)

############# Transpose ###############
# To get those species into columns and treatments into rows 
MyData <- t(MyData) # t for transpose
                    # means swapping rows and columns
fix (MyData)
head(MyData)
dim(MyData)

############# Replace species absences with zeros ###############
MyData[MyData == ""] = 0

############# Convert raw matrix to data frame ###############

TempData <- as.data.frame(MyData[-1,],stringsAsFactors = F) #stringsAsFactors = F is important! 
                                #excludes first row
colnames(TempData) <- MyData[1,] # assign column names from original data

fix(TempData)

############# Convert from wide to long format  ###############
require(reshape2) # load the reshape2 package

?melt #check out the melt function

#this will put all species into a SINGLE column (wide to long format)
MyWrangledData <- melt(TempData, id=c("Cultivation", "Block", "Plot", "Quadrat"), variable.name = "Species", value.name = "Count")
                                #identifier variables that should remain as cols
                                                                                # defines the name of the new col that will hold the names of the og cols
fix(MyWrangledData)                                                                                                            #name of new col containing values from melted cols

MyWrangledData[, "Cultivation"] <- as.factor(MyWrangledData[, "Cultivation"])
MyWrangledData[, "Block"] <- as.factor(MyWrangledData[, "Block"])
MyWrangledData[, "Plot"] <- as.factor(MyWrangledData[, "Plot"])
MyWrangledData[, "Quadrat"] <- as.factor(MyWrangledData[, "Quadrat"])
MyWrangledData[, "Count"] <- as.integer(MyWrangledData[, "Count"])

str(MyWrangledData)
head(MyWrangledData)
dim(MyWrangledData)

############# Exploring the data (extend the script below)  ###############

require(tidyverse)

tidyverse_packages(include_self = TRUE)

MyWrangledData <- dplyr::as_tibble(MyWrangledData) # double colons say where the command comes from. Here is not necessary- could do MyWrangledData <- as_tibble(MyWrangledData) 
class(MyWrangledData)
#tibble is equiv to dataframe in R- modified to make data exploration more robust
#good idea to convert- see link in notes

glimpse(MyWrangledData) #like str() but nicer

utils::View(MyWrangledData) #same as fix()

filter(MyWrangledData, Count>100) #like subset() but nicer

slice(MyWrangledData, 10:15) #look at a particular range of rows

#using pipe operators %>% 

MyWrangledData %>% 
    group_by(Species) %>% 
        summarise(avg = mean(Count))

#the same as doing this in base R
aggregate(MyWrangledData$Count, list(MyWrangledData$Species), FUN=mean)
    #maybe less intuitive

#### Data Visualisation

### Data exploration with basic plotting

# see basic plotting commands in R 

MyDF <- read.csv("../data/EcolArchives-E089-51-D1.csv")
dim(MyDF)
str(MyDF)
head(MyDF)
require(tidyverse)
glimpse(MyDF)

#converting some columns to factors to use them as grouping variables
MyDF$Type.of.feeding.interaction <- as.factor(MyDF$Type.of.feeding.interaction)
MyDF$Location <- as.factor(MyDF$Location)
str(MyDF) #note the new Factors

## scatter plots

plot(MyDF$Predator.mass,MyDF$Prey.mass)

#try using logs
    #because body sizes across species tend to be log-normally distributed 
        #(the logs are normally distributed)
        #i.e. there are lots of small species and few large ones
        #now can inspect body size range in a meaningful scale
plot(log(MyDF$Predator.mass), log(MyDF$Prey.mass)) #default log is ln (natural log, e)

#same again with base 10
plot(log10(MyDF$Predator.mass), log10(MyDF$Prey.mass))
    #useful because you can see things in terms of orders of magnitude (10, 100, 1000 etc)

plot(log10(MyDF$Predator.mass), log10(MyDF$Prey.mass), pch = 20) #change the plot characters pch to a different marker

plot(log10(MyDF$Predator.mass), log10(MyDF$Prey.mass), pch=20, xlab = "Predator Mass (g)", ylab = "Prey Mass (g)") 

## Histograms

hist(MyDF$Predator.mass)

hist(log10(MyDF$Predator.mass), xlab = "log10(Predator Mass (g))", ylab = "Count")

hist(log10(MyDF$Predator.mass), xlab = "log10(Predator Mass (g))", ylab = "Count", col = "Lightblue", border = "pink") # see bookmarks for more on formatting in r

hist(log10(MyDF$Prey.mass), xlab = "log10(Prey Mass (g))", ylab = "Count")

?hist
breakpred <- seq(floor(min(log10(MyDF$Predator.mass))), ceiling(max(log10(MyDF$Predator.mass))), by = 0.5) #setting the bins to have equal width. what is wrong with this?
hist(log10(MyDF$Predator.mass), breaks = breakpred, 
    xlab = "log10(Predator Mass (g))", 
    ylab = "Count",
    main = "Histogram of Log10 Predator Mass")

#setting bins of equal width- make a vector of breakpoints
breakprey <- seq(floor(min(log10(MyDF$Prey.mass))), #floor rounds down
                ceiling(max(log10(MyDF$Prey.mass))), #ceiling rounds up
                by = 0.5) 
                

hist(log10(MyDF$Prey.mass), breaks = breakprey, 
    xlab = "log10(Prey Mass (g))", 
    ylab = "Count",
    main = "Histogram of Log10 Prey Mass")


## subplots

par(mfcol=c(2,1)) # initialise multi-paneled plot
par(mfg = c(1,1)) # specify which subplot to use first
hist(log10(MyDF$Predator.mass),
    xlab = "log10(Predator Mass (g))", ylab = "Count", col = "Lightblue",
    main = "Predator")
par(mg = c(2,1)) #second subplot
hist(log10(MyDF$Prey.mass), xlab="log10(Prey Mass (g))", ylab = "Count", 
    col = "Lightgreen", main = "Prey")

dev.off()
graphics.off()

par(mfcol=c(2,1)) #initialize multi-paneled plot. a vector of (rows,cols)
par(mfg = c(1,1)) # specify which sub-plot to use first 
hist(log10(MyDF$Predator.mass),
    xlab = "log10(Predator Mass (g))", ylab = "Count", col = "lightblue", border = "pink", 
    main = 'Predator') # Add title
par(mfg = c(2,1)) # Second sub-plot
hist(log10(MyDF$Prey.mass), xlab="log10(Prey Mass (g))",ylab="Count", col = "lightgreen", border = "pink", main = 'prey')


#also see layout function

#want to overlay the two plots

hist(log10(MyDF$Predator.mass), # pred histogram
    xlab="log10(Body Mass (g))", ylab = "Count",
    col = rgb(1, 0, 0, 0.5), #red, 4th value is transparency
    main = "Predator-Prey Size Overlap")
hist(log10(MyDF$Prey.mass), col = rgb(0, 0, 1, 0.5), add = T) #ADDS to the old plot
legend('topleft',c('Predators', 'Prey'),
    fill=c(rgb(1, 0, 0, 0.5), rgb(0, 0, 1, 0.5)))

#trying to use my breaks from before

hist(log10(MyDF$Predator.mass), # pred histogram
    xlab="log10(Body Mass (g))", ylab = "Count",
    col = rgb(1, 0, 0, 0.5), #red, 4th value is transparency
    main = "Predator-Prey Size Overlap", 
    breaks = breakpred)
hist(log10(MyDF$Prey.mass), col = rgb(0, 0, 1, 0.5), add = T, breaks = breakprey) #ADDS to the old plot
legend('topleft',c('Predators', 'Prey'),
    fill=c(rgb(1, 0, 0, 0.5), rgb(0, 0, 1, 0.5)))

#it worked!

## Boxplots
graphics.off()

boxplot(log10(MyDF$Predator.mass), xlab = "Location", ylab = "Log10(Predator Mass)", main = "Predator mass")

boxplot(log(MyDF$Predator.mass) ~ MyDF$Location, #why the tilde? it means BY
    xlab = "Location", ylab = "Predator Mass", 
    main = "Predator mass by location")

boxplot(log(MyDF$Predator.mass) ~ MyDF$Type.of.feeding.interaction,
    xlab = "Location", ylab = "Predator Mass",
    main = "Predator mass by feeding interaction type")

## combining plot types

#how to see pred and prey distributions as well as the scatterplot
#for exploring purposes

par(fig=c(0,0.8,0,0.8)) # specify figure size as a proportion
                        # bottom left is (0,0), top right is (1,1)
                        #sets up scatterplot from 0-0.8 on x and 0-0.8 on y
plot(log(MyDF$Predator.mass), log(MyDF$Prey.mass), xlab = "Predator Mass (g)", ylab = "Prey Mass (g)") # scatter w labels
par(fig=c(0,0.8,0.5,1),new=TRUE)
                        #next plot (pred boxplot will go from 0-0.8 on x, 0.5-1 on y)
boxplot(log(MyDF$Predator.mass), horizontal = TRUE, axes = FALSE)
par(fig=c(0.6,1,0,0.8),new = TRUE)
boxplot(log(MyDF$Prey.mass), axes = FALSE)

## saving your graphics

pdf("../results/Pred_Prey_Overlay.pdf", #open blank pdf 
    11.7, 8.3) #page dims in inches
hist(log(MyDF$Predator.mass),
    xlab = "Body Mass (g)", ylab = "Count", col = rgb(1,0,0,0.5),
    main = "Predator-Prey Size Overlap")
hist(log(MyDF$Prey.mass),
    col = rgb(0, 0, 1, 0.5),
    add = T)
legend('topleft', c('Predators', 'Prey'),
    fill=c(rgb(1,0,0,0.5), rgb(0,0,1,0.5)))
graphics.off();

### Beautiful graphics in R- ggplot2

require(ggplot2)

## qplot to quickly make graphics

qplot(Prey.mass, Predator.mass, data = MyDF)

# taking logarithms

qplot(log10(Prey.mass), log(Predator.mass), data = MyDF)

# colour points by feeding interaction

qplot(log(Prey.mass), log(Predator.mass), data =  MyDF, colour = Type.of.feeding.interaction)

# changing aspect ratio using asp option

qplot(log(Prey.mass), log(Predator.mass), data =  MyDF, colour = Type.of.feeding.interaction, asp = 1)

## aesthetic mappings

qplot(log(Prey.mass), log(Predator.mass),
    data = MyDF, colour = "red") # variable is mapped automatically to a colour
# ggplot mapping converted it to a particular shade of red

# use I() (for identity) to set it manually to the real red 
qplot(log(Prey.mass), log(Predator.mass), data = MyDF, colour = I("red"))

# see same comparison for point size:
qplot(log(Prey.mass), log(Predator.mass), data = MyDF, size = 3) # with ggplot size mapping
qplot(log(Prey.mass), log(Predator.mass), data = MyDF, size = I(3)) # no mapping

# for shape there is no mapping (as shapes are discrete)
qplot(log(Prey.mass), log(Predator.mass), data = MyDF, shape = 3) # gives an error
qplot(log(Prey.mass), log(Predator.mass), data = MyDF, shape = I(3)) # gives an error

## setting transparency

# see overlap by using alpha to make points semi transparent
qplot(log(Prey.mass), log(Predator.mass), data = MyDF, colour = Type.of.feeding.interaction, alpha = I(.5)) # using I() tells ggplot this is a constant value and not an aesthetic mapping
qplot(log(Prey.mass), log(Predator.mass), data = MyDF, colour = Type.of.feeding.interaction, alpha = .5) # wrong- indicates transparency level applied to all points- wrong here

## adding smoothers and regression lines

# smoother
qplot(log(Prey.mass), log(Predator.mass), data = MyDF, geom = c("point", "smooth"))

# having linear regression
qplot(log(Prey.mass), log(Predator.mass), data = MyDF, geom = c("point", "smooth")) + geom_smooth(method = "lm")

# adding a smoother for each type of interaction
qplot(log(Prey.mass), log(Predator.mass), data = MyDF, geom = c("point", "smooth"),
    colour = Type.of.feeding.interaction) + geom_smooth(method = "lm")

# ^ extending lines to full range
qplot(log(Prey.mass), log(Predator.mass), data = MyDF, geom = c("point", "smooth"),
    colour = Type.of.feeding.interaction) + geom_smooth(method = "lm", fullrange = TRUE)

# ratio of pred/prey masses VS interaction type
qplot(Type.of.feeding.interaction, log(Prey.mass/Predator.mass), data = MyDF)

# adding jitter to get a better idea of spread of points (as there are too many)
qplot(Type.of.feeding.interaction, log(Prey.mass/Predator.mass), data = MyDF, geom = "jitter")

## Boxplots 

#of the above using geom(etry) argument
qplot(Type.of.feeding.interaction, log(Prey.mass/Predator.mass), data = MyDF, geom = "boxplot")

## Histograms

qplot(log(Prey.mass/Predator.mass), data = MyDF, geom =  "histogram")

# colour by interaction
qplot(log(Prey.mass/Predator.mass), data = MyDF, geom = "histogram",
    fill = Type.of.feeding.interaction)

# setting bin widths (in units of the x axis)
qplot(log(Prey.mass/Predator.mass), data = MyDF, geom = "histogram", 
    fill = Type.of.feeding.interaction, binwidth = 1)

# smoothed density of the data for ease of reading
qplot(log(Prey.mass/Predator.mass), data = MyDF, geom =  "density", 
      fill = Type.of.feeding.interaction)

# transparency to see overlaps
qplot(log(Prey.mass/Predator.mass), data = MyDF, geom = "density",
    fill = Type.of.feeding.interaction, alpha = I(0.5))

# using colour not fill draws on the edge of the curve
qplot(log(Prey.mass/Predator.mass), data = MyDF, geom =  "density", 
      colour = Type.of.feeding.interaction)

## multi-faceted plots

# faceting- create multiple plots based on the levels of a categorical variable
qplot(log(Prey.mass/Predator.mass), facets = Type.of.feeding.interaction ~., #note the tilda dot
    data = MyDF, geom = "density")
    # ~ separates the response variable (left) from the explanatory variables (right)
    # dot (.) afterwards indicaes there are no explanatory variables

# swapping . and Type means ggplot will use by-column config
qplot(log(Prey.mass/Predator.mass), facets = .~ Type.of.feeding.interaction, #note the tilda dot
    data = MyDF, geom = "density")

## log axes

# another way to plot data in the log scale
qplot(Prey.mass, Predator.mass, data = MyDF, log="xy")

## plot annotations

# adding a title and labels
qplot(Prey.mass, Predator.mass, data = MyDF, log="xy",
    main = "Relation between predator and prey mass", 
    xlab = "log(Prey mass) (g)", 
    ylab = "log(Predator mass) (g)")

# bw theme for bw printing
qplot(Prey.mass, Predator.mass, data = MyDF, log="xy",
    main = "Relation between predator and prey mass", 
    xlab = "Prey mass (g)", 
    ylab = "Predator mass (g)") + theme_bw()

## saving plots as a pdf

pdf("../results/MyFirst-ggplot2-Figure.pdf")
print(qplot(Prey.mass, Predator.mass, data = MyDF, log="xy", # print necessary to create the output in the pdf
    main = "Relation between predator and prey mass",        # and ensures whole command is kept together
    xlab = "Prey mass (g)", 
    ylab = "Predator mass (g)") + theme_bw())
dev.off() # closes the pdf device, finalising and saving the file

## the geom argument

# specifies the objects that define the graph type

#load the data
MyDF <- as.data.frame(read.csv("../data/EcolArchives-E089-51-D1.csv"))

# barplot
qplot(Predator.lifestage, data = MyDF, geom = "bar")

# boxplot
qplot(Predator.lifestage, log(Prey.mass), data = MyDF, geom = "boxplot")

# violin plot
qplot(Predator.lifestage, log(Prey.mass), data = MyDF, geom = "violin")

# density
qplot(log(Predator.mass), data = MyDF, geom = "density")

# histogram
qplot(log(Predator.mass), data = MyDF, geom = "histogram")

# scatterplot
qplot(log(Predator.mass), log(Prey.mass), data = MyDF, geom = "point")

# smooth line
qplot(log(Predator.mass), log(Prey.mass), data = MyDF, geom = "smooth") # what is grey bit at start?

# linear
qplot(log(Predator.mass), log(Prey.mass), data = MyDF, geom = "smooth", method = "lm")

### advanced plotting - ggplot

# qplot - only one dataset and a single set of aesthetics
# with ggplot command we can layer:
    # add additional data elements to a plot
    # can come from different datasets with different aesthetic mappings

# using ggplot we need
    # the data in a dataframe
    # aesthetics mappings
    # geom
    # (optional) some stat that transforms data / does stats on them

# starting graph - specify data and aesthetics
p <- ggplot(MyDF, aes(x = log(Predator.mass),
                      y = log(Prey.mass),
                      colour = Type.of.feeding.interaction))

# trying to plot graph:
p # no geom yet set
p + geom_point()

# can use + to concatenate commands
p <- ggplot(MyDF, aes(x = log(Predator.mass), 
                      y = log(Prey.mass), 
                      colour = Type.of.feeding.interaction))
q <- p + geom_point(size = I(2), shape = I(10)) + 
    theme_bw() + # make the background white
    theme(aspect.ratio = 1) # make the plot square
q

# removing legend
q + theme(legend.position = "none")

# density
p <- ggplot(MyDF, aes(x = log(Prey.mass / Predator.mass), 
                      fill = Type.of.feeding.interaction)) + 
    geom_density()
p

# transparency
p <- ggplot(MyDF, aes(x = log(Prey.mass / Predator.mass), 
                      fill = Type.of.feeding.interaction)) + 
    geom_density(alpha = 0.5)
p

## multifaceted
p <- ggplot(MyDF, aes(x = log(Prey.mass / Predator.mass), 
                      fill = Type.of.feeding.interaction)) +
    geom_density() +
    facet_wrap(. ~ Type.of.feeding.interaction) +
    theme(legend.position = "none") # YOU CANNOT PUT PLUSSES AT THE START OF LINES
p

# allowing data-specific axis limits
p <- ggplot(MyDF, aes(x = log(Prey.mass / Predator.mass), 
                      fill = Type.of.feeding.interaction)) +  
    geom_density() + 
    facet_wrap(. ~ Type.of.feeding.interaction, scales = "free")
p

# plotting size-ratio distributions by location
p <- ggplot(MyDF, aes(x = log(Prey.mass / Predator.mass))) +  
    geom_density() + 
    facet_wrap(. ~ Location, scales = "free")
p

# pred size vs prey size, scatter, by location 
p <- ggplot(MyDF, aes(x = log(Prey.mass), 
                      y = log(Predator.mass))) +  
    geom_point() + 
    facet_wrap(. ~ Location, scales = "free")
p

# same thing BUT ALSO BY FEEDING INTERACTION
p <- ggplot(MyDF, aes(x = log(Prey.mass), 
                      y = log(Predator.mass))) +  
    geom_point() + 
    facet_wrap(. ~ Location + Type.of.feeding.interaction, scales = "free")
p # BIG plot

# changing the order
p <- ggplot(MyDF, aes(x = log(Prey.mass), 
                      y = log(Predator.mass))) +  
    geom_point() + 
    facet_wrap(. ~ Type.of.feeding.interaction + Location, scales = "free")
p

### Useful ggplot examples

require(reshape2)

# function to make a matrix
GenerateMatrix <- function(N) {
    M <- matrix(runif(N * N), N, N) # generates matrix with N * N random numbers and organizes them into an NxN matrix
    return(M)
}

# making a DF
M <- GenerateMatrix(10) # 10 by 10 matrix with 10 randos
Melt <- melt(M) # converts matrix to a long form data frame

Melt # note DF has three columns - Var1 (row), Var2 (col), and value (the rando)

# tile plot
p <- ggplot(Melt, aes(Var1, Var2, fill = value)) +
    geom_tile() +
    theme(aspect.ratio = 1) # square
p

# add a black line dividing cells
p + geom_tile(colour = "black")

# no legend
p + theme(legend.position = "none")

# remove everything else
p + theme(legend.position = "none", 
          panel.background = element_blank(),
          axis.ticks = element_blank(), 
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          axis.text.x = element_blank(),
          axis.title.x = element_blank(),
          axis.text.y = element_blank(),
          axis.title.y = element_blank())

# changing colours
p + scale_fill_continuous(low = "yellow", high = "darkgreen")
p + scale_fill_gradient2()
p + scale_fill_gradientn(colours = grey.colors(10))
p + scale_fill_gradientn(colours = rainbow(10))
p + scale_fill_gradientn(colours = c("red", "white", "blue"))

# interactive graphs??
# plotly package

## Plotting two dataframes together - Girko's law

build_ellipse <- function(hradius, vradius) { # function that returns an ellipse
    npoints = 250
    a <- seq(0, 2 * pi, length = npoints + 1)
    x <- hradius * cos(a)
    y <- vradius * sin(a)
    return(data.frame(x = x, y = y))
}

N <- 250 # assign size of matrix

M <- matrix(rnorm(N * N), N, N) # build the matrix (250x250)

eigvals <- eigen(M)$values # find the eigenvalues

eigDF <- data.frame("Real" = Re(eigvals), "Imaginary" = Im(eigvals)) # build a dataframe

my_radius <- sqrt(N) # the radius of the circle is sqrt(N)

ellDF <- build_ellipse(my_radius, my_radius) # DF to plot the ellipse

names(ellDF) <- c("Real", "Imaginary") # rename the columns

# plotting the eigenvalues
p <- ggplot(eigDF, aes(x = Real, y = Imaginary))
p <- p +
    geom_point(shape = I(3)) +
    theme(legend.position = "none")

# add vertical and horizontal line
p <- p + geom_hline(aes(yintercept = 0))
p <- p + geom_vline(aes(xintercept = 0))

# finally add the ellipse
p <- p + geom_polygon(data = ellDF, aes(x = Real, y = Imaginary, alpha = 1/20, fill = "red"))
p

### Annotating plots
require(tidyverse)

a <- read.table("../data/Results.txt", header = TRUE)

head(a)

a$ymin <- rep(0, dim(a)[1]) # append a column of zeros

# Print the first linerange
p <- ggplot(a)
p <- p + geom_linerange(data = a, aes(
    x = x,
    ymin = ymin,
    ymax = y1,
    linewidth = (0.5)
),
colour = "#E69F00",
alpha = 1/2, show.legend = FALSE)

# Print the second linerange
p <- p + geom_linerange(data = a, aes(
    x = x,
    ymin = ymin,
    ymax = y2,
    linewidth = (0.5)
),
colour = "#56B4E9",
alpha = 1/2, show.legend = FALSE)

# Print the third linerange
p <- p + geom_linerange(data = a, aes(
    x = x,
    ymin = ymin,
    ymax = y3,
    size = (0.5)
),
colour = "#D55E00",
alpha = 1/2, show.legend = FALSE)

# Annotate the plot with labels
p <- p + geom_text(data = a, aes(x = x, y = -500, label = Label))

# now set the axis labels, remove the legend, and prepare for bw printing
p <- p + scale_x_continuous("My x axis",
                             breaks = seq(3, 5, by = 0.05)) + 
                             scale_y_continuous("My y axis") + 
                             theme_bw() + 
                             theme(legend.position = "none")
p

### Mathematical display
x <- seq(0, 100, by = 0.1)
y <- -4. + 0.25 * x +
    rnorm(length(x), mean = 0., sd = 2.5) # randos

# put them in a df
my_data <- data.frame(x = x, y = y)

head(my_data)

# perform a linear regression
my_lm <- summary(lm(y ~ x, data = my_data))

my_lm # understanding this summary is key to understanding the rest of the code

# plot the data
p <- ggplot(my_data, aes(x = x, y = y,
                          colour = abs(my_lm$residual))) +
    geom_point() +
    scale_colour_gradient(low = "black", high = "red") +
    theme(legend.position = "none") +
    scale_x_continuous(expression(alpha^2 * pi / beta * sqrt(Theta)))

# add the regression line
p <- p + geom_abline(
    intercept = my_lm$coefficients[1][1],
    slope = my_lm$coefficients[2][1],
    colour = "red")

# throw some math on the plot
p <- p + geom_text(aes(x = 60, y = 0,
                       label = "sqrt(alpha) * 2* pi"), 
                       parse = TRUE, size = 6, 
                       colour = "blue")

p

## ggthemes package

install.packages("ggthemes")

library(ggthemes)

p <- ggplot(MyDF, aes(x = log(Predator.mass), y = log(Prey.mass),
                colour = Type.of.feeding.interaction )) +
                geom_point(size=I(2), shape=I(10)) + theme_bw()
p

p + geom_rangeframe() + # now fine tune the geom to Tufte's range frame
        theme_tufte() # and theme to Tufte's minimal ink theme