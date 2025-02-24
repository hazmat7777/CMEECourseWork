#### StatsinR wk2 Friday HO6

# housekeeping
rm(list = ls())

# load packages
install.packages("usdm")
require(usdm)
install.packages("psych")
require(psych)
require(lmerTest)
install.packages("sjPlot")
require(sjPlot)

# load data
parkgrass <- read.csv("../data/parkgrass_ms.csv")
str(parkgrass)
    # CWM = community-weighted measure
        # LDMC- Leaf dry matter content
        # SLA- specific leaf area (area per unit dry mass)
        # leaf C:N ratio

### exploring covariates and colinearity
# see pairwise scatterplots for all continuous covariates except harvest (response)
pairs.panels(parkgrass[,-c(1,10,11,12,13)]) # remove the rest of the cols
    # lots of strong correlations

# VIF
vif(parkgrass[,-c(1,10,11,12,13)])
    # remove highest = leafthickness
vif(parkgrass[,-c(1,6,10,11,12,13)])
    # remove highest = leafN
vif(parkgrass[,-c(1,6,7,10,11,12,13)])
    # remove highest = CN
vif(parkgrass[,-c(1,6,7,8,10,11,12,13)])
    #remove plantheight
vif(parkgrass[,-c(1,2,6,7,8,10,11,12,13)])
    # all VIFs under 3

### Model selection
## 'Do nothing' approach
M1<- lm(Harvest~scale(CWM.LDMC)+scale(CWM.SLA)+scale(CWM.Seed.Mass)+scale(SpRich)+
    factor(Ammonium)+factor(Nitrate)+factor(Minerals)+scale(pH), data = parkgrass)
    # scale is z-standardizing continuous variables (as they are on many scales)
anova(M1)
    # sum sq- how much variation is explained by that variable
    # seems plant composition has greater impact than environmental variables
summary(M1)
    # all the continuous variables are slopes
    # all the factors are diffs in intercepts
    # model explained 79% of variation

# plotting model
plot_model(M1, show.values = TRUE, show.intercept = TRUE)

# model validation
par(mfrow=c(2,2))
plot(M1)
dev.off()
    # looks good

## Classic approaches- hypothesis testing
summary(M1)
    # highest p value- remove CWM.LDMC
M2 <- update(M1, .~.-scale(CWM.LDMC))
    # put a minus (-) before name of the term to remove
anova(M1, M2)
    # negligible increase in RSS, not sig worse

summary(M2)
    # remove sprich
M3 <- update(M2, .~.-scale(SpRich))
anova(M2, M3)
    # not sig worse

summary(M3)
    # try removing Ammonium
M4 <- update(M3, .~.-factor(Ammonium))
anova(M3, M4)
    # sig worse, way more residual variance
    # stick with M3

summary(M3)
plot_model(M3, show.values = T, show.intercept = T)
    # red ones are slopes
    # blue ones are intercept (diffs)

tab_model(M1,M3) #the result of this code will appear in the "Viewer" where your plots are usually shown

# model validation
par(mfrow=c(2,2))
plot(M3)
    # looks good

## classic approach- information criteria (AIC)
# automating model selection using step()
M5 <- step(M1, direction = "backward", scope = list(lower=~1,
    upper=~scale(CWM.LDMC) + scale(CWM.SLA) + scale(CWM.Seed.Mass) + 
    scale(SpRich) + factor(Ammonium) + factor(Nitrate) + 
    factor(Nitrate) + factor(Minerals) + scale(pH)))
    # scope- the range of models to consider. From lower to upper
        # lower- the minimal model
            # only an intercept (~1)
        # upper- the full set of predictors considered in the stepwise process
            # the scaled continuous predictors
            # the categorical variables
    # step() iteratively removes predictors to find a simpler model with lower AIC
formula(M5)
    # produces the same structure as the hypothesis testing approach

## Information Theoretic (IT) approach
Model<- c("M1", "M2", "M3", "M4", "M5", "M6", "M7", "M8", "M9", "M10")
Code<- c("CWM.LDMC + CWM.SLA + CWM.Seed.Mass + SpRich + factor(Ammonium) + factor(Nitrate) + factor(Minerals) + pH", "CWM.LDMC + CWM.SLA + CWM.Seed.Mass + factor(Ammonium) + factor(Nitrate) + factor(Minerals) + pH", "SpRich + factor(Ammonium) + factor(Nitrate) + factor(Minerals) + pH", "CWM.LDMC + CWM.SLA + factor(Ammonium) + factor(Nitrate) + factor(Minerals) + pH", "CWM.Seed.Mass + factor(Ammonium) + factor(Nitrate) + factor(Minerals) + pH", "SpRich + factor(Ammonium) + factor(Nitrate) + factor(Minerals) + pH + SpRich:factor(Ammonium) + SpRich:factor(Nitrate) + SpRich:factor(Minerals)", "CWM.Seed.Mass + factor(Ammonium) + factor(Nitrate) + factor(Minerals) + pH + CWM.Seed.Mass:factor(Ammonium) + CWM.Seed.Mass:factor(Nitrate) + CWM.Seed.Mass:factor(Minerals)","CWM.LDMC + factor(Ammonium) + factor(Nitrate) + factor(Minerals) + pH + CWM.LDMC:factor(Ammonium) + CWM.LDMC:factor(Nitrate) + CWM.LDMC:factor(Minerals)", "CWM.SLA + factor(Ammonium) + factor(Nitrate) + factor(Minerals) + pH + CWM.SLA:factor(Ammonium) + CWM.SLA:factor(Nitrate) + CWM.SLA:factor(Minerals)", "factor(Ammonium) + factor(Nitrate) + factor(Minerals) + pH + factor(Ammonium):factor(Minerals) + factor(Nitrate):factor(Minerals) + factor(Ammonium):pH + factor(Nitrate):pH + factor(Minerals):pH")
Description <- c("All variables model", "Plant traits and the environment", "Species richness and the environment", "Leaf traits and the environment", "Size traits and the environment", "Species richness and the environment with selected interactions", "Seed mass and the environment with selected interactions", "Leaf dry matter content and the environment with selected interactions", "Specific leaf area and the environment with selected interactions", "Only environmental measures with selected interactions")
table<- data.frame(Model=Model, Code=Code, Description=Description)
knitr::kable(table, caption = "Models used for the IT Approach")

View(table)

# fit the models individually
M1_IT<- lm(Harvest~scale(CWM.LDMC) + scale(CWM.SLA) + scale(CWM.Seed.Mass) + 
scale(SpRich) + factor(Ammonium) + factor(Nitrate) + factor(Minerals) + scale(pH), data = parkgrass)

M2_IT<- lm(Harvest~scale(CWM.LDMC) + scale(CWM.SLA) + scale(CWM.Seed.Mass) + 
factor(Ammonium) + factor(Nitrate) + factor(Minerals) + scale(pH), data = parkgrass)

M3_IT<- lm(Harvest~scale(SpRich) + factor(Ammonium) + factor(Nitrate) + 
factor(Minerals) + scale(pH), data = parkgrass)

M4_IT<- lm(Harvest~scale(CWM.LDMC) + scale(CWM.SLA) + factor(Ammonium) + 
factor(Nitrate) + factor(Minerals) + scale(pH), data = parkgrass)

M5_IT<- lm(Harvest~scale(CWM.Seed.Mass) + factor(Ammonium) + factor(Nitrate) + factor(Minerals) + scale(pH), data = parkgrass)

M6_IT<- lm(Harvest~SpRich + factor(Ammonium) + factor(Nitrate) + factor(Minerals) + scale(pH) + scale(SpRich):factor(Ammonium) + scale(SpRich):factor(Nitrate) + scale(SpRich):factor(Minerals), data = parkgrass)

M7_IT<- lm(Harvest~scale(CWM.Seed.Mass) + factor(Ammonium) + factor(Nitrate) + factor(Minerals) + scale(pH) + scale(CWM.Seed.Mass):factor(Ammonium) + scale(CWM.Seed.Mass):factor(Nitrate) + scale(CWM.Seed.Mass):factor(Minerals), data = parkgrass)

M8_IT<- lm(Harvest~scale(CWM.LDMC) + factor(Ammonium) + factor(Nitrate) + 
factor(Minerals) + scale(pH) + scale(CWM.LDMC):factor(Ammonium) + scale(CWM.LDMC):factor(Nitrate) + scale(CWM.LDMC):factor(Minerals), data = parkgrass)

M9_IT<- lm(Harvest~scale(CWM.SLA) + factor(Ammonium) + factor(Nitrate) + 
factor(Minerals) + scale(pH) + scale(CWM.SLA):factor(Ammonium) + scale(CWM.SLA):factor(Nitrate) + scale(CWM.SLA):factor(Minerals), data = parkgrass)

M10_IT<- lm(Harvest~factor(Ammonium) + factor(Nitrate) + factor(Minerals) + 
scale(pH) + factor(Ammonium):factor(Minerals) + factor(Nitrate):factor(Minerals) + factor(Ammonium):scale(pH) + factor(Nitrate):scale(pH) + factor(Minerals):
scale(pH), data = parkgrass)

AICs<- AIC(M1_IT, M2_IT, M3_IT, M4_IT, M5_IT, M6_IT, M7_IT, M8_IT, M9_IT, M10_IT)
DoF<- AICs[,1] # first col of AICs is the DoFs
AICsNum<- AICs[,2] # AIC values
minAW<- min(AICsNum) # finding the minimum AIC 
Delta <- AICsNum-minAW # finding the difference between each AIC and minimum AIC 
RL <- exp(-0.5*Delta) # finding the relative likelihood of each AIC/model 
wi <- RL/sum(RL) # weighting these relative likelihoods 
AkaikeWeights_table<- data.frame(Model=1:10,DoF=DoF, AIC=round(AICsNum, digits = 2), AICDifferences= round(Delta, digits = 2), AkaikeWeights=round(wi, digits=2))
AkaikeWeights_table
    # if I were to repeat the expt many times
    # 52% of the time model 7 is the best model, 31% model 2 is the best, 11% model 1 
    # present as many models as you want- capture 100% likelihood or less

# models 1,2 and 7 interpretation
summary(M1_IT)
plot_model(M1_IT, show.values = TRUE, show.intercept = TRUE)
summary(M2_IT)
plot_model(M2_IT, show.values = TRUE, show.intercept = TRUE)
summary(M7_IT)
plot_model(M7_IT, show.values = TRUE, show.intercept = TRUE)

tab_model(M1_IT, M2_IT, M7_IT, file = "../results/model_summary.html") #puts all three models in one table
    # model 7 has different slope for seedmass
    # model 7- the seedmass slope is different for ammonium 2
    # etc
