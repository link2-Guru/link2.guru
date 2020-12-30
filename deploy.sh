#!/bin/sh


echo "Deleting old docs publication"
rm -rf docs

echo "Generating site"
hugo

echo "Copy CNAME"
cp CNAME ./docs/CNAME



echo "$1"
if [ ! -n "$1" ]
then
    echo "Please print commit msg"
    exit 1;
fi
git add .
git commit -m "$1"

if [[ $(git status -s) ]]
then
    echo "The working directory is dirty. Please commit any pending changes."
    exit 1;
fi


echo "Push to origin master"
git push origin master