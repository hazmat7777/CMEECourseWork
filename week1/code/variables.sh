#!/bin/sh

## illustrates he use of variables

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
echo 'Enter two numbers separated by space(s)'
read a b
echo
echo 'you entered' $a 'and' $b '; Their sum is:'

#Command substitution
MY_SUM=$(expr $a + $b)
echo $MY_SUM
