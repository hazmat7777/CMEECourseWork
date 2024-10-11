#!/bin/bash

# Checking if one file is being called

if [ $# -eq 1 ] && [ -f $1 ]; then
    NumLines=`wc -l < $1`
    echo "The file $1 has $NumLines lines"
    echo

else 
    echo "Please enter one file."

fi