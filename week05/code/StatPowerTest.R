# error in handout (6)

rm(list = ls())
d

# conducting a statistical power test- horn lengths in dragons
    # overall q- what sample size will we need to be 80% sure we will detect an effect if it exists?

install.packages("WebPower") # where we do power analysis
require(WebPower)

?WebPower

# Cohen's effect size d = effect size (diff between means) / standard deviation
    # quantifies the effect size (difference between means)
    # in terms of standard deviation units

# effect size = 0.3, sd = 1.2

0.3/1.2 # d = 0.25

# we want to detect an effect size that is 0.25 of a sd

# simulating data
y <- rnorm(51, mean=1, sd = 1.3) # 51 horn lengths
x <- seq(from=0, to=5, by = 0.1) # 51 dragons

plot(hist(y, breaks = 10))

mean(y) # not exactly as asked because of small sample size
sd(y)

segments(x0=mean(y), y0=0, x1=mean(y), y1=40, lty=1, col="blue") # blue line for mean
segments(x0=(mean(y)+0.25*sd(y)), y0=0, x1=(mean(y)+0.25*sd(y)), y1=40, lty = 1, col = "red") # red line for 0.25sds higher
# seems there is a small effect size

# doing a t test with webpower
?wp.t
wp.t(d=0.25, power=0.8, type="two.sample", alternative="two.sided")
    # d- Cohen's effect size
    # alpha = 0.05- convention. We accept 5% chance of false pos (type1 error)
    # power = 0.8- convention. We accept 20% chance of false neg (type 2 error)
    # (error in handout)
    # LOOK AT n!!!

# n is 252- need to sample 252 dragons in each group to get a clear answer

## producing a power curve

# shows the power at various sample sizes

res.1<-wp.t(n1=seq(20,300,20), n2=seq(20,300,20), d=0.25, 
    type="two.sample.2n", alternative="two.sided")

res.1 # as n increases, power increases

plot(res.1, xvar='n1', yvar = 'power')

## exercises

#1

# n = 300 per group, Cohen's effect size d = 0.11, p - 0.044. What is statistical power?
# significance level alpha = 0.05

# calculate non centrality parameter lambda
    # the extent to which the null hypothesis is false
    # effect size * sqrt(n)
0.11*sqrt(300) # lambda = 1.91

statpower <- wp.t(d=0.11, n1=300, n2=300)
statpower # power is 0.27- high chance there is a false negative

# what n would you need to get to power of 0.8?
wp.t(d=0.11, power=0.8, type="two.sample", alternative="two.sided") # required n is much higher


