### ANOVA and repeatability (HO12)

rm(list=ls())

d <- read.table("../data/SparrowSize.txt", header = TRUE)
str(d)

d1 <- subset(d, d$Wing!="NA")
summary(d1$Wing)
hist(d1$Wing)
    # some missing values, some outliers

model1<-lm(Wing~Sex.1, data=d1)
summary(model1)

boxplot(d1$Wing~d1$Sex.1, ylab = "Wing length (mm)")
anova(model1)
    # first row- between-group variance
    # second row- within-group variances (residuals)
    # F value- divide mean squares -> ratio of variances
    # then look up p-value of the F-distribution
    # tells us means are different but not in what way

t.test(d1$Wing~d1$Sex.1, var.equal = TRUE) # t-test

attach(d1) # means you don't need to call df name each time (like d1$Wing)

boxplot(Mass~Year)

m2<- lm(Mass~as.factor(Year), data = d)
anova(m2)
summary(m2) # most years are different from 2000

?TukeyHSD # compare multiple means, all combos
?aov # needed for Tukey. Like an lm

am2<- aov(Mass~as.factor(Year), data = d)
summary(am2) # same result as the lm anova
TukeyHSD(am2)

## exercise 1

list.files(path = "../data")

Aconite <- read.csv("../data/Aconite.csv", header = TRUE)
str(Aconite) # 3 treatment groups, made measurements d1,d2 and c(?)
summary(Aconite)

Aconite1 <- subset(Aconite, !is.na(d1))

summary(Aconite1)

head(Aconite)

attach(Aconite)

groupvsd1 <- lm(d1 ~ group, data = Aconite1)

summary(groupvsd1) # groups are sig diff from A

groupvsd2 <- lm(d2 ~ group, data = Aconite1)

summary(groupvsd2) # B and C not sig diff from A

groupvsc <- lm(c ~ group, data = Aconite1)

summary(groupvsc) # B and C not sig diff from A




