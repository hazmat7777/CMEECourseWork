# housekeeping
rm(list=ls())

# load packages
require(ggplot2)
require(ggpubr)

# reading and inspecting data
worker <- read.csv("../data/workerbees.csv", stringsAsFactors = T)
str(worker)

summary(worker$Parasites)
    # 1 means parasites present
    # binary data

scatterplot<- ggplot(worker, aes(x = CellSize, y = Parasites))+
    geom_point()+
    labs(x = "Cell Size (cm)", y = "Probability of Parasite")+
    theme_classic()
boxplot<- ggplot(worker, aes(x=factor(Parasites), y=CellSize))+
    geom_boxplot()+
    theme_classic()+
    labs(x="Presence/Absence of Parasites", y="Cell Size (cm)")
ggarrange(scatterplot, boxplot, labels=c("A", "B"), ncol=1, nrow=2)

# fitting model
M1 <- glm(Parasites~CellSize, data = worker, family = "binomial")
summary(M1)

anova(M1, test = "Chisq")

# finding flip
abs(-11.25/22.175)
    # 0.507
    # at this cellsize the prob of parasites flips from 0 to 1

# prepping model
range(worker$CellSize)

new_data <- data.frame(CellSize=seq(from=0.352, to=0.664, length=100))
predictions <- predict(M1, newdata = new_data, type = "link", se.fit = TRUE)
    # TYPE = LINK predicted the fit and se on log-linear scale
new_data$pred<- predictions$fit
new_data$se<- predictions$se.fit
new_data$upperCI<- new_data$pred+(new_data$se*1.96)
new_data$lowerCI<- new_data$pred-(new_data$se*1.96)
str(new_data)

# making the Plot 
ggplot(new_data, aes(x=CellSize, y=plogis(pred)))+ 
  geom_line(col="black")+
  geom_point(worker, mapping = aes(x=CellSize, y=Parasites), col="blue")+
  geom_ribbon(aes(ymin=plogis(lowerCI), ymax=plogis(upperCI), alpha=0.2), show.legend = FALSE)+ 
  labs(y="Probability of Infection", x="Cell Size (cm)")+
  theme_classic()

# pseudoRsquared
1-(1104.9/1259.6)
    # model explains only 0.12 of variation of parasite prob

## new data

# load
chytrid<- read.csv("../data/chytrid.csv", stringsAsFactors= T)
str(chytrid)
    # infectionstatus = binary

scatterplot<-ggplot(chytrid, aes(x=Springavgtemp, y=InfectionStatus))+
  geom_point()+
  labs(x= "Probability of Infection", y="Average Spring Temperature (Degrees Celsius)")+
  theme_classic()
boxplot<- ggplot(chytrid, aes(x=factor(InfectionStatus), y=Springavgtemp))+
  geom_boxplot()+
  theme_classic()+
  labs(x="Presence/Absence of Infection", y="Average Spring Temperature (Degrees Celsius)")
ggarrange(scatterplot, boxplot, labels=c("A","B"), ncol=1, nrow=2)

# fitting model
M2 <- glm(InfectionStatus~Springavgtemp, data = chytrid, family = "binomial")
summary(M2)
anova(M2, test = "Chisq")

# flipping point
abs(-0.06/0.05)
    # 1.2 degrees celsius
    # hotter than this -> more likely to be infected

# pseudoRsquared
1-(9270/9310)
    # model explains not much

# prepping plot
range(chytrid$Springavgtemp) # Finding the range of Average Spring Temperature
new_data <- data.frame(Springavgtemp=seq(from=0.99, to=13.67, length=100))
predictions<- predict(M2, newdata = new_data, type = "link", se.fit = TRUE) # the type="link" here predicted the fit and se on the log-linear scale. 
new_data$pred<- predictions$fit
new_data$se<- predictions$se.fit
new_data$upperCI<- new_data$pred+(new_data$se*1.96)
new_data$lowerCI<- new_data$pred-(new_data$se*1.96)

# Making the Plot 
ggplot(new_data, aes(x=Springavgtemp, y=plogis(pred)))+ 
  geom_line(col="black")+
  geom_point(chytrid, mapping = aes(x=Springavgtemp, y=InfectionStatus), col="blue")+
  geom_ribbon(aes(ymin=plogis(lowerCI), ymax=plogis(upperCI), alpha=0.2), show.legend = FALSE)+ 
  labs(y="Probability of Infection", x="Average Spring Temperature (Degrees Celsius)")+
  theme_classic()

## analysing the data as a BINOMIAL (not binary) outcome

chytrid_binomial<- read.csv("../data/chytrid_binomial.csv", stringsAsFactors = T)
str(chytrid_binomial)

# fitting the model
M3 <- glm(cbind(Positives, Total-Positives)~AverageSpringTemp, data =
    chytrid_binomial, family = "binomial")
    # cbind = column bind
    # combine the number of infections with the number of non-infections
        # these get plugged into the logit link function
        # to calc log odds ratio

summary(M3)
    # for every 1C increase in temp, log odds of infection increases by 0.09
        # which is an increase in odds of 1.094 (exp(0.09))
        # so 1C increase in temp = 9.4% higher odds
anova(M3, test = "Chisq")

# flip point
abs(-0.4/0.09)
    # 4.44 C is flip pt

# pseudoRsquared
1-(4795.7/5055.4)
    # 0.05 of var explained

# model validation
4795.7/173
    # dispersion parameter- 27.72
    # overdispersed
        # simplistic model?
        # outliers?

# diagnostic plots
par(mfrow=c(2,2))
plot(M3)
sum(cooks.distance(M3)>1)
    # 2 outliers

# fitting a quasi-binomial model
M4 <- glm(cbind(Positives, Total-Positives)~AverageSpringTemp, data = 
    chytrid_binomial, family = "quasibinomial")
summary(M4)
anova(M4, test = "F") # for quasi we use the F test

# estimate values do not change but SEs increase

# prepping plot
range(chytrid_binomial$AverageSpringTemp)

new_data <- data.frame(AverageSpringTemp=seq(from=0.99, to=13.67, length=100))
predictions<- predict(M4, newdata = new_data, type = "link", 
    se.fit = TRUE) # the type="link" here predicted the fit and se on the log-linear scale. 
new_data$pred<- predictions$fit
new_data$se<- predictions$se.fit
new_data$upperCI<- new_data$pred+(new_data$se*1.96)
new_data$lowerCI<- new_data$pred-(new_data$se*1.96)

# Making the Plot 
ggplot(new_data, aes(x=AverageSpringTemp, y=plogis(pred)))+ 
  geom_line(col="black")+
  geom_point(chytrid_binomial, mapping = aes(x=AverageSpringTemp, y=(Positives/Total)), col="blue")+
  geom_ribbon(aes(ymin=plogis(lowerCI), ymax=plogis(upperCI), alpha=0.2), show.legend = FALSE)+ # adding CI
  labs(y="Probability of Infection", x="Average Spring Temperature (Degrees Celsius)")+
  theme_classic()

## New data

# reading data, fitting model
mites <- read.csv("../data/bee_mites.csv")
str(mites)
M5<-glm(cbind(Dead_mites, Total-Dead_mites)~Concentration, data = 
mites, family = "binomial")
summary(M5)
anova(M5, test = "Chisq")

194.82/113
    # dispersion factor- 1.72
    # overdispersed a bit- do a quasi

dev.off()
par(mfrow=c(2,2))
plot(M5)

# fitting quasi-binomial model
M6 <- glm(cbind(Dead_mites, Total-Dead_mites)~Concentration, data = 
mites, family = "quasibinomial")

range(mites$Concentration)

new_data <- data.frame(Concentration = seq(from = 0, to=2.16, length = 100))
predictions<- predict(M6, newdata = new_data, type = "link", se.fit=
TRUE) #PREDICT FIT AND SE ON LOGLINEAR SCALE
new_data$pred<- predictions$fit
new_data$se<- predictions$se.fit
new_data$upperCI<- new_data$pred+(new_data$se*1.96)
new_data$lowerCI<- new_data$pred-(new_data$se*1.96)

# making plot
ggplot(new_data, aes(x=Concentration, y = plogis(pred)))+
    geom_line(col="black")+
    geom_point(mites, mapping = aes(x=Concentration,
    y = (Dead_mites/Total)), col = "blue")+
    geom_ribbon(aes(ymin=plogis(lowerCI), ymax=plogis(upperCI),
    alpha=0.2), show.legend = FALSE)+
    labs(y="Probability of Infection", x="Concentration")+
    theme_classic()