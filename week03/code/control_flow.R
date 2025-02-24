# demonstrates the use of 'if' statements, 
#'for' loops, 'while' loops, 'next', 
# and 'break' control  structures in R

## If statements
a <- TRUE
if (a == TRUE) {
    print ("a is TRUE")
} else {
    print ("a is FALSE")
}

z <- runif(1) ## generate a z-uniformly distributed random no
if (z <= 0.5) {print ("Less than a half")} # can squeeze on one line but less readable

#better:
z <- runif(1)
if (z <= 0.5) {
    print ("Less than a half")
   }

## for loops
for (i in 1:10) { #same as seq(10)
    j <- i * i 
    print(paste(i, "squared is", j ))
}

# can loop over a vector of strings:
for(species in c('Heliodoxa rubinoides', #notice that for in r needs brackets
                 'Boissonneaua jardini', 
                 'Sula nebouxii')) {
      print(paste('The species is', species))
} # on separate lines for readability

v1 <- c("a", "bc", "def")
for (i in v1) { # for needs brackets in r
    print(i)
}

## while loops
i <- 0
while (i < 10) {
    i <- i+1
    print(i^2)
}

## breaking out of loops
i <- 0 #initialise i
    while (i < Inf) {
        if (i ==10) {
            break #break out of the while loop!
        } else { 
            cat("i equals ", i, "\n")
            i <- i + 1 #update i
    }
}

## using next
for (i in 1:10) {
    if ((i%% 2) == 0) #check if no is even
        next # pass to next iteration of loop (skip the evens)
    print(i)
}