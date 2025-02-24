#!/bin/bash

## cat means stick together or print

# $1 and $2 are the files you want to merge

# $3 is the merged file. Remember this will be output to the current directory unless a separate path is specified in the $3 argument

## old version

#cat "$1" > "$3"
#cat "$2" >> "$3"
#echo "Merged File is"
#cat "$3"

#exit

## new version

#if [ $# -eq 3 ]; then
    #cat $1 > $3
    #cat $2 >> $3

    #echo "Merged File is" 
    #cat $3
    #echo -e "\nConcatenated file was saved as $3" #-e to escape echo to enable special \n

#else
   #echo "Please enter three arguments: two files to concatenate, and the name for the concatenated output."
   #exit

#fi

#exit 


## newest version to additionally check input type and with clearer comments

# Check if exactly 3 arguments are provided
if [ $# -ne 3 ]; then
    echo "Please enter three arguments: two files to concatenate, and the name for the concatenated output."
    exit 1
fi

# Check if the first two arguments are files
if [ -f "$1" ] && [ -f "$2" ]; then #arguments in "" to avoid special characters being interpreted
    cat "$1" > "$3"
    cat "$2" >> "$3"

    echo "Merged File is:"
    cat "$3"
    echo -e "\nConcatenated file was saved as $3"
else
    echo "The first two arguments must be valid files."
    exit 1
fi

exit 0