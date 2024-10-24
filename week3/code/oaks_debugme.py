#!/usr/bin/env ipython3

"""Missing oaks problem"""

__appname__ = 'oaks_debugme.py'
__author__ = 'dashing_dingos(4)'  


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
    if len(name.split()[0]) == len("quercus"): 
        return name.lower().startswith("quercus")
    return False
    
    
def main(argv): 
    """ Main entry point of the program"""
    f = open('../data/TestOaksData.csv','r')  # Open input file
    g = open('../results/JustOaksData.csv','w')  # Open output file
    
    taxa = csv.reader(f)  # Read input CSV
    csvwrite = csv.writer(g)  # Prepare to write output CSV
    
    for row in taxa:
        if 'Genus' in row[0]:  # Check for header row
            csvwrite.writerow([row[0], row[1]])  # Write header
            continue
        
        print(row)  # Debugging output
        print("The genus is: ") 
        print(row[0] + '\n')  # Print genus name
        
        if is_an_oak(row[0]):  # Check for oak genus
            print('FOUND AN OAK!\n')  # Found an oak
            csvwrite.writerow([row[0], row[1]])  # Write to output

    return 0  # Return status code


if (__name__ == "__main__"):
    """Ensure main function runs when called from command line"""
    status = main(sys.argv)  # Run main function with arguments
    

doctest.testmod()  # Run embedded tests