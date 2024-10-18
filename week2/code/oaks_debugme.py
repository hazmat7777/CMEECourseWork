import csv
import sys
import ipdb
import doctest 

#Define function
def is_an_oak(name):
    """ Returns True if name is 'quercus' 
    >>> is_an_oak('Pinus')
    False
    >>> is_an_oak('Quercus')
    True
    >>> is_an_oak('Quercuss')
    False
    """
    return name.lower() == 'quercus'

def main(argv): 
    with open('../data/TestOaksData.csv','r') as f, open('../data/JustOaksData.csv','w') as g:
        taxa = csv.reader(f)

        csvwrite = csv.writer(g)
        next(taxa) # skip the header rows
        oaks = set()
        for row in taxa:
            #ipdb.set_trace()
            print(row)
            print ("The genus is: ") 
            print(row[0] + '\n')
            if is_an_oak(row[0]):
                print('FOUND AN OAK!\n')
                csvwrite.writerow([row[0], row[1]])
            else:
                print('Not an oak.\n')    

    return 0
    
if (__name__ == "__main__"):
    status = main(sys.argv)
    doctest.testmod(verbose=True)