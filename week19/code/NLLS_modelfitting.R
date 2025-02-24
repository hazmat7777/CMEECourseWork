rm(list = ls())
graphics.off()

## Generating data: michaelis menten model
S_data <- seq(1,50,5)
S_data

V_data <- ((12.5 * S_data)/(7.1+S_data))
plot(S_data, V_data)

# add normal fluctuations to data to emulate error
set.seed(1456) # To get the same random fluctuations in the "data" every time
V_data <- V_data + rnorm(10,0,1) # Add 10 random fluctuations  with standard deviation of 1 to emulate error
plot(S_data, V_data)

## Fitting model using NLSS
MM_model <- nls(V_data ~ V_max * S_data / (K_M + S_data))
    # note warning- nls requires starting values for the parameters (V_max and K_M)
    # without start the default is 1

## visualising the fit
plot(S_data,V_data, xlab = "Substrate Concentration", ylab = "Reaction Rate")  # first plot the data 
lines(S_data,predict(MM_model),lty=1,col="blue",lwd=2) # now overlay the fitted model 

# problem- by default nls() generates predicted values
# for actual x values used to fit the model
# -> not a smooth curve

# solution- generate many x vlaues
coef(MM_model) # check the coefficients
Substrate2Plot <- seq(min(S_data), max(S_data),len=200) # generate some new x-axis values just for plotting
Predict2Plot <- coef(MM_model)["V_max"] * Substrate2Plot / (coef(MM_model)["K_M"] + Substrate2Plot) # calculate the predicted values by plugging the fitted coefficients into the model equation 

plot(S_data,V_data, xlab = "Substrate Concentration", ylab = "Reaction Rate")  # first plot the data 
lines(Substrate2Plot, Predict2Plot, lty=1,col="blue",lwd=2) # now overlay the fitted model

## summary stats of the fit
summary(MM_model)
# estimate- estimated values of coefficients
    # quite diff from what we fit due to the errors
# se, t, p
# no its to conv- how many times the algo
    # adjusted parameter values to minimize RSS
# achieved convergence tolerance- when algo decided 
    # to stop trying to improve RSS

coef(MM_model) # just the coefs

### Statistical inference

# goodness of fit
anova(MM_model) # no
    # anova compares fitted model to null model
    # unclear what the null model is for a nonlinear model

# to get f statistic, null model must be nested within the alternative model
    # can do anova(Nullmodel, Altmodel)

# best ways to assess NLSS model's fit:
    # compare likelihood to other alt models (including your guess for a null model)
    # examine the reliability of coefs (as above)- check se,t,p

# rsquared
    # don't use for nonlinear models

## confidence intervals around estimated coefs
confint(MM_model)
    # can calc coefs of same model from diff samples
    # compare coefs to (quickly, not robustly) see if they are sig diff

### starting values problem
MM_model2 <- nls(V_data ~ V_max * S_data / (K_M + S_data), start = list(V_max = 12, K_M = 7))
MM_model3 <- nls(V_data ~ V_max * S_data / (K_M + S_data), start = list(V_max = .1, K_M = 20))

coef(MM_model) # idk why this is different
coef(MM_model2)
coef(MM_model3) # similar but not identical 

# plot model 1 vs model 3
plot(S_data,V_data)  # first plot the data 
lines(S_data,predict(MM_model),lty=1,col="blue",lwd=2) # overlay the original model fit
lines(S_data,predict(MM_model3),lty=1,col="red",lwd=2) # overlay the latest model fit

nls(V_data ~ V_max * S_data / (K_M + S_data), start = list(V_max = 0, K_M = 0.1))
# singular gradient matrix error
    # starting values were so far from optimal
    # that algo failed

nls(V_data ~ V_max * S_data / (K_M + S_data), start = list(V_max = -0.1, K_M = 100))
    # model fitting started but failed bc too far from optimal

MM_model4 <- nls(V_data ~ V_max * S_data / (K_M + S_data), start = list(V_max = 12.96, K_M = 10.61))

coef(MM_model)
coef(MM_model4) # shows its not an exact procedure

### a more robust nlls algo

# ^ was gauss-newton algo
# gets lost and stuck
# use levenberg-marqualdt algo

install.packages("minpack.lm") 
require("minpack.lm")

MM_model5 <- nlsLM(V_data ~ V_max * S_data / (K_M + S_data), start = list(V_max = 12, K_M = 7))
coef(MM_model2)
coef(MM_model5)

# using the failed ones:
MM_model6 <- nlsLM(V_data ~ V_max * S_data / (K_M + S_data), start = list(V_max = .01, K_M = 20))
MM_model7 <- nlsLM(V_data ~ V_max * S_data / (K_M + S_data), start = list(V_max = 0, K_M = 0.1))
MM_model8 <- nlsLM(V_data ~ V_max * S_data / (K_M + S_data), start = list(V_max = -0.1, K_M = 100))

coef(MM_model6)
coef(MM_model7)
coef(MM_model8) # failed before but not now

# absurd starting value
nlsLM(V_data ~ V_max * S_data / (K_M + S_data), start = list(V_max = -10, K_M = -100))
    # it has limits

## bounding parameter values
nlsLM(V_data ~ V_max * S_data / (K_M + S_data), start = list(V_max = 0.1, K_M = 0.1))
nlsLM(V_data ~ V_max * S_data / (K_M + S_data), start = list(V_max = 0.1, K_M = 0.1), lower=c(0.4,0.4), upper=c(100,100)) 
    # stops starting values exceeding a range
    # takes fewer iterations= IMPROVEMENT

## model diagnostics
hist(residuals(MM_model6))
    # as with ols, assume measurement errors are normally distribd

### Allometric scaling of traits
MyData <- read.csv("../data/GenomeSize.csv") # using relative path assuming that your working directory is "code"
head(MyData)

Data2Fit <- subset(MyData,Suborder == "Anisoptera")

Data2Fit <- Data2Fit[!is.na(Data2Fit$TotalLength),] # remove NA's

plot(Data2Fit$TotalLength, Data2Fit$BodyWeight, xlab = "Body Length", ylab = "Body Weight")

library(ggplot2)
ggplot(Data2Fit, aes(x = TotalLength, y = BodyWeight))+
    geom_point(size = 3, color = "red") + theme_bw() +
    labs(y = "Body mass (mg)", x = "Wing length (mm)")

nrow(Data2Fit)

PowFit <- nlsLM(BodyWeight ~ a * TotalLength^b, data = Data2Fit, start = list(a = .1, b = .1))

## NLSS fitting using a model object

# first create a function object for the power law model
powMod <- function(x, a, b){
    return(a * x^b)
}

# now fit model to data using NLLS by calling model
PowFit <- nlsLM(BodyWeight ~ powMod(TotalLength,a,b), data = Data2Fit, start = list(a = .1, b = .1))

## visualising the fit

# vector of body lengths
Lengths <- seq(min(Data2Fit$TotalLength),max(Data2Fit$TotalLength),len=200)

# calculate the predicted line using coefs from model fit
coef(PowFit)
Predict2PlotPow <- powMod(Lengths,coef(PowFit)["a"],coef(PowFit)["b"])

plot(Data2Fit$TotalLength,Data2Fit$BodyWeight)  
lines(Lengths, Predict2PlotPow, col = 'blue', lwd = 2.5)    

## Summary of the fit
summary(PowFit)
print(confint(PowFit))

# examine residuals
hist(residuals(PowFit))