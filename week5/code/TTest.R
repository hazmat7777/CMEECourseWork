## See also HO5

## is the mean of a subsample of the data (2001) different from the grand mean?

d <- read.table("../data/SparrowSize.txt", header = TRUE)

length(d$Tarsus) # but has NAs

d2 <- subset(d, d$Tarsus!="NA") # removing the NAs

mean(d2$Tarsus) # can also do this with na.rm = T

d3 <- subset(d2, d2$Year == "2001") # only the year 2001

t.test(d3$Tarsus, mu = 18.52335, na.rm = TRUE) # mu is 'grand mean' of wider group you are comparing it to
    # note p value

# two sample t test

# ms vs fs in Tarsi length
t.test(d$Tarsus~d$Sex, na.rm = TRUE)
    # 95% CI is that of the differences between the two means
    # if 0 is within this range, then they are not stat different
    # 0 isn't- so they are statistically different (see also p value)

# ms vs fs in Tarsi length in 2001
t.test(d3$Tarsus~d3$Sex, na.rm = TRUE)
    # these are not statistically different
    # see p and 95% CIs including 0 difference