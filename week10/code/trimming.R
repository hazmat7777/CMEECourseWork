# housekeeping
rm(list = ls())

# sequence editor
install.packages("Biostrings")
BiocManager::install("Biostrings")

library(Biostrings)

# Read sequences from a FASTA file
sequences <- readDNAStringSet("../data/Pestedepestisdataset.tex")


names(sequences)


sequences2<- sequences

sequences2[[1]] <- subseq(sequences[[1]], start = 218, end = 2018)
sequences2[[2]] <- subseq(sequences[[2]], start = 218, end = 2018)
sequences2[[3]] <- subseq(sequences[[3]],start = 62, end = 1834)
11071

# Indices of sequences to trim
indices_to_trim <- c(4, 5, 6, 7, 8, 10, 11, 12, 13, 14, 15)

# Trim the specified sequences
for (i in indices_to_trim) {
  sequences2[[i]] <- subseq(sequences[[i]], start = 9349, end = 11071)
}
sequences2[[9]] <- subseq(sequences[[9]],start = 62, end = 1834)

###########################

sequences3 <- readDNAStringSet("../data/Pestedepestisdataset.tex")
names(sequences3)

sequences3[[1]] <- subseq(sequences3[[1]], start = 1, end = 6538)
sequences3[[7]] <- subseq(sequences3[[7]], start = 1, end = 6538)

indices <- c(2:6, 8, 10:13)
for (i in indices) {
  sequences3[[i]] <- subseq(sequences3[[i]], start = 9287, end = 15824)
}

length(sequences3[[1]])
length(sequences3[[2]])
length(sequences3[[3]])
length(sequences3[[5]])
length(sequences3[[9]])

sequences3[[9]] <- subseq(sequences3[[9]], start = (9300-13), end = (15831-7))

## write the seqs

writeXStringSet(sequences3, file = "../data/trimmedsequences4.fasta")