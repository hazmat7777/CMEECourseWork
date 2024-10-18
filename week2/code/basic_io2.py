#############################
# FILE OUTPUT
#############################

# Save the elements of a list to a file
list_to_save = range(100)

f = open('../sandbox/testout.txt', 'w') #w for write
for i in list_to_save:
    f.write(str(i) + '\n') # add a newline at the end

f.close()


## simplifying using with open()

with open('../sandbox/testout2.txt', 'w') as f:
    for i in list_to_save:
        f.write(str(i) + '\n') # add a newline at the end
