## testing the execution speed with vectorisation

M <- matrix(runif(1000000), 1000,1000) #takes 1mil randos (from 0-1) and organises into a matrix w 1000 rows and cols

SumAllElements <- function(M) {
    Dimensions <- dim(M) # creates vector of rows and cols (1000,1000)
    Tot <- 0
    for (i in 1:Dimensions[1]) { # for every row
        for (j in 1:Dimensions[2]) { #and every col
            Tot <- Tot + M[i,j] #accumulate the total
        }
    }
    return (Tot)
}


print("Using loops, the time taken is:")
print(system.time(SumAllElements(M)))

print("Using the in-built vectorised function, the time taken is:")
print(system.time(sum(M)))