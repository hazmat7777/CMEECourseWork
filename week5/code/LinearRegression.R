rm(list = ls())

x <- c(1,2,3,4,8)
y <- c(4,3,5,7,9)

model1 <- lm(y~x)
model1 # x is the slope
summary(model1) # note residuals
anova(model1)
resid(model1)
cov(x,y)    # there is a positive correlation
            # covariance is not standardized so cant interpret quantitatively
var(x) # average variability. Sum of squares divided by n
plot(y~x)
abline(model1)

dev.off()