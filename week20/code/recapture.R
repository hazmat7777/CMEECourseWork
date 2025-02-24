# read data
recapture.data <- read.csv("../data/recapture.csv", header = T)
head(recapture.data)
    # how many days between recapturing
    # how much they grew

#scatterplot
plot(recapture.data, pch = 16)

## LOG LIKEL;IHOOD AND LINEAR REGRESSION

# input parameters as a vector
regression.log.likelihood<- function(parm, dat){
    
    # define parameters
    # we have three- a, b, sigma
    a <- parm[1]
    b<-parm[2]
    sigma<-parm[3]

    # define data dat
    x<- dat[,1] #1st col is x
    y<- dat [,2] # 2ND COL IS Y

    # model on vectorized error terms
    error.term<- (y-a-b*x)
    # error.term[i] ARE IID NORMAL, WITH MEAN 0 AND A COMMON VARIANCE sigma^2
    density<-dnorm(error.term, mean=0, sd=sigma, log=T)

    # THE LOG-LIKELIHOOD IS THE SUM OF INDIVIDUAL LOG-DENSITY
    return(sum(density))
}

regression.log.likelihood(c(1,1,1), dat = recapture.data)

# optimise the log likelihood fn in r
# optim() generalises to multi-dim cases (optimize() is 1d)
M2<-optim(par=c(1, 1, 1), # starting point somewhere in the middle (not near bound)
      regression.log.likelihood, dat=recapture.data, 
      method='L-BFGS-B', # specify the algorithm. This one needs lb and ub
      lower=c(-1000, -1000, 0.001), upper=c(1000, 1000, 1000), # know sigma is above zero
      control=list(fnscale=-1))

M2
    # value doesn't matter on its own- it's about the difference (LRT)

# repeat for m1: without the intercept

regression.no.intercept.log.likelihood<-function(parm, dat)
{
# DEFINE THE PARAMETERS parm
# WE HAVE two free PARAMETERS: b, sigma. BE CAREFUL OF THE ORDER
b<-parm[1]
sigma<-parm[2]

# DEFINE THE DATA dat
# FIRST COLUMN IS x, SECOND COLUMN IS y
x<-dat[,1]
y<-dat[,2]

# MODEL ON THE ERROR TERMS. VECTORISED
error.term<-(y-b*x)
# error.term[i] ARE IID NORMAL, WITH MEAN 0 AND A COMMON VARIANCE sigma^2
density<-dnorm(error.term, mean=0, sd=sigma, log=T)

# THE LOG-LIKELIHOOD IS THE SUM OF INDIVIDUAL LOG-DENSITY
return(sum(density))
}

M1<-optim(par=c(1,1), regression.no.intercept.log.likelihood, method='L-BFGS-B', 
          lower=c(-1000, 0.001), upper=c(1000, 1000), dat=recapture.data, 
         control=list(fnscale=-1))
M1

# compute TEST STATISTIC D
D<- 2*(M2$value - M1$value)
D

# critical value
qchisq(0.95, df = 1)

# we accept M1


## confidence intervals

# define the range of parameters to be plotted
b<- seq(2,4,0.1)
sigma<-seq(2,5,0.1)

#log-likelihood value stored in a matriz
log.likelihood.value<- matrix(nr=length(b), nc=length(sigma))

# compute loglik for each pair
for(i in 1:length(b)){
    for(j in 1:length(sigma)){
        log.likelihood.value[i,j]<- 
        regression.no.intercept.log.likelihood(parm = c(b[i],sigma[j]),
        dat=recapture.data)
    }
}

# we are interested in knowing the relative loglik value
# relative to the peak (maximum)
rel.log.likelihood.value<- log.likelihood.value-M1$value # how far below max loglik value it is- set max to 0

#FN FOR 3D PLOT
persp(b,sigma,rel.log.likelihood.value, theta = 30, phi = 20,
    xlab = 'b', ylab = 'sigma', zlab = 'rel.log.lik.value', col = 'grey')

# contour plot- move camera to top
contour(b,sigma, rel.log.likelihood.value, xlab = 'b', ylab = 'sigma',
    xlim = c(2.5,3.9), ylim = c(2.0,4.3),
    levels = c(-1:-5,-10), cex = 2) # where you draw the circles
#draw a cross
points(M1$par[1]) # didnt finish

contour.line<-contourLines(b,sigma,
    rel.log.likelihood.value, levels=-1.92)[[1]]
    lines(contour.line$x, contour.line$y, col = "red", lty =2, lwd = 2)

# ^ idk how to draw the lines around the 95% ci which would be the individual 95%cis for those params

# what about joint 95% ci REGION for the pair (b,sigma)?
#-> need to consider the correlation between ML estimators

# optim() for 2d param space with hessian matriz

result<- optim(par = c(1,1), regression.no.intercept.log.likelihood,
    method = 'L-BFGS-B',
    lower = c(-1000,0.0001), upper = c(1000,10000),
    control=list(fnscale=-1), dat = recapture.data, hessian=T)

# obtain hessian matrix
result$hessian

# the variance covariance matrix is the negative of the inverse of this
# and this can be used to get CIs

var.cov.matrix <-(-1)*solve(result$hessian)
var.cov.matrix

# so for b, 95CI is 3.1629 +- sqrt(0.04227)