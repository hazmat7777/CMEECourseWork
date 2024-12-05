# This function calculates heights of trees given distance of each tree 
# from its base and angle to its top, using  the trigonometric formula 
#
# height = distance * tan(radians)
#
# ARGUMENTS
# degrees:   The angle of elevation of tree
# distance:  The distance from base of tree (e.g., meters)
#
# OUTPUT
# The heights of the tree, same units as "distance"

# housekeeping
rm(list=ls())

# loading data
TreeData <- read.csv("../data/trees.csv", header = TRUE) #import w headers
str(TreeData)

# function
TreeHeight <- function(degrees, distance) {
    radians <- degrees * pi / 180
    height <- distance * tan(radians)
    print(paste("Tree height is:", height))

    return (height)
}

# example use of function
TreeHeight(37, 40) # test the function works

# adding treeheight as a new column
TreeData$Tree.Height.m <- mapply(FUN = TreeHeight, # multiple apply
    degrees = TreeData[,3], distance = TreeData[,2])

# writing output file to results
write.csv(TreeData, "../results/TreeHts.csv")
