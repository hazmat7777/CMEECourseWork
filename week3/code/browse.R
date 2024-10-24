Exponential <- function(N0 = 1, r = 1, generations = 10) {
    #runs a simulation of exponential growth
    # returns a vector of length 'generations' (here 10)
    N <- rep(NA, generations) #creates a vector of NA (*10?)
    
    N[1] <- N0
    for (t in 2:generations) {
        N[t] <- N[t-1] * exp(r)
        browser()
    }
    return (N)
}

plot (Exponential(), type = "l", main = "Exponential growth")

