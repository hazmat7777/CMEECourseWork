## illustrates how to break out of a loop when some condition is met

i <- 0 #Initialize i
while (i < Inf) {
    if (i == 10) { # Once i gets to 10
        break # break out of the while loop! 
    } else {  
        cat("i equals " , i , " \n")
        i <- i + 1 # Update i
    }
}