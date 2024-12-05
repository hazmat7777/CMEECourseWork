#!/usr/bin/env python3

"""Defining and testing various mathematical functions"""

__appname__ = 'maths functions'
__author__ = 'Harry'

## imports ## 
import sys # module to interface our program with the operating system
import doctest
## functions ## 

## functions ##

def even_or_odd(x=0):
    """Find whether a number x is even or odd.
    
    >>> even_or_odd(22)
    '22 is even!'
    >>> even_or_odd(33)
    '33 is odd!'
    >>> even_or_odd(-4)
    '-4 is even!'  # Edge case: Negative even number
    """
    if x % 2 == 0:
        return f"{x} is even!"
    return f"{x} is odd!"
    
def largest_divisor_five(x=120):
    """Find which is the largest divisor of x among 2,3,4,5.
    
    >>> largest_divisor_five(120)
    'The largest divisor of 120 is 5'
    >>> largest_divisor_five(121)
    'No divisor found for 121!' 
    >>> largest_divisor_five(6)
    'The largest divisor of 80 is 3'
    """
    largest = 0
    if x % 5 == 0:
        largest = 5
    elif x % 4 == 0: 
        largest = 4
    elif x % 3 == 0:
        largest = 3
    elif x % 2 == 0:
        largest = 2
    else: 
        return f"No divisor found for {x}!"
    return f"The largest divisor of {x} is {largest}"

def is_prime(x=70):
    """Find whether an integer is prime.
    
    >>> is_prime(60)
    '60 is not a prime: 2 is a divisor'
    >>> is_prime(59)
    '59 is a prime!'
    >>> is_prime(1)
    '1 is not a prime: No divisors found'
    """
    if x < 2:
        return f"{x} is not a prime: No divisors found"
    for i in range(2, x): 
        if x % i == 0:
            return f"{x} is not a prime: {i} is a divisor"
    return f"{x} is a prime!"

def find_all_primes(x=22):
    """Find all the primes up to x
    
    >>> find_all_primes(10)
    'There are 4 primes between 2 and 10'
    >>> find_all_primes(5)
    'There are 3 primes between 2 and 5'
    >>> find_all_primes(1)
    'There are 0 primes between 2 and 1'
    """
    allprimes = []
    for i in range(2, x + 1):
        if is_prime(i):
            allprimes.append(i)
    return f"There are {len(allprimes)} primes between 2 and {x}"
    
def main(argv):
    print(even_or_odd(22))
    print(even_or_odd(33))
    print(largest_divisor_five(120))
    print(largest_divisor_five(59))
    print(is_prime(60))
    print(is_prime(59))
    print(find_all_primes(100))
    return 0

if __name__ == "__main__":
    """Makes sure the "main" function is called from command line"""
    status = main(sys.argv)
    sys.exit(status)

