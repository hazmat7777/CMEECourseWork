## WF DIPLOID SIMULATOR

sim_genetic_drift <- function(p0=0.5,t=10, N=10)
{
# INITIALISATION

# pop is a list storing all the allelic configs 
# from gen 0 to t, hence (t+1) elements
population <- list()
length(population)<- t+1

# give names to the elements in population
for (i in 1:length(population))
    {names(population)[i]<- paste(c('generation',i-1), collapse='')}

# also keep track of allele freq over time as a vectoir
allele.freq<- rep(NA, t+1)

#at gen 0 there are (2*N*p0)copies of allele 0
# shuffle these alleles and assign them into a 2-by-N matrix
k <- ceiling(2*N*p0)
population[[1]] <- matrix(sample(c(rep(0,k), rep(1,2*N-k))), nr = 2)

# the initial allele freq
allele.freq[1] <- sum(population[[1]]==0)/(2*N)

# PROPAGATION

for (i in 1:t)
    {
        # sample alleles in next gen
        # based on the allele freq in current gen
        population[[i+1]]<- matrix(sample(0:1, size = 2*N, 
                prob = c(allele.freq[i], 1-allele.freq[i]),
                replace = TRUE), nr = 2)
        # allele freq at next gen
        allele.freq[i+1]<- sum(population[[i+1]]==0)/(2*N)
    }

        
# OUTPUTS

# to return multiple, put elements into one big list
return(list(population=population, allele.freq=allele.freq))

}

## Monte Carlo estimations

result_MC<- rep(NA, 10000)

#find final allele freq
for (i in 1:length(result_MC))
{
    result_MC[i]<- sim_genetic_drift(p0=0.5,N=200,t=10)$allele.freq[11]
}

# RESULTS
mean(result_MC)
var(result_MC)

# distrib
hist(result_MC, main = 'Histogram of 10000 final allele freqs', xlab = 'allele freq')



### WF SIMULATOR, ESTIMATE TIME TO FIXATION/EXTINCTION

sim_drift_persistence_time <- function(p0=0.5, N=10)
{
# INITIALISATION

# keep track of p and t
p <- p0
t <- 0

# PROPAGATION
while (p>0 & p<1)
{
    # allele freq next gen
    p<-rbinom(1, size=2*N, prob=p)/(2*N) # take one value, 2*N times 
    t<- t+1
}

# OUTPUT

return(t)

}

## results

result_MC<- rep(NA, 1000)

for (i in 1:length(result_MC))
{
    result_MC[i]<- sim_drift_persistence_time(p0 = 0.02, N=200)
}

mean(result_MC)
var(result_MC)

hist(result_MC, xlab = "time to extinction")


### INCORPORATING MIGRATION

sim_drift_mig <- function(p0A=0.5, p0B = 0.5, t=10, mA = 0.1, mB = 0.1, N=10)
{
# INITIALISATION

# track populations
popA <- list()
length(popA)<- t+1

popB <- list()
length(popA)<- t+1

# give names to the elements in population
# for (i in 1:(t+1))
#     {names(popA)[i]<- paste(c('generation',i-1), collapse='')
#     names(popB)[i]<- paste(c('generation',i-1), collapse='')}

# also keep track of allele freq and FST
allele.freq_A<- rep(NA, t+1)
allele.freq_B<- rep(NA, t+1)
FST <- rep(NA, t+1)

# initial pop structure

# shuffle alleles and assign them into a 2-by-N matrix
kA <- ceiling(2*N*p0A) # k initial copies of allele 0 in pop A
popA[[1]] <- matrix(sample(c(rep(0,kA), rep(1,2*N-kA))), nr = 2)

kB <- ceiling(2*N*p0B) # k initial copies of allele 0 in pop B
popB[[1]] <- matrix(sample(c(rep(0,kB), rep(1,2*N-kB))), nr = 2)

# initial allele freq
allele.freq_A[1] <- sum(popA[[1]]==0)/(2*N)
allele.freq_B[1] <- sum(popB[[1]]==0)/(2*N)

# initial FST
FST[1] <- ((allele.freq_A[1]-allele.freq_B[1])**2)/(mean(c(allele.freq_A,allele.freq_B)))*(1-(mean(c(allele.freq_A,allele.freq_B))))

# PROPAGATION

for (i in 1:t)
    {
        # gametic freq
        allele.freq_A[i+1]<- (1-mA)*allele.freq_A[i] + mA*allele.freq_B[i]

        # sample alleles in next gen
        popA[[i+1]]<- matrix(sample(0:1, size = 2*N, 
                prob = c(allele.freq_A[i], 1-allele.freq_A[i]),
                replace = TRUE), nr = 2)
        popB[[i+1]]<- matrix(sample(0:1, size = 2*N, 
                prob = c(allele.freq_B[i], 1-allele.freq_B[i]),
                replace = TRUE), nr = 2)
        
        # now migration

        
        # allele freq at next gen
        allele.freq_A[i+1]<- sum(popA[[i+1]]==0)/(2*N)
        allele.freq_B[i+1]<- sum(popB[[i+1]]==0)/(2*N)

        # FST
        FST[i+1] <- ((allele.freq_A[i]-allele.freq_B[i])**2)/(mean(c(allele.freq_A[i],allele.freq_B[i])))*(1-(mean(c(allele.freq_A[i],allele.freq_B[i]))))

    }

        
# OUTPUTS

# to return multiple, put elements into one big list
return(list(popA=popA, allele.freq_A=allele.freq_B, allele.freq_B=allele.freq_B, FST=FST))

}

sim_drift_mig()

