## imports
import ipdb
import csv

# Two example sequences to match
#seq2 = "ATCGCCGGATTACGGG"
#seq1 = "CAATTCGGAT"

with open('../sandbox/seqs_to_align2.csv', 'r') as file:
    reader = csv.reader(file)               #read the csv as a nested list
    seqs = [item for row in reader for item in row]    #uses a list comprehension (?) to create a vector from those rows

seq1 = seqs[0]
seq2 = seqs[1]
seq1
seq2

# Assign the longer sequence s1, and the shorter to s2
# l1 is length of the longest, l2 that of the shortest

l1 = len(seq1)
l2 = len(seq2)
if l1 >= l2:
    s1 = seq1
    s2 = seq2
else:
    s1 = seq2
    s2 = seq1
    l1, l2 = l2, l1 # swap the two lengths

# A function that computes a score by returning the number of matches starting
# from arbitrary startpoint (chosen by user)
def calculate_score(s1, s2, l1, l2, startpoint):
    global matched
    matched = "" # to hold string displaying alignements
    score = 0
    for i in range(l2):
        if (i + startpoint) < l1:
            if s1[i + startpoint] == s2[i]: # if the bases match
                matched = matched + "*"
                score = score + 1
            else:
                matched = matched + "-"

    # some formatted output
    print("." * startpoint + matched) # first prints 'startpoint' many dots           
    print("." * startpoint + s2)
    print(s1)
    print(score) 
    print(" ")

    return score


# Test the function with some example starting points:
#calculate_score(s1, s2, l1, l2, 0)
#calculate_score(s1, s2, l1, l2, 1)
#calculate_score(s1, s2, l1, l2, 5)

# now try to find the best match (highest score) for the two sequences
my_best_align = None
my_best_score = -1

for i in range(l1): #trying all startpoints
    z = calculate_score(s1, s2, l1, l2, i) 
    if z > my_best_score:
        #global my_best_matched #dont need this, as not in a function
        my_best_matched = "." * i + matched
        my_best_align = "." * i + s2 # adding 'i' many dots to align the seqs
        my_best_score = z 

print(my_best_align) # Note that you just take the last alignment with the highest score
print(s1)
print("Best score:", my_best_score)


with open('../results/best_alignment2.txt', 'w') as f:
    f.write(my_best_matched + '\n')
    f.write(my_best_align + '\n') # Note that you just take the last alignment with the highest score
    f.write(s1 + '\n')
    f.write(f"Best score: {my_best_score}\n")

