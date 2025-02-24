#!/bin/sh
# Author: Harry Trevelyan hjt24@ic.ac.uk
# Script: tabtocsv.sh
# Description: substitute the tabs in the files with commas
#
# Saves the output into a .csv file
# Arguments: 1 -> tab delimited file
# Date: Oct 2019

##old version

#echo "Creating a comma delimited version of $1 ..."
#cat $1 | tr -s "\t" "," >> $1.csv
#echo "Done!"

##improved version

if [ $# -eq 1 ]; then
    echo "Creating a comma delimited version of $1 ..."
    cat "$1" | tr -s "\t" "," >> "$1.csv"
else
    echo "Please enter one file."
    exit 1
fi

echo "Done!"

exit