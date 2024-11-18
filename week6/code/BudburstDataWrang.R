## load data
# trees
trees <- read.csv("../data/trees.csv")
head(trees)
str(trees)
    # species and location for trees
max(trees$TreeID)
length(unique(trees$TreeID))

# girth
girth <- read.csv("../data/girth.csv")
head(girth)
str(girth)
    # girth of monitored trees
max(girth$TreeID)
    # 3960
length(unique(girth$TreeID))
    # only have girth for 2604 trees
    # as there are 3500 rows some trees have multiple rows
        # measured over multiple years
unique(girth$Date)
    sum(girth$Date == "30/03/2021")
    sum(girth$Date == "23/03/2021")
    # 3 values after 2019
    # remove them

girth <- subset(girth, girth$Date == "2007-2015\n" | girth$Date == "2016-2019\n")
    # checking it worked
    str(girth)
    unique(girth$Date)

# budburst
bburst <- read.csv("../data/phenology.csv")
head(bburst)
str(bburst)
summary(bburst)
unique(bburst$Year)
unique(bburst$remarks)
    # removing observations where there is uncertainty in comment
    bburst_nocomment <- subset(bburst, remarks == "NA\n"| is.na(remarks) | remarks == "\n")
    str(bburst_nocomment)
    unique(bburst_nocomment$remarks)
unique(bburst_nocomment$Score) # needs cleaning
    # excluding error scores
    bburst_scores <- subset(
        bburst_nocomment,
        !grepl("^<\\$$|^>\\$$|^>7$|^>8$|^>9$|^>10$|5>4|^<7$", Score) # ^ means at start of word
        )
    str(bburst_scores)
        unique(bburst_scores$Score)
    
    # converting uncertain scores to min or max boundary
    library(dplyr)
    bb_newscores <- bburst_scores %>%
        mutate(Score = case_when(
            Score == "<1" ~ 0,       # Convert "<1" to 0
            Score == ">1" ~ 1,       # Convert ">1" to 1
            Score == "<2" ~ 1,       # Convert "<2" to 1
            Score == ">2" ~ 2,       # Convert ">2" to 2
            Score == "<3" ~ 2,       # Convert "<3" to 2
            Score == ">3" ~ 3,       # Convert ">3" to 3
            Score == "<4" ~ 3,       # Convert "<4" to 3
            Score == ">4" ~ 4,       # Convert ">4" to 4
            Score == "<5" ~ 4,       # Convert "<5" to 4
            Score == ">5" ~ 5,       # Convert ">5" to 5
            Score == "<6" ~ 5,       # Convert "<6" to 5
            Score == ">6" ~ 6,       # Convert ">6" to 6
            Score %in% c("0", "1", "2", "3", "4", "5", "6") ~ as.numeric(Score),  # Directly convert "0" to "6"
            TRUE ~ NA_real_           # Set any unexpected values to NA
        ))
    str(bb_newscores)
    unique(bb_newscores$Score)





length(bb_newscores$TreeID)
length(unique(bb_newscores$TreeID))
    # each tree has several burst scores taken per year
    onetree <- subset(bb_newscores, TreeID == "2131")
    head(onetree)
    # some trees had bb recorded on multiple years

# clean out the needless columns
bb_ns_cleaned <- subset(bb_newscores, select = -c(VisitID, remarks))
str(bb_ns_cleaned)

# Calculating day of year from date
install.packages("lubridate")
library(lubridate)

bb_ns_dates <- bb_ns_cleaned %>%
    mutate(
        Date = dmy(Date),          # Convert dd/mm/yyyy to Date format
        Year = year(Date),          # Extract just the year
        DayOfYear = yday(Date)      # calculates day of year
    )

tail(bb_ns_dates)
unique(bb_ns_dates$Year) # why is there no 2014 or 2019?
    # check og data
    bb2014n19 <- bburst %>%
        mutate(
            Date = dmy(Date),
            Year = year(Date)
        ) 
    print(subset(bb2014n19, Year == 2014 | Year == 2019))
        # there are none from these years. OK

str(bb_ns_dates)

# deciding what level to set full burst
sum(bb_ns_dates$Score >= 3)
sum(bb_ns_dates$Score < 3)

# could set fullburst at a score of 3
# if I remove trees for which first recorded budburst was >3.
# finding trees which were measured the latest
result <- bb_ns_dates %>%
    group_by(TreeID) %>% # Group by TreeID
    summarise(EarliestDate = min(DayOfYear, na.rm = TRUE)) %>% # Get the earliest date per TreeID
    filter(EarliestDate == max(EarliestDate)) # Filter for the TreeID with the latest earliest bb date

print(result)
subset(bb_ns_dates, TreeID == 3295)
    # for this tree we don't know when bb score 3 was as we missed it!

# filtering out the trees where first recorded score of the year > 3
bb_ns_d_pre3 <- bb_ns_dates %>%
    mutate(Year = year(Date)) %>% # Extract year from Date
    group_by(TreeID, Year) %>%  # Group by TreeID and Year
    arrange(Date) %>% # Sort by Date within each TreeID-Year group
    slice(1) %>% # Keep only the first (earliest) entry for each TreeID-Year
    filter(Score < 3) %>% # Keep only years where the earliest Score is less than 3
    ungroup() %>% # Ungroup for the join
    select(TreeID, Year) %>% # Keep only TreeID and Year
    inner_join(bb_ns_dates, by = c("TreeID", "Year"))  # Join back to keep only these TreeIDs and Years data to keep only these TreeIDs

# Budburst day of year
budburst <- as.data.frame(bb_ns_d_pre3)
str(budburst)

# adding column for if bud has fully burst
budburst <- budburst %>%
    mutate(Full_burst = ifelse(Score >= 3, 1, 0)) # if >=3 then Fb is 1

str(budburst) 

print(subset(budburst, TreeID == 1))

# merging with trees species
str(trees)

trees_cleaned <- trees[, 1:2]
    str(trees_cleaned)
unique(trees$species)

bb_sp <- merge(budburst, trees_cleaned, by = "TreeID")

str(bb_sp)

unique(bb_sp$species)
sum(is.na(bb_sp$species))
    # 25 NAs to remove
bb_sp_na <- subset(bb_sp, !is.na(species))

str(bb_sp_na)

# date of first full budburst column
bb_sp_firstbb <- bb_sp_na %>% 
    group_by(TreeID, Year) %>%
    filter(Full_burst == 1) %>%
    summarize(EarliestFullBurst = min(DayOfYear), .groups = 'drop') %>%
    right_join(bb_sp_na, by = c("TreeID", "Year"))

str(bb_sp_firstbb)

# calculate the mean first bb date per treeID
bb_sp_firstbb_mean <- bb_sp_firstbb %>% 
    group_by(TreeID) %>%
    summarize(mean_first_bb = mean(EarliestFullBurst), .groups = 'drop') %>%
    right_join(bb_sp_firstbb, by = c("TreeID"))

str(bb_sp_firstbb_mean)

length(unique(bb_sp_firstbb_mean$TreeID))
    # 3779 trees

# what is the overall mean first bb and sd
# Calculate earliest full burst per TreeID and Year, then compute overall mean and SD
bb_sp_na %>% 
    group_by(TreeID, Year) %>%
    filter(Full_burst == 1) %>%
    summarize(EarliestFullBurst = min(DayOfYear), .groups = 'drop') %>%
    summarize(mean_EarliestFullBurst = mean(EarliestFullBurst, na.rm = TRUE),
              sd_EarliestFullBurst = sd(EarliestFullBurst, na.rm = TRUE))


## incorporating girth

# averaging girth over study
str(girth)
meangirth <- girth %>%
    group_by(TreeID) %>%
    summarize(Mean_girth_cm = mean(Girth_cm), .groups = 'drop') %>% # creates meangirth per treeID
    right_join(girth, by = "TreeID")

str(meangirth)

# getting rid of other cols
cleangirth <- meangirth[,1:2]
str(cleangirth)

# merging datasets
bb_sp_girth <- merge(x = bb_sp_firstbb_mean, y = cleangirth, by = "TreeID", all.y = TRUE)

str(bb_sp_girth)

## reducing down the table
# only relevant columns:

bb_sp_girth_red <- bb_sp_girth %>% 
    select(TreeID, mean_first_bb, species, Mean_girth_cm)
str(bb_sp_girth_red)

# Reduce data to one row per TreeID
reduced_bbspgirth <- bb_sp_girth_red %>%
    group_by(TreeID) %>%
    summarize(
        species = first(species),
        mean_first_bb = first(mean_first_bb),
        Mean_girth_cm = first(Mean_girth_cm),  # Average girth across all years
        .groups = 'drop'
    )

reduced_bbspgirth <- as.data.frame(reduced_bbspgirth)
str(reduced_bbspgirth)
head(reduced_bbspgirth)
    # why are there NaNs
rd_bbspgirth_na <- subset(reduced_bbspgirth, 
    !is.na(mean_first_bb) & !is.na(Mean_girth_cm))
str(rd_bbspgirth_na)

###########################
## running an lm

# for reduced data
simplemodel <- lm(mean_first_bb ~ Mean_girth_cm, data = rd_bbspgirth_na)
summary(simplemodel)

# for full data
model <- lm(mean_first_bb ~ Mean_girth_cm, data = bb_sp_girth)
summary(model)

plot(mean_first_bb ~ Mean_girth_cm, data = bb_sp_girth)

## adding random effects = mixed models

install.packages("lme4")
library(lme4)

# for reduced data
simplemixedmodel <- lmer(mean_first_bb ~ Mean_girth_cm + (1 | species), data = rd_bbspgirth_na)
summary(simplemixedmodel) #########################

# view model
require(ggplot2)
ggplot(rd_bbspgirth_na, aes(x = Mean_girth_cm, y = mean_first_bb)) +
    geom_point()

# trying with logaxes as looks nonlinear
ggplot(rd_bbspgirth_na, aes(x = log(Mean_girth_cm), y = mean_first_bb)) +
    geom_point()

# reincorporating into model
simplmixdlogmodel <- lmer(mean_first_bb ~ log(Mean_girth_cm) + (1 | species), data = rd_bbspgirth_na)
summary(simplmixdlogmodel)
    # should remove species as it explains ZERO of the variation
    # which would make it NOT a mixed model :(

reduced_simple_model <- lm(mean_first_bb ~ log(Mean_girth_cm), data = rd_bbspgirth_na)
summary(reduced_simple_model)

plot(mean_first_bb ~ log(Mean_girth_cm), data = rd_bbspgirth_na)

# model validation
par(mfrow = c(2,2))
plot(reduced_simple_model) ########################################



## mixed model incorporating TREEID and Year
bigmixedmodel <- lmer(EarliestFullBurst ~ log(Mean_girth_cm) + (1 | Year) + (1 | TreeID) + (1 | species), data = bb_sp_girth)

summary(bigmixedmodel)
AIC(bigmixedmodel)

str(bb_sp_girth)

# should i lose the random effects?
model_no_species <- lmer(EarliestFullBurst ~ log(Mean_girth_cm) + (1 | Year) + (1 | TreeID), data = bb_sp_girth)

# Model without TreeID random effect
model_no_tree <- lmer(EarliestFullBurst ~ log(Mean_girth_cm) + (1 | Year), data = bb_sp_girth)

# Model without Year random effect
model_no_year <- lmer(EarliestFullBurst ~ log(Mean_girth_cm) + (1 | TreeID), data = bb_sp_girth)

# LRT to test the significance of TreeID random effect
lrtest(bigmixedmodel, model_no_tree)

# LRT to test the significance of Year random effect
lrtest(bigmixedmodel, model_no_year)

# sp?
lrtest(bigmixedmodel, model_no_species)

    # i dont care, species should never be a random effect! renaming bmm
    # and as a fixed effect nothing is sig

bigmixedmodelfinal <- lmer(EarliestFullBurst ~ log(Mean_girth_cm) + (1 | Year) + (1 | TreeID), data = bb_sp_girth)
summary(bigmixedmodelfinal)

# sve the summary w sjplot tabmodel()
install.packages("bayestestR")
library(sjPlot)

tab_model(bigmixedmodelfinal,
    title = "Summary of Linear Mixed Model for Budburst Timing",
    dv.labels = "Julian Date of Full Budburst",
    digits = 3,
    show.se = TRUE, 
    show.icc = TRUE,          # Display ICC for random effects
    show.re.var = TRUE,       # Show random effects variance
    show.stat = "std",
    show.p = FALSE,
    show.ci = FALSE,
    file = "../results/budburst_model_summary3.tex")


str(bb_sp_girth)
length(!is.na(bb_sp_girth$EarliestFullBurst))

# Count unique combinations of TreeID and Year
group_count <- bb_sp_girth %>%
    distinct(TreeID, Year) %>%
    summarise(num_groups = n())

# Display the result
group_count

# checking if spp are sig different
anova_model <- aov(EarliestFullBurst ~ species, data = bb_sp_girth)
summary(anova_model)

str(bb_sp_girth)

finaldata <- subset(bb_sp_girth, select = c(TreeID, Year, Full_burst, Date, species, Mean_girth_cm))
str(finaldata)

finaldata_summary <- finaldata %>%
    filter(Full_burst == 1) %>%                                   # Keep only rows with Full_burst == 1
    group_by(TreeID, Year) %>%                                    # Group by TreeID and Year
    slice_min(order_by = yday(Date), n = 1) %>%                   # Keep only the earliest day of Full_burst == 1
    mutate(EarliestFullBurst = yday(Date)) %>%
    ungroup()       

str(finaldata_summary)
unique(finaldata_summary$Full_burst)

mean(finaldata_summary$EarliestFullBurst)
sd(finaldata_summary$EarliestFullBurst)


#checking sp differences
anova_model <- aov(EarliestFullBurst ~ species, data = finaldata_summary)
summary(anova_model)

## all important: checking model
bigmixedmodelfinal <- lmer(EarliestFullBurst ~ log(Mean_girth_cm) + (1 | Year) + (1 | TreeID), data = finaldata_summary)
summary(bigmixedmodelfinal)
AIC(bigmixedmodelfinal) ######################################

# diagnostic plots
dev.off()
par(mfrow = c(2,2))
plot(bigmixedmodelfinal, which = 2)

plot_model(bigmixedmodelfinal, type = "resid")
plot_model(bigmixedmodelfinal, type = "diag")
plot_model(bigmixedmodelfinal, type = "re")

library(performance)

# Display all diagnostic plots in one window
check_model(bigmixedmodelfinal)

boxplot(finaldata_summary$EarliestFullBurst)
# many outliers

cooks_d <- cooks.distance(bigmixedmodelfinal)
threshold <- 1
sum(cooks_d > threshold)

nrow(finaldata_summary)
length(unique(finaldata_summary$TreeID))

sum(is.na(finaldata_summary$EarliestFullBurst))

max(finaldata_summary$Year)

# quick one
bigmixedfixedmodelfinal <- lmer(EarliestFullBurst ~ log(Mean_girth_cm) + Year + (1 | TreeID), data = finaldata_summary)
summary(bigmixedfixedmodelfinal)
AIC(bigmixedfixedmodelfinal)
    # ignore

# Model without TreeID random effect
model_no_tree <- lmer(EarliestFullBurst ~ log(Mean_girth_cm) + (1 | Year), data = finaldata_summary)

# Model without Year random effect
model_no_year <- lmer(EarliestFullBurst ~ log(Mean_girth_cm) + (1 | TreeID), data = finaldata_summary)

# LRT to test the significance of TreeID random effect
lrtest(bigmixedmodelfinal, model_no_tree)

# LRT to test the significance of Year random effect
lrtest(bigmixedmodelfinal, model_no_year)

AIC(model_no_tree)
AIC(model_no_year)



plot <- ggplot(finaldata_summary, aes(x = log(Mean_girth_cm), y = EarliestFullBurst)) +
    geom_jitter(alpha = 0.3, col = "red") + # like geom_point
    geom_smooth(method = "lm", fill = "darkblue", alpha = 0.6, se = TRUE, size = 0.5, color = "black") +
    labs(x = "Log of Mean Trunk Girth (cm)", y = "Date of first full budburst",
    title = "Impact of Tree Girth on Budburst Timing") +
    theme_bw() +
    theme(
        plot.title = element_text(size = 20),  # Increase title size
        axis.title.x = element_text(size = 16),
        axis.title.y = element_text(size = 16),
        axis.text.x = element_text(size = 16),
        axis.text.y = element_text(size = 16)
    )

dev.off()

plot4 <- ggplot(finaldata_summary, aes(x = log(Mean_girth_cm), y = EarliestFullBurst)) +
    geom_jitter(alpha = 0.5, size = 1) + # like geom_point
    geom_smooth(method = "lm", color = "black", se = TRUE, linetype = "solid", alpha = 0.8, size = 0.5) +
    labs(x = "Log of Mean Trunk Girth (cm)", y = "Date of first full budburst") +
    theme_minimal(base_size = 12) + # Minimal theme as a base
    theme(
        axis.title.x = element_text(face = "italic", size = 14),          # Italic x-axis label
        axis.title.y = element_text(face = "italic", size = 14),          # Italic y-axis label
        panel.grid = element_blank(),                                     # Remove grid lines
        axis.line = element_line(color = "black"),                        # Add axis lines
        axis.ticks = element_line(color = "black"),                       # Add axis ticks
        panel.border = element_rect(fill = NA, color = "black"),          # Add border
        text = element_text(family = "serif")
    )

ggsave("../results/myplot4.pdf", plot = plot4, width = 6, height = 4)  # for PDF






# fixed effect plot
ggplot(bb_sp_girth, aes(x = log(Mean_girth_cm), y = EarliestFullBurst)) +
    geom_point(alpha = 0.2) +
    geom_smooth(method = "lm", color = "blue") +
    labs(title = "Effect of Mean Girth on Earliest Full Burst",
         x = "Log(Mean Girth in cm)", y = "Earliest Full Burst (Day of Year)")

# Plot random intercepts for TreeID and Year

library(sjPlot)
plot_model(bigmixedmodel, type = "re", title = "Random Effects for TreeID and Year")
    # is there a bit of a trend in year..? try year as a fixed effect:

### year as a fixed effect 

yeargirthmixedmodel <- lmer(EarliestFullBurst ~ log(Mean_girth_cm) + Year + (1 | TreeID), data = bb_sp_girth)
summary(yeargirthmixedmodel)
     # dpnt use this- see lrtset check later

###########################

# checking which model is the best

install.packages("lmtest")
library(lmtest)

lrtest(yeargirthmixedmodel, bigmixedmodel) # year should be random not fixed

AIC(bigmixedmodel)
formula(reduced_simple_model)
AIC(reduced_simple_model)
    # lower AIC

###############################

reduced_simple_model <- lm(mean_first_bb ~ log(Mean_girth_cm), data = rd_bbspgirth_na)
summary(reduced_simple_model)
anova(reduced_simple_model)

ggplot(rd_bbspgirth_na, aes(x = log(Mean_girth_cm), y = mean_first_bb)) +
    geom_point() +
    geom_smooth(method = "lm", se = TRUE)+
    labs(x = "Log(Mean girth in cm)", y = "Date of first full budburst",
    title = "Impact of tree girth on budburst timing")

# converting julian day to date?
    # would need to set to a non leap year
str(rd_bbspgirth_na)
rd_bbspgirth_na$Date <- as.Date(rd_bbspgirth_na$mean_first_bb - 1, origin = paste0("2007", "-01-01"))
class(rd_bbspgirth_na$Date)

dev.off()

ggplot(rd_bbspgirth_na, aes(x = log(Mean_girth_cm), y = Date)) +
    geom_point() +
    geom_smooth(method = "lm", se = TRUE) +
    scale_y_date(date_labels = "%b", date_breaks = "1 month") +
    labs(x = "Log of Mean Trunk Girth (cm)", y = "Date of first full budburst",
    title = "Impact of Tree Girth on Budburst Timing") +
    theme_bw()



# or do I use the bigger model?

# or do I incorporate e.g. number of limbs?? #############################
str(rd_bbspgirth_na)

girth_branches <- merge(x = girth, y = rd_bbspgirth_na, by = "TreeID", all.y = TRUE)

str(girth_branches)
unique(girth_branches$Stems)

sum(girth_branches$Stems == 4)
    # remove 2 3 and 4?

unique(girth_branches$TreeForm)
sum(girth_branches$TreeForm == "maiden")

girth_maidens <- subset(girth_branches, TreeForm == "maiden")

str(girth_maidens)

girth_maiden_model <- lm(mean_first_bb ~ log(Mean_girth_cm), data = girth_maidens)
summary(girth_maiden_model)
AIC(girth_maiden_model)
    # higher- ignore it

ggplot(girth_maidens, aes(x = log(Mean_girth_cm), y = Date.y)) +
    geom_point() +
    geom_smooth(method = "lm", se = TRUE) +
    scale_y_date(date_labels = "%b", date_breaks = "1 month") +
    labs(x = "Log of Mean Trunk Girth (cm)", y = "Date of first full budburst",
    title = "Impact of Tree Girth on Budburst Timing") +
    theme_bw()
    
