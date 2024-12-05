#### Demonstration of preallocation to increase execution speed

### pre-allocation
NoPreallocFun <- function(x) {
    a <- vector() #empty vector
    for (i in 1:x) {
        a <- c(a,i)
    }
}

system.time(NoPreallocFun(10000))
    # 0.037 elapsed

PreallocFun <- function(x) {
    a <- rep(NA, x) #pre-allocated vector- repeats NA x times?
    for (i in 1:x) {
        a[i] <- i #assign
    }
}

system.time(PreallocFun(10000))
    # 0.001 elapsed
    # preallocation decreases execution time!

