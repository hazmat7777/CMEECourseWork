#!/usr/bin/env python3
"""Simple script to demonstrate the use of the __name__ special variable."""

# Filename: using)name.py

if __name__ == '__main__':
    print('This program is being run by itself!')
else:
    print('I am being imported from another script/program/module!')

print("This module's name is: " + __name__)