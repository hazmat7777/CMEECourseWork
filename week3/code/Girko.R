## Plotting two dataframes together - Girko's law

build_ellipse <- function(hradius, vradius){ # function that returns an ellipse
    npoints = 250
    a <- seq(0, 2 * pi, length = npoints + 1)
    x <- hradius * cos(a)
    y <- vradius * sin(a)
    return(data.frame(x = x, y = y))
}

N <- 250 # assign size of matrix

M <- matrix(rnorm(N * N), N, N) # build the matrix (250x250)

eigvals <- eigen(M)$values # find the eigenvalues

eigDF <- data.frame("Real" = Re(eigvals), "Imaginary" = Im(eigvals)) # build a dataframe

my_radius <- sqrt(N) # the radius of the circle is sqrt(N)

ellDF <- build_ellipse(my_radius, my_radius) # DF to plot the ellipse

names(ellDF) <- c("Real", "Imaginary") # rename the columns

# plotting the eigenvalues
p <- ggplot(eigDF, aes(x = Real, y = Imaginary))
p <- p +
    geom_point(shape = I(3)) +
    theme(legend.position = "none")

# add vertical and horizontal lin e
p <- p + geom_hline(aes(yintercept = 0))
p <- p + geom_vline(aes(xintercept = 0))

# finally add the ellipse
p <- p + geom_polygon(data = ellDF, aes(x = Real, y = Imaginary, alpha = 1/20, fill = "red"))

pdf("../results/Girko.pdf")
print(p)
dev.off()