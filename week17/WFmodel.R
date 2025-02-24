
sim_genetic_drift <- function(p0=0.5,t=10, N=10)
{
# INITIALISATION
    # what do we need to track over time?
    # what are the appropriate object, data types? 
    # what are initial arguments?
    # what are the initial conditions?

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
    # use info from gen i to sample alleles at gen (i+1)
        # or from gen (i-1) to i
    # use a loop for recursive calc?
        # for()? sample()? while()?

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
    # whatg do we want to know?
    # return() and exit fn

    # you can only return() one element from a fn
    # to return multiple, put elements into one big list
return(list(population=population, allele.freq=allele.freq))

}

sim_genetic_drift()

### MONTE CARLO METHODS
# find mean, variance and distribution of allele freq
# under given condistions

#10000 independent sims
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

######## new challenge

# how many gens will the allele '0' persist 
# before extinction/fixation
# if p0 = 0.05, N = 100

sim_genetic_drift2 <- function(p0=0.5, N=100)
{
# INITIALISATION
# pop is a list of the allelic configs
population <- list()
length(population)

# also keep track of allele freq over time as a vector
allele.freq<- vector()

# also keep track of time
t <- list()

# at gen 0 there are (2*N*p0)copies of allele 0
# shuffle these alleles and assign them into a 2-by-N matrix
k <- ceiling(2*N*p0)
population[[1]] <- matrix(sample(c(rep(0,k), rep(1,2*N-k))), nr = 2)

# the initial allele freq
allele.freq[1] <- sum(population[[1]]==0)/(2*N)

# PROPAGATION
while(allele.freq[i]!== 0| allele.freq[i]!==1)
    {
        population[[i+1]]<- matrix(sample(0:1, size = 2*N, 
                prob = c(allele.freq[i], 1-allele.freq[i]),
                replace = TRUE), nr = 2)
        # allele freq at next gen
        allele.freq[i+1]<- sum(population[[i+1]]==0)/(2*N)    
    }


        
# OUTPUTS
    # whatg do we want to know?
    # return() and exit fn

    # you can only return() one element from a fn
    # to return multiple, put elements into one big list
return(list(population=population, allele.freq=allele.freq))

}


