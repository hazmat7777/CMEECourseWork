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
dev.off()

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
