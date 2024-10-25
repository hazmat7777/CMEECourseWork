"""Script demonstrating how to save objects for later use."""

#############################
# STORING OBJECTS
#############################

# To save an object (even complex) for later use
my_dictionary = {"a key": 10, "another key": 11}

import pickle #can convert files into a byte stream and reread them:

f = open('../sandbox/testp.p', 'wb') ## see b: accept binary files
pickle.dump(my_dictionary, f)   #put my dict in the testp file
f.close

## load the data again
f = open('../sandbox/testp.p', 'rb')
another_dictionary = pickle.load(f) #reread the dumped dict into a new dict
f.close()

print(another_dictionary)