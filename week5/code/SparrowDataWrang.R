rm(list=ls())
d<-read.table("../data/SparrowSize.txt", header=TRUE)

boxplot(d$Mass~d$Sex.1, col = c("red", "blue"), ylab="Body mass (g)")

t.test(d$Mass~d$Sex.1)
    # males are heavier

# taking a smaller sample size
d1 <- as.data.frame(head(d, 50)) # first 50 rows

t.test(d1$Mass~d1$Sex)
    # CIs include zero 
    # no difference

# data wrang
d2 <- subset(d, d$Tarsus!="NA") # removing the NAs
d3 <- subset(d, d$Year == "2001") # only the year 2001


## exercises

#1- wing length in 2001 vs grand mean
mean(d$Wing, na.rm = TRUE) # grand mean
mean(d3$Wing, na.rm = TRUE)

t.test(d3$Wing, mu = mean(d$Wing, na.rm = TRUE))

# m vs f winglength in 2001
t.test(d3$Wing~d3$Sex, na.rm = TRUE)
    # ~ is the same as as.factor- used for categories 
    # 95% CI is that of the differences between the two means
    # if 0 is within this range, then they are not stat different
    # 0 isnt -> they are different (see also p value)

# ms vs fs in Tarsi length
t.test(d$Tarsus~d$Sex, na.rm = TRUE)
    # they are statistically different
    # ~ is the same as as.factor- used for categories 

#2- taking a t test of each year

# grand mean of tarsus
mean(d$Tarsus, na.rm = TRUE) # this is mu

Years <- unique(d$Year)

for (Year in Years) {
    subset_df <- d[d$Year == Year, ] # make subsets of each year. Note comma- takes those rows
    t_test_year <- t.test(subset_df$Tarsus, mu = 18.52335, na.rm = TRUE)
    print(paste("Year:", Year, "T value:", t_test_year$statistic, "P value:", t_test_year$p.value))
}

#3- are first 5 years different from latter 6 years
unique(d$Year)
length(unique(d$Year))

d_firstyears <- subset(d, d$Year == 2000:2004)
d_lastyears <- subset(d, d$Year == 2005:2010)

t.test(d_firstyears$Tarsus, d_lastyears$Tarsus, na.rm = TRUE)
    # no sig diff in tarsus

t.test(d_firstyears$Wing, d_lastyears$Wing, na.rm = TRUE)
    # no sig diff in wing

# trying to do this another way- making a new variable of early/late

# ifelse- vectorised if function
d$Yearhalf <- ifelse(d$Year <= 2004, "Early", "Late")

str(d)

t.test(d$Tarsus~ d$Yearhalf, na.rm = TRUE) # why is this different from the above

t.test(d$Wing~ d$Yearhalf, na.rm = TRUE)

