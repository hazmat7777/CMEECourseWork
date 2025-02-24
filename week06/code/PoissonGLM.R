# housekeeping
rm(list = ls())

# loading packages
require(ggplot2)
require(MASS)
require(ggpubr)

# load and inspect data
fish <- read.csv("../data/fisheries.csv", stringsAsFactors = T)
str(fish)
    # dens= density
    # Period 1: 1979-1989. Period 2: 1997-2002
    # Xkm, Ykm- lengths of x and y areas sampled

ggplot(fish, aes(x=MeanDepth, y=TotAbund))+
    geom_point()+
    labs(x= "Mean Depth (km)", y = "Total Abundance")+
    theme_classic()

# fitting the model
M1 <- glm(TotAbund~MeanDepth, data = fish, family = "poisson")
summary(M1)

# check diagnostics
par(mfrow=c(2,2)) # par for partition
plot(M1)
    # many outliers

sum(cooks.distance(M1)>1)
    # 29 outliers- keep this in mind!

15770/144
    # dispersion parameter = 109.5
    # massively overdispersed

# why the overdispersion?
    # missing covariates/interactions?
    # inherent dependency?

# exploring adding additional covariate
scatterplot<- ggplot(fish, aes(x = MeanDepth, y = TotAbund,
color=factor(Period)))+
    geom_point()+
    labs(x= "Mean Depth (km)", y="Total Abundance")+
    theme_classic()+
    scale_color_discrete(name="Period", labels=c("1979-1989", "1997-2002"))
boxplot<- ggplot(fish, aes(x=factor(Period, labels=c("1979-1989", "1997-2002")), y=TotAbund))+
    geom_boxplot()+
    theme_classic()+
    labs(x="Period", y="Total Abundance")
ggarrange(scatterplot, boxplot, labels = c("A","B"), ncol=1, nrow=2)
    # seems to be an effect
        # period 1 has higher abundance

# adding Period as fixed factor
fish$Period<- factor(fish$Period)
M2<- glm(TotAbund~MeanDepth*Period, data = fish, family = "poisson")
summary(M2)
anova(M2, test = "Chisq")
    # period does have a sig impact on the effect of MeanDepth on Totabund
    # can write 2 eqns
        # Period1: ln(TotAbund)= 6.83 - 0.66 * MeanDepth
        # Period2: 6.16- 0.54 * MeanDepth
14293/142
    # dispersion parameter = 100.65
    # still overdispersed

# fitting a negative binomial to reduce dispersion
M3 <- glm.nb(TotAbund~MeanDepth*Period, data = fish)
summary(M3)

anova(M3, test = "Chisq")
    # suggests there is no sig diff between the slopes
    # but there is sig diff between intercepts

# running a reduced model (without the interaction)
M4<- glm.nb(TotAbund~MeanDepth+Period, data = fish)
summary(M4)

anova(M4, test = "Chisq")

158.23/143
    # 1.11 dispersion parameter- not bad

# diagnostic plots
par(mfrow=c(2,2))
plot(M4)
    #looking ok

# preparing negative binomial model plot
range(fish$MeanDepth)

period1 <- data.frame(MeanDepth=seq(from=0.804, to=4.865, length=100),Period="1")
period2 <- data.frame(MeanDepth=seq(from=0.804, to=4.865, length=100), Period="2")
period1_predictions<-predict(M4, newdata=period1, type = "link", se.fit = T)
    # type = link preducts the fit and se on the log-linear scale
period2_predictions<- predict(M4, newdata = period2, type = "link", se.fit = TRUE)
period1$pred<- period1_predictions$fit
period1$se<- period1_predictions$se.fit
period1$upperCI<- period1$pred+(period1$se*1.96)
period1$lowerCI<- period1$pred-(period1$se*1.96)
period2$pred<- period2_predictions$fit
period2$se<- period2_predictions$se.fit
period2$upperCI<- period2$pred+(period2$se*1.96)
period2$lowerCI<- period2$pred-(period2$se*1.96)
complete<- rbind(period1, period2)

# making the plot
ggplot(complete, aes(x=MeanDepth, y=exp(pred)))+ 
  geom_line(aes(color=factor(Period)))+
  geom_ribbon(aes(ymin=exp(lowerCI), ymax=exp(upperCI), fill=factor(Period), alpha=0.3), show.legend = FALSE)+ 
  geom_point(fish, mapping = aes(x=MeanDepth, y=TotAbund, color=factor(Period)))+
  labs(y="Total Abundance", x="Mean Depth (km)")+
  theme_classic()+
  scale_color_discrete(name="Period", labels=c("1979-1989", "1997-2002"))

# simpler way to plot
require(ggeffects)

plot(ggpredict(M4, terms=c("MeanDepth", "Period")), show_data=T)
