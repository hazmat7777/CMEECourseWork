#!/usr/bin/env python3
"""Script to demonstrate how to use the sys module to interact with command-line arguments."""


import sys
print("This is the name of the script:", sys.argv[0])
print("Number of arguments: ", len(sys.argv))
print("The arguments are: ", str(sys.argv))