#!/usr/bin/env ipython3

"""Script to identify oaks from a csv file and output them to a separate file."""

__appname__ = 'oaks_debugme.py'


### Imports ###
import csv  # CSV module for file operations
import sys  # Sys module for command line arguments
import doctest  # Doctest for running tests


### Functions ###
def is_an_oak(name):
    """ Returns True if name starts with 'quercus' 
    >>> is_an_oak('quercus petraea')
    True
    >>> is_an_oak('Quercus petraea')
    True
    >>> is_an_oak('Quercuss petraea')
    False
    >>> is_an_oak('Quercusquercus petraea')
    False
    >>> is_an_oak('Fraxinus excelsior')
    False
    >>> is_an_oak('Fagus sylvatica')
    False
    """
    # Check if the first word matches 'quercus'
    return name.lower() == "quercus"
    
    
def main(argv): 
    """ Main entry point of the program"""
    with open('../data/TestOaksData.csv','r') as f, open('../data/JustOaksData.csv','w') as g:
        taxa = csv.reader(f)
        csvwrite = csv.writer(g)
        csvwrite.writerow(['Genus', ' Species'])
        next(taxa) # skip the header row
        for row in taxa:
            print(row)
            print ("The genus is: ") 
            print(row[0] + '\n')
            if is_an_oak(row[0]):
                print('FOUND AN OAK!\n')
                csvwrite.writerow([row[0], row[1]])
            else:
                print('Not an oak.\n')    

    return 0

if (__name__ == "__main__"): #Ensures main function runs when called from command line
    status = main(sys.argv)  # Run main function with arguments
    doctest.testmod()  # Run embedded tests