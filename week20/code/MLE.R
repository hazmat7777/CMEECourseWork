# Write likelihood fn
binomial.likelihood<- function(p){
    choose(10,7)*p^7*(1-p)^3
}

# let us calculatre likelihood at p = 0.1
binomial.likelihood(p = 0.1)

# plot likelihood for a range of p
p<- seq(0,1,0.01)
likelihood.values <- binomial.likelihood(p)
plot(p, likelihood.values, type = "l")

# log-likelihood
log.binomial.likelihood<-function(p){
    log(binomial.likelihood(p=p))
}

# plot the log-likelihood
p<- seq(0,1,0.01)
log.likelihood.values<- log.binomial.likelihood(p)
plot(p, log.likelihood.values, type = "l")

# mavimilse loglike
optimize(binomial.likelihood, interval = c(0,1), maximum  = TRUE)