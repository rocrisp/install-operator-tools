#!/bin/bash

#permission to execute for everyone
echo "Update Source of Truth"
echo "file is $1"

#update the file
echo " adding $2 $3 $4 $5 $6 $7"

#OS dependent tools
unameOut="$(uname -s)"

if [[ $unameOut == "Darwin" ]]; then
   echo "OS=Darwin"
   sed -i '' "s#.*$2.*#$2:$3:$4:$5:$6:$7#w changelog.txt" $1

elif [[ $unameOut == "Linux" ]]; then
   echo "OS=Linux"
   sed -i "s#.*$2.*#$2:$3:$4:$5:$6:$7#w changelog.txt" $1

else echo "Bad sed command, exiting..."
   exit
fi

echo $?

if [ -s changelog.txt ]; then
    echo "Changes made."
else
    echo "$2 not found, adding a new operator."
    echo "$2:${3:+$3}:${4:+$4}:${5:+$5}:${6:+$6}:${7:+$7}" >> $1
fi