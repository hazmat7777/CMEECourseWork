### Functions

## A function to take a sample of size n from a pop "popn" and return its mean
myexperiment <- function(popn, n) {
    pop_sample <- sample(popn, n, replace = FALSE)
    return(mean(pop_sample))
}

## calculate means using a for loop on a vector without preallocation:
loopy_sample1 <- function(popn, n, num) { #num is how many means you need to calc
    result1 <- vector() #initialise empty vector of size 1
    for(i in 1:num) {
        result1 <- c(result1,myexperiment(popn, n)) #growing vector of means
    }
    return(result1)
}

## to run "num" iterations of the mean using a FOR loop on a vector with preallocation
loopy_sample2 <- function(popn, n, num) {
    result2 <- vector(,num) #preallocate expected size # first arg is empty so defaults to numeric 
    # length is num
    for(i in 1:num) {
        result2[i] <- myexperiment(popn, n) #remember this takes the mean of a sample
    }
    return(result2)
}

## to run "num" iterations of the expt using a FOR loop on a list with preallocation:
loopy_sample3 <- function(popn, n, num) {
    result3 <- vector("list", num) #its a list type vector (ordered, hetero, flexible length)
    for(i in 1:num) {
        result3[[i]] <- myexperiment(popn, n) #in a list you access elements using [[]] double sq brs
    }
}

## to run "num" iterations of the experiment with lapply:
lapply_sample <- function(popn, n, num) {
    result4 <- lapply(1:num, function(i) myexperiment(popn, n))
    return(result4)
}

# lapply applies a fucntion to each element of a list/vector
# returns results as a list

## to run "num" iterations of the experiment using vectorisation with sapply:
sapply_sample <- function(popn, n, num) {
    result5 <- sapply(1:num, function(i) myexperiment(popn, n))
    return(result5)
}
# sapply applies a function to each element of a list/vector and SIMPLIFIES the result
# return value is a vector or matrix rather than a list


### Generating a sample

set.seed(12345)
popn <- rnorm(10000) # gen the pop
hist(popn)

n <- 100 #sample size for each expt
num <- 10000 # num of times to rerun the expt

print("Using loops without preallocation on a vector took" )
print(system.time(loopy_sample1(popn, n, num)))

print("Using loops with preallocation on a vector took:" )
print(system.time(loopy_sample2(popn, n, num)))

print("Using loops with preallocation on a list took:" )
print(system.time(loopy_sample3(popn, n, num)))

print("Using the vectorized sapply function (on a list) took:" )
print(system.time(sapply_sample(popn, n, num)))

print("Using the vectorized lapply function (on a list) took:" )
print(system.time(lapply_sample(popn, n, num)))######## Functions #########

## A function to take a sample of size n from a pop "popn" and return its mean
myexperiment <- function(popn, n) {
    pop_sample <- sample(popn, n, replace = FALSE)
    return(mean(pop_sample))
}

## calculate means using a for loop on a vector without preallocation:
loopy_sample1 <- function(popn, n, num) { #num is how many means you need to calc
    result1 <- vector() #initialise empty vector of size 1
    for(i in 1:num) {
        result1 <- c(result1,myexperiment(popn, n)) #growing vector of means
    }
    return(result1)
}

## to run "num" iterations of the mean using a FOR loop on a vector with preallocation
loopy_sample2 <- function(popn, n, num) {
    result2 <- vector(,num) #preallocate expected size # first arg is empty so defaults to numeric # length is num
    for(i in 1:num) {
        result2[i] <- myexperiment(popn, n) #remember this takes the mean of a sample
    }
    return(result2)
}

## to run "num" iterations of the expt using a FOR loop on a list with preallocation:
loopy_sample3 <- function(popn, n, num) {
    result3 <- vector("list", num) #its a list type vector (ordered, hetero, flexible length)
    for(i in 1:num) {
        result3[[i]] <- myexperiment(popn, n) #in a list you access elements using [[]] double sq brs
    }
    return(result3)
}

## to run "num" iterations of the experiment with lapply:
lapply_sample <- function(popn, n, num) {
    result4 <- lapply(1:num, function(i) myexperiment(popn, n))
    return(result4)
}

# lapply applies a fucntion to each element of a list/vector
# returns results as a list

## to run "num" iterations of the experiment using vectorisation with sapply:
sapply_sample <- function(popn, n, num) {
    result5 <- sapply(1:num, function(i) myexperiment(popn, n))
    return(result5)
}
# sapply applies a function to each element of a list/vector and SIMPLIFIES the result
# return value is a vector or matrix rather than a list


### Generating a pop

set.seed(12345)
popn <- rnorm(10000) # gen the pop
hist(popn)

n <- 100 #sample size for each expt
num <- 10000 # num of times to rerun the expt

print("Using loops without preallocation on a vector took" )
print(system.time(loopy_sample1(popn, n, num)))

print("Using loops with preallocation on a vector took:" )
print(system.time(loopy_sample2(popn, n, num)))

print("Using loops with preallocation on a list took:" )
print(system.time(loopy_sample3(popn, n, num)))
    # preallocation increases execution speed

print("Using the vectorized sapply function (on a list) took:" )
print(system.time(sapply_sample(popn, n, num)))

print("Using the vectorized lapply function (on a list) took:" )
print(system.time(lapply_sample(popn, n, num)))
    # vectorization increases execution speed