##############################
# FILE INPUT
##############################
"""Script on how to read and input data from external files."""


# Open a file for reading
f = open('../sandbox/test.txt', 'r') #r means open in read mode

# if the object is a file, python will cycle over lines
for line in f: #implicit, doesnt state details of iteration e.g. how many times it runs
    print(line) 

#close the file
f.close()

#same example, skip blank lines
f = open('../sandbox/test.txt', 'r')
for line in f:
    if len(line.strip()) > 0:
        print(line)

f.close()



