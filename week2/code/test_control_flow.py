#!/usr/bin/env python3

"""Some functions exemplifying the use of control statements"""

__author__ = 'Harry'
__version__ = '0.0.1'

## imports ## 

import sys # module to interface our program with the operating system
import doctest

## functions ## 

def even_or_odd(x=0): # if not specified, x should take value 0
    """Find whether a number x is even or odd.

    >>> even_or_odd(10)
    '10 is even!'

    >>> even_or_odd(5)
    '5 is odd!'

    in case of negative numbers, the positive is taken:
    >>> even_or_odd(-2)
    '-2 is even!'

    """
    # Define function to be tested
    if x % 2 == 0:
        return f"{x} is even!"
    return f"{x} is odd!"

def main(argv):
    print(even_or_odd(22))
    print(even_or_odd(33))
    return 0

#if __name__ == "__main__":
    #"""Makes sure the "main" function is called from command line"""
    #status = main(sys.argv)

doctest.testmod()   #to run with embedded tests (???)
    
