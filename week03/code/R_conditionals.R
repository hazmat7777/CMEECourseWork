## conditional functions

#Checks if an itneger is even
is.even <- function(n = 2) {
    if (n %% 2 == 0) {
        return(paste(n,'is even!'))
    } else {
        return(paste(n,'is odd!'))
    }
    } # get to grips with the curly brackets

is.even(6)

# checks if a number is a power of 2
is.power2 <- function(n = 2) {
    if (log2(n) %% 1==0) {                          #if log2 n is a whole number
        return(paste(n, 'is a power of 2!'))
    } else {
        return(paste(n,'is not a power of 2!'))
        }
    }

is.power2(4)

# Checks if a number is prime
is.prime <- function(n) {
    if (n==0) {
        return(paste(n,'is a zero!'))
    } else if (n==1) {
        return(paste(n,'is just a unit!'))
    }

    ints <- 2:(n-1)

    if (all(n%%ints!=0)) {
        return(paste(n,'is a prime!'))
    } else {
        return(paste(n,'is a composite!'))
        }
}

print(is.even(6))
print(is.power2(4))
print(is.prime(17))
