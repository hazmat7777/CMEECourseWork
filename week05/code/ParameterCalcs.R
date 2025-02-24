## Importing data

rm(list = ls())

getwd()

d <- read.table("../data/SparrowSize.txt", header = TRUE)
str(d) # structure

names(d)

head(d)

length(d$Tarsus)

## Histograms, mean, median, mode

hist(d$Tarsus)

mean(d$Tarsus) # NA due to missing values
help(mean)
mean(d$Tarsus, na.rm = T)

median(d$Tarsus, na.rm = T)

mode(d$Tarsus) # mode returns a description of object type
    # in a continuous dataset most values occur once

par(mfrow = c(2,2)) # prepping four plots, 2*2
hist(d$Tarsus, breaks = 3, col = "grey")
hist(d$Tarsus, breaks = 10, col = "grey")
hist(d$Tarsus, breaks = 30, col = "grey")
hist(d$Tarsus, breaks = 100, col="grey") # gaps in histogram- when the resolution of the graph is higher than the resolution of the measuring device

## no package to calc mode- do it manually

head(table(d$Tarsus)) # weird rounding issues

?round
d$Tarsus.rounded <- round(d$Tarsus, digits = 1)
head(d$Tarsus.rounded)

require(dplyr) # to sort the data

TarsusTally <- d %>% count(Tarsus.rounded, sort = TRUE)
TarsusTally # top value (19) is the mode

d2 <- subset(d, d$Tarsus!="NA") # d2 has no NAs
length(d$Tarsus)-length(d2$Tarsus) # removed 85 NAs

TarsusTally <- d2 %>% count(Tarsus.rounded, sort = TRUE)
head(TarsusTally)

# indexing from the tibble to get the first value from the first column

TarsusTally[1] # 1st col
TarsusTally[2] # 2nd col

TarsusTally[[1]] # 1st col AS A VECTOR 
    # with column naming and wrapping removed

TarsusTally[[1]][1] # 1st element of 1st col = MODE

## Range, variance, SD

range(d$Tarsus, na.rm = TRUE) # min and max

var(d$Tarsus, na.rm = TRUE)

# writing out variance formula in R

sum((d2$Tarsus - mean(d2$Tarsus))^2)/(length(d2$Tarsus) - 1)

# standard deviation
sd(d2$Tarsus)
sqrt(var(d2$Tarsus))

## Z scores and quantiles

# z scores come from a standardized normal dist
    # with mean = 0, sd = 1 -> var = 1

# z-transforming data: making it like that (mean 0 sd 1)
    # see general formula for doing that
        # subtract the mean (so new mean 0)
        # divide by sd (so new sd 1)

zTarsus <- (d2$Tarsus - mean(d2$Tarsus))/sd(d2$Tarsus)
var(zTarsus)
hist(zTarsus)

# there is a function for this ^ in R
z2Tarsus <- scale(d2$Tarsus)

print(z2Tarsus)
var(z2Tarsus)
hist(z2Tarsus)

# z score- how many standard deviations is a data point from the mean

znormal <- rnorm(1e+06) # 1 million randos
hist(znormal, breaks = 100)

summary(znormal)

qnorm(c(0.025, 0.975)) # gives the value at the given quantiles
pnorm(.Last.value) # probability at a given value


par(mfrow = c(1, 2))
hist(znormal, breaks = 100)
abline(v = qnorm(c(0.25, 0.5, 0.75)), lwd = 2) # adds straight lines.
abline(v = qnorm(c(0.025, 0.975)), lwd = 2, lty = "dashed") #lwd = line width
plot(density(znormal))
abline(v = qnorm(c(0.25, 0.5, 0.75)), col = "gray")
abline(v = qnorm(c(0.025, 0.975)), lty = "dotted", col = "black")
abline(h = 0, lwd = 3, col = "blue")
text(2, 0.3, "1.96", col = "red", adj = 0)
text(-2, 0.3, "-1.96", col = "red", adj = 1)

# the 2.5% and 97.5% quantiles are important for hypothesis testing (later)
    # encompass true population value with 95% prob
    # 95 times in 100 sampling events, true mean lines within this confidence interval

## Exercises

# 1 
boxplot(d$Tarsus~d$Sex.1, col = c("red", "blue"), ylab="Tarsus length (mm)")
    # use dSex.1 and not dSex so you get M and F on x axis

# 2
    # when is median/ mode useful over a mean

# 3 a) how does variable precision size affect ideal bin size in histograms
    # more precise -> use more bins
        # -> allows you to capture more of the variation
    # can't be too precise with bin size
        # otherwise you will get gaps in probabilities
    #b) variance of z-standardized data is 0

#4) how to z transform data?
    # scale()

#5) for boxplot could label axes using xlab

#6) higher variance means larger spread of data


### different distributions

## Poisson
x <- 1:500
lambda <- 400 # expected number of occurrences of an event

dev.off()
plot(x, dpois(x, lambda), type = "h", lwd = 2, ylab = "Probability")

## Exponential

# models time until an event occurs

lambda <- 1 # rate parameter

x <- seq(0, 5, by = 0.1) # Generate a sequence of x values
y <- dexp(x, rate = lambda) # Calculate the Exponential probability density function (PDF)

plot(x, y, type = "l", col = "blue", lwd = 2,
     main = "Exponential Distribution (λ=1)",
     xlab = "Time until event occurs",
     ylab = "Density")

### exploring sparrow data
    # determining data type of each variable

str(d2)

## BirdID
length(d2$BirdID)

hist(d2$BirdID) # some birds ided multiple times
# bimodal

# count data

## Year

# discrete data

## Tarsus

hist (d2$Tarsus)

# continuous data
# normal distribution

## wing
dev.off()
class(d2$Wing)

hist(d2$Wing)
# continuous data

## mass

# continuous

## sex

# binomial

## sex. l

# nominal





