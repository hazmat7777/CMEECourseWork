# housekeeping
rm (list = ls())

# load data
uni<- read.table("../data/RUnicorns.txt", header = T)
str(uni)
head(uni)

# eploring
mean(uni$Bodymass)
sd(uni$Bodymass)
var(uni$Bodymass)
hist(uni$Bodymass)

mean(uni$Hornlength)
sd(uni$Hornlength)
var(uni$Hornlength)
hist(uni$Hornlength)

# quick plot
plot(uni$Bodymass~uni$Hornlength, pch = 19, col = "blue")
mod<-lm(uni$Bodymass~uni$Hornlength)
abline(mod, col="red")
res <- signif(residuals(mod), 5) # calcs resids, signif() rounds to 5 sig fig
pre <- predict(mod) # calculates fitted values from mod lm
segments(uni$Hornlength, uni$Bodymass, uni$Hornlength, pre, col="black") 
    # draws vert lines from actual values to fitted values
    # arguments- segments(x0, y0, x1, y1, col="black")

# interpreting
    # plot suggests a clear relationship
    # could be many other variables which play a part
        # e.g. long horn -> attractive -> preg -> heavier
    # add covariates and fixed factors to account for this
    # test which variable explains most variation

## GLM
# checking more data
hist(uni$Bodymass)
hist(uni$Hornlength)
hist(uni$Height)
    # ok ish data

cor.test(uni$Hornlength, uni$Height)
    # seem to be independent

boxplot(uni$Bodymass~uni$Gender)
    # fems larger and bigger variance

par(mfrow=c(2,1))
boxplot(uni$Bodymass~uni$Pregnant)

plot(uni$Hornlength[uni$Pregnant==0],uni$Bodymass[uni$Pregnant==0], pch=19, 
xlab="Horn length", ylab="Body mass", xlim=c(2,10), ylim=c(6,19)) # non pregs
points(uni$Hornlength[uni$Pregnant==1],uni$Bodymass[uni$Pregnant==1], pch=19,
col="red") # add pregs
    # pregnancy has an impact on body mass and maybe its impact on hornlength

dev.off()
boxplot(uni$Bodymass~uni$Pregnant)
plot(uni$Hornlength[uni$Gender=="Female"],uni$Bodymass[uni$Gender=="Female"],
    pch=19, xlab="Horn length", ylab="Body mass", xlim=c(2,10), ylim=c(6,19))
points(uni$Hornlength[uni$Gender=="Male"],uni$Bodymass[uni$Gender=="Male"],
    pch=19, col="red")
points(uni$Hornlength[uni$Gender=="Undecided"],
    uni$Bodymass[uni$Gender=="Undecided"], pch=19, col="green")
    # males are longer and heavier

boxplot(uni$Bodymass~uni$Glizz) # = decorations on horn

plot(uni$Hornlength[uni$Glizz==0], uni$Bodymass[uni$Glizz==0], pch=19,
    xlim=c(2,10), ylim=c(6,19))
points(uni$Hornlength[uni$Glizz==1],uni$Bodymass[uni$Glizz==1], pch=19, 
    col="red")
    # glizzes are heavier and longer

# so we want to include gender, pregnant, and glizz
FullModel<-lm(uni$Bodymass~uni$Hornlength+uni$Gender+uni$Pregnant+uni$Glizz)
summary(FullModel)
    # no sig slope
    # only 2 preg fems, and preg will only influence fems- get rid

u1<- subset(uni, uni$Pregnant==0)
FullModel<-lm(u1$Bodymass~u1$Hornlength+u1$Gender+u1$Glizz)
summary(FullModel)
    # indicates we don't need gender to explain impact of horn on bodymass
    # get rid as it's costing dfs

ReducedModel<-lm(u1$Bodymass~u1$Hornlength+u1$Glizz)
summary(ReducedModel)
    # better

plot(u1$Hornlength[u1$Glizz==0],u1$Bodymass[u1$Glizz==0], pch=19, 
    xlab="Horn length", ylab="Body mass", xlim=c(2,10), ylim=c(6,19))
points(u1$Hornlength[u1$Glizz==1],u1$Bodymass[u1$Glizz==1], pch=19, col="red")
abline(ReducedModel) # see warning- line is only for glizz = 0
abline(a = 4.0106 + 1.7702, b = (0.8864), col = "red") # glizz line
    # glizz looks like it could be steeper
    

# including an interaction ^
Glizz_affects_slope<-lm(u1$Bodymass~u1$Hornlength*u1$Glizz)
summary(Glizz_affects_slope)
    # no impact of glizz on slope- remove this again

# plotting without glizz
ModForPlot<-lm(u1$Bodymass~u1$Hornlength)
summary(ModForPlot)
    # multipleRsquared = 0.46 explained by hornlength
    # ReducedModel mRsq = 0.61 explained by hornlength and glizz
    # if glizz and hornlength were independent..
    # then glizz would account for 0.15 of variance (additive rule for variances)
    # test if they are independent



cor(u1$Hornlength, u1$Glizz)
cor.test(u1$Hornlength, u1$Glizz)
boxplot(u1$Hornlength~u1$Glizz)
t.test(u1$Hornlength~u1$Glizz)
    # positive correlation
    # longer horns are more likely to wear glizz, or vice versa
    # so not independent

# model validation
par(mfrow = c(2,2))
plot(ReducedModel)
    # see outliers 14 and 12 and 6
View(u1)
    # nothing unusual about those rows so keep em in

# final plot (again)
plot(u1$Hornlength[u1$Glizz==0],u1$Bodymass[u1$Glizz==0], pch=19, 
    xlab="Horn length", ylab="Body mass", xlim=c(2,10), ylim=c(6,19))
points(u1$Hornlength[u1$Glizz==1],u1$Bodymass[u1$Glizz==1], pch=19, col="red")
abline(ReducedModel) # see warning- line is only for glizz = 0
abline(a = 4.0106 + 1.7702, b = (0.8864), col = "red") # glizz line

#############################################################################

# interactions

rm(list = ls())

dat<- read.table("../data/data.txt", header = TRUE)
head(dat)
str(dat)

dat$method <- as.factor(dat$method)