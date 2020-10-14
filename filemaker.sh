#!/bin/bash
# Use: filemaker.sh $1 $2
# $1 = number of files you want made.
# $2 = name of the file (will add a number at the begining up to $1).

# Description:  This short little script takes a few arguements and generates a file with the desired name.
# It is scalable, using Arguement1 you can specify any number of files you want made.  The first file will be named whatever Arguement2 is.
# Successive files will be named Whatever Arguement2 is, but will also have a number apended to the end. So if you wanted three files
# named test, you would get back "test, test2, test3".  I made this because it's actually a good example of a more complex for loop.

# What I learned:
# 1. Getting a for loop to be both an index and a variable is tricky and c-like. https://tldp.org/LDP/abs/html/dblparens.html
# 2. Spaces in the if statement are super important, especially those spaces around the square brackets.
# 3. Semicolon at the end of the if statement appears to not be needed. However if you had it, you could move 'then' up to that line.

for ((i = 1; i <= $1; i++))
do
    if [ $i == 1 ];
    then
        touch $2
    else
        touch $2$i
    fi
done