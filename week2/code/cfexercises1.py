#!/usr/bin/env python3

"""Description of this program or application.
You can use several lines"""

__appname__ = 'foo functions'
__author__ = 'Harry'

## imports ## 

import sys # module to interface our program with the operating system
import doctest

## functions

def foo_1(x):
    """Find square root.
    >>> foo_1(9)
    3.0

    """
    try:
        return x ** 0.5
    except:
        print("Input must be a number")
        return 1

def foo_2(x, y):
    """Find square root.
    
    >>> foo_2(1, 8)
    8

    """
    try:
        if x > y:
            return x
        return y
    except:
        print("Input must be a number")
        return 1


def foo_3(x, y, z):
    """Places 3 nos in ascending order.
    
    >>> foo_3(8, 4, 2)
    [2, 4, 8]

    """
    try:  
        if x > y:
            tmp = y
            y = x
            x = tmp
        if y > z:
            tmp = z
            z = y
            y = tmp
        if x > y:
            tmp = y
            y = x
            x = tmp
        return [x, y, z]
    except:
        print("Please input 3 numbers")
        return 1


def foo_4(x):
    """Find factorial.
    
    >>> foo_4(6)
    720

    """
    try:
        result = 1
        for i in range(1, x + 1):
            result = result * i
        return result
    except:
        print("Input must be a number")
        return 1

def foo_5(x):
    """Find factorial recursively.
    
    >>> foo_5(6)
    720

    """
    try:
        if x == 1:
            return 1
        return x * foo_5(x - 1)
    except:
        print("Input must be a number")
        return 1



def foo_6(x): # Calculate the factorial of x in a different way; no if statement involved
    """Find factorial.
    
    >>> foo_4(6)
    720

    """
    try:
        facto = 1
        while x >= 1:
            facto = facto * x
            x = x - 1
        return facto
    except:
        print("Input must be a number")
        return 1
    #so for x = 5, start with 5*1. Then x = 4, facto = 20...

## Main ##

def main(argv): #examples of the functioning scripts
    print(foo_1(64))
    print(foo_2(89,54))
    print(foo_3(4, 1, 0.9))
    print(foo_4(3))
    print(foo_5(4))
    print(foo_6(5))

if __name__ == "__main__":
    """Makes sure the "main" function is called from command line"""
    status = main(sys.argv)
    sys.exit(status)

doctest.testmod() # to run with embedded tests


