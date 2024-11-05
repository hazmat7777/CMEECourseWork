d <- read.table("../data/SparrowSize.txt", header = TRUE)

head(d)

# calculating SE of tarsus

length(d$Tarsus) # but has NAs

d2 <- subset(d, d$Tarsus!="NA") # removing the NAs

length(d2$Tarsus)
sd(d2$Tarsus)


Tarsus_SE <- sd(d2$Tarsus)/(sqrt(length(d2$Tarsus)))
Tarsus_SE

## SE of Tarsus in only year 2001
d3 <- subset(d2, d2$Year == "2001") # only the year 2001

head(d3)
length(d3$Tarsus)
sd(d3$Tarsus)

Tarsus_SE_2001 <- sd(d3$Tarsus)/(sqrt(length(d3$Tarsus)))
Tarsus_SE_2001