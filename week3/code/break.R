## illustrates how to break out of a loop when some condition is met

i <- 0 #Initialize i
    while (i < Inf) {
        if (i == 10) {
            break 
        } else { # Break out of the while loop!  
            cat("i equals " , i , " \n")
            i <- i + 1 # Update i
    }
}