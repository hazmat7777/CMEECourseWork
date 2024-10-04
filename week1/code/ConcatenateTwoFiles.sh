#!/bin/bash

## cat means stick together or print

# $1 and $2 are the files you want to merge

# $3 is the merged file. Remember this will be output to the current directory unless a separate path is specified in the $3 argument

cat $1 > $3
cat $2 >> $3
echo "Merged File is"
cat $3
