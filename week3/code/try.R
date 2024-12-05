# function to find the mean of a sample of x
doit <- function(x) { 
    temp_x <- sample(x, replace = TRUE) # by default sample size will be the number of elements in x (here = 50)
    if(length(unique(temp_x)) > 30) {# only take mean if sample is sufficient
        print(paste("Mean of this sample was:", as.character(mean(temp_x))))
        }
    else {
        stop("Couldn't calculate mean: too few unique values!")
    }
}

# using apply without try
set.seed(1345) # to get the same result
popn <- rnorm(50)
hist(popn)
lapply(1:15, function(i) doit(popn)) # applies the doit function 15 times to popn
    # error- there weren't 30 unique values. Then it stops

# Using try
result <- lapply(1:15, function(i) try(doit(popn), FALSE))
    # no error this time because the FALSE modifier for try suppresses any error messages
class(result) # lapply always creates a list
result # long output

# can also store results manually using a loop
result <- vector("list", 15) # preallocate
for(i in 1:15) {
    result[[i]] <- try(doit(popn), FALSE)
}

# tryCatch() as an alternative to try()
result <- lapply(1:15, function(i) {
  tryCatch(
    {
      # Attempt to run doit(popn)
      doit(popn)
    },
    error = function(e) {
      # Handle the error if it occurs and return the error message or some other value
      return(paste("Error in iteration", i, ": ", e$message))
    }
  )
})

