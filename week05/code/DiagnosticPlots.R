## fitting models in R using multiple variables to explain the response variable.
# adding error bars to boxplots


rm(list = ls())

### Investigating growth rate in daphnia vs categorical explanatory vars

# First checking if the data are appropriate for regression analysis

daphnia <- read.delim("../data/daphnia.txt", header = TRUE) # reads tab-delimited files
summary(daphnia)

head(daphnia)

str(daphnia)

## 1. Outliers

par(mfrow = c(1,2))
plot(Growth.rate ~ as.factor(Detergent), data=daphnia) # why do we need as.factor
    # plot(Growth.rate ~ Detergent, data=daphnia) # see error
plot(Growth.rate ~ as.factor(Daphnia), data=daphnia)

# can see there are no outliers

## 2. homogeneity of variances

# regression analysis assumes variances within each group are similar
# test this

require(dplyr)

daphnia %>% # pipe operator passes the output of one function to the next
    group_by(Detergent)  %>% 
        summarise (variance=var(Growth.rate))

daphnia %>%
    group_by(Daphnia) %>%
        summarise (variance=var(Growth.rate))

# this tells us they're not that similar 
# (will continue anyway but remember this when making conclusions)

## 3. are the data normally distributed

# another assumption of lms is that observations for each x are normal

dev.off() # only do this after par

hist(daphnia$Growth.rate) # read handout- this isnt even relevant

# lm reasonably robust against violations

# for other assumptions see HO

### Model daphnia

# function to calculate SE
seFun <- function(x) {
    sqrt(var(x)/length(x))
}

# finding mean and SE for each detergent
detergentMean <- with(daphnia, tapply(Growth.rate, INDEX = Detergent,
FUN = mean)) # calculate mean growth rate in each detergent
detergentMean

detergentSEM <- with(daphnia, tapply(Growth.rate, INDEX = Detergent,
FUN = seFun)) # calculate SE of growth rate in each detergent
detergentSEM

# unsure why we do this step:
cloneMean <- with(daphnia, tapply(Growth.rate, INDEX = Daphnia, FUN = mean))
cloneSEM <- with(daphnia, tapply(Growth.rate, INDEX = Daphnia, FUN = seFun))

# plotting boxplots 
par(mfrow=c(2,1),mar=c(4,4,1,1)) #margins

barMids <- barplot(detergentMean, xlab = "Detergent type", 
ylab = "Population growth rate", ylim = c(0, 5))

arrows(barMids, detergentMean - detergentSEM, barMids, detergentMean +
detergentSEM, code = 3, angle = 90) # adding error bars
    # code is type of arrow (both ends have ticks)
    # angle is angle of ticks 

barMids <- barplot(cloneMean, xlab = "Daphnia clone", 
ylab = "Population growth rate", ylim = c(0, 5))

arrows(barMids, cloneMean - cloneSEM, barMids, cloneMean + cloneSEM,
code = 3, angle = 90)

# lm
daphniaMod <- lm(Growth.rate ~ Detergent + Daphnia, data = daphnia)
summary(daphniaMod)
    # intercept- the mean of brand A clone 1 is significantly diff from 0
    # BrandB,C,D- the means of brands BCD clone 1 compared to the reference ^
    # CLone23- the means of brand A clones 2 and 3 compared to the reference ^^
    # impact of detergents is not significant
    # clones 2 and 3 grew significantly faster

# plotting this
par(mfrow=c(2,2))
plot(daphniaMod)
    # 4 plots test the assumptions of a lm. Top 2 are most important
        # fitted vs residuals
            # here: fitted values = the growth rate
            # want this to look like a starry night
            # a problem if there is a relationship between them
            # would mean variance is not constant
            # ours is fine
        # Normal quantile-quantile plot
            # a straight line if errors are normally distributed
            # ours is good
        # other plots check for outliers
            # we are fine
    # quicker than doing all the steps before

# analysis of variance
daphniaANOVAMod <- aov(Growth.rate ~ Detergent + Daphnia, data = daphnia)
summary(daphniaANOVAMod)
    # similar to lm but less powerful because it only uses the variances

# Tukey multiple comparison of means
daphniaModHSD <- TukeyHSD(daphniaANOVAMod)
daphniaModHSD
    # gives 95% CIs

# plotting this
par(mfrow=c(2,1), mar=c(4,4,3,3)) #large margin for labels
plot(daphniaModHSD)

### New data

timber <- read.delim("../data/timber.txt")
str(timber)
summary(timber)
head(timber)

## Girth vs height

# quick visualisation
dev.off()
plot(timber$girth ~ timber$height)

# checking assumptions the quick way
dev.off()
girthvsheight <- lm(girth ~ height, data = timber)

par(mfrow=c(2,2))
plot(girthvsheight)

# looks ok

# testing if residuals are normally distribd- another way
hist(residuals(girthvsheight))
    # about as good as it gets in ecology

summary(girthvsheight)
    # at height = 0, girth = -49.4 (meaningless)
    # slope is 6
    # slope is significant

## multiple variables

timberMod <- lm(volume ~ girth + height, data = timber)

# model validation
dev.off()
par(mfrow = c(2,2))
plot(timberMod)
    # not great
    # one big outlier too- 31

cor(timber) # tests correlation between variables (colinearity)
    # can see all variables are positively correlated
    # we don't want too much colinearity
    # colinearity causes larger SEs of these variables
    # increase in SE is proportional to sqrt(VIF)
        # Variance inflation factor

    #calculating VIF
    summary(lm(girth ~ height, data = timber))
    VIF <- 1/(1-0.27)
    VIF # not too high
    sqrt(VIF) # how much SE gets inflated
    # VIF < 3 or sometimes < 10 is ok

summary(timberMod)

anova(timberMod)

### Exercises

#1 excluding an outlier from lm

# removing row 31

timber_filtered <- timber[-31,]

timberMod_2 <- lm(volume ~ girth + height, data = timber_filtered)

summary(timberMod_2)

dev.off()
par(mfrow = c(2,2))
plot(timberMod_2)

# 2 Continuous AND categorical explanatory variables

plantGrowth <- read.delim("../data/ipomopsis.txt")

str(plantGrowth)
summary(plantGrowth)

plantGrowth$Grazing <- as.factor(plantGrowth$Grazing) # now have a categorical var

FruitMod <- lm(Fruit ~ Root + Grazing, data = plantGrowth)

dev.off()
par(mfrow=c(2,2))
plot(FruitMod)
    # a few outliers
    # variance is homogenous
dev.off()
hist(residuals(FruitMod))
    # resiudals are normally distributed
    # not excessive zeroes

# calculating colinearity- find VIFs
    # Load the car package
    install.packages("car")
    library(car)
    
    # Calculate VIF values using car
    vif_values <- vif(FruitMod)
    print(vif_values) # can see we have low VIFs

# interpreting lm

summary(FruitMod)
    # Slope of root- 23.56
        # increasing root increases fruit size
    # Ungrazed plants had a mean 36.103 higher
    # all stat significant





