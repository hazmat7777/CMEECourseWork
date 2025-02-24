### apply

# function family which can vectorise your code

## build a random matrix
M <- matrix(rnorm(100), 10, 10) #100 randos in 10 row 10 col

## take the mean of each row
RowMeans <- apply(M, 1, mean) # 2nd arg specifies MARGIN over which code is applied- 1 = over rows, 2 = over cols
print (RowMeans)

## now variance
RowVars <- apply(M, 1, var)
print (RowVars)

## by column
ColMeans <- apply(M, 2, mean) #margin = 2 = cols
print (ColMeans)

## can also apply your own functions (not inbuilt ones)

SomeOperation <- function(v) {
    if (sum(v) > 0) { #note that sum(v) is a single (scalar) value
        return (v * 100) #the WHOLE VECTOR multiplied by 100 
    } else {
        return (v)
    }
}

M <- matrix(rnorm(100), 10, 10)
print (apply(M, 1, SomeOperation)) #by row

