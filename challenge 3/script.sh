#!/bin/sh


if [ $# -eq 0 ]; then

echo "Pass any one of the key as arguments from the following options: a / b / c / x / y / z "
exit 1

fi

if [[ $1 == a || $1 == b || $1 == c ]]; then

echo "value = d"

elif [[ $1 == x || $1 == y || $1 == z ]]; then

echo "value = a"

else 

echo "The key passed is not correct or is in uppercase. Try Again!!"

fi
