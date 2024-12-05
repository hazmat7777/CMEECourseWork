#!/bin/sh

### illustrates variable assignment and special variables

## special variables

echo "This script was called with $# parameters"
echo "The script's name is $0"
echo "The first argument is $1"
echo "The second argument is $2"

## assigned variables

#explicit declaration
MY_VAR='some string'
echo 'the current value of the variable is:' $MY_VAR
 echo 'Please enter a new string'
read MY_VAR
echo
echo 'the current value of the variable is:' $MY_VAR
echo

#Reading (multiple values) from user input:
echo 'Enter two integers separated by space(s)'
read a b
echo

if ! ((a)) 2>/dev/null || ! ((b)) 2>/dev/null; then # check if input is numeric
    echo "Please enter two integers."
else
    echo 'you entered' $a 'and' $b '; Their sum is:'
    MY_SUM=$((a + b))
    echo $MY_SUM
fi
