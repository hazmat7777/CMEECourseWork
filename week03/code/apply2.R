# function multiplies vectors with positive sums by 100, but not vectors with negative sums
SomeOperation <- function(v) {
  if (sum(v) > 0) { # sum(v) is a single (scalar) value
    return (v * 100)
  } else { 
  return (v)
    }
}

set.seed(123)
M <- matrix(rnorm(100), 10, 10) # 100 random numbers from z normal distribution in 10*10 matrix
print(M) # view matrix before applying the function
print (apply(M, 1, SomeOperation)) # 1: applies the function row-wise, 2 for column-wise